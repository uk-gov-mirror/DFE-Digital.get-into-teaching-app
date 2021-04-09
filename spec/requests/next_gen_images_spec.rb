require "rails_helper"

describe "Next Gen Images" do
  before do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(/.*\.svg/) { true }
    get root_path
  end
  subject { response.body }

  it do
    is_expected.to match(
      /<picture><source srcset=\"\" type="image\/svg\+xml" data-srcset=".*\.svg"><\/source><img alt="Department for education" src=\"\" width=\"92\" height=\"54\" data-src=".*\.svg" class=" lazyload"><noscript>.*<\/noscript><\/picture>/,
    )
  end
end
