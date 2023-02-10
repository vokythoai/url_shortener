# frozen_string_literal: true

class Url < ApplicationRecord
  validates :url_hash, presence: true
  validates :original_url, presence: true
end
