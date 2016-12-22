require "algebrick"
require "aoc/list"
require "hamster"

class AOC::Day2
  include Algebrick::Matching

  Button = Algebrick.type { fields String }

  Movement = Algebrick.type {
    variants  Up = atom,
              Down = atom,
              Left = atom,
              Right = atom
  }

  def run_part1(instructions)
    current_button = Button["5"]
    Parser
      .new(instructions)
      .map{|line|
        line.inject(current_button){|button, movement|
          current_button = next_button_part1(button, movement)
        }
      }
      .map(&:value)
      .join
  end

  def run_part2(instructions)
    current_button = Button["5"]
    Parser
      .new(instructions)
      .map{|line|
        line.inject(current_button){|button, movement|
          current_button = next_button_part2(button, movement)
        }
      }
      .map(&:value)
      .join
  end

  def next_button_part1(button, movement)
    match [button, movement],
      on([Button["1"], Up],     button),
      on([Button["1"], Down],   Button["4"]),
      on([Button["1"], Left],   button),
      on([Button["1"], Right],  Button["2"]),

      on([Button["2"], Up],     button),
      on([Button["2"], Down],   Button["5"]),
      on([Button["2"], Left],   Button["1"]),
      on([Button["2"], Right],  Button["3"]),

      on([Button["3"], Up],     button),
      on([Button["3"], Down],   Button["6"]),
      on([Button["3"], Left],   Button["2"]),
      on([Button["3"], Right],  button),

      on([Button["4"], Up],     Button["1"]),
      on([Button["4"], Down],   Button["7"]),
      on([Button["4"], Left],   button),
      on([Button["4"], Right],  Button["5"]),

      on([Button["5"], Up],     Button["2"]),
      on([Button["5"], Down],   Button["8"]),
      on([Button["5"], Left],   Button["4"]),
      on([Button["5"], Right],  Button["6"]),

      on([Button["6"], Up],     Button["3"]),
      on([Button["6"], Down],   Button["9"]),
      on([Button["6"], Left],   Button["5"]),
      on([Button["6"], Right],  button),

      on([Button["7"], Up],     Button["4"]),
      on([Button["7"], Down],   button),
      on([Button["7"], Left],   button),
      on([Button["7"], Right],  Button["8"]),

      on([Button["8"], Up],     Button["5"]),
      on([Button["8"], Down],   button),
      on([Button["8"], Left],   Button["7"]),
      on([Button["8"], Right],  Button["9"]),

      on([Button["9"], Up],     Button["6"]),
      on([Button["9"], Down],   button),
      on([Button["9"], Left],   Button["8"]),
      on([Button["9"], Right],  button)
  end

  def next_button_part2(button, movement)
    match [button, movement],
      on([Button["1"], Up], button),
      on([Button["1"], Down], Button["3"]),
      on([Button["1"], Left], button),
      on([Button["1"], Right], button),

      on([Button["2"], Up], button),
      on([Button["2"], Down], Button["6"]),
      on([Button["2"], Left], button),
      on([Button["2"], Right], Button["3"]),

      on([Button["3"], Up], Button["1"]),
      on([Button["3"], Down], Button["7"]),
      on([Button["3"], Left], Button["2"]),
      on([Button["3"], Right], Button["4"]),

      on([Button["4"], Up], button),
      on([Button["4"], Down], Button["8"]),
      on([Button["4"], Left], Button["3"]),
      on([Button["4"], Right], button),


      on([Button["5"], Up], button),
      on([Button["5"], Down], button),
      on([Button["5"], Left], button),
      on([Button["5"], Right], Button["6"]),

      on([Button["6"], Up], Button["2"]),
      on([Button["6"], Down], Button["A"]),
      on([Button["6"], Left], Button["5"]),
      on([Button["6"], Right], Button["7"]),

      on([Button["7"], Up], Button["3"]),
      on([Button["7"], Down], Button["B"]),
      on([Button["7"], Left], Button["6"]),
      on([Button["7"], Right], Button["8"]),

      on([Button["8"], Up], Button["4"]),
      on([Button["8"], Down], Button["C"]),
      on([Button["8"], Left], Button["7"]),
      on([Button["8"], Right], Button["9"]),

      on([Button["9"], Up], button),
      on([Button["9"], Down], button),
      on([Button["9"], Left], Button["8"]),
      on([Button["9"], Right], button),

      on([Button["A"], Up], Button["6"]),
      on([Button["A"], Down], button),
      on([Button["A"], Left], button),
      on([Button["A"], Right], Button["B"]),

      on([Button["B"], Up], Button["7"]),
      on([Button["B"], Down], Button["D"]),
      on([Button["B"], Left], Button["A"]),
      on([Button["B"], Right], Button["C"]),

      on([Button["C"], Up], Button["8"]),
      on([Button["C"], Down], button),
      on([Button["C"], Left], Button["B"]),
      on([Button["C"], Right], button),

      on([Button["D"], Up], Button["B"]),
      on([Button["D"], Down], button),
      on([Button["D"], Left], button),
      on([Button["D"], Right], button)
  end

  class Parser
    include Enumerable
    include AOC::List
    include Algebrick::Matching

    ParseResult = Algebrick.type(:a) {
      variants  Result = type(:a) { fields :a, String },
                More = type { fields String },
                Finished = atom
    }

    def initialize(str)
      @str = str
      @str = @str + "\n" unless @str.end_with?("\n")
    end

    def each
      str = @str
      while true
        match parse_instruction_line(str),
          on(Result[Hamster::Vector].(~Hamster::Vector.to_m, ~String.to_m)) {|line, remaining|
            yield line
            str = remaining
          },
          on(Finished) { return }
      end
    end

    private
    def parse_instruction_line(str)
      instruction_line = Hamster::Vector.new
      while true
        match parse_instruction(str),
          on(Result[Movement].(~Movement, ~String.to_m)){|movement, remaining|
            instruction_line = instruction_line.add(movement)
            str = remaining
          },
          on(More.(~String.to_m)) {|remaining| return Result[Hamster::Vector][instruction_line, remaining] },
          on(Finished) { return Finished }
      end
    end

    def parse_instruction(str)
      instruction_char, str = ht(str)
      case instruction_char
      when "U" then Result[Movement][Up, str]
      when "D" then Result[Movement][Down, str]
      when "L" then Result[Movement][Left, str]
      when "R" then Result[Movement][Right, str]
      when "\n" then More[str]
      when "" then Finished
      end
    end
  end
end
