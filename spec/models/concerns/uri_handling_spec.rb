require 'rails_helper'

# Test the instance methods defined in ::UriHandling::ClassMethods
include UriHandling::ClassMethods

RSpec.describe UriHandling, type: :model do

  # for let(:locale1)
  include_context 'common'

  let(:address) { StreetAddress.new(**locale1) }
  let(:encoded_for_uri) { address.for_uri_encoding }
  let(:encoded_query) { URI.encode_www_form("q" => encoded_for_uri, "api_key" => "test_api_key") }

  it '.build_uri_from joins together its arguments to create a properly formatted URI' do
    expect { build_uri_from(encoded_query) }.not_to raise_error
  end

  it '.fetch_uri does not raise an ApiAccessError when the response is Net::HTTPOK ' do
    response = double('response', code_type: Net::HTTPOK)

    allow(Net::HTTP).to receive(:get_response).and_return(response)

    expect { fetch_uri(encoded_query) }.not_to raise_error
  end

  it '.fetch_uri raises an ApiAccessError when an API response is not Net::HTTPOK' do
    response = double('geocode_response', code_type: Net::HTTPError, code: 500, message: "Server Error" )

    allow(Net::HTTP).to receive(:get_response).and_return(response)

    expect { fetch_uri(encoded_query) }.to raise_error( ::UriHandling::ApiAccessError )
  end
end
