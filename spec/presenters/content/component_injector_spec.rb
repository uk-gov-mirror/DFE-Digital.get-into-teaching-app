require "rails_helper"

RSpec.describe Content::ComponentInjector, type: :component do
  {
    "simple component" => {
      "name" => "simple",
      "arguments" => {
        "title" => "simple component",
        "link_target" => "#simple-component",
        "link_text" => "simple component link",
        "icon" => "icon-person",
      },
    },
    "chat online component" => "chat_online",
    "next steps component" => "next_steps",
    "story component" => {
      "name" => "story",
      "arguments" => {
        "name" => "story component",
        "link" => "/story/component",
        "text" => "this is a story component",
        "heading" => "story component heading",
        "image" => "chat-online-card.jpg",
      },
    },
  }.each do |name, meta|
    describe "rendering a #{name}" do
      subject { described_class.new(meta).component }

      specify "generates a view component from the arguments" do
        is_expected.to be_a(ViewComponent::Base)
      end
    end
  end

  context "with invalid arguments" do
    let(:invalid_args) do
      { "story component" => { "name" => "story", "arguments" => { "something" => "story component" } } }
    end

    specify "raises an error describing bad config of the component" do
      expect { described_class.new(invalid_args).component }.to raise_error(ArgumentError, /call to action not properly configured/)
    end
  end
end
