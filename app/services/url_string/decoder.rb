# frozen_string_literal: true

# UrlString::Decoder.new(url).call
module UrlString
  class Decoder
    attr_reader :url_hash

    def initialize(url_hash)
      @url_hash = url_hash
    end

    def call
      return unless url_hash.present?

      decode
    end

    private

    def decode
      encoded_url = get_url_hash(url_hash)

      cached_url = Cache::Lru.new.get(encoded_url)
      return cached_url if cached_url

      url = Url.find_by(url_hash: encoded_url)
      return unless url

      Cache::Lru.new.set(encoded_url, url.original_url)
      url.original_url
    end

    def get_url_hash(url)
      url.gsub!("#{ENV['domain']}/", '')
    end
  end
end
