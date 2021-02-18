module CircuitBreaker
  class CircuitBrokenError < RuntimeError; end
  class NotAvailablePathMissingError < RuntimeError; end

  extend ActiveSupport::Concern

  THRESHOLD = 3
  COOL_OFF_TIME = 5.minutes

  included do
    before_action :check_api_available

    rescue_from GetIntoTeachingApiClient::ApiError, with: :update_circuit_breaker
    rescue_from CircuitBreaker::CircuitBrokenError, with: :redirect_to_not_available
  end

protected

  def redirect_to_not_available
    redirect_to(not_available_path)
  end

  def not_available_path
    raise NotAvailablePathMissingError
  end

private

  def update_circuit_breaker(error)
    if error.code == 500
      light = Stoplight("api-error") { raise error }.with_threshold(THRESHOLD).with_cool_off_time(COOL_OFF_TIME)
      light.run
    end

    raise
  rescue Stoplight::Error::RedLight
    raise CircuitBreaker::CircuitBrokenError
  end

  def check_api_available
    raise CircuitBreaker::CircuitBrokenError if Stoplight("api-error").color == "red"
  end
end
