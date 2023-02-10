# frozen_string_literal: true

require 'rails_helper'

describe UrlString::Shortener, aggregate_failures: true do
  it 'creates new url record from user url input' do
    original_url = 'https://translate.google.com/?hl=vi'
    counter_number = 1
    url = described_class.new(original_url, counter_number).call

    expect(url.url_hash).to eq '48HuOl'
    expect(url.original_url).to eq 'https://translate.google.com/?hl=vi'
  end

  it 'increases Url.count by 1' do
    original_url = 'https://translate.google.com/?hl=vi'
    counter_number = 1

    expect { described_class.new(original_url, counter_number).call }.to change { Url.count }.by(1)
  end

  context 'When original url is blank' do
    it 'returns nil' do
      original_url = ''
      counter_number = 1
      result = described_class.new(original_url, counter_number).call

      expect(result).to be_nil
    end
  end

  context 'When original url is nil' do
    it 'returns nil' do
      original_url = nil
      counter_number = 1
      result = described_class.new(original_url, counter_number).call

      expect(result).to be_nil
    end
  end

  context 'When counter number is nil' do
    it 'creates new url record from user url input' do
      original_url = 'https://translate.google.com/?hl=vi'
      counter_number = nil
      url = described_class.new(original_url, counter_number).call

      expect(url.url_hash).to eq '31KNKY'
      expect(url.original_url).to eq 'https://translate.google.com/?hl=vi'
    end
  end

  context 'When has 2 requests with same original url and different counter number' do
    it 'creates 2 records url in database' do
      original_url = 'https://translate.google.com/?hl=vi'
      counter_number = 1
      described_class.new(original_url, counter_number).call

      counter_number = 2
      expect { described_class.new(original_url, counter_number).call }.to change { Url.count }.from(1).to(2)
    end
  end
end
