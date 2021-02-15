require "rails_helper"

describe "Circuit breaker" do
  context "when the API returns a single error" do
    let(:error) { GetIntoTeachingApiClient::ApiError.new(code: 404) }

    before do
      allow_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi).to \
        receive(:get_teaching_event).with("456")
                                    .and_raise error
      Rails.application.config.action_dispatch.show_exceptions = true
    end

    it "redirect to an error page" do
      get event_steps_path("456")
      expect(response).to have_http_status(500)
    end
  end

  context "when the API returns a number errors above the threshold" do
    let(:error) { GetIntoTeachingApiClient::ApiError.new(code: 500) }
    let(:threshold) { 3 }

    before do
      allow_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi).to \
          receive(:get_teaching_event).with("456")
                                      .and_raise error
      Rails.application.config.action_dispatch.show_exceptions = true
    end

    it "should redirect to service unavailable page" do
      (threshold + 1).times do
        get event_steps_path("456")
      end
      expect(response).to redirect_to :controller => :event, :action => :not_available
      # is_expected.to redirect_to(event_step_path("123", { id: :personal_details, query: "param" }))
    end
  end

end
