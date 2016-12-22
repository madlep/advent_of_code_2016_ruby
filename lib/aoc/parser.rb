require "hamster/vector"
require "algebrick"
require "aoc"

class AOC::Parser
  def initialize(parser)
    @parser = parser
  end

  def parse(str)
    @parser.(str).captures
  end
end

