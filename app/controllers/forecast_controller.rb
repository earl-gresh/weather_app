class ForecastController < ApplicationController
  include CustomLogger

  def new; end

  def create
    street_address  = StreetAddress.new(**forecast_params)
    id              = street_address.zipcode

    unless ForecastCache.valid?(id: id)
      log { "Zipcode #{id} not cached, fetching new data" }
      Forecast.new(street_address: street_address)
      redirect_to forecast_path(id)

      return
    end

    log { "Zipcode #{id} found in cache" }
    minutes_remaining = ForecastCache.cache_time_remaining_in_minutes(id)
    redirect_to forecast_path(id), notice: minutes_remaining
  rescue => e
    # Catch API related errors and redirect to new form page
    raise unless e.class.to_s =~ /ApiAccessError/

    log { "API Error Detected" }
    log { e.message }
    log { e.class }

    redirect_to new_forecast_path, alert: "Something went wrong, please try again!"
  end

  def show
    id = params.require(:id)

    unless @forecast = ForecastCache.create_from_cache(id: id)
      redirect_to new_forecast_path
    end
  end

  private

  def forecast_params
    street, city, state, zipcode =
      params.require(%i[street city state zipcode])

    { street:, city:, state:, zipcode: }
  end
end
