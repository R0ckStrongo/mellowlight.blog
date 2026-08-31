# frozen_string_literal: true
#
# Mellowlight Journal — image metadata
#
# Reads real pixel dimensions straight out of the image file header.
# No ImageMagick, no libvips, no gems: just the first 64 bytes of the file.
# That keeps the GitHub Actions build fast and dependency-free.
#
# It also assembles the responsive `srcset` from the sibling export folders
# the authors already produce (webp-800 / webp-1200 / webp-2000), and quietly
# degrades to the original file when a derivative has not been exported yet.

module Mellowlight
  module ImageMeta
    # The sizes script/make_image_sizes.sh produces. Chosen from the widths the
    # photographs are actually displayed at in an article, not from round
    # numbers: a trio row shows each picture at ~232px, a pair at ~358px, and a
    # full-width picture at 736px — doubled for retina screens, that is roughly
    # 460 / 720 / 1470.
    #
    # A size larger than the original is never generated and never listed, so
    # adding 1400 here costs nothing while your files stay 1000px wide.
    DERIVATIVES = [400, 700, 1000, 1400].freeze

    # Anything wider than this ratio counts as landscape, narrower as portrait.
    PORTRAIT_MAX = 0.9
    LANDSCAPE_MIN = 1.15

    @cache = {}

    class << self
      # --- dimensions -------------------------------------------------------

      # Returns [width, height] or nil if the format is not recognised.
      def dimensions(absolute_path)
        return @cache[absolute_path] if @cache.key?(absolute_path)

        @cache[absolute_path] = read_dimensions(absolute_path)
      end

      def read_dimensions(path)
        return nil unless File.file?(path)

        head = File.binread(path, 64).to_s
        return webp(head) if head[0, 4] == "RIFF" && head[8, 4] == "WEBP"
        return png(head)  if head[0, 8] == "\x89PNG\r\n\x1a\n".b
        return jpeg(path) if head[0, 2] == "\xFF\xD8".b

        nil
      rescue StandardError => e
        Jekyll.logger.warn "Mellowlight:", "could not read dimensions of #{path} (#{e.message})"
        nil
      end

      # WebP comes in three flavours and each stores its size differently.
      def webp(b)
        case b[12, 4]
        when "VP8X"                                    # extended
          [le24(b[24, 3]) + 1, le24(b[27, 3]) + 1]
        when "VP8 "                                    # lossy
          [b[26, 2].unpack1("v") & 0x3FFF, b[28, 2].unpack1("v") & 0x3FFF]
        when "VP8L"                                    # lossless
          n = b[21, 4].unpack1("V")
          [(n & 0x3FFF) + 1, ((n >> 14) & 0x3FFF) + 1]
        end
      end

      def png(b)
        [b[16, 4].unpack1("N"), b[20, 4].unpack1("N")]
      end

      # JPEG needs a walk through the marker segments to find the frame header.
      def jpeg(path)
        File.open(path, "rb") do |io|
          io.seek(2)
          while (marker = io.read(2))
            break unless marker.getbyte(0) == 0xFF

            code = marker.getbyte(1)
            length = io.read(2).unpack1("n")
            # SOF0..SOF15, excluding the DHT/JPG/DAC markers that share the range
            if code.between?(0xC0, 0xCF) && ![0xC4, 0xC8, 0xCC].include?(code)
              io.read(1) # sample precision
              return io.read(4).unpack("nn").reverse # [width, height]
            end
            io.seek(length - 2, IO::SEEK_CUR)
          end
        end
        nil
      end

      def le24(bytes)
        bytes.unpack1("C") | (bytes.unpack("C3")[1] << 8) | (bytes.unpack("C3")[2] << 16)
      end

      # --- orientation ------------------------------------------------------

      def orientation(width, height)
        return "L" unless width && height && height.positive?

        ratio = width.to_f / height
        return "P" if ratio < PORTRAIT_MAX
        return "L" if ratio > LANDSCAPE_MIN

        "S"
      end

      # --- responsive sources ----------------------------------------------

      # Builds the srcset from whichever derivative folders actually exist.
      # `relative` is e.g. "/assets/images/posts/standesamt-hassfurt/foo.webp"
      def srcset(site, relative)
        dir  = File.dirname(relative)
        file = File.basename(relative)

        sources = DERIVATIVES.filter_map do |w|
          candidate = File.join(dir, "webp-#{w}", file)
          next unless File.file?(File.join(site.source, candidate))

          "#{candidate} #{w}w"
        end
        return nil if sources.empty?

        sources.join(", ")
      end

      # The file the browser falls back to: mid-size derivative if present,
      # otherwise the original the author dropped in.
      def fallback_src(site, relative)
        dir  = File.dirname(relative)
        file = File.basename(relative)
        mid  = File.join(dir, "webp-1200", file)
        File.file?(File.join(site.source, mid)) ? mid : relative
      end
    end
  end

  # Hero images get the same responsive treatment as gallery images, worked out
  # from the file itself. Authors write `image:` and nothing else — the
  # srcset and the real pixel dimensions are never typed by hand (§9, §17).
  class HeroImageGenerator < Jekyll::Generator
    safe true
    priority :high    # must run before anything reads these values

    def generate(site)
      (site.posts.docs + site.pages).each do |doc|
        hero = doc.data["image"]
        next if hero.nil? || hero.to_s.start_with?("http")

        absolute = File.join(site.source, hero)
        unless File.file?(absolute)
          Jekyll.logger.warn "Mellowlight:", "#{doc.relative_path}: image not found at #{hero}"
          next
        end

        width, height = ImageMeta.dimensions(absolute)
        doc.data["image_width"]  ||= width
        doc.data["image_height"] ||= height
        doc.data["image_srcset"] ||= ImageMeta.srcset(site, hero)

        if doc.data["image_alt"].to_s.strip.empty?
          Jekyll.logger.warn "Mellowlight:", "#{doc.relative_path}: image has no alt text"
        end
      end
    end
  end
end
