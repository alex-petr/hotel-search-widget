class Api::V1::HotelsController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'

  def search
    city = params[:city]
    adults = params[:adults] || 2

    # TODO: auth by API keys
    uri = URI("https://api.boomnow.com/search?city=#{city}&adults=#{adults}")
    response = Net::HTTP.get(uri)

    render json: JSON.parse(response)
  end
end
