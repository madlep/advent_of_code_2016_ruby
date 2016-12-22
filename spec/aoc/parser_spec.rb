require "aoc/parser"
require "aoc/parser/combinators"

RSpec.describe AOC::Parser do
  context "simple arithmetic" do
    include AOC::Parser::Combinators

    it "parses" do
      parser = described_class.new(
        capture(seq(
          capture(int()),
          maybe(space),
          capture(one_of(symbol(:+), symbol(:-), symbol(:*), symbol(:/))),
          maybe(space),
          capture(int())
        )
      ))

      str = "12 + 23"
      expect(parser.parse(str)).to eq([12, :+, 23])
    end
  end
end
