require 'rails_helper'

Expiration = YAML.load_file("#{Rails.root}/config/weather_app.yml")['cache_expiration']

RSpec.describe ForecastCache do
  include_context 'common'

  before do
    # @cache is an instance variable of the class.
    # Ensure it's reset to empty between test runs
    empty_forecast_cache
  end

  it 'has an expiration defined in weather_app.yml multiplied by 60' do
    expect(ForecastCache::CACHE_EXPIRY_SECONDS).to eq(Expiration * 60)
  end

  it '.present returns false when an id is not in the cache' do
    expect(ForecastCache.instance_eval do
      present?(id: '55555')
    end).to be false
  end

  it '.insert adds a new entry to the cache' do
    ForecastCache.insert(id: '92101', data: { test: 'data' })
    expect(ForecastCache.cache.size).to eq(1)
  end

  it '.expired? returns false if the age of the item is less than the expiration' do
    ForecastCache.insert(id: '92101', data: { test: 'data' })
    expect(ForecastCache.instance_eval do
      expired?('92101')
    end).to be false
  end

  it '.expired? returns true if the age of the item is greater than the expiration' do
    ForecastCache.insert(id: '92101', data: { test: 'data' })

    expect(
      ForecastCache.instance_eval do
        @cache['92101'][:inserted_at] = epoch_time - (ForecastCache::CACHE_EXPIRY_SECONDS + 10)
        expired?('92101')
      end
    ).to be true
  end

  it '.create_from_cache returns a cache object' do
    ForecastCache.insert(id: '92101', data: { test: 'data' })
    cached = ForecastCache.create_from_cache(id: '92101')
    expect(cached.id).to eq('92101')
  end
end

# Weather properties returned by the API should be accessible as simple
# getter methods for any class that includes the WeatherServiceProperties module.
RSpec.describe 'Instance Method Inclusion' do
  include_examples 'instance method inclusion'

  let(:obj) do
    ForecastCache.insert(id: '92007', data: { test: 'data' })
    ForecastCache.create_from_cache(id: '92007')
  end
end
