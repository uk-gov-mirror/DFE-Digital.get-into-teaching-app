require "rails_helper"

RSpec.feature "Internal section", type: :feature do

  before do
    fill_in "Username", with: "publisher"
    fill_in "Password", with: "password"
  end

  scenario "Go to new form" do

    visit internal_events_path

    expect(page).to have_text "Pending Provider Events"

    click_button "Submit a provider event for review"

    expect(page).to have_text("Provider Event Details")
  end
end
