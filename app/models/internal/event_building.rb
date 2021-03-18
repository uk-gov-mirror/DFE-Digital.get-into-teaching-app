module Internal
  class EventBuilding
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_accessor :fieldset

    attribute :id, :string
    attribute :venue, :string
    attribute :address_line_1, :string
    attribute :address_line_2, :string
    attribute :address_line_3, :string
    attribute :address_postcode, :string
  end
end
