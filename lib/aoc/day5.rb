require 'algebrick'
require 'aoc'

class AOC::Day5
  State = Algebrick.type { fields! current_index: Integer, code: String }
  def run_part1(instructions)
    8.times.inject(State[0, ""]){|state, _n|
      index = state.current_index
      while true do
        hash = Digest::MD5.digest("#{instructions}#{index}").bytes
        index += 1
        break if hash[0] == 0 && hash[1] == 0 && hash[2] < 0x10
      end
      State[current_index: index, code: state.code + hash[2].to_s(16)[0]]
    }.code
  end
end
