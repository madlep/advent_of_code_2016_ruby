require 'aoc/day3'

RSpec.describe AOC::Day3 do
  context "part 1" do
    it "finds count of possible triangles" do
      instructions = "5 10 25"
      expect(subject.run_part1(instructions)).to eq(0)
    end

    it "handles possible triangles" do
      instructions = "2 3 4\n123 234 345\n4 2 3\n2 4 3"
      expect(subject.run_part1(instructions)).to eq(4)
    end

    it "handles impossible triangles" do
      instructions = "2 3 10\n123 234 1000\n10 2 3\n2 10 3\n1 2 3"
      expect(subject.run_part1(instructions)).to eq(0)
    end

    it "handles whitespace" do
      instructions = "    2  2    3\n4  7  99  \n   4  99  2  \n"
      expect(subject.run_part1(instructions)).to eq(1)
    end
  end

  context "part 2" do
    it "finds count of possible triangles by parsing sets of 3 vertical numbers" do
      instructions = "101 301 501
                      102 302 502
                      103 303 503
                      201 401 601
                      202 402 602
                      203 999 603"
      expect(subject.run_part2(instructions)).to eq(5)
    end
  end
end
