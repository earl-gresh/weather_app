module WeatherServiceProperties
  extend ActiveSupport::Concern

  # Weather properties retuned by the weather service for presentation
  # to the client.
  included do
    attr_accessor :id
  end

  FORECAST_PROPERTIES = %w[
    name temperature temperatureUnit shortForecast detailedForecast
    windSpeed windDirection probabilityOfPrecipitation
  ]

  module ClassMethods

    # define forecast instance reader methods to make weather properties callable
    # as instance.property() (ex: foo.temperature)
    def create_getter_methods
      FORECAST_PROPERTIES.each do |property|
        if property == 'probabilityOfPrecipitation'
          define_method(:precipitation) do
            precipation = ForecastCache.fetch(id: id).dig(:data, property.to_s, 'value')

            # The API returns nil in absence of precipitation
            (precipitation ||= 0).to_s + ' percent'
          end
        else
          define_method(property) do
            ForecastCache.fetch(id: id).dig(:data, property.to_s)
          end
        end
      end
    end
  end
end
