require 'day1'

RSpec.describe Day1 do
  context "provided examples" do
    it "calculates correctly" do
      expect(subject.run("R2, L3")).to eq(5)
      expect(subject.run("R2, R2, R2")).to eq(2)
      expect(subject.run("R5, L5, R5, R3")).to eq(12)
    end
  end
end
