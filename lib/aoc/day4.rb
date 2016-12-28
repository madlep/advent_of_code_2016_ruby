require "aoc/parser/combinators"
require "algebrick"

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

  EncryptedRoom = Algebrick.type { fields! name: String, sector: Integer }
  DecryptedRoom = Algebrick.type { fields! name: String, sector: Integer }

  def run_part2(instructions)
    parser = many!(
      seq!(
        match!(/[a-z-]+/),
        int!(),
        term("["),
        match(/[a-z]{5}/),
        term("]"),
        one_of(eol(), eof())
      )
    )

    parser
      .(instructions)
      .captures
      .map{|line|
        encrypted_name, sector = line
        decrypt(EncryptedRoom[name: encrypted_name, sector: sector])
      }
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

  def decrypt(encrypted_room)
    encrypted_name = encrypted_room.name.downcase
    rotate = encrypted_room.sector % 26

    decrypted_name = encrypted_name
      .each_byte
      .map{|b|
        if b == '-'.ord
          ' '
        else
          rotated_b = b + rotate
          if rotated_b > 'z'.ord
            (rotated_b - 26).chr
          else
            rotated_b.chr
          end
        end
      }
      .join
      .strip
    DecryptedRoom[name: decrypted_name, sector: encrypted_room.sector]
  end
end
