require "aoc/parser/combinators"

class AOC::Day4
  include AOC::Parser::Combinators

  def run_part1(instructions)
    parser = many!(
      seq!(
        many!(one_of(match!(/[a-z]+/), term("-"))),
        int!(),
        term("["),
        match!(/[a-z]{5}/),
        term("]"),
        one_of(eol(), eof())
      )
    )

    parser
      .(instructions)
      .captures
      .map{|line|
        char_groups, sector, checksum = line
        chars = char_groups.join
        checksum(chars) == checksum ? sector : 0
      }
      .sum
  end

  private
  def checksum(chars)
    chars
      .each_char
      .inject(Hamster::Hash[]) {|hash, char|
        hash.put(char) {|count| (count || 0) + 1 }
      }
      .sort_by{|key, value| [-value, key]}
      .map{|k,_v| k}
      .take(5)
      .join
  end
end
