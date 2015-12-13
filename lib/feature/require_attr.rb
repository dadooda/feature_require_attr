
module Feature
  # Provide simple class attribute validation via the <tt>#require_attr</tt> method.
  #
  #   require "feature/require_attr"
  #
  #   class Person
  #     def format
  #       require_attr :name, not_to_be: empty
  #       require_attr :age, to_be_a: Fixnum
  #       require_attr :jobs, to_respond_to: :each
  #
  #       ...
  #     end
  #   end
  #
  # @see InstanceMethods#require_attr
  module RequireAttr
    def self.load(owner)
      return if owner < InstanceMethods
      owner.send(:include, InstanceMethods)
    end

    module InstanceMethods
      private

      # Require an attribute to be set or be otherwise "good". Examples:
      #
      #   require_attr :attr
      #   require_attr :attr, to_be_a: Klass
      #   require_attr :attr, to_be_a: [Klass, Array]
      #   require_attr :attr, to_respond_to: :each
      #   require_attr :attr, to_be: :present
      #   require_attr :attr, not_to_be: :empty
      def require_attr(attr, expression = {})
        value = send(attr)

        # NOTE: There's some written philosophy on the subject.
        #       See notes "#ruby `Feature::RequireAttr`", something like that.

        # IMPORTANT: Execution speed is important. Carefully consider it in the implementation logic below.

        # NOTE: There are 2 types of exceptions below: 1) true "production" exceptions;
        #       2) exceptions caused by programmer's mis-use of our method as such.
        #       For added clarity, programmer errors are commented "PE".

        # Validate expression. It's important to avoid confusion below.
        raise ArgumentError, "Expression must be Hash: #{expression.inspect}" if not expression.is_a? Hash

        if expression.empty?
          # Trivial case.
          raise "Attribute must be set: #{attr}" if value.nil?
        else
          # NOTE: At the moment there are no options other than predicates. When options appear, this will need to be removed.
          raise ArgumentError, "Expression too long: #{expression.inspect}" if expression.size > 1    # PE.

          # NOTE: Some predicates assume other predicates.

          # We've got an exactly 1-key hash.
          if (cls = expression[:to_be_a])
            if cls.is_a? Array
              raise "Attribute `#{attr}` must be a #{cls.join(' or ')} (value:#{value.inspect})" if not cls.any? {|c| value.is_a? c}
            else
              # NOTE: We don't check `cls` for being a Class, Ruby will take care of that.
              raise "Attribute `#{attr}` must be a #{cls} (value:#{value.inspect})" if not value.is_a? cls
            end
          elsif (m = expression[:to_respond_to])
            raise "Attribute `#{attr}` must respond to `#{m}` (value:#{value.inspect})" if not value.respond_to? m
          elsif (cond = expression[:to_be])
            m = "#{cond}?"
            require_attr(attr, to_respond_to: m)
            raise "Attribute `#{attr}` must be #{cond} (value:#{value.inspect})" if not value.send(m)
          elsif (cond = expression[:not_to_be])
            m = "#{cond}?"
            require_attr(attr, to_respond_to: m)
            raise "Attribute `#{attr}` must not be #{cond} (value:#{value.inspect})" if value.send(m)
          else
            raise ArgumentError, "Invalid expression: #{expression.inspect}"
          end
        end # if expression.empty?

        nil
      end
    end
  end
end

#
# Implementation notes
#
# * It's very unlikely that there will ever be a multi-attribute invocation.
#   Each requirement will always be a separate statement.
