require 'system_helper'

describe 'The Front End', type: :system do
  include_context 'common'

  it 'Displays the form to enter a new address' do
    visit new_forecast_path

    expect(page).to have_text('Retreive Forecast For Street Address')
    expect(page).to have_field('street')
    expect(page).to have_field('city')
    expect(page).to have_field('state')
    expect(page).to have_field('zipcode')
  end

  describe 'When the form is filled in and submitted' do
    before do
      empty_forecast_cache

      visit new_forecast_path

      fill_in 'street', with: street_address.street
      fill_in 'city', with: street_address.city
      fill_in 'state', with: street_address.state
      fill_in 'zipcode', with: street_address.zipcode

      allow(Net::HTTP).to receive(:get_response).and_return(
        mocked_geocode_response,
        mocked_metadata_response,
        mocked_forecast_response
      )
    end

    it 'an address not in the cache will be inserted into the cache' do
      expect { click_button 'Show Forecast' }.to change { ForecastCache.cache.size }.by(1)
    end

    it 'it redirects to the show page' do
      click_button 'Show Forecast'

      expect(current_path).to eq(forecast_path(street_address.zipcode))

      expect(page).to have_text(period['name'])
      expect(page).to have_text(period['temperature'])
      expect(page).to have_text(period['windSpeed'])
      expect(page).to have_text(period['windDirection'])
      expect(page).to have_text(period['shortForecast'])
    end

    it 'it displays a "served from cache" notification when the zipcode is found in the cache' do
      ForecastCache.insert(id: street_address.zipcode, data: period)

      click_button 'Show Forecast'

      expect(page).to have_text('Served from cache')
    end

    describe 'And an Api error occurrs' do
      it 'a warning is displayed' do

        forecast_response_with_error = mocked_forecast_response

        allow(forecast_response_with_error).to receive(:code_type).and_return(Net::HTTPError)
        allow(forecast_response_with_error).to receive(:code).and_return(500)
        allow(forecast_response_with_error).to receive(:message).and_return("API Access Errror")

        # Override the forecast response with one exposing an error
        allow(Net::HTTP).to receive(:get_response).and_return(
          mocked_geocode_response,
          mocked_metadata_response,
          forecast_response_with_error
        )

        click_button 'Show Forecast'

        expect(page).to have_text('Something went wrong')
      end
    end
  end

  describe 'When the Show page is viewd for an expired entry' do
    it 'When the show page is viewed for an expired entry, the new page is rendered' do
      address = street_address
      ForecastCache.insert(id: address.zipcode, data: period)

      # Expire the entry just inserted
      ForecastCache.instance_eval do
        @cache[address.zipcode][:inserted_at] = epoch_time - (ForecastCache::CACHE_EXPIRY_SECONDS + 10)
      end

      visit forecast_path(address.zipcode)

      expect(current_path).to eq(new_forecast_path)
    end
  end
end
