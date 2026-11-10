require 'minitest/autorun'
require 'fileutils'
require 'open3'
require 'rbconfig'
require 'tmpdir'

describe "gem packaging" do
  before do
    @root = File.expand_path('..', __dir__)
    @files = %w[CHANGELOG.md LICENSE.txt README.md lib/debug_me.rb lib/debug_me/version.rb]
  end

  it "includes only runtime Ruby files and top-level documentation" do
    spec = Gem::Specification.load(File.join(@root, 'debug_me.gemspec'))

    _(spec.files.sort).must_equal @files
    _(spec.executables).must_be_empty
    _(spec.test_files).must_be_empty
  end

  it "loads quietly with the same file list outside a git checkout" do
    Dir.mktmpdir('debug_me-gemspec') do |directory|
      FileUtils.cp(File.join(@root, 'debug_me.gemspec'), directory)
      FileUtils.cp_r(File.join(@root, 'lib'), directory)
      FileUtils.cp(@files.reject { |file| file.start_with?('lib/') }.map { |file| File.join(@root, file) }, directory)

      # Run outside this checkout for real: `bundle exec` exports RUBYOPT,
      # RUBYLIB, and BUNDLE_GEMFILE, which would re-activate the parent gem and
      # load its version.rb, so loading the copied gemspec warns about an
      # already-initialized constant. Clear them so the subprocess is clean.
      clean_env = { 'RUBYOPT' => nil, 'RUBYLIB' => nil, 'BUNDLE_GEMFILE' => nil }

      stdout, stderr, status = Open3.capture3(
        clean_env,
        RbConfig.ruby, '-e',
        'spec = Gem::Specification.load("debug_me.gemspec"); abort "gemspec failed to load" unless spec; puts spec.files.sort',
        chdir: directory
      )

      _(status.success?).must_equal true
      _(stderr).must_equal ''
      _(stdout.lines.map(&:chomp)).must_equal @files
    end
  end
end
