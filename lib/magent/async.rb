# Example
#     class Processor
#       include Magent::Async
#       [..snip..]
#
#       def process
#         puts "Processing #{@params}"
#       end
#     end
#
#     async call:
#         Processor.find(id).async(:my_queue).process.commit!
#     chained methods:
#         Processor.async(:my_queue, true).find(1).process.commit!
#

module Magent
  module Async
    def self.included(base)
      base.class_eval do
        include Methods
        extend Methods
      end
    end

    class Proxy
      instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$|proxy_|^object_id$)/ }

      def initialize(queue, target, test = false)
        @queue = queue
        @method_chain = []
        @target = target
        @test = test

        @channel = Channel.new(@queue)
      end

      def commit!
        if @target.kind_of?(Class)

        elsif @target.respond_to?(:find) && @target.respond_to?(:id)

        else
          raise ArgumentError, "I don't know how to handle #{@target.inspect}"
        end

        if @test
          target = @target
          @method_chain.each do |c|
            target = target.send(c[0], *c[1])
          end

          target
        end
      end

      def method_missing(m, *args, &blk)
        raise ArgumentError, "ruby blocks are not supported yet" if !blk.nil?
        @method_chain << [m, args]
        self
      end
    end

    module Methods
      # @question.async(:judge).on_view_question.commit!
      def async(queue, test = false)
        Magent::Async::Proxy.new(queue, self, test)
      end
    end
  end # Async
end
