# frozen_string_literal: true

module Cache
  # Cache::Lru.new.set(key, value)
  class Lru
    attr_reader :container

    MAX_LENGTH = 100

    def initialize
      @container = Rails.cache.read('ShortUrl::least_recently_used') || []
    end

    def set(key, value)
      if @container.length < MAX_LENGTH
        container.unshift([key, value])
      else
        container.pop
        container.unshift([key, value])
      end

      Rails.cache.write('ShortUrl::least_recently_used', container, expires_in: 10.days.from_now)
    end

    def get(key)
      i = 0
      while i < container.length
        if container[i][0] == key
          data = container[i][1]
          container.insert(0, container.delete_at(i))
          return data
        end
        i += 1
      end
    end
  end
end
