# frozen_string_literal: true

require 'minitest/autorun'
require 'stringio'
require_relative '../lib/debug_me'
require_relative 'debug_me_on'

describe 'debug_me logger: option' do
  include DebugMeOn

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
