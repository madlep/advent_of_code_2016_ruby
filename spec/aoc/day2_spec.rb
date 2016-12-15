require 'aoc/day2'

RSpec.describe AOC::Day2 do
  context "provided examples" do
    it "finds part 1 code correctly" do
      instructions = "ULL\nRRDDD\nLURDL\nUUUUD"
      expect(subject.run_part1(instructions)).to eq("1985")
    end

    it "finds part 2 code correctly" do
      instructions = "ULL\nRRDDD\nLURDL\nUUUUD"
      expect(subject.run_part2(instructions)).to eq("5DB3")
    end
  end
end
