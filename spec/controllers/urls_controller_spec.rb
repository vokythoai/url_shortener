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
      post '/decode', params: { url: 'https://vnexpress.net/' }

      expect(response).to be_successful
    end

    context 'When params are invalid' do
      it 'returns original_url nil' do
        post '/decode', params: { url1: '' }

        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body).to eq({ 'original_link' => nil })
      end
    end
  end
end
