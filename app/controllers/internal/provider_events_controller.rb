module Internal
  class ProviderEventsController < ::InternalController

    def index
      @no_results = true
      @minimal = true
      load_pending_events
      render "index", layout: "internal"
    end

    def show
      @minimal = true

      @event = GetIntoTeachingApiClient::TeachingEventsApi.new.get_teaching_event(params[:id])
      @page_title = @event.name

      render "show", layout: "application"
    end

    def new
      @minimal = true
      @provider_event = ProviderEvent.new
      render "new", layout: "internal"
    end

    def edit
      @minimal = true
      @event = GetIntoTeachingApiClient::TeachingEventsApi.new.get_teaching_event(params[:id])
      hash = @event.to_hash.transform_keys { |k| k.to_s.underscore }.filter { |k| ProviderEvent.attribute_names.include?(k) }
      byebug
      @provider_event = ProviderEvent.new(hash)
      # @provider_event = ProviderEvent
      # Get event -
      render "new", layout: "internal"
    end

    def create
      @provider_event = ProviderEvent.new(event_params)
      if @provider_event.submit
        # successfully submitted
      else
        @minimal = true
        render action: :new, layout: "internal"
      end
      # respond_with @success, location: some_success_path
    end




    private

    # def load_type
    #   # TODO: Change to Pending type
    #
    #   GetIntoTeachingApiClient::PickListItem.new(id: 222750001, value: "Train to Teach event")
    # end


    def event_params
      params.require(:internal_provider_event).permit(:event_name, :event_description, :event_summary, :edit)
    end

    def load_pending_events
      # TODO: Change to Pending type
      @event_search = Events::Search.new(type: GetIntoTeachingApiClient::Constants::EVENT_TYPES["School or University event"])

      @events = @event_search.query_events[0]&.teaching_events
      @no_results = @events.blank?
    end
  end
end
