class Forecast
  include CustomLogger
  include WeatherServiceProperties

  class ApiAccessError < RuntimeError; end

  #   latitude and longitude:
  #     returned by the geolocating service and used to retrieve the weather
  #     forecast from the weather service
  #   id: saved for weather property lookup from the ForecastCache to
  #       access properties directly (in the getters)
  attr_accessor :latitude,  :longitude
  private       :latitude=, :longitude=

  def initialize(street_address: nil)
    # Retreive latitude/longitude to submit to the weather lookup service
    fetch_coordinates_for(street_address)

    # Using the coordinates returned, fetch the forecast
    forecast = fetch_forecast

    # The api returns a week's worth of data. Let's focus on the first phase.
    first_phase = forecast.first

    # Update ForecastCache
    ForecastCache.insert(id: street_address.zipcode, data: first_phase)

    self.id = street_address.zipcode
  end

  private

  def trim(json_forecast_body)
    JSON.parse(json_forecast_body).dig('properties', 'periods').first
  end

  def fetch_forecast
    log { "LAT: #{latitude} LONG: #{longitude}" }

    WeatherService.forecast_for(latitude: latitude, longitude: longitude)
  end

  def fetch_coordinates_for(street_address)
    coordinates = Geocode.coordinates_for(address: street_address)

    log { "Coordinates for #{street_address.zipcode}: #{coordinates.inspect}" }

    self.latitude  = coordinates['latitude']
    self.longitude = coordinates['longitude']

    return unless latitude.nil? || longitude.nil?

    message = "Invalid coordinates: Latitude: #{latitude.inspect}, " +
              "Longitude: #{longitude.inspect}"

    raise ForecastError, message
  end
end
