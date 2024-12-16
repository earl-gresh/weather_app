class ForecastCache
  include CustomLogger
  include WeatherServiceProperties

  APP_CONFIGURATION = YAML.load_file("#{Rails.root}/config/weather_app.yml")

  # Convert into seconds
  CACHE_EXPIRY_SECONDS = APP_CONFIGURATION['cache_expiration'] * 60

  @cache = {}

  create_getter_methods

  class << self
    attr_reader :cache

    def fetch(id:)
      # don't give back the real entry
      # otherwise the caller can change it
      cache[id].dup
    end

    def valid?(id:)
      present?(id) && !expired?(id)
    end

    def insert(id:, data:)
      cache[id] = { inserted_at: epoch_time, data: data }
    end

    def create_from_cache(id:)
      (valid?(id: id) && new(id)) || false
    end

    def cache_time_remaining_in_minutes(id)
      (CACHE_EXPIRY_SECONDS - cache_age_in_seconds(id)) / 60
    end

    private

    def epoch_time
      Time.now.strftime('%s').to_i
    end

    def present?(id)
      cache.has_key?(id)
    end

    def cache_age_in_seconds(id)
      inserted_at = cache.dig(id, :inserted_at)
      epoch_time - inserted_at
    end

    def expired?(id)
      cache_age_in_seconds(id) > CACHE_EXPIRY_SECONDS
    end
  end

  def initialize(id)
    self.id = id
  end
end
