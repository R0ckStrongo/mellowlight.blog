#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Post-build check. Runs against _site after `jekyll build`, in CI and locally.
#
# The point is that a broken internal link or a missing meta description is
# invisible until a reader or Google finds it. This finds it first and fails
# the build, so nothing silently ships.
#
#   ruby script/check_build.rb

require "set"

SITE = File.expand_path("../_site", __dir__)

abort "No _site directory. Run `bundle exec jekyll build` first." unless Dir.exist?(SITE)

errors = []
warnings = []

html_files = Dir.glob(File.join(SITE, "**", "*.html"))
abort "No HTML in _site — did the build produce anything?" if html_files.empty?

# Every URL the site can actually serve.
available = Set.new
Dir.glob(File.join(SITE, "**", "*")).each do |path|
  next if File.directory?(path)

  rel = path.sub(SITE, "")
  available << rel
  available << File.dirname(rel) + "/" if File.basename(rel) == "index.html"
end
available << "/"

def rel_of(path)
  path.sub(SITE, "")
end

html_files.each do |file|
  html = File.read(file, encoding: "utf-8")
  page = rel_of(file)

  # --- internal links -------------------------------------------------------
  html.scan(/(?:href|src)="([^"]+)"/).flatten.each do |link|
    next if link.start_with?("http://", "https://", "//", "mailto:", "tel:", "#", "data:")

    target = link.split("#").first.split("?").first
    next if target.nil? || target.empty?
    next unless target.start_with?("/")

    unless available.include?(target) || available.include?(target + "index.html")
      errors << "#{page}: broken internal link -> #{target}"
    end
  end

  # --- images ---------------------------------------------------------------
  html.scan(/<img\b[^>]*>/).each do |tag|
    errors << "#{page}: <img> without alt" unless tag =~ /\balt=/
    unless tag =~ /\bwidth=/ && tag =~ /\bheight=/
      warnings << "#{page}: <img> without width/height (risks layout shift)"
    end
  end

  # --- malformed links ------------------------------------------------------
  # A Liquid `default` filter followed by more filters silently mangles URLs:
  # `x | default: y | append: '/z'` appends even when x was set, producing
  # /gallery.html/anfrage.html. External links are not otherwise checked here,
  # so this catches the class of bug that would never surface as a 404 locally.
  html.scan(/(?:href|src)="([^"]+)"/).flatten.each do |link|
    errors << "#{page}: malformed URL, path continues after .html -> #{link}" if link =~ %r{\.html/}
  end

  # --- metadata -------------------------------------------------------------
  # Redirect stubs and the feed have no business carrying article metadata.
  next if page.include?("/seite") || page.end_with?("404.html")

  errors << "#{page}: no <title>" unless html =~ /<title>[^<]+<\/title>/
  errors << "#{page}: no meta description" unless html =~ /<meta name="description" content="[^"]+"/
  errors << "#{page}: no canonical" unless html =~ /<link rel="canonical"/

  h1s = html.scan(/<h1[\s>]/).length
  errors << "#{page}: #{h1s} <h1> elements (expected exactly 1)" unless h1s == 1

  # --- structured data ------------------------------------------------------
  if (block = html[/<script type="application\/ld\+json">(.*?)<\/script>/m, 1])
    require "json"
    begin
      JSON.parse(block)
    rescue JSON::ParserError => e
      errors << "#{page}: invalid JSON-LD (#{e.message[0, 80]})"
    end
  end
end

# --- duplicate titles and descriptions --------------------------------------
# Two articles sharing a meta description is a self-inflicted SEO wound.
titles = Hash.new { |h, k| h[k] = [] }
descriptions = Hash.new { |h, k| h[k] = [] }

html_files.each do |file|
  html = File.read(file, encoding: "utf-8")
  next unless html =~ /<meta property="og:type" content="article"/

  titles[html[/<title>([^<]+)<\/title>/, 1]] << rel_of(file)
  descriptions[html[/<meta name="description" content="([^"]+)"/, 1]] << rel_of(file)
end

titles.each { |t, pages| errors << "duplicate <title> #{t.inspect} on #{pages.join(', ')}" if pages.length > 1 }
descriptions.each { |d, pages| errors << "duplicate description on #{pages.join(', ')}" if pages.length > 1 }

# --- required files ----------------------------------------------------------
%w[/sitemap.xml /feed.xml /robots.txt /search.json /404.html].each do |required|
  errors << "missing #{required}" unless File.exist?(File.join(SITE, required))
end

# --- report ------------------------------------------------------------------
warnings.uniq.each { |w| puts "  warn  #{w}" }
puts "  #{warnings.uniq.length} warning(s)" unless warnings.empty?

if errors.empty?
  puts "check_build: #{html_files.length} pages OK"
  exit 0
end

puts
errors.uniq.each { |e| puts "  ERROR #{e}" }
puts
puts "check_build failed with #{errors.uniq.length} error(s)."
exit 1
