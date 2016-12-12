require "aoc"

module AOC::List
  def ht(list)
    head = list[0..0]
    tail = list[1..-1]
    [head,tail]
  end
end
