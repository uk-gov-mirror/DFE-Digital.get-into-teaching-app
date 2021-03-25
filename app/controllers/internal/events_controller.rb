module Internal
  class EventsController < ::InternalController
    before_action :load_buildings, only: %i[new edit create]
    layout "internal"

    def index
      @no_results = true
      load_pending_events
    end

    def show
      @event = GetIntoTeachingApiClient::TeachingEventsApi.new.get_teaching_event(params[:id])
      @page_title = @event.name
    end

    def new
      @event = Event.new
      @event.building = EventBuilding.new
      @event.building.fieldset = "select"
    end

    def create
      @event = Event.new(event_params)
      if @event.submit
        # successfully submitted
      else
        render action: :new
      end
      # respond_with @success, location: some_success_path
    end

    def edit
      @event = GetIntoTeachingApiClient::TeachingEventsApi.new.get_teaching_event(params[:id])
      hash = @event.to_hash.transform_keys { |k| k.to_s.underscore }.filter { |k| Event.attribute_names.include?(k) }
      @event = Event.new(hash)
      hash = hash["building"].transform_keys { |k| k.to_s.underscore }.filter { |k| EventBuilding.attribute_names.include?(k) }
      @event.building = EventBuilding.new(hash)
      @event.building.fieldset = "select"
      render "new"
    end

    def update
      create
    end

    private

    def load_buildings
      @buildings = GetIntoTeachingApiClient::TeachingEventBuildingsApi
                     .new.get_teaching_event_buildings
    end

    def event_params
      params.require(:internal_event).permit(
        :id,
        :name,
        :summary,
        :description,
        :is_online,
        :start_at,
        :end_at,
        :provider_contact_email,
        :provider_organiser,
        :provider_target_audience,
        :provider_website_url,
        :building,
      )
    end

    def load_pending_events
      @event_search = Events::Search.new(
        type: GetIntoTeachingApiClient::Constants::EVENT_TYPES["School or University event"])

      @events = @event_search.query_events[0]&.teaching_events
      @events = @events.select do |event|
        event.status_id == GetIntoTeachingApiClient::Constants::EVENT_STATUS["Open"]
      end
      @events = Kaminari.paginate_array(@events).page(params[:page])
      @no_results = @events.blank?
    end
  end
end
