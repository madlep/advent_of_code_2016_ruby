require "aoc"
require "aoc/parser/combinators"

class AOC::Day6
  include AOC::Parser::Combinators

  PossibleMessage = Algebrick.type { fields! positions: Hamster::Vector }
  module PossibleMessage
    def mappend_possible_character(position, possible_character)
      PossibleMessage[
        positions.put(position) {|current|
          (current || PossibleCharacter.id).mappend(possible_character)
        }
      ]
    end

    def decode_most_likely
      positions.map(&:most_likely_character).join
    end

    def decode_least_likely
      positions.map(&:least_likely_character).join
    end
  end

  PossibleCharacter = Algebrick.type { fields! char_counts: Hamster::Hash }
  def PossibleCharacter.id
    PossibleCharacter[Hamster::Hash[]]
  end
  module PossibleCharacter
    def mappend(other)
      PossibleCharacter[char_counts.merge(other.char_counts){|k,v1, v2| v1 + v2 }]
    end

    def most_likely_character
      char_counts.max_by{|kv| kv[1]}[0]
    end

    def least_likely_character
      char_counts.min_by{|kv| kv[1]}[0]
    end
  end

  def run_part1(instructions)
    run(instructions).decode_most_likely
  end

  def run_part2(instructions)
    run(instructions).decode_least_likely
  end

  private
  def run(instructions)
    parser = many!(
      seq!(
        maybe(space()),
        match!(/\w+/),
        maybe(space()),
      )
    )

    partial_messages = parser.(instructions).captures.flatten

    partial_messages.inject(PossibleMessage[Hamster::Vector[]]){|possible_message, partial_message|
      partial_message.chars.each_with_index.inject(possible_message){|current_possible_message, char_index|
        char, index = char_index
        current_possible_message.mappend_possible_character(index, PossibleCharacter[Hamster::Hash[char => 1]])
      }
    }
  end
end
