class CardComponent < ViewComponent::Base
  MAX_HEADER_LENGTH = 70
  with_collection_parameter :card
  attr_accessor :snippet, :link, :link_text, :image, :video, :header, :title

  def initialize(card:)
    @card = card

    @snippet           = card["snippet"]
    @link              = card["link"]
    @link_text         = card["link_text"].presence || card["linktext"]
    @image             = card["image"]
    @image_description = card["image_description"]
    @video             = card["video"]
    @header            = card["header"]
    @title             = card["title"]
  end

  def media_link
    @video ? video_link : image_link
  end

  def truncated_header
    header&.truncate(MAX_HEADER_LENGTH)
  end

private

  def image_link
    link_to(thumbnail_image_tag, link, class: "card__thumb")
  end

  def thumbnail_image_tag
    helpers.image_tag(image, data: { "object-fit" => "cover" }, **thumbnail_image_alt_attribute)
  end

  def thumbnail_image_alt_attribute
    return {} if @image_description.blank?

    { alt: @image_description }
  end

  def video_link
    link_to(video, class: "card__thumb", data: { action: "click->video#play", "video-target": "link" }) do
      safe_join([tag.div(helpers.fas_icon("play"), class: "card__thumb--play-icon"), image_tag(image)])
    end
  end
end
