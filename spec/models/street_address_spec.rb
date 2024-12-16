require 'rails_helper'

RSpec.describe StreetAddress, type: :model do

  include_context 'common'

  describe 'requires named parameters for initialization' do
    it 'street_address required' do
      expect do
        StreetAddress.new(
          city: locale1[:city],
          state: locale1[:state],
          zipcode: locale1[:zipcode]
        )
      end.to raise_error ArgumentError
    end

    it 'city required' do
      expect do
        StreetAddress.new(
          street: locale1[:street],
          state: locale1[:state],
          zipcode: locale1[:zipcode]
        )
      end.to raise_error ArgumentError
    end

    it 'state required' do
      expect do
        StreetAddress.new(
          street: locale1[:street],
          city: locale1[:city],
          zipcode: locale1[:zipcode]
        )
      end.to raise_error ArgumentError
    end

    it 'zipcode required' do
      expect do
        StreetAddress.new(
          street: locale1[:street],
          city: locale1[:city],
          state: locale1[:state]
        )
      end.to raise_error ArgumentError
    end
  end

  it '#for_uri_encoding requires argument order' do
    api_order = Array[locale1[:street], locale1[:city], locale1[:state], locale1[:zipcode]].join(' ')
    expect(api_order).to eq(StreetAddress.new(**locale1).for_uri_encoding)
  end
end
