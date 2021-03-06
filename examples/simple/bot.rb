$:.unshift File.dirname(__FILE__)+"/../../lib/"
require 'rubygems'
require 'magent'

# Use: magent /path/to/this/file

Magent.push("bots", :echo, "hello, world")
Magent.push("bots", :do_task, "File", :exist?, "/etc/passwd")
Magent.push("bots", :echo, "Press ctrl+c to close")
Magent.push("bots", :do_not_exist, "you should not see this message")

class Bot
  include Magent::Actor
  channel_name "bots"
  expose :echo, :do_task

  def echo(payload)
    $stderr.puts payload.inspect
  end

  def do_task(payload)
    klass, *args = payload

    result = Object.module_eval(klass).send(*args)
    $stderr.puts "RESULT: #{result}"
  end

  at_least_every 15 do
    puts "Hi there!, you'll see this message again in ~15 seconds"
  end
end

Magent.register(Bot.new)

if $0 == __FILE__
  Magent::Processor.new(Bot.channel).run!
end

