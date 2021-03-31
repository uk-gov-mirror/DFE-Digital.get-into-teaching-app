require "rails_helper"

RSpec.describe Internal::EventsController do
  let(:auth_headers) do
    { headers:
        { "HTTP_AUTHORIZATION" =>
            ActionController::HttpAuthentication::Basic.encode_credentials(
              "publisher",
              "password",
            ) } }
  end

  let(:types) { Events::Search.available_event_type_ids }
  let(:events) do
    5.times.collect do |index|
      start_at = Time.zone.today.at_end_of_month - index.days
      type_id = types[index % types.count]
      build(:event_api, name: "Event #{index + 1}", start_at: start_at, type_id: type_id)
    end
  end
  let(:events_by_type) { group_events_by_type(events) }

  before { events[0].status_id = 222_750_003 }

  describe "#index" do
    context "when there are no pending events" do
      before do
        expect_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi)
          .to receive(:search_teaching_events_grouped_by_type) { [] }

        get internal_events_path, auth_headers
      end
      it "shows a no events banner" do
        expect(response.body).to include("No pending events")
      end
    end

    context "when there are pending events" do
      before do
        expect_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi)
          .to receive(:search_teaching_events_grouped_by_type) { events_by_type }

        get internal_events_path, auth_headers
      end
      it "shows pending events" do
        expect(response.body).not_to include("No pending events")
        expect(response.body).to include("<h4>Event 1</h4>")
        expect(response.body).not_to include("<h4>Event 2</h4>")
      end
    end
  end

  describe "#show" do
    context "when there are pending events" do
      before do
        event_to_get_readable_id = "1"

        expect_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi)
          .to receive(:get_teaching_event).with(event_to_get_readable_id) { events[0] }

        get internal_event_path(event_to_get_readable_id), auth_headers
      end
      it "shows pending events" do
        expect(response.body).to include("This is a pending event")
        expect(response.body).to include("<h1>Event 1</h1>")
      end
    end
  end

  private

  def get_auth_headers(user_type)
    { headers:
        { "HTTP_AUTHORIZATION" =>
            ActionController::HttpAuthentication::Basic.encode_credentials(
              user_type,
              "password",
            ) } }
  end

end
