require "rails_helper"

RSpec.describe Internal::InternalController do

  let(:git_api_endpoint) { ENV["GIT_API_ENDPOINT"] }
  before do
    stub_request(:get, /#{git_api_endpoint}.*/)
      .to_return \
        status: 200,
        headers: { "Content-type" => "application/json" },
        body: ""
  end

  it "should reject unauthenticated users" do
    authorization = ActionController::HttpAuthentication::Basic.encode_credentials(
      "wrong",
      "wrong",
    )

    get internal_events_path, headers: { "HTTP_AUTHORIZATION" => authorization }

    assert_response 401
  end

  it "should set the account role of publishers" do
    expect_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi)
      .to receive(:search_teaching_events_grouped_by_type) { [] }

    authorization = ActionController::HttpAuthentication::Basic.encode_credentials(
      "publisher",
      "password",
    )

    get internal_events_path, headers: { "HTTP_AUTHORIZATION" => authorization }

    assert_response 200
    expect(session[:publisher]).to be(true)
  end

  it "should set the account role of authors" do
    expect_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi)
      .to receive(:search_teaching_events_grouped_by_type) { [] }

    authorization = ActionController::HttpAuthentication::Basic.encode_credentials(
      "author",
      "password",
    )

    get internal_events_path, headers: { "HTTP_AUTHORIZATION" => authorization }

    assert_response 200
    expect(session[:author]).to be(true)
  end

end
