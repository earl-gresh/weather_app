require 'rails_helper'

class WeatherServiceTest
  include WeatherServiceProperties

  create_getter_methods
end

# Weather properties returned by the API should be accessible as simple
# getter methods for any class that includes the WeatherServiceProperties module.
describe 'Instance Method Includion' do
  let(:obj) { WeatherServiceTest.new }

  include_examples 'instance method inclusion'
end
