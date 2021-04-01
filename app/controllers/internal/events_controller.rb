module Internal
  class EventsController < ::InternalController
    before_action :load_buildings, only: %i[new edit create update]
    layout "internal"

    def index
      @no_results = load_pending_events
    end

    def show
      @event = GetIntoTeachingApiClient::TeachingEventsApi.new.get_teaching_event(params[:id])
      @page_title = @event.name
      if @event.status_id != GetIntoTeachingApiClient::Constants::EVENT_STATUS["Pending"]
        raise ActionController::RoutingError, "Not Found"
      end
    end

    def new
      @event = Event.new
      @event.building = EventBuilding.new
      @event.building.fieldset = "existing"
    end

    def final_submit
      # TODO: fix
      @event = GetIntoTeachingApiClient::TeachingEventsApi.new.get_teaching_event(params[:format])
      transform_event(@event)
      @event.start_at = Time.zone.parse(@event.start_at.to_s)
      @event.end_at = Time.zone.parse(@event.end_at.to_s)
      if @event.approve
        redirect_to internal_events_path(method: :get, success: true)
      else
        render action: :new
      end
      # Ensure final submit has building attached
    end

    def create
      @event = Event.new(event_params)
      @event.building = format_building(event_params["building"])
      if @event.submit_pending
        redirect_to internal_events_path(method: :get, success: :pending)
      else
        render action: :new
      end
    end

    def edit
      @event = GetIntoTeachingApiClient::TeachingEventsApi.new.get_teaching_event(params[:id])
      transform_event(@event)
      @event.building.fieldset = "existing"
      render "new"
    end

    def update
      create
    end

    private

    def format_building(building_params)
      if building_params[:fieldset] == "existing"
        building = @buildings.select { |building| building.id == building_params[:id] }
        transform_event_building(building.first.to_hash)
      elsif building_params[:fieldset] == "add"
        building = transform_event_building(building_params.to_hash)
        building.id = nil # Id may be present from previous event
        building
      end
    end

    def transform_event(event)
      hash = event.to_hash.transform_keys { |k| k.to_s.underscore }.filter { |k| Event.attribute_names.include?(k) }
      @event = Event.new(hash)
      if event.building.nil?
        @event.building = EventBuilding.new
      else
        transform_event_building(hash["building"])
      end
    end

    def transform_event_building(building)
      hash = building.transform_keys { |k| k.to_s.underscore }.filter { |k| EventBuilding.attribute_names.include?(k) }
      @event.building = EventBuilding.new(hash)
    end

    def load_buildings
      @buildings = GetIntoTeachingApiClient::TeachingEventBuildingsApi
                     .new.get_teaching_event_buildings
    end

    def event_params
      params.require(:internal_event).permit(
        :id,
        :name,
        :readable_id,
        :summary,
        :description,
        :is_online,
        :start_at,
        :end_at,
        :provider_contact_email,
        :provider_organiser,
        :provider_target_audience,
        :provider_website_url,
        building: %i[
          id
          fieldset
          venue
          address_line_1
          address_line_2
          address_line_3
          address_city
          address_postcode
        ]
      )
    end

    def load_pending_events
      opts = {
        type_id: GetIntoTeachingApiClient::Constants::EVENT_TYPES["School or University event"],
        status_ids: [GetIntoTeachingApiClient::Constants::EVENT_STATUS["Pending"]],
        quantity_per_type: 1_000,
      }

      @events = GetIntoTeachingApiClient::TeachingEventsApi
                  .new
                  .search_teaching_events_grouped_by_type(opts)[0]&.teaching_events

      unless @events.nil?
        @events = Kaminari.paginate_array(@events).page(params[:page])
      end
      @events.blank?
    end
  end
end
