# weather_app

## Synopsis
This is a Rails 8 App that provides a weather forecast based on a given street address. After the app is started, it can be accessed through a web browser. A form will be presented requiring the following fields:

- street address
- city
- state
- zipcode

After clicking the submit button, the address will be used as the basis to retrieve a local forecast and then displayed. Accessing the forecast for the same zipcode within a configurable amount of time will cause the weather forecast to be served from cache in lieu of re-fetching the data from weather services.

### Quickstart

After cloning the project to your system, install Rails and Gems:

`bundle install` 

Start the App.

`bundle exec rails s` 

Connect to the App from your browser.

`Connect to http://localhost/3000 OR http://127.0.0.1/3000` 

* If there's a port conflict on startup, it may be necessary to stop any other Apps that may be using that port or start up the App on a different port:

`rails s -p 5000` 

* Ruby versions 3.2 and 3.3 should work. Earlier versions are incompatible with Rails 8.

### Weather APIs

Many if not most weather APIs that I researched require the user to sign up with the service and obtain an API token to access their endpoint. In order to reduce that burden, I chose to use the National Weather Service's API because it offers token free access. The API requires both latitude and longitude components in order to generate a forecast. Additionally, once provided with those components, it requires an additional API query to retrieve the forecast from a URL provided by the first query. The forecast resolution pattern follows these steps:

1. Convert a given address into latitude and longitude components (aka Geocoding)
2. Query the National Weather Service's API for metadata based on those components.
3. Extract the URL from the metadata
4. Query the National Weather Service's API again using the extracted URL to get the forecast.

Note: Many online services provide an API to convert a street address into latitude and longitude components. I was unable to find a token free service and settled on [Geocoding API](http://geocode.maps.co) to achieve the first step in the process.

### Application Configuration

There are four settings configurable in the following file:

`config/weather_app.yaml` 

```Ruby
geocode_api_key: 
geocode_api_url: https://geocode.maps.co/search?
weather_service_url: https://api.weather.gov/points/
cache_expiration: 30
```
A working API token is included in this file to ensure a smooth experience. If you would prefer to register with the Geocode service and obtain your own API token, please make the setting adjustment. There should not be a reason to change either of the URLs. If you want to change the cache expiration for already completed queries, please change the cache_expiration variable to a different value (expressed in minutes).

### Controller Actions
There is a single controller to handle user facing interactions with three actions: new, create, and show.

The forecast controller initially renders a form for input and expects a street address, city, state, and zipcode. Submitting the form posts to the forecast controller's create action. A cache lookup is then conducted in the create action to potentially serve the forecast from cache. If not, API forecast resolution (steps 1-4 above) is followed to obtain the local forecast and insert it into the cache. A redirect to the controllers show action with the zipcode as a parameter causes the forecast data to be displayed.

### Models
The business logic of the App is broken out into five models.

#### street_address
Encapsulates the address given to the App.

#### forecast
The entry point into forecast resolution. It orchestrates calls to the geocode and weather_service models to access api endpoints, cache, and then return given forecast.

#### geocode
Responsible for translating the street address into latitude and longitude components by querying the Geocode service.

#### weather_service
Responsible for initiating a query to the National Weather Service's API to resolve the latitude and longitude components into intermediate metadata. The "forecast url" is extracted from the metadata and another query is issued to that URL endpoint to retrieve the actual forecast. The forecast is returned as fourteen "periods", with each period representing a time slice of six hours. In total, that provides a seven day forcast. Only the first "period", the most recent, is presented to the user.

#### forecast_cache
An in memory cache that stores entries by zipcode. When a new entry is inserted, the time of insertion is recorded as an epoch value (an absolute number representing the number of seconds since 01-01-1970). Comparisons against this value can be made to check if the cached zipcode is expired.

##### Model Concerns
Concerns are used for two reasons:

1. Share code between the geocode and weather_service model that make API requests.
2. Share code between the forecast and forecast_cache model to creates accessors to match the names of the weather service properties. For example, a cache entry will have a read accessor called "temperature" and "windSpeed" that maps to the returned values from the weather service.

### Routes
There are only three routes to interact with the forecast controller:

```Ruby  root "forecast#new"
  get "forecast/new" => "forecast#new", as: "new_forecast"
  get "forecast/:id" => "forecast#show", as: "forecast"
  post "forecast" => "forecast#create"
```
A fourth route for convenience directs an empty landing page to the "forecast/new" action.

`  root "forecast#new
` 
### Application Errors and Exceptions
Models are configured to raise API related errors. For example, when a request produces a valid HTTP 200 response but the API wasn't able to resolve the address to a forecast and provides and empty data payload. In addition, API errors such as connection timeouts or invalid requests are raised. These errors are rescued in the forecast controller to add a warning that something problematic happened and then re-render the input form.

### Tests
A suite of tests covering Models, Concerns, and Integrations are included. They can be executed by simply calling "bundle exec rspec".

#### Models
The two models responsible for handling forecast API access contain tests to validate their public facing API. Requests are made to the geocode and weather_service models, and the test mocks the returned data of the API call each model makes to a weather service endpoint.

The forecast model test validates the orchestration of the API resolution process. That is, a request is handed off to the geocode model, its return values are handed off to the weather_service model, the forecast is cached, and then handed back to the caller.

The forecast_cache model contains tests that validate cache insertion, expiration, and access.

The concern tests validate that code is properly shared between models.
#### System
The system integration tests simulate access from a user's perspective by making browser requests. These exercise the totality of the path of entering an address, clicking the submit button, and rendering a forecast.
