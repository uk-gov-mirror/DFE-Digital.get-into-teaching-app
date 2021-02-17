class ApplicationController < ActionController::Base
  include UtmCodes

  CIRCUIT_BREAKER_THRESHOLD = 3

  @circuit_breaker_open = Stoplight("api-error").color == "red"

  rescue_from ActionController::RoutingError, with: :render_not_found
  rescue_from GetIntoTeachingApiClient::ApiError, with: :handle_api_error

  before_action :check_api_available
  before_action :http_basic_authenticate
  before_action :record_utm_codes

  def raise_not_found
    raise ActionController::RoutingError, "Not Found"
  end

  private

  def check_api_available
    if Stoplight("api-error").color == "red"
      redirect_to_not_available?
      # circuit_breaker_status
    end
  end

  def circuit_breaker(error)
    light = Stoplight("api-error") { raise error }.with_threshold(CIRCUIT_BREAKER_THRESHOLD)
    light.run
  end

  def redirect_to_not_available?
    redirect = true
    Stoplight("api-error").color == "red"
    # if controller_name.include? "event"
    #   redirect_to events_not_available_path
    if controller_name.include? "mailing"
      redirect_to mailinglist_not_available_path
    else
      redirect = false
    end
    redirect
  end

  def handle_api_error(error)
    if error.code == 500
      begin
        circuit_breaker(error)
      rescue Stoplight::Error::RedLight
        return if redirect_to_not_available?
      end
    end

    render_too_many_requests && return if error.code == 429
    render_not_found && return if error.code == 404

    raise
  end

  def render_not_found
    render template: "errors/not_found", layout: "application", status: :not_found
  end

  def render_too_many_requests
    render template: "errors/too_many_requests", layout: "application", status: :too_many_requests
  end

  def http_basic_authenticate
    return true if ENV["HTTPAUTH_USERNAME"].blank?

    authenticate_or_request_with_http_basic do |name, password|
      name == ENV["HTTPAUTH_USERNAME"].to_s &&
        password == ENV["HTTPAUTH_PASSWORD"].to_s
    end
  end
end
