require "rails_helper"

describe Internal::Event do
  describe "attributes" do
    it { should respond_to :id }
    it { should respond_to :name }
    it { should respond_to :summary }
    it { should respond_to :description }
    it { should respond_to :building }
    it { should respond_to :is_online }
    it { should respond_to :start_at }
    it { should respond_to :end_at }
    it { should respond_to :provider_contact_email }
    it { should respond_to :provider_organiser }
    it { should respond_to :provider_target_audience }
    it { should respond_to :provider_website_url }
  end

  describe "validations" do
    describe "#name" do
      it { should allow_value("test").for :name }
      it { should_not allow_value("").for :name }
      it { should_not allow_value(nil).for :name }
    end

    describe "#summary" do
      it { should allow_value("test").for :summary }
      it { should_not allow_value("").for :summary }
      it { should_not allow_value(nil).for :summary }
    end

    describe "#description" do
      it { should allow_value("test").for :description }
      it { should_not allow_value("").for :description }
      it { should_not allow_value(nil).for :description }
    end

    describe "#is_online" do
      it { should allow_value(true).for :is_online }
      it { should allow_value(false).for :is_online }
      it { should_not allow_value(nil).for :is_online }
    end

    describe "#start_at" do
      it { should_not allow_value(nil).for :start_at }
      it { should_not allow_value(Time.zone.now - 1.minute).for :start_at }
      it { should_not allow_value(Time.zone.now).for :start_at }
      it { should allow_value(Time.zone.now + 1.minute).for :start_at }
    end

    describe "#end_at" do
      it { should_not allow_value(nil).for :end_at }
      it { should_not allow_value(Time.zone.now - 1.minute).for :end_at }
      it { should_not allow_value(Time.zone.now).for :end_at }
      it { should allow_value(Time.zone.now + 1.minute).for :end_at }
      it "is expected not to allow end at to be the same as start at" do
        subject.start_at = Time.zone.now + 1.minute
        should_not allow_value(Time.zone.now + 1.minute).for :end_at
      end
      it "is expected not to allow end at to be earlier than start at" do
        subject.start_at = Time.zone.now + 2.minutes
        should_not allow_value(Time.zone.now + 1.minute).for :end_at
      end
      it "is expected to allow end at to be later than start at" do
        subject.start_at = Time.zone.now + 1.minutes
        should allow_value(Time.zone.now + 2.minute).for :end_at
      end
    end

    describe "#provider contact email" do
      it { should allow_value("test@test.com").for :provider_contact_email }
      it { should_not allow_value("test").for :provider_contact_email }
      it { should_not allow_value("").for :provider_contact_email }
      it { should_not allow_value(nil).for :provider_contact_email }
      it { should validate_length_of(:provider_contact_email).is_at_most(100) }
    end

    describe "#provider organiser" do
      it { should allow_value("test").for :provider_organiser }
      it { should_not allow_value("").for :provider_organiser }
      it { should_not allow_value(nil).for :provider_organiser }
    end

    describe "#provider target audience" do
      it { should allow_value("test").for :provider_target_audience }
      it { should_not allow_value("").for :provider_target_audience }
      it { should_not allow_value(nil).for :provider_target_audience }
    end

    describe "#provider website url" do
      it { should allow_value("test").for :provider_website_url }
      it { should_not allow_value("").for :provider_website_url }
      it { should_not allow_value(nil).for :provider_website_url }
    end
  end
end
