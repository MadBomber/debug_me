require 'pp'
require_relative 'debug_me/version'

# Initialize $DEBUG_ME from environment variable or default to true
# Supports common boolean representations: true/false, yes/no, 1/0, on/off
if ENV.key?('DEBUG_ME')
  env_value = ENV['DEBUG_ME'].to_s.downcase
  $DEBUG_ME = !['false', 'no', '0', 'off', ''].include?(env_value)
else
  $DEBUG_ME = true if !defined?($DEBUG_ME) || $DEBUG_ME.nil?
end

DebugMeDefaultOptions = {
  tag:    'DEBUG',  # A tag to prepend to each output line
  time:   true,     # Include a time-stamp in front of the tag
  strftime:  '%Y-%m-%d %H:%M:%S.%6N', # timestamp format
  header: true,     # Print a header string before printing the variables
  levels: 0,        # Number of additional backtrack entries to display
  skip1:  false,    # skip 1 lines between different outputs
  skip2:  false,    # skip 2 lines between different outputs
  lvar:   true,     # Include local variables
  ivar:   true,     # Include instance variables in the output
  cvar:   true,     # Include class variables in the output
  cconst: true,     # Include class constants
  logger: nil,      # Pass in an instance of logger class like Rails.logger
                    # must respond_to? :debug
  file:   $stdout   # The output file
}

# Maximum number of backtrace entries to show
DEBUG_ME_MAX_BACKTRACE = 10000

module DebugMe
  extend self

  # Internal, used by empty-block discovery: true when klass resolves name
  # to a constant defined in DebugMe itself, such as DEBUG_ME_VERSION reached
  # through include DebugMe; false inside DebugMe itself. The const_defined?
  # guard matters: without it, DebugMe.const_source_location would find a
  # top-level constant through Object and match it.
  def self.own_constant?(klass, name)
    !klass.equal?(DebugMe) &&
      DebugMe.const_defined?(name, false) &&
      klass.const_source_location(name) == DebugMe.const_source_location(name)
  end


  def debug_me(options = {}, **keyword_options, &block)
    return unless $DEBUG_ME

    options = { tag: options } unless options.is_a?(Hash)
    options = DebugMeDefaultOptions.merge(options).merge!(keyword_options)

    skip        = ''
    skip        = "\n"    if options[:skip1]
    skip        = "\n\n"  if options[:skip2]
    out_string  = skip

    f = options[:file]
    l = options[:logger]
    s = ''
    s += Time.now.strftime(options[:strftime])+' ' if options[:time]
    s += "#{options[:tag]}"
    bt_out = []

    if options[:header]
      cf = caller(1, 1).first
      out_string += "#{s} Source:  #{cf}\n"
      levels = options[:levels].to_i
      if levels > 0
        bt = caller(1, levels + 1)
        bt[1..levels].each_with_index do |cff, level |
          bt_out << [level, cff]
        end
      end
    end

    if block_given? || bt_out.size > 0
      # Only the Symbol or String "backtrace" asks for the call stack
      backtrace_marker = ->(v) { (v.is_a?(Symbol) || v.is_a?(String)) && v.to_s == 'backtrace' }
      block_value = []
      if block_given?
        [block.call].flatten.compact.each do |v|
          block_value << v
        end
      end
      # levels adds the backtrace first, unless the block already lists it
      if bt_out.size > 0 && block_value.none?(&backtrace_marker)
        block_value.unshift('backtrace')
      end

      # Discovered class variables and constants, read from the receiver's
      # class rather than by evaluating their names in the block's scope
      discovered = {}
      if block_value.empty?
        context = block.binding.receiver
        context_class = Kernel.instance_method(:class).bind_call(context)
        context_class = context if context_class <= Module
        block_value += block.binding.local_variables if options[:lvar]
        block_value += Kernel.instance_method(:instance_variables).bind_call(context) if options[:ivar]
        if options[:cvar]
          context_class.class_variables.each do |name|
            discovered[name] = context_class.class_variable_get(name)
          end
        end
        if options[:cconst]
          context_class.constants.each do |name|
            next if DebugMe.own_constant?(context_class, name)

            discovered[name] = context_class.const_get(name) unless context_class.autoload?(name)
          end
        end
        block_value += discovered.keys
      end

      if bt_out.empty? && block_value.any?(&backtrace_marker)
        backtrace = caller(1, DEBUG_ME_MAX_BACKTRACE + 1)[1..DEBUG_ME_MAX_BACKTRACE]
      end

      block_value.each do |v|

        # Only Symbols and Strings name something to evaluate;
        # any other value is printed as it is, labeled by its class
        # (or by its own name when it is a Class or Module).
        unless v.is_a?(Symbol) || v.is_a?(String)
          label = v.is_a?(Module) ? v : v.class
          out_string += "#{s} #{label} -=> #{v.pretty_inspect}"
          next
        end

        v   = v.to_s
        ev  = if 'backtrace' == v
                bt_out.size > 0 ? bt_out : backtrace
              else
                discovered.fetch(v.to_sym) do
                  eval("defined?(#{v})",block.binding).nil? ? '<undefined>' : eval(v, block.binding)
                end
              end
        out_string += sprintf( "%s %s -=> %s", s,v,ev.pretty_inspect)
      end

    end ## if block_given?

    unless f.nil?
      f.puts out_string
      f.flush
    end

    unless l.nil?
      l.debug(out_string) if l.respond_to? :debug
    end

    return out_string
  end ## def debug_me( options={}, **keyword_options, &block )
end # module DebugMe
