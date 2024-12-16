require 'uri'
require 'net/http'

# Convert a street address into latitude and longitude
class Geocode
  include UriHandling
  extend CustomLogger

  API_ACCESS = YAML.load_file("#{Rails.root}/config/weather_app.yml")
  API_KEY    = API_ACCESS['geocode_api_key']
  API_URL    = API_ACCESS['geocode_api_url']

  class ApiAccessError < RuntimeError; end

  class << self
    def coordinates_for(address:)
      log { "Processing new forward geocode lookup for: #{address.inspect}" }

      encoded_query = URI.encode_www_form('q' => address.for_uri_encoding, 'api_key' => API_KEY)

      uri = build_uri_from(API_URL, encoded_query)

      response = fetch_uri(uri).body

      # Return a hash with latitude and longitude keys
      Hash['latitude', latitude(response), 'longitude', longitude(response)]
    end

    private

    def latitude(response)
      parse_body(response, 'lat')
    end

    def longitude(response)
      parse_body(response, 'lon')
    end

    def parse_body(response, value)
      body_content = JSON.parse(response)

      raise ApiAccessError, 'Received empty reponse from API' if body_content.empty?

      String(body_content.first[value].to_f.round(4))
    end
  end
end
