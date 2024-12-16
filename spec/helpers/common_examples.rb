RSpec.shared_examples 'instance method inclusion' do
  it 'should create a getter method for properties obtained from the API' do
    WeatherServiceProperties::FORECAST_PROPERTIES.each do |property|
      # this property is rewritten to 'precipitation'
      property = 'precipitation' if property == 'probabilityOfPrecipitation'

      expect(obj.respond_to?(property)).to be true
    end
  end
end
