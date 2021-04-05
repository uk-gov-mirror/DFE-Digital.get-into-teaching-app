require "rails_helper"
require "action_text/system_test_helper"

RSpec.feature "Internal section", type: :feature do
  let(:types) { Events::Search.available_event_type_ids }
  let(:events) do
    5.times.collect do |index|
      start_at = Time.zone.today.at_end_of_month - index.days
      type_id = types[index % types.count]
      build(:event_api, name: "Event #{index + 1}", start_at: start_at, type_id: type_id)
    end
  end
  let(:events_by_type) { group_events_by_type(events) }

  before do
    if page.driver.browser.respond_to?(:authorize)
      page.driver.browser.authorize("publisher", "password")
    end

    allow_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi).to \
        receive(:search_teaching_events_grouped_by_type) { events_by_type }

    allow_any_instance_of(GetIntoTeachingApiClient::TeachingEventBuildingsApi).to \
        receive(:get_teaching_event_buildings) { [] }
  end

  scenario "Submit a new form" do
    allow_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi).to \
        receive(:upsert_teaching_event) { [] }

    visit internal_events_path
    expect(page).to have_text "Pending Provider Events"

    click_button "Submit a provider event for review"
    expect(page).to have_text("Provider Event Details")

    fill_in "Event name", with: "test"
    fill_in "External event name", with: "test"
    fill_in "Event summary", with: "test"
    find(:id, "internal_event_description", visible: false)
      .click
      .set "some value here"
    fill_in "Provider email address", with: "test@test.com"
    fill_in "Provider organiser", with: "test"
    fill_in "Target audience", with: "test"
    fill_in "Provider website/registration link", with: "test"
    choose "Yes"
    fill_in "internal_event[start_at]", with: Time.zone.now + 1.day
    fill_in "internal_event[end_at]", with: Time.zone.now + 2.days
    choose "No venue"

    click_button "Submit for review"
    expect(page).to have_text "Event submitted for review"
  end

  scenario "Submit final" do
    allow_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi).to \
        receive(:upsert_teaching_event) { [] }

    allow_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi).to \
        receive(:get_teaching_event) { events[0] }



    visit internal_events_path
    expect(page).to have_text "Pending Provider Events"

    click_link "Event 1"
    click_button "Edit this provider event"


  end

  # scenario "Edit a pending event" do
  #   allow_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi).to \
  #       receive(:upsert_teaching_event) { [] }
  #
  #   allow_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi).to \
  #       receive(:get_teaching_event) { events[0] }
  #
  #
  #   visit internal_events_path
  #   expect(page).to have_text "Pending Provider Events"
  #
  #   click_link "Event name"
  #
  #   click_button "Edit this provider content"
  #
  #
  #   ## event name should have text
  # end
end
