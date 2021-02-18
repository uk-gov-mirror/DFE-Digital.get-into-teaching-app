shared_examples "a path that handles broken circuits" do
  let(:internal_error) { GetIntoTeachingApiClient::ApiError.new(code: 500) }
  let(:bad_request_error) { GetIntoTeachingApiClient::ApiError.new(code: 400) }

  before do
    Stoplight::Light.default_data_store = Stoplight::DataStore::Memory.new
    Stoplight::Light.default_notifiers = []

    api_constants = GetIntoTeachingApiClient::constants.select { |klass| klass.to_s.end_with?("Api") }
    apis_to_mock = api_constants.map { |const| GetIntoTeachingApiClient::const_get(const) }
    apis_to_mock.each do |api|
      api.instance_methods(false).each do |method|
        allow_any_instance_of(api).to receive(method).and_raise(error)
      end
    end
  end

  context "when the API returns a single error that can cause a broken circuit" do
    let(:error) { internal_error }

    it "does not break the circuit" do
      expect { get test_path }.to raise_error(error)
    end
  end

  context "when the API returns #{CircuitBreaker::THRESHOLD + 1} errors that can cause a broken circuit" do
    let(:error) { internal_error }

    context "when in immediate succesion" do
      it "breaks the circuit" do
        trigger_api_errors(CircuitBreaker::THRESHOLD)
        get test_path
        expect(response).to redirect_to(not_available_path)
      end
    end

    context "when spaced apart" do
      it "does not break the circuit" do
        trigger_api_errors(CircuitBreaker::THRESHOLD, CircuitBreaker::COOL_OFF_TIME + 1.second)
        expect { get test_path }.to raise_error(error)
      end
    end
  end

  context "when the API returns #{CircuitBreaker::THRESHOLD + 1} errors that don't cause a broken circuit" do
    let(:error) { bad_request_error }

    it "does not break the circuit" do
      trigger_api_errors(CircuitBreaker::THRESHOLD + 1)
    end
  end

  context "when the circuit was broken in a previous request" do
    let(:error) { internal_error }

    it "stays broken for subsequent requests" do
      force_circuit_breacker_state(Stoplight::State::LOCKED_RED)
      get test_path
      expect(response).to redirect_to(not_available_path)
    end

    it "re-closes the circuit after 1 minute" do
      trigger_api_errors(CircuitBreaker::THRESHOLD)
      get test_path
      expect(response).to redirect_to(not_available_path)
      travel_to((CircuitBreaker::COOL_OFF_TIME + 1.second).from_now)
      expect { get test_path }.to raise_error(error)
    end
  end

private

  def trigger_api_errors(count, interval = 0.seconds)
    count.times do
      expect { get test_path }.to raise_error { |error|
        expect(error).not_to eq(CircuitBreaker::CircuitBrokenError)
      }
      travel_to(interval.from_now)
    end
  end

  def force_circuit_breacker_state(state)
    light = Stoplight("api-error")
    light.data_store.set_state(light, state)
  end
end
