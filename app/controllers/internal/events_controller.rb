module Internal
  class EventsController < ::InternalController
    before_action :load_buildings, only: %i[new edit create]
    layout "internal"

    def index
      @no_results = load_pending_events
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

    def final_submit
      transform_event(params[:format])
      if @event.approve
        true
      end
    end

    def create
      @event = Event.new(event_params)
      if @event.submit_pending
        redirect_to internal_events_path(method: :get, success: :pending)
      else
        render action: :new
      end
    end

    def edit
      transform_event(params[:id])
      @event.building.fieldset = "select"
      render "new"
    end

    def update
      create
    end

    private

    def transform_event(id)
      @event = GetIntoTeachingApiClient::TeachingEventsApi.new.get_teaching_event(id)
      hash = @event.to_hash.transform_keys { |k| k.to_s.underscore }.filter { |k| Event.attribute_names.include?(k) }
      @event = Event.new(hash)
      hash = hash["building"].transform_keys { |k| k.to_s.underscore }.filter { |k| EventBuilding.attribute_names.include?(k) }
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
        :building,
      )
    end

    def load_pending_events
      opts = {
        type_id: 222_750_009,
        status_ids: [222_750_003],
        # quantity_per_type: 99,
      }

      @events = GetIntoTeachingApiClient::TeachingEventsApi.new
                                                           .search_teaching_events_grouped_by_type(opts)[0]&.teaching_events
      puts @events

      # @event_search = Events::Search.new(
      #   type: GetIntoTeachingApiClient::Constants::EVENT_TYPES["School or University event"])
      #
      # @events = @event_search.query_events[0]&.teaching_events
      #
      #
      # @events = GetIntoTeachingApiClient::TeachingEventsApi.new.search_teaching_events_grouped_by_type(
      #     # type_id: GetIntoTeachingApiClient::Constants::EVENT_TYPES["School or University event"],
      #   quantity_per_type: 9
      #     )
      #
      # @events = @events[0]&.teaching_events
      # @events = @events.select do |event|
      #   event.status_id == 222750000
      # end
      @events = Kaminari.paginate_array(@events).page(params[:page])
      @events.blank?
    end
    # @events = GetIntoTeachingApiClient::TeachingEventsApi.new.search_teaching_events_grouped_by_type(
    #   type_id: GetIntoTeachingApiClient::Constants::EVENT_TYPES["School or University event"],
    # # quantity_per_type: 1_000
    #   )[0]
  end
end
