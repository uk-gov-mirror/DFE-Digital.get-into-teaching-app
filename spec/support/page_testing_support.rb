class PageLister
  IGNORE = %w[
    /test
    /guidance_archive
    /index
    /steps-to-become-a-teacher/v2-index
    /privacy-policy
  ].freeze

  class << self
    def md_files
      Dir["app/views/content/**/[^_]*.md"]
    end

    def html_files
      Dir["app/views/content/**/[^_]*.html.erb"]
    end

    def files
      html_files + md_files
    end

    def remove_folders(filename)
      filename.gsub "app/views/content", ""
    end

    def remove_extension(filename)
      filename.gsub %r{(\.[a-zA-Z0-9]+)+\z}, ""
    end

    def content_urls
      files.map(&method(:remove_folders)).map(&method(:remove_extension)) - IGNORE
    end
  end
end

class LinkChecker
  IGNORE = %w[127.0.0.1 localhost ::1 www.linkedin.com linkedin.com].freeze
  GET_NOT_HEAD = %w[www.instagram.com].freeze

  attr_reader :page, :document

  class Results < Hash; end
  Result = Struct.new(:status, :pages)

  def initialize(page, body)
    @page = page
    @document = Nokogiri.parse(body)
  end

  def check_links(results = Results.new)
    external_links.each do |link|
      next if ignored?(link)

      results[link] ||= Result.new(check(link), [])
      results[link].pages << page
    end

    results
  end

private

  def links
    document.css("a").pluck("href")
  end

  def external_links
    links.select { |href| href.starts_with? %r{https?://} }
  end

  def faraday(link)
    ::Faraday.new(link) do |f|
      f.request :retry, max: 2
      f.use ::FaradayMiddleware::FollowRedirects
    end
  end

  def check(link)
    if needs_get?(link)
      faraday(link).get.status
    else
      faraday(link).head.status
    end
  rescue ::Faraday::Error
    nil
  end

  def needs_get?(link)
    GET_NOT_HEAD.any? do |domain|
      link.starts_with? %r{https?://#{domain}/}
    end
  end

  def ignored?(link)
    IGNORE.any? do |ignore|
      link.starts_with? %r{https?://#{ignore}/}
    end
  end
end
