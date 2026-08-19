# frozen_string_literal: true
#
# Mellowlight Journal — {% photos %} … {% endphotos %}
#
# Ein Bildblock mitten im Text. Die Autor:innen schreiben zwischen zwei
# Absätzen einfach:
#
#   {% photos %}
#   erster-blick.webp        | First Look vor der Trauung
#   * braut-portrait.webp    | Portrait der Braut in Schwarzweiß
#   torte.webp               | Tortenanschnitt | Kurz vor neun.
#   {% endphotos %}
#
#   Dateiname | ALT-Text | Bildunterschrift (optional)
#   Ein vorangestelltes *  gibt dem Bild die volle Spaltenbreite.
#
# Der Ordner kommt aus dem Front Matter (`photo_folder:`) oder direkt aus dem
# Tag: {% photos andere-hochzeit %}.
#
# Jeder Block wird für sich gesetzt. Das Raster aus ml_gallery.rb wird
# weiterverwendet, arbeitet aber ausschließlich innerhalb dieses einen Blocks —
# es fasst nichts mehr über den ganzen Artikel zusammen.

require "cgi"

module Mellowlight
  class PhotosTag < Liquid::Block
    # Passend zu den Spaltenbreiten, die das Raster erzeugt. Ein falscher
    # sizes-Wert ist der einfachste Weg, ein viel zu großes Bild zu laden.
    SIZES = {
      "solo-full"  => "(min-width: 64rem) 46rem, 100vw",
      "trio-row"   => "(min-width: 64rem) 15rem, (min-width: 40rem) 30vw, 50vw",
      "trio-stack" => "(min-width: 64rem) 28rem, 50vw"
    }.freeze
    SIZES_DEFAULT = "(min-width: 64rem) 23rem, 50vw"

    def initialize(tag_name, markup, options)
      super
      folder = markup.to_s.strip
      @folder = folder.empty? ? nil : folder
    end

    def render(context)
      site = context.registers[:site]
      page = context.registers[:page]
      lines = super.to_s.lines

      folder = @folder || page["photo_folder"]
      if folder.to_s.strip.empty?
        warn_for(page, "{% photos %} ohne Ordner — bitte `photo_folder:` im Front Matter setzen")
        return ""
      end

      base = File.join("/assets/images/posts", folder.to_s.strip).squeeze("/")
      images = lines.filter_map { |line| build_image(site, page, base, line) }
      return "" if images.empty?

      # Deterministisch, aber pro Block verschieden: zwei Blöcke mit derselben
      # Formatfolge sollen nicht identisch aussehen. Der Schlüssel hängt am
      # ersten Dateinamen, ist also unabhängig von der Renderreihenfolge.
      seed = "#{page['slug'] || page['url']}::#{images.first['full']}"

      blocks = Gallery.new(images, seed).blocks
      render_blocks(site, blocks)
    end

    private

    def build_image(site, page, base, raw)
      line = raw.strip
      return nil if line.empty?

      featured = false
      if line.start_with?("*")
        featured = true
        line = line[1..].to_s.strip
      end

      file, alt, caption = line.split("|", 3).map { |part| part.to_s.strip }
      return nil if file.nil? || file.empty?

      relative = File.join(base, file)
      unless File.file?(File.join(site.source, relative))
        warn_for(page, "Bild nicht gefunden: #{relative}")
        return nil
      end
      warn_for(page, "#{file} hat keinen ALT-Text") if alt.to_s.empty?

      width, height = ImageMeta.dimensions(File.join(site.source, relative))

      {
        "src"         => ImageMeta.fallback_src(site, relative),
        "full"        => relative,
        "srcset"      => ImageMeta.srcset(site, relative),
        "alt"         => alt.to_s,
        "caption"     => (caption.to_s.empty? ? nil : caption),
        "featured"    => featured,
        "width"       => width,
        "height"      => height,
        "ratio"       => width && height ? (width.to_f / height).round(4) : nil,
        "orientation" => ImageMeta.orientation(width, height)
      }
    end

    def render_blocks(site, blocks)
      out = +%(<div class="gallery gallery--inline" data-lightbox-gallery>)

      blocks.each do |block|
        type = block["type"]
        # Der randlose Blocktyp entfällt hier bewusst: er rechnet damit, dass
        # seine Spalte mittig im Fenster sitzt. Im Artikel steht die Textspalte
        # auf breiten Schirmen aber links der Mitte, ein 100vw-Bild liefe
        # dadurch um rund 140px versetzt aus dem Layout heraus.
        type = "solo-full" if type == "solo-bleed"

        sizes = SIZES.fetch(type, SIZES_DEFAULT)
        style = +"--cols: #{block['columns']};"
        style << " --cols-sm: #{block['columns_sm']};" if block["columns_sm"]

        out << %(<div class="gallery__block gallery__block--#{type}" style="#{style}">)
        block["images"].each { |image| out << figure(site, image, sizes) }
        out << "</div>"
      end

      out << "</div>"
      out
    end

    def figure(site, image, sizes)
      src  = url(site, image["src"])
      full = url(site, image["full"])
      alt  = CGI.escapeHTML(image["alt"].to_s)

      trigger = +%(<button class="gallery__trigger" type="button" data-lightbox )
      trigger << %(data-full="#{full}" )
      trigger << %(data-srcset="#{CGI.escapeHTML(image['srcset'])}" ) if image["srcset"]
      trigger << %(data-alt="#{alt}")
      if image["width"] && image["height"]
        trigger << %( data-width="#{image['width']}" data-height="#{image['height']}")
      end
      trigger << ">"

      img = +%(<img class="gallery__img" src="#{src}" )
      if image["srcset"]
        img << %(srcset="#{CGI.escapeHTML(image['srcset'])}" sizes="#{sizes}" )
      end
      img << %(alt="#{alt}" )
      img << %(width="#{image['width']}" height="#{image['height']}" ) if image["width"] && image["height"]
      img << %(loading="lazy" decoding="async">)

      html = +%(<figure class="gallery__figure">)
      html << trigger << img << "</button>"
      if image["caption"]
        html << %(<figcaption class="gallery__caption">#{CGI.escapeHTML(image['caption'])}</figcaption>)
      end
      html << "</figure>"
      html
    end

    def url(site, path)
      baseurl = site.config["baseurl"].to_s
      baseurl.empty? ? path : File.join(baseurl, path)
    end

    def warn_for(page, message)
      Jekyll.logger.warn "Mellowlight:", "#{page['path'] || page['url']}: #{message}"
    end
  end
end

Liquid::Template.register_tag("photos", Mellowlight::PhotosTag)
