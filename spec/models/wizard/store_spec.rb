require "rails_helper"

describe Wizard::Store do
  let(:backingstore) do
    { "name" => "Joe", "age" => 20, "region" => "Manchester" }
  end
  let(:instance) { described_class.new backingstore }
  subject { instance }

  describe ".new" do
    context "with valid source data" do
      it { is_expected.to be_instance_of(Wizard::Store) }
      it { is_expected.to have_attributes data: backingstore }
      it { is_expected.to respond_to :[] }
      it { is_expected.to respond_to :[]= }
    end

    context "with invalid source data" do
      subject { described_class.new nil }

      it "should raise an InvalidBackingStore" do
        expect { subject }.to raise_exception(Wizard::Store::InvalidBackingStore)
      end
    end
  end

  describe "#[]" do
    context "name" do
      subject { instance["name"] }
      it { is_expected.to eql "Joe" }
    end

    context "age" do
      subject { instance["age"] }
      it { is_expected.to eql 20 }
    end
  end

  describe "#[]=" do
    it "will update stored value" do
      expect { subject["name"] = "Jane" }.to \
        change { subject["name"] }.from("Joe").to("Jane")
    end
  end

  describe "#fetch" do
    context "with multiple keys" do
      subject { instance.fetch :name, :region }
      it "will return hash of requested keys" do
        is_expected.to eql({ "name" => "Joe", "region" => "Manchester" })
      end
    end

    context "with array of keys" do
      subject { instance.fetch %w[name region] }
      it "will return hash of requested keys" do
        is_expected.to eql({ "name" => "Joe", "region" => "Manchester" })
      end
    end
  end

  describe "#purge!" do
    before { instance.purge! }
    subject { instance.keys }

    it "will remove all keys" do
      is_expected.to have_attributes empty?: true
    end
  end
end
