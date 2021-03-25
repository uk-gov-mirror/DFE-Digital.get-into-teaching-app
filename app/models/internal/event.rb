module Internal
  class Event
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :string
    attribute :readable_id, :string
    attribute :name, :string
    attribute :summary, :string
    attribute :description, :string

    attribute :is_online, :boolean

    attribute :start_at, :datetime
    attribute :end_at, :datetime

    attribute :provider_contact_email, :string
    attribute :provider_organiser, :string
    attribute :provider_target_audience, :string
    attribute :provider_website_url, :string

    attribute :building

    validates :name, presence: true, allow_blank: false
    validates :summary, presence: true, allow_blank: false
    validates :description, presence: true, allow_blank: false
    validates :summary, presence: true, allow_blank: false
    validates :is_online, inclusion: { in: [true, false] }
    validates :start_at, presence: true, allow_blank: false
    validates :end_at, presence: true
    validates :provider_contact_email,
              presence: true,
              allow_blank: false,
              email_format: true,
              length: { maximum: 100 }
    validates :provider_organiser, presence: true, allow_blank: false
    validates :provider_target_audience, presence: true, allow_blank: false
    validates :provider_website_url, presence: true, allow_blank: false
    validate :end_after_start, :time_must_be_future

    def persisted?
      id.present?
    end

    def submit
      return false if invalid?

      submit_to_api
      true
    end

    private

    def end_after_start
      return if end_at.blank? || start_at.blank?

      if end_at <= start_at
        errors.add(:end_at, "must be after the start date")
      end
    end

    def time_must_be_future
      return if start_at.blank?
      if start_at <= Time.zone.now
        errors.add(:start_at, "must be later than current time")
      end

      if end_at <= Time.zone.now
        errors.add(:end_at, "must be later than current time")
      end
    end

    def submit_to_api
      api = GetIntoTeachingApiClient::TeachingEventsApi.new

      opts = {
        body: GetIntoTeachingApiClient::TeachingEvent.new(
          name: name,
          readableId: name,
          typeId: GetIntoTeachingApiClient::Constants::EVENT_TYPES["School or University event"],
          statusId: GetIntoTeachingApiClient::Constants::EVENT_STATUS["Pending"],
          summary: summary,
          description: description,
          isOnline: is_online,
          startAt: start_at,
          endAt: end_at) }
      result = api.upsert_teaching_event(opts)
      p result

      # start_date: format_start_date,
      # postcode: postcode&.strip,
      # start_after: start_of_month,
      # start_before: end_of_month,
      # quantity_per_type: limit,

    end

    # def format_date
    #   helpers.format_date
    # end
  end
end

