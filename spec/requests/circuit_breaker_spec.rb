require "rails_helper"

describe "Circuit breaker" do
  let(:error) { GetIntoTeachingApiClient::ApiError.new(code: 500) }

  context "when the API returns a single error" do
    before do
      allow_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi).to \
        receive(:get_teaching_event).with("456")
                                    .and_raise error
    end

    it "redirects to an error page" do
      get event_steps_path("456")
      expect(response).to have_http_status(500)
    end
  end

  context "when the API returns a number of errors greater than the threshold" do
    it "should redirect to events service unavailable page" do
      allow_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi).to \
        receive(:get_teaching_event).with("456")
                                    .and_raise error


      (ApplicationController::CIRCUIT_BREAKER_THRESHOLD + 1).times do
        get event_steps_path("456")
      end
      expect(response).to redirect_to(events_not_available_path)
    end

    let(:request) do
      GetIntoTeachingApiClient::ExistingCandidateRequest.new(
        email: "email@address.com",
        firstName: "first",
        lastName: "last",
      )
    end
    it "should redirect to mailing list service unavailable page" do
      allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to \
        receive(:create_candidate_access_token).and_raise error
      (ApplicationController::CIRCUIT_BREAKER_THRESHOLD + 1).times do
        GetIntoTeachingApiClient::CandidatesApi.new.create_candidate_access_token(request)
      end
      expect(response).to redirect_to(mailinglist_not_available_path)
    end
  end

  context "when the circuit breaker has been opened" do
    it "should redirect all events traffic to service unavailable page" do
      allow_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi).to \
        receive(:get_teaching_event).with("456")
                                    .and_raise error

      (ApplicationController::CIRCUIT_BREAKER_THRESHOLD + 1).times do
        get event_steps_path("456")
      end
      expect(response).to redirect_to(events_not_available_path)
    end
  end

end
