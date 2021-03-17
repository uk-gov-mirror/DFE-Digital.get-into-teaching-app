class SubmitEventForm
  include ActiveModel::Model

  # for re-populating form
  attr_accessor :edit

  # building helpers
  attr_accessor :building
  attr_accessor :building_fieldset
  attr_accessor :search_building_postcode

  # event submission fields
  attr_accessor :event_name
  # building submission fields
  attr_accessor :building_id
  attr_accessor :venue
  attr_accessor :address_line_1
  attr_accessor :address_line_2
  attr_accessor :address_line_3
  attr_accessor :address_postcode

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
