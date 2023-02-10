# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UrlsController, type: :request do
  describe 'POST encode' do
    it 'returns a successful response' do
      post '/encode', params: { original_url: 'https://vnexpress.net/' }

      expect(response).to be_successful
    end

    context 'When params are invalid' do
      it 'returns errors status' do
        post '/encode', params: { original_url: '' }

        expect(response.status).to eq 500
      end
    end
  end

  describe 'POST decode' do
    it 'returns a successful response' do
      original_url = 'https://translate.google.com/?hl=vi'
      counter_number = 1

      url = UrlString::Shortener.new(original_url, counter_number).call
      url_hash = "#{ENV['domain']}/#{url.url_hash}"

      post '/decode', params: { url: url_hash }

      expect(response).to be_successful
    end

    context 'When link is not found' do
      it 'returns 404 error' do
        post '/decode', params: { url: 'https://vnexpress.net/' }

        expect(response.status).to eq 404
      end
    end

    context 'When params are invalid' do
      it 'returns original_url nil' do
        post '/decode', params: { url1: '' }

        body = JSON.parse(response.body)
        expect(response.status).to eq 404
        expect(body).to eq({ 'original_link' => nil })
      end
    end
  end
end
