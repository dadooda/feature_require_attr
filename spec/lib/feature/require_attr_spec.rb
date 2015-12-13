
require "feature/require_attr"

describe Feature::RequireAttr do
  it "generally works" do
    klass = Class.new do
      Feature::RequireAttr.load(self)

      attr_accessor :x

      def initialize(attrs = {})
        attrs.each {|k, v| send("#{k}=", v)}
      end

      def check(*args)
        require_attr *args

        # No failure.
        true
      end
    end

    # NOTES:
    #
    # * Tests below are individual, we create a new instance every time to stay decoupled.
    # * Order is loosely logical. Basically everything after "trivial tests" can be shuffled if that's found appropriate.

    # Trivial cases.
    r = klass.new
    expect {r.check(:no_such)}.to raise_error(NoMethodError, /\Aundefined method `no_such'/)
    expect {r.check(:x, :something)}.to raise_error(ArgumentError, "Expression must be Hash: :something")
    expect {r.check(:x, kk: 0)}.to raise_error("Invalid expression: {:kk=>0}")
    expect {r.check(:x, {a: 1, b: 2})}.to raise_error(ArgumentError, "Expression too long: {:a=>1, :b=>2}")   # NOTE: Ruby 1.9+ maintains hash key order. The message is not volatile.

    # No predicate.
    r = klass.new
    expect {r.check(:x)}.to raise_error("Attribute must be set: x")
    r.x = 1
    expect(r.check(:x)).to be true

    # `to_be_a`.
    r = klass.new(x: 1)
    expect {r.check(:x, to_be_a: String)}.to raise_error("Attribute `x` must be a String (value:1)")
    expect {r.check(:x, to_be_a: [String, Array])}.to raise_error("Attribute `x` must be a String or Array (value:1)")
    expect(r.check(:x, to_be_a: Fixnum)).to be true
    expect(r.check(:x, to_be_a: Integer)).to be true

    # `to_respond_to`.
    r = klass.new(x: 1)
    expect {r.check(:x, to_respond_to: :each)}.to raise_error("Attribute `x` must respond to `each` (value:1)")
    expect(r.check(:x, to_respond_to: :to_i)).to be true

    # `to_be`, `not_to_be`.
    r = klass.new(x: 1)
    expect {r.check(:x, to_be: :empty)}.to raise_error("Attribute `x` must respond to `empty?` (value:1)")
    expect {r.check(:x, to_be: :even)}.to raise_error("Attribute `x` must be even (value:1)")
    expect {r.check(:x, not_to_be: :odd)}.to raise_error("Attribute `x` must not be odd (value:1)")
    expect(r.check(:x, to_be: :odd)).to be true
    expect(r.check(:x, not_to_be: :even)).to be true
  end
end
