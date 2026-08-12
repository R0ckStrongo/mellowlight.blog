# frozen_string_literal: true
#
# Mellowlight Journal — related articles
#
# "Recent posts" is not a recommendation. This scores every other article
# against the one being read and keeps the best three, so a reader who has just
# finished a piece about timing at a registry office is offered the registry
# office location guide — not whatever happened to be published last week.
#
# Scoring, highest first:
#   same location        6   (a reader planning a Schweinfurt wedding wants Schweinfurt)
#   shared primary topic 5
#   each shared tag      3
#   secondary category   2
#   same article type    1
#
# Ties break towards the newer article. Anything scoring zero is dropped rather
# than padded out, so a lone article shows no related block at all instead of
# an irrelevant one.

module Mellowlight
  class RelatedGenerator < Jekyll::Generator
    safe true
    priority :low   # after categories and tags are resolved

    RELATED_COUNT = 3

    def generate(site)
      posts = site.posts.docs
      return if posts.length < 2

      posts.each do |post|
        scored = posts.filter_map do |other|
          next if other.url == post.url

          score = score_for(post, other)
          next if score.zero?

          [score, other.date.to_i, other]
        end

        best = scored.sort_by { |score, time, _| [-score, -time] }
                     .first(RELATED_COUNT)
                     .map(&:last)

        post.data["related_posts"] = best
      end
    end

    private

    def score_for(post, other)
      score = 0

      location = post.data["location"].to_s.downcase
      score += 6 if !location.empty? && other.data["location"].to_s.downcase == location

      post_cats  = Array(post.data["categories"])
      other_cats = Array(other.data["categories"])
      score += 5 if post_cats.first && post_cats.first == other_cats.first
      score += 2 * (post_cats.drop(1) & other_cats).length

      score += 3 * (Array(post.data["tags"]) & Array(other.data["tags"])).length

      score += 1 if post.data["type"] && post.data["type"] == other.data["type"]

      score
    end
  end
end
