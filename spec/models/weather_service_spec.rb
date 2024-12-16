require 'rails_helper'

RSpec.describe WeatherService do
  include_context 'common'

  it '.fetch_metadata_for returns metadata forecast URL from lat, lon' do
    latitude = mocked_geocode_response.lat
    longitude = mocked_geocode_response.lon

    allow(Net::HTTP).to receive(:get_response).and_return(mocked_metadata_response)

    forecast_url = WeatherService.instance_eval do
      fetch_metadata_for(latitude, longitude)
    end

    expect(forecast_url).to eq(mocked_metadata_response.forecast_url)
  end

  it '.fetch_forecast_from returns the forecast' do
    allow(Net::HTTP).to receive(:get_response).and_return(mocked_forecast_response)

    url = mocked_metadata_response.forecast_url
    periods = mocked_forecast_response.periods

    expect(
      WeatherService.instance_exec do
        fetch_forecast_from(url)
      end
    ).to eq(periods)
  end

  it '.forecast_for fetches from both the geocode and weather apis then returns the forecast' do
    latitude = mocked_geocode_response.lat
    longitude = mocked_geocode_response.lon

    allow(Net::HTTP).to receive(:get_response).and_return(
      mocked_metadata_response, mocked_forecast_response)

    forecast = WeatherService.forecast_for(latitude: latitude, longitude: longitude)

    expect(forecast).to eq(mocked_forecast_response.periods)
  end
end
