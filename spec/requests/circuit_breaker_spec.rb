require "rails_helper"

describe "Circuit breaker" do
  it { expect(CircuitBreaker::THRESHOLD).to eq(3) }
  it { expect(CircuitBreaker::COOL_OFF_TIME).to eq(5.minutes) }

  it_behaves_like "a path that handles broken circuits" do
    let(:test_path) { event_path("event-id") }
    let(:not_available_path) { events_not_available_path }
  end

  it_behaves_like "a path that handles broken circuits" do
    let(:test_path) { event_category_path("category-id") }
    let(:not_available_path) { events_not_available_path }
  end

  it_behaves_like "a path that handles broken circuits" do
    let(:test_path) { event_step_path("event-id", "privacy_policy") }
    let(:not_available_path) { events_not_available_path }
  end

  it_behaves_like "a path that handles broken circuits" do
    let(:test_path) { mailing_list_step_path("privacy_policy") }
    let(:not_available_path) { mailinglist_not_available_path }
  end
end
