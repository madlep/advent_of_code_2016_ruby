require "hamster/vector"
require "algebrick"

class AOC::Parser
  def initialize(parser)
    @parser = parser
  end

  def parse(str)
    result = @parser.call(str)
  end
end

