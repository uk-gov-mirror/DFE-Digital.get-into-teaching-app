module Internal
  class Event
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :string
    attribute :name, :string
    attribute :summary, :string
    attribute :description, :string
    attribute :building

    validates :name, presence: true, allow_blank: false

    def persisted?
      id.present?
    end



  end
end

