require "aoc/day6"

describe AOC::Day6 do
  context "part 1" do
    it "finds message from input" do
      input = <<-INPUT
eedadn
drvtee
eandsr
raavrd
atevrs
tsrnev
sdttsa
rasrtv
nssdts
ntnada
svetve
tesnvt
vntsnd
vrdear
dvrsen
enarar
INPUT
      expect(subject.run_part1(input)).to eq("easter")
    end
  end

  context "part 2" do
    it "finds message from input" do
      input = <<-INPUT
eedadn
drvtee
eandsr
raavrd
atevrs
tsrnev
sdttsa
rasrtv
nssdts
ntnada
svetve
tesnvt
vntsnd
vrdear
dvrsen
enarar
INPUT
      expect(subject.run_part2(input)).to eq("advent")
    end
  end
end
