# frozen_string_literal: true

# UrlString::Shortener.new(original_url, url_counter).call
require 'base62'

module UrlString
  class Shortener
    attr_reader :original_url, :counter_number

    def initialize(original_url, counter_number)
      @counter_number = counter_number
      @original_url = original_url
    end

    def call
      return unless original_url.present?

      create_url
    end

    private

    def create_url
      url_hash_encoded = generate_unique_hash
      Url.create(url_hash: url_hash_encoded, original_url:)
    end

    def generate_unique_hash
      url_md5_encoded = md5_hash[0..7].hex
      url_md5_encoded.base62_encode
    end

    def md5_hash
      url = original_url + counter_number.to_i.to_s
      Digest::MD5.hexdigest(url)
    end
  end
end
