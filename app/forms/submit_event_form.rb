class SubmitEventForm
  include ActiveModel::Model

  attr_accessor :event_name
  attr_accessor :building
  attr_accessor :building_name
  attr_accessor :search_building_postcode

  validates :event_name, format: { with: /\A[a-zA-Z]+\z/,
                                   message: "only allows letters" }

  def submit
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
          id: building.id, name: "#{building.address_postcode}, #{building.venue}"
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
