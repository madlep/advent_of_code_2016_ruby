require 'aoc/day2'

RSpec.describe AOC::Day2 do
  context "provided examples" do
    it "finds code correctly" do
      instructions = "ULL\nRRDDD\nLURDL\nUUUUD"
      expect(subject.run(instructions)).to eq("1985")
    end
  end
end
