require 'rails_helper'

RSpec.describe 'Geocode' do
  include_context 'common'

  it '.coordinates_for returns a hash with keys latitude and longitude' do
    allow(Net::HTTP).to receive(:get_response).and_return(mocked_geocode_response)
    coordinates = Geocode.coordinates_for(address: street_address)

    expect(coordinates).to eq({ 'latitude' => mocked_geocode_response.lat,
                                'longitude' => mocked_geocode_response.lon })
  end
end
