require 'algebrick'
require 'aoc'

class AOC::Day5
  def run_part1(instructions)
    gen = md5_generator(instructions)

    8.times.inject(""){|code|
      code + gen.next[2].to_s(16)[0]
    }
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
