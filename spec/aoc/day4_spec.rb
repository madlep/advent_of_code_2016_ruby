require 'aoc/day4'

RSpec.describe AOC::Day4 do
  context "part 1" do
    it "finds sum of real rooms" do
      instructions = "aaaaa-bbb-z-y-x-123[abxyz]
a-b-c-d-e-f-g-h-987[abcde]
not-a-real-room-404[oarel]
totally-real-room-200[decoy]"
      expect(subject.run_part1(instructions)).to eq(1514)
    end
  end
end
