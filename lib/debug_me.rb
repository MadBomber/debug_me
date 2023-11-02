require 'pp'
require_relative 'debug_me/version'

$DEBUG_ME = true

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

module DebugMe
  def debug_me(options = {}, &block)
    return unless $DEBUG_ME

    if 'Hash' == options.class.to_s
      options = DebugMeDefaultOptions.merge(options)
    else
      options = DebugMeDefaultOptions.merge(tag: options)
    end

    skip        = ''
    skip        = "\n"    if options[:skip1]
    skip        = "\n\n"  if options[:skip2]
    out_string  = ''

    f = options[:file]
    l = options[:logger]
    s = ''
    s += Time.now.strftime(options[:strftime])+' ' if options[:time]
    s += "#{options[:tag]}"
    bt = caller # where_from under 1.8.6 its a stack trace array under 1.8.7+ as a string
    bt_out = []

    if options[:header]
      cf = bt.is_a?(Array) ? bt[0] : bt
      out_string = sprintf("%s Source:  %s\n", skip+s, cf)
      if options[:levels] > 0
        levels = options[:levels].to_i
        bt[1..levels].each_with_index do |cff, level |
          bt_out << [level, cff]
        end
      end
    end

    if block_given? || bt_out.size > 0
      block_value = []
      block_value << 'backtrace' if bt_out.size > 0
      if block_given?
        [block.call].flatten.compact.each do |v|
          block_value << v
        end
      end

      if block_value.empty?
        block_value += [eval('local_variables', block.binding)] if options[:lvar]
        block_value += [eval('instance_variables', block.binding)] if options[:ivar]
        block_value += [self.class.send('class_variables')] if options[:cvar]
        block_value += [self.class.constants] if options[:cconst]
        block_value = block_value.flatten.compact
      end

      block_value.map!(&:to_s)

      block_value.each do |v|

        ev  = if 'backtrace' == v
                bt_out.size > 0 ? bt_out : bt[1..10000]
              else
                eval("defined?(#{v})",block.binding).nil? ? '<undefined>' : eval(v, block.binding)
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
  end ## def debug_me( options={}, &block )

  # def log_me(msg, opts={})
  #   debug_me({tag: msg, header: false}.merge(opts))
  # end
end # module DebugMe
