require "acronyms"

module TemplateHandlers
  class Markdown
    attr_reader :template, :source, :options

    DEFAULTS = {}.freeze
    GLOBAL_FRONT_MATTER = Rails.root.join("config/frontmatter.yml").freeze

    class << self
      def call(template, source = nil)
        new(template, source).call
      end

      def global_front_matter
        @global_front_matter ||= begin
          if GLOBAL_FRONT_MATTER.exist?
            YAML.load_file GLOBAL_FRONT_MATTER
          else
            {}
          end
        end
      end
    end

    def initialize(template, source = nil, **options)
      @template = template
      @source = source.to_s

      @options = DEFAULTS.merge(options)
    end

    def call
      # inspect objects to Ruby strings which can be eval'd
      return %(#{render.inspect}.html_safe) if front_matter.empty?

      %(@front_matter = #{front_matter.inspect}; #{render.inspect}.html_safe)
    end

  private

    def render_markdown
      Kramdown::Document.new(markdown, { toc_levels: 1..2 }).to_html
    end

    def autolink_html(content)
      Rinku.auto_link content
    end

    def add_acronyms(content)
      Acronyms.new(content, front_matter["acronyms"]).render
    end

    def render
      add_acronyms autolink_html render_markdown
    end

    # rubocop:disable Style/PerlBackrefs
    def markdown
      # use $1 rather than a block argument here because gsub assigns the
      # entire placeholder to the arg (including dollar symbols) but we only
      # want what's inside the capture group

      parsed.content.gsub(/\$([A-z0-9-]+)\$/) { call_to_action($1) }
    end
    # rubocop:enable Style/PerlBackrefs

    def call_to_action(placeholder)
      component = Content::ComponentInjector.new(front_matter.dig("calls_to_action", placeholder)).component

      return unless component

      ApplicationController.render(component, layout: false)
    end

    def front_matter
      @front_matter ||= self.class.global_front_matter.deep_merge(parsed.front_matter)
    end

    def parsed
      @parsed ||= parser.call(source)
    end

    def parser
      FrontMatterParser::Parser.new(:md)
    end
  end
end
