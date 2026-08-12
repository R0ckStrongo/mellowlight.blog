# frozen_string_literal: true
#
# Mellowlight Journal — table of contents
#
# Builds the contents list from the article's own headings. Authors write
# Markdown; kramdown gives every heading an id; this reads them back out.
# Nobody maintains a list by hand, and it can never fall out of sync.
#
# Used in the article layout as:
#
#   {% assign show_toc = content | ml_show_toc %}
#   {% if show_toc %}{{ content | ml_toc }}{% endif %}
#
# (Liquid cannot take a filter inside an {% if %}, hence the assign.)

module Mellowlight
  module TocFilter
    # A contents list only earns its space on a long article. Below this many
    # sections the reader can just scroll (§22).
    MIN_HEADINGS = 4

    HEADING = %r{<h([23])[^>]*\sid="([^"]+)"[^>]*>(.*?)</h\1>}mi

    def ml_show_toc(html)
      return false if html.nil?

      headings(html).count { |level, _, _| level == 2 } >= MIN_HEADINGS
    end

    def ml_toc(html)
      items = headings(html)
      return "" if items.empty?

      list = items.map do |level, id, text|
        item_class = "toc__item toc__item--h#{level}"
        %(<li class="#{item_class}"><a class="toc__link" href="##{id}">#{text}</a></li>)
      end.join

      <<~HTML
        <nav class="toc" aria-labelledby="toc-heading">
          <h2 class="toc__heading eyebrow eyebrow--bare" id="toc-heading">Inhalt</h2>
          <ol class="toc__list">#{list}</ol>
        </nav>
      HTML
    end

    private

    def headings(html)
      html.to_s.scan(HEADING).map do |level, id, inner|
        [level.to_i, id, strip_markup(inner)]
      end
    end

    # Headings may contain <em>, <code> and the like. The contents list wants
    # the words only.
    def strip_markup(text)
      text.gsub(%r{<[^>]+>}, "").strip
    end
  end
end

Liquid::Template.register_filter(Mellowlight::TocFilter)
