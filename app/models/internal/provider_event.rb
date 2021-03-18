module Internal
  class ProviderEvent
    include ActiveModel::Model
    include ActiveModel::Attributes

    # building helpers
    attr_accessor :building
    attr_accessor :building_fieldset
    attr_accessor :search_building_postcode

    # event submission fields
    attribute :event_name, :string
    attribute :event_summary, :string
    attribute :event_description, :string
    # building submission fields
    attribute :building_id, :string
    attribute :venue, :string
    attribute :address_line_1, :string
    attribute :address_line_2, :string
    attribute :address_line_3, :string
    attribute :address_postcode, :string

    validates :event_name, presence: true, allow_blank: false

    def submit
      return false if edit
      puts "invalid" if invalid?
      return false if invalid?

      # submit via API
      true
    end

    def get_building_options
      options = [OpenStruct.new(id: 1, name: "", disabled: true)]

      get_buildings.each do |building|
        options.push(
          OpenStruct.new(
            id: building.id,
            name: "#{building.address_postcode}, "\
                "#{building.venue}",
          ),
        )
      end

      options
    end

    private

    def get_buildings
      GetIntoTeachingApiClient::TeachingEventBuildingsApi
        .new.get_teaching_event_buildings
    end

  end
end

