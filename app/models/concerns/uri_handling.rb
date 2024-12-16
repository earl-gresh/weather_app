require 'uri'
require 'net/http'

module UriHandling
  extend ActiveSupport::Concern

  class ApiAccessError < RuntimeError; end

  module ClassMethods
    def build_uri_from(*components)
      URI( components.join('') )
    end

    def fetch_uri(uri)

      log { "Fetching api data from: #{uri}" }
      response = Net::HTTP.get_response(uri)

      unless response.code_type == Net::HTTPOK

        log { "Response code: #{response.code}"}
        log { "Response message: #{response.message}" }

        raise ApiAccessError, "Bad response code accessing #{uri}"
      end

      response
    end
  end
end
