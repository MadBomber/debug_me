# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/debug_me'
require_relative 'debug_me_on'

describe 'debug_me timestamp' do
  include DebugMeOn

  before { @value = 1 }

  it 'formats the timestamp with the strftime option' do
    output = DebugMe.debug_me(file: nil, header: false, strftime: '%%STAMP') { :@value }
    with_header = DebugMe.debug_me(file: nil, strftime: '%%STAMP') { :@value }

    _(output).must_equal "%STAMP DEBUG @value -=> 1\n"
    _(with_header).must_match(/\A%STAMP DEBUG Source:  .*\n%STAMP DEBUG @value -=> 1\n\z/)
  end

  it 'stamps the current time to the microsecond by default' do
    format = '%Y-%m-%d %H:%M:%S.%6N'
    started = Time.now.strftime(format)
    output = DebugMe.debug_me(file: nil, header: false) { :@value }
    finished = Time.now.strftime(format)

    stamp = output.delete_suffix(" DEBUG @value -=> 1\n")
    _(started..finished).must_be :cover?, stamp
  end

  it 'leaves the timestamp out when time is false' do
    output = DebugMe.debug_me(file: nil, time: false, strftime: 'STAMP') { :@value }

    _(output).must_match(/\ADEBUG Source:  .*\nDEBUG @value -=> 1\n\z/)
  end
end
