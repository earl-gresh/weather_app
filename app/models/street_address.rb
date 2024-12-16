class StreetAddress
  attr_reader :street, :city, :state, :zipcode

  def initialize(street:, city:, state:, zipcode:)
    @street = street
    @city = city
    @state = state
    @zipcode = zipcode
  end

  # Joined attributes are used for URI encoding. Order required for API.
  def for_uri_encoding
    [street, city, state, zipcode].join(' ')
  end
end
