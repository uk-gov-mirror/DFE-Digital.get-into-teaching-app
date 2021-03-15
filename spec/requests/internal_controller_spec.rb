require "rails_helper"

RSpec.describe Internal::InternalController do
  it "should reject unauthenticated users" do
    authorization = ActionController::HttpAuthentication::Basic.encode_credentials(
      "wrong",
      "wrong",
    )

    get "/internal/submit-event", headers: { "HTTP_AUTHORIZATION" => authorization }

    assert_response 401
  end

  it "should set the account role of publishers" do
    authorization = ActionController::HttpAuthentication::Basic.encode_credentials(
      "publisher",
      "password",
    )

    get "/internal/submit-event", headers: { "HTTP_AUTHORIZATION" => authorization }

    assert_response 200
    expect(session[:publisher]).to be(true)
  end

  it "should set the account role of authors" do
    authorization = ActionController::HttpAuthentication::Basic.encode_credentials(
      "author",
      "password",
      )

    get "/internal/submit-event", headers: { "HTTP_AUTHORIZATION" => authorization }

    assert_response 200
    expect(session[:author]).to be(true)
  end

end
