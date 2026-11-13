require 'minitest/autorun'
require 'ripper'
require 'logger'
require 'stringio'
require_relative '../lib/debug_me'

describe "README examples" do
  before do
    @saved_debug_me = $DEBUG_ME
    $DEBUG_ME = true
    @readme = File.read(File.expand_path('../README.md', __dir__))
  end

  after { $DEBUG_ME = @saved_debug_me }

  it "parses the backtrace and quoted expression examples" do
    snippets = @readme.scan(/```ruby\n(.*?)```/m).flatten
    ['debug_me{[ :backtrace ]}', 'some_hash.keys.reject'].each do |example|
      snippet = snippets.find { |code| code.include?(example) }
      refute_nil snippet
      refute_nil Ripper.sexp(snippet), "README example containing #{example} does not parse"
    end
  end

  it "forwards blocks and merges caller options in the Rails logging example" do
    method = @readme[/  def log_me\(message, options=\{\}, &block\)\n.*?  end/m]
    refute_nil method

    default_output = StringIO.new
    custom_output = StringIO.new
    namespace = Module.new
    namespace.const_set(:Rails, Module.new)
    namespace.const_get(:Rails).define_singleton_method(:logger) { Logger.new(default_output) }
    namespace.module_eval("module DebugMe\n#{method}\nend", 'README.md')
    object = Object.new.extend(DebugMe).extend(namespace.const_get(:DebugMe))

    value = 42
    options = { logger: Logger.new(custom_output), file: nil, tag: 'custom', header: true }
    original_options = options.dup
    result = object.log_me('default', options) { :value }

    assert_includes result, 'custom Source:'
    assert_includes result, "custom value -=> #{value}"
    assert_includes custom_output.string, "custom value -=> #{value}"
    assert_empty default_output.string
    assert_equal original_options, options

    result = object.log_me('default', file: nil) { :value }
    assert_equal "default value -=> 42\n", result
    assert_includes default_output.string, 'default value -=> 42'
    assert_equal '', object.log_me('default', file: nil)
  end
end
