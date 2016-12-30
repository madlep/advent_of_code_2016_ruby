require "algebrick"
require "hamster"
require "aoc"

class AOC::Day5
  def run_part1(instructions)
    gen = md5_generator(instructions)

    8.times.inject(""){|code|
      code + gen.next[2].to_s(16)[0]
    }
  end

  State2 = Algebrick.type { fields! code: Hamster::Vector }
  module State2
    def complete?
      (0..7).none?{|n| self.code[n].nil? }
    end
  end

  def run_part2(instructions)
    state = State2[Hamster::Vector[]]
    gen = md5_generator(instructions)

    until(state.complete?)
      md5 = gen.next
      position = md5[2]
      value = md5[3] >> 4
      code = state.value
      if position < 8 && code[position].nil?
        code = code.put(position, value)
      end
      state = State2[code]
    end

    state.value
      .map{|n| n.to_s(16)}
      .join
  end

  private
  def md5_generator(instructions)
    Enumerator.new do |y|
      i = 0
      loop do
        hash = Digest::MD5.digest("#{instructions}#{i}").bytes
        y << hash if hash[0] == 0 && hash[1] == 0 && hash[2] < 0x10
        i = i.next
      end
    end
  end
end
