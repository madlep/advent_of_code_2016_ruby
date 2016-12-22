require "hamster/vector"
require "algebrick"
require "aoc"

class AOC::Parser
  def initialize(parser)
    @parser = parser
  end

  def parse(str)
    @parser.call(str).captures
  end
end

