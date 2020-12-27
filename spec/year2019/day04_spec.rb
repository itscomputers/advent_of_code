require 'year2019/day04'

describe Year2019::Day04::Password do
  let(:password) { described_class.new string }

  describe "part 1" do
    subject { password.increasing? && password.has_repeat? }

    context "111111" do
      let(:string) { "111111" }
      it { is_expected.to be true }
    end

    context "233450" do
      let(:string) { "233450" }
      it { is_expected.to be false }
    end

    context "123789" do
      let(:string) { "123789" }
      it { is_expected.to be false }
    end
  end

  describe "part 2" do
    subject { password.increasing? && password.has_double? }

    context "112233" do
      let(:string) { "112233" }
      it { is_expected.to be true }
    end

    context "123444" do
      let(:string) { "123444" }
      it { is_expected.to be false }
    end

    context "111122" do
      let(:string) { "111122" }
      it { is_expected.to be true }
    end
  end
end

