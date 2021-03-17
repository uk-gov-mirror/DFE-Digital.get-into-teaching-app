module Internal
  class PendingEventsController < InternalController
    before_action :load_type

    def index
      @no_results = true
      @minimal = true

      load_pending_events
      render "index", layout: "internal"
    end

    def individual_event
      @minimal = true

      @event = GetIntoTeachingApiClient::TeachingEventsApi.new.get_teaching_event(params[:id])
      @page_title = @event.name

      render "individual_event", layout: "internal"
    end

    private

    def load_type
      # TODO: Change to Pending type
      GetIntoTeachingApiClient::PickListItem.new(id: 222750001, value: "Train to Teach event")
    end

    def load_pending_events
      # TODO: Change to Pending type
      @event_search = Events::Search.new(type: 222750001)

      @events = @event_search.query_events[0]&.teaching_events
      @no_results = @events.blank?
    end
  end
end
