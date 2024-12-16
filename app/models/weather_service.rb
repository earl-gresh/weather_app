require 'uri'
require 'net/http'

class WeatherService

  extend CustomLogger
  include UriHandling

  class ApiAccessError < RuntimeError; end

  API_ACCESS = YAML.load_file("#{Rails.root}/config/weather_app.yml")
  API_URL    = API_ACCESS['weather_service_url']

  # Two queries to the api are required to retreive forcast data.
  # The first query returns a page of metadata with a property
  # called "forecast". The second query is a call to that endpoint..
  class << self
    def forecast_for(latitude:, longitude:)
      # First query to get the URL for forecast data
      forecast_api = fetch_metadata_for(latitude, longitude)

      # Second query to retreive the forecast
      fetch_forecast_from(forecast_api)
    end

    private

    def fetch_metadata_for(latitude, longitude)
      query = "#{latitude},#{longitude}"
      uri = build_uri_from(API_URL, query)

      log { "Fetching metadata from #{uri}" }
      response = fetch_uri(uri)

      # The returned URL to fetch the forecast from
      extract_metadata_from(response.body)
    end

    def extract_metadata_from(response_body)
      body_content = JSON.parse(response_body)
      check_for_empty_content(body_content)

      body_content.dig("properties", "forecast")
    end

    def fetch_forecast_from(forecast_api)
      uri = build_uri_from(forecast_api)

      log { "Fetching forecast from #{uri}" }
      response = fetch_uri(uri)

      # The forecast data itself
      extract_forecast_from(response.body)
    end

    def extract_forecast_from(response_body)
      body_content = JSON.parse(response_body)
      check_for_empty_content(body_content)

      body_content.dig("properties", "periods")
    end

    def check_for_empty_content(content)
      raise ApiAccessError, "Received empty response from API" if content.empty?
    end
  end
end
