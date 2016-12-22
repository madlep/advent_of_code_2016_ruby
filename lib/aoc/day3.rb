require "algebrick"
require "aoc/parser/combinators"

class AOC::Day3
  include AOC::Parser::Combinators

  def run_part1(instructions)
    parser = capture(many(
      capture(seq(
        maybe(space), capture(int()), space(), capture(int()), space(), capture(int()), one_of(eol(), eof())
      ))
    ))

    parser.(instructions).captures.map{|tri_ints|
      t1, t2, t3 = tri_ints
      Triangle[t1, t2, t3]
    }
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
end
