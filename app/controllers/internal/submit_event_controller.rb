module Internal
  class SubmitEventController < InternalController
    def new
      @minimal = true
      @submit_event = SubmitEventForm.new
      render "submit_event_form", layout: "internal"
    end

    def create
      @submit_event = SubmitEventForm.new(event_params)
      if @submit_event.submit
        # successfully submitted
      else
        @minimal = true
        render action: :submit_event_form, layout: "internal"
      end
      # respond_with @success, location: some_success_path
    end

  private

    def event_params
      params.require(:submit_event_form).permit(:event_name)
    end
  end
end
