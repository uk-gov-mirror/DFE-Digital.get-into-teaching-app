require "rails_helper"

RSpec.describe Internal::EventsController do
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
    context "when any user type" do
      context "when there are no pending events" do
        before do
          expect_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi)
            .to receive(:search_teaching_events_grouped_by_type) { [] }

          get internal_events_path, generate_auth_headers("author")
        end
        it "shows a no events banner" do
          assert_response :success
          expect(response.body).to include("No pending events")
        end
      end

      context "when there are pending events" do
        before do
          expect_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi)
            .to receive(:search_teaching_events_grouped_by_type) { events_by_type }

          get internal_events_path, generate_auth_headers("author")
        end
        it "shows pending events" do
          assert_response :success
          expect(response.body).not_to include("No pending events")
          expect(response.body).to include("<h4>Event 1</h4>")
          expect(response.body).not_to include("<h4>Event 2</h4>")
        end
      end
    end

    context "when unauthenticated" do
      it "should reject bad login" do
        get internal_events_path, generate_auth_headers("wrong")

        assert_response :unauthorized
      end

      it "should reject no authentication" do
        get internal_events_path

        assert_response :unauthorized
      end
    end
  end

  describe "#show" do
    let(:event_to_get_readable_id) { "1" }
    context "when any user type" do
      context "when the event is pending" do
        before do
          expect_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi)
            .to receive(:get_teaching_event).with(event_to_get_readable_id) { events[0] }

          get internal_event_path(event_to_get_readable_id), generate_auth_headers("author")
        end
        it "shows pending events" do
          assert_response :success
          expect(response.body).to include("This is a pending event")
          expect(response.body).to include("<h1>Event 1</h1>")
        end
      end

      context "when the event is not pending" do
        before do
          expect_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi)
            .to receive(:get_teaching_event).with(event_to_get_readable_id) { events[1] }

          get internal_event_path(event_to_get_readable_id), generate_auth_headers("author")
        end
        it "redirects to not found" do
          assert_response :not_found
          expect(response.body).to include "Page not found"
        end
      end
    end

    context "when author user type" do
      context "when the event is pending" do
        before do
          expect_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi)
            .to receive(:get_teaching_event).with(event_to_get_readable_id) { events[0] }

          get internal_event_path(event_to_get_readable_id), generate_auth_headers("author")
        end
        it "does not have a final submit button" do
          assert_response :success
          expect(response.body).to_not include "Submit this provider event"
        end
      end
    end

    context "when publisher user type" do
      context "when the event is pending" do
        before do
          expect_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi)
            .to receive(:get_teaching_event).with(event_to_get_readable_id) { events[0] }

          get internal_event_path(event_to_get_readable_id), generate_auth_headers("publisher")
        end
        it "should have a final submit button" do
          assert_response :success
          expect(response.body).to include "Submit this provider event"
        end
      end
    end

    context "when unauthenticated" do
      it "should reject bad login" do
        get internal_event_path(event_to_get_readable_id, generate_auth_headers("wrong"))

        assert_response :unauthorized
      end

      it "should reject no authentication" do
        get internal_event_path(event_to_get_readable_id)

        assert_response :unauthorized
      end
    end
  end

  describe "#new" do
    context "when any user type" do
      before do
        expect_any_instance_of(GetIntoTeachingApiClient::TeachingEventBuildingsApi)
          .to receive(:get_teaching_event_buildings) { [] }

        get new_internal_event_path, generate_auth_headers("author")
      end

      it "should have an events form" do
        assert_response :success
        expect(response.body).to include("form")
      end
    end

    context "when unauthenticated" do
      it "should reject bad login" do
        get new_internal_event_path, generate_auth_headers("wrong")

        assert_response :unauthorized
      end

      it "should reject no authentication" do
        get new_internal_event_path

        assert_response :unauthorized
      end
    end
  end

  describe "#edit" do
    let(:event_to_edit_readable_id) { "1" }
    context "when any user type" do
      before do
        expect_any_instance_of(GetIntoTeachingApiClient::TeachingEventBuildingsApi)
          .to receive(:get_teaching_event_buildings) { [] }
        expect_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi)
          .to receive(:get_teaching_event).with(event_to_edit_readable_id) { events[0] }

        get edit_internal_event_path(event_to_edit_readable_id), generate_auth_headers("author")
      end

      it "should have an events form with populated fields" do
        assert_response :success
        expect(response.body).to include("value=\"Event 1\"")
      end
    end

    context "when unauthenticated" do
      it "should reject bad login" do
        get edit_internal_event_path(event_to_edit_readable_id), generate_auth_headers("wrong")

        assert_response :unauthorized
      end

      it "should reject no authentication" do
        get edit_internal_event_path(event_to_edit_readable_id)

        assert_response :unauthorized
      end
    end
  end

  private

  def generate_auth_headers(user_type)
    { headers:
        { "HTTP_AUTHORIZATION" =>
            ActionController::HttpAuthentication::Basic.encode_credentials(
              user_type,
              "password",
            ) } }
  end

end
