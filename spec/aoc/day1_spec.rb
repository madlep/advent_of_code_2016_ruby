require "aoc/day1"

RSpec.describe AOC::Day1 do
  context "provided examples" do
    it "calculates correctly" do
      expect(subject.run("R2, L3")).to eq(5)
      expect(subject.run("R2, R2, R2")).to eq(2)
      expect(subject.run("R5, L5, R5, R3")).to eq(12)
    end

    it "calculates part 2 correctly" do
      expect(subject.run_part2("R8, R4, R4, R8")).to eq(4)
    end
  end
end
