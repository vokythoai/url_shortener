# frozen_string_literal: true

require 'rails_helper'

describe Cache::Lru, aggregate_failures: true do
  describe '#set' do
    before do
      Rails.cache.clear
    end

    it 'saves key value to cache' do
      cache_class = described_class.new
      cache_class.set('Thoai', 'Vo')

      expect(cache_class.container.size).to eq(1)
    end

    context 'when caching is reach limit' do
      it 'removes last element from cache' do
        cache_class = described_class.new

        key = 'Thoai'
        value = 'Vo'
        key2 = 'Thoai1'
        value2 = 'Vo1'
        100.times { cache_class.set(key, value) }
        cache_class.set(key2, value2)

        expect(cache_class.container.length).to eq(100)
      end
    end
  end

  describe '#get' do
    it 'returns a value which have key in cache' do
      cache_class = described_class.new
      cache_class.set('Thoai', 'Vo')
      cache_class.set('Thoai1', 'Vo1')

      expect(cache_class.get('Thoai')).to eq 'Vo'
      expect(cache_class.get('Thoai1')).to eq 'Vo1'
    end

    it 'moves selected element to index 0' do
      cache_class = described_class.new

      2.times { cache_class.set('Thoai', 'Vo') }
      4.times { cache_class.set('Thoai1', 'Vo1') }
      expect { cache_class.get('Thoai') }.to change { cache_class.container[0] }.from(%w[Thoai1 Vo1]).to(%w[Thoai Vo])
    end
  end
end
