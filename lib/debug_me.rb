require 'pp'
require_relative 'debug_me/version'

module DebugMe
  def debug_me(options = {}, &block)
    default_options = {
      tag: 'DEBUG:',   # A tag to prepend to each output line
      time: true,      # Include a time-stamp in front of the tag
      header: true,    # Print a header string before printing the variables
      lvar: true,      # Include local variables
      ivar: true,      # Include instance variables in the output
      cvar: true,      # Include class variables in the output
      cconst: true,    # Include class constants
      file: $stdout    # The output file
    }


    if 'Hash' == options.class.to_s
      options = default_options.merge(options)
    else
      options = default_options.merge(tag: options)
    end

    out_string = ''

    f = options[:file]
    s = ''
    s += "#{sprintf('%010.6f', Time.now.to_f)} " if options[:time]
    s += " #{options[:tag]}"
    wf = caller # where_from under 1.8.6 its a stack trace array under 1.8.7 is a string
    wf = wf[0] if 'Array' == wf.class.to_s

    out_string = sprintf("%s Source: %s\n",s,wf) if options[:header]

    if block_given?

      block_value = [block.call].flatten.compact

      if block_value.empty?
        block_value = []
        block_value += [eval('local_variables', block.binding)] if options[:lvar]
        block_value += [eval('instance_variables', block.binding)] if options[:ivar]
        block_value += [self.class.send('class_variables')] if options[:cvar]
        block_value += [self.class.constants] if options[:cconst]
        block_value = block_value.flatten.compact
      end

      block_value.map!(&:to_s)

      block_value.each do |v|
        ev = eval("defined?(#{v})",block.binding).nil? ? '<undefined>' : eval(v, block.binding)
        out_string += sprintf( "%s %s -=> %s", s,v,ev.pretty_inspect)
      end

    end ## if block_given?

    unless f.nil?
      f.puts out_string
      f.flush
    end

    return out_string
  end ## def debug_me( options={}, &block )

  # def log_me(msg, opts={})
  #   debug_me({:tag => msg, :header => false}.merge(opts))
  # end
end # module DebugMe
