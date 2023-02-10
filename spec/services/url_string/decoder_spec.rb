# frozen_string_literal: true

require 'rails_helper'

describe UrlString::Decoder, aggregate_failures: true do
  it 'decodes hash url to original url' do
    original_url = 'https://translate.google.com/?hl=vi'
    counter_number = 1

    url = UrlString::Shortener.new(original_url, counter_number).call
    url_hash = "#{ENV['domain']}/#{url.url_hash}"
    decoded_original_url = described_class.new(url_hash).call
    expect(decoded_original_url).to eq original_url
  end

  context 'When url already decoded before and storing in cache' do
    it 'returns data from cache and does not query from db' do
      original_url = 'https://translate.google.com/?hl=vi'
      counter_number = 1

      url = UrlString::Shortener.new(original_url, counter_number).call
      url_hash = "#{ENV['domain']}/#{url.url_hash}"
      described_class.new(url_hash).call

      described_class.new(url_hash).call
      expect(Url).not_to receive(:find_by)
    end
  end
end
