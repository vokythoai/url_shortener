# frozen_string_literal: true

class UrlsController < ApplicationController
  def encode
    original_url = params[:original_url]
    # We should have a key generator service to creating a counter
    # Each request will have a unique counter to prevent hashing collistion
    # For demo purpose we use random number
    counter_number = SecureRandom.random_number(100_000_000_000)
    url = UrlString::Shortener.new(original_url, counter_number).call
    return render json: { short_link: nil, error_message: 'Invalid params' }, status: 500 unless url

    render json: { short_link: build_link(url.url_hash), error_message: nil }, status: :ok
  end

  def decode
    encoded_url = params['url']
    original_url = UrlString::Decoder.new(encoded_url).call
    return render json: { original_link: original_url }, status: :not_found unless original_url

    render json: { original_link: original_url }, status: :ok
  end

  private

  def get_url_hash(url)
    url.gsub!("#{ENV['domain']}/", '')
  end

  def build_link(url_hash)
    "#{ENV['domain']}/#{url_hash}"
  end
end
