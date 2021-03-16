module Internal
  class PendingEventsController < InternalController

    def index
      @no_results = true
      @minimal = true

      load_pending_events
      render "index", layout: "internal"
    end

    def load_pending_events
      api = GetIntoTeachingApiClient::TeachingEventsApi.new
      search_results = api.search_teaching_events_grouped_by_type(
        start_after: DateTime.now.utc.beginning_of_day,
        )
      @group_presenter = Events::GroupPresenter.new(search_results)
      @events_by_type = @group_presenter.sorted_events_by_type
      @no_results = @events_by_type.all? { |_, events| events.empty? }
    end
  end
end
