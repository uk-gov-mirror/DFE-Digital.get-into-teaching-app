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

  def get_buildings
    buildings = GetIntoTeachingApiClient::TeachingEventBuildingsApi
                  .new.get_teaching_event_buildings
    obj = [
      OpenStruct.new(id: 1, name: 'Add a new building'),
      OpenStruct.new(id: nil, name: nil),
      OpenStruct.new(id: 3, name: 'Finance'),
    ]
    obj
  end
end
