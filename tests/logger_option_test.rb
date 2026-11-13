# frozen_string_literal: true

require 'minitest/autorun'
require 'stringio'
require_relative '../lib/debug_me'

describe 'debug_me logger: option' do
  # These tests exercise debug_me's output, so turn it on even when the
  # shell has DEBUG_ME=false (which turns it off at require time).
  before do
    @saved_debug_me = $DEBUG_ME
    $DEBUG_ME = true
  end

  after { $DEBUG_ME = @saved_debug_me }

  # A logger must respond_to? :debug; anything else is skipped.
  it 'skips a logger that does not respond to #debug' do
    file   = StringIO.new
    logger = StringIO.new
    _(logger).wont_respond_to :debug

    result = DebugMe.debug_me(file: file, logger: logger, header: false, time: false) { 42 }

    _(result).must_equal "DEBUG Integer -=> 42\n"
    _(file.string).must_equal result
    _(logger.string).must_be_empty
  end
end
