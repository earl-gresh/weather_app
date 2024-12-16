require 'rails_helper'

RSpec.describe Forecast do
  include_context 'common'

  it 'Resolves a street address into a forecast' do
    empty_forecast_cache

    allow(Net::HTTP).to receive(:get_response).and_return(
      mocked_geocode_response,
      mocked_metadata_response,
      mocked_forecast_response
    )
    request = Forecast.new(street_address: street_address)

    expect(request.id).to eq(street_address.zipcode)
  end

  it 'Caches a newly completed request' do
    empty_forecast_cache

    allow(Net::HTTP).to receive(:get_response).and_return(
      mocked_geocode_response,
      mocked_metadata_response,
      mocked_forecast_response
    )

    expect { Forecast.new(street_address: street_address) }.to change { ForecastCache.cache.size }.by(1)
  end
end
