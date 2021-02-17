module CircuitBreaker
  class CircuitBrokenError < RuntimeError;

  extend ActiveSupport::Concern

  CIRCUIT_BREAKER_THRESHOLD = 3

  rescue_from GetIntoTeachingApiClient::ApiError, with: :update_circuit_breaker
  rescue_from CircuitBreaker::CircuitBrokenError, with: :redirect_to_not_available

  before_action :set_api_available
  before_action  unless @api_available

protected

  def redirect_to_not_available
    redirect_to(not_available_path)
  end

  def not_available_path
    raise NotImplementedError
  end

private

  def update_circuit_breaker(error)
    return unless error.code == 500

    light = Stoplight("api-error") { raise error }.with_threshold(CIRCUIT_BREAKER_THRESHOLD)
    light.run
  end

  def set_api_available
    @api_available = Stoplight("api-error").color != "red"
  end
end
