class SubmitEventForm
  include ActiveModel::Model

  attr_accessor :event_name

  validates :event_name, format: { with: /\A[a-zA-Z]+\z/,
                                     message: "only allows letters" }

  def submit
    puts "invalid" if invalid?
    return false if invalid?

    # submit via API
    true
  end
end
