module Internal
  class Event
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :string
    attribute :name, :string
    attribute :summary, :string
    attribute :description, :string

    attribute :is_online, :boolean

    attribute :provider_contact_email, :string
    attribute :provider_organiser, :string
    attribute :provider_target_audience, :string
    attribute :provider_website_url, :string

    attribute :building

    validates :name, presence: true, allow_blank: false

    def persisted?
      id.present?
    end
  end
end

