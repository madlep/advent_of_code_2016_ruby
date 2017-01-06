require "aoc/pattern"

RSpec.describe AOC::Pattern do
  context "basic pattern matching" do
    class PatternTest
      include AOC::Pattern

      def_pat :foo, 1 do |_1|
        "foo was explicitly 1"
      end

      def_pat :foo, "abc" do |_abc|
        "foo was explicitly abc"
      end

      def_pat :foo, Integer do |n|
        "foo was case matched #{n}"
      end
    end

    subject{PatternTest.new}

    it "matches explicit values" do
      expect(subject.foo(1)).to eq("foo was explicitly 1")
      expect(subject.foo("abc")).to eq("foo was explicitly abc")
    end

    it "matches case equality values" do
      expect(subject.foo(123)).to eq("foo was case matched 123")
    end

    it "complains if nothing matches" do
      expect{subject.foo("haha")}.to raise_error(NoMethodError)
    end
  end

  context "fibonacci" do
    class Fibonacci
      include AOC::Pattern

      def_pat(:fib, 0) { 0 }
      def_pat(:fib, 1) { 1 }
      def_pat(:fib, Integer) {|n| fib(n-1) + fib(n-2) }
    end
  end

  subject{Fibonacci.new}

  it "calculates fibonacci numbers" do
    expect(subject.fib(0)).to eq(0)
    expect(subject.fib(1)).to eq(1)
    expect(subject.fib(2)).to eq(1)
    expect(subject.fib(10)).to eq(55)
  end
end
