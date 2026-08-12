source "https://rubygems.org"

# The Journal is built by GitHub Actions (see .github/workflows/build.yml),
# not by the classic GitHub Pages builder. That is deliberate: it lets us run
# the two small plugins in _plugins/ that read image dimensions and lay out
# photostories. Nothing here needs to appear on the Pages plugin whitelist.

gem "jekyll", "~> 4.3"

group :jekyll_plugins do
  gem "jekyll-archives", "~> 2.2"   # category and tag pages
  gem "jekyll-feed",     "~> 0.17"  # /feed.xml
  gem "jekyll-paginate", "~> 1.1"   # /seite/2/
  gem "jekyll-sitemap",  "~> 1.4"   # /sitemap.xml
  gem "jekyll-redirect-from"
end

gem "webrick", "~> 1.8", group: :development   # local `jekyll serve` on Ruby 3+

# _config.yml sets `timezone: Europe/Berlin`, so Jekyll needs a timezone
# database. Linux and macOS have one; Windows and JRuby do not, so they get
# it from a gem. The Actions runner is Linux and skips this entirely.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end
