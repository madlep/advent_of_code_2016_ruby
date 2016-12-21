require "aoc/parser"
require "aoc/parser/combinators"

RSpec.describe AOC::Parser do
  context "simple arithmetic" do
    include AOC::Parser::Combinators

    it "parses" do
      parser = described_class.new(
        seq(
          int(label: :operand1),
          maybe(space),
          one_of(term("+"), term("-"), term("*"), term("/"), label: :operator),
          maybe(space),
          int(label: :operand2)
        )
      )

      str = "12 + 23"
      expect(parser.parse(str)).to eq("foobar")
    end
  end
end
