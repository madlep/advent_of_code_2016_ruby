require "algebrick"
require "aoc/list"
require "aoc/parser/combinators"

class AOC::Day3
  include AOC::Parser::Combinators

  def run_part1(instructions)
    Parser
      .new(instructions)
      .select(&:possible?)
      .count
  end

  def run_part2(instructions)
    parser = capture(many(
      capture(seq(
        maybe(space), capture(int()), space(), capture(int()), space(), capture(int()), eol(),
        maybe(space), capture(int()), space(), capture(int()), space(), capture(int()), eol(),
        maybe(space), capture(int()), space(), capture(int()), space(), capture(int()), one_of(eol(), eof()),
      ))
    ))

    parser.(instructions).captures.map{|set9|
      t11, t21, t31, t12, t22, t32, t13, t23, t33 = set9

      Hamster::Vector[
        Triangle[t11, t12, t13],
        Triangle[t21, t22, t23],
        Triangle[t31, t32, t33]
      ]
        .select(&:possible?)
        .count
    }.sum
  end

  Triangle = Algebrick.type { fields Integer, Integer, Integer }
  module Triangle
    def possible?
      a, b, c = self.fields.sort
      a + b > c
    end
  end

  class Parser
    include Enumerable
    include AOC::List
    include Algebrick::Matching

    ParseResult = Algebrick.type {
      variants Result = type { fields Triangle, String},
               Finished = atom
    }

    IncompleteInteger = Algebrick.type {
      variants  Integer,
                NotInteger = atom
    }
 
    def initialize(str)
      @str = str
    end

    def each
      str = @str
      while true
        match parse_instruction_line(str),
          on(Result.(~Triangle, ~String.to_m)) {|triangle, remaining|
            yield triangle
            str = remaining
          },
          on(Finished) { return }
      end
    end

    private
    def parse_instruction_line(str)
      str = parse_whitespace(str)

      a, str = parse_integer(str)
      str = parse_whitespace(str)

      b, str = parse_integer(str)
      str = parse_whitespace(str)

      c, str = parse_integer(str)
      str = parse_whitespace(str)

      return Finished if [a,b,c].any?{|n| n.is_a?(NotInteger)}

      Result[Triangle[a,b,c], str]
      # match [a,b,c],
      #   on(Array.(Integer, Integer, Integer), Result[Triangle[a,b,c], str]),
      #   on(any, Finished)
    end

    def parse_integer(str, current=NotInteger)
      int_str, new_str = ht(str)
      begin
        int = Integer(int_str)
        match current,
          on(Integer) { parse_integer(new_str, current * 10 + int) },
          on(NotInteger) { parse_integer(new_str, int) }
      rescue ArgumentError
        [current, str]
      end
    end

    def parse_whitespace(str)
      maybe_whitespace, new_str = ht(str)
      match maybe_whitespace,
        on(/\s/) { parse_whitespace(new_str) },
        on(any, str)
    end
  end
end
