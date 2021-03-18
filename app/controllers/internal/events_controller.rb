module Internal
  class EventsController < ::InternalController
    before_action :load_buildings, only: %i[new edit]
    layout "internal"

    def index
      @no_results = true
      @minimal = true
      load_pending_events
    end

    def show
      @minimal = true

      @event = GetIntoTeachingApiClient::TeachingEventsApi.new.get_teaching_event(params[:id])
      @page_title = @event.name

    end

    def new
      @minimal = true
      @event = Event.new
    end

    def create
      @event = Event.new(event_params)
      if @event.submit
        # successfully submitted
      else
        @minimal = true
        render action: :new
      end
      # respond_with @success, location: some_success_path
    end

    def edit
      @minimal = true
      @event = GetIntoTeachingApiClient::TeachingEventsApi.new.get_teaching_event(params[:id])
      hash = @event.to_hash.transform_keys { |k| k.to_s.underscore }.filter { |k| Event.attribute_names.include?(k) }
      @event = Event.new(hash)
      hash = hash["building"].transform_keys { |k| k.to_s.underscore }.filter { |k| EventBuilding.attribute_names.include?(k) }
      @event.building = EventBuilding.new(hash)


      # @provider_event = ProviderEvent
      # Get event -
      render "new"
    end

    def update; end

    private


    # def get_building_options
    #   options = [OpenStruct.new(id: 1, name: "", disabled: true)]
    #
    #   get_buildings.each do |building|
    #     options.push(
    #       OpenStruct.new(
    #         id: building.id,
    #         name: "#{building.address_postcode}, "\
    #               "#{building.venue}",
    #       ),
    #     )
    #   end
    #
    #   options
    # end


    def load_buildings
      @buildings = GetIntoTeachingApiClient::TeachingEventBuildingsApi
        .new.get_teaching_event_buildings
    end



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
