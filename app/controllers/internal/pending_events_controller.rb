module Internal
  class PendingEventsController < InternalController
    def index
      @minimal = true
      render "index", layout: "internal"
    end
  end
end
