class Api::HotelsController < ApplicationController
  # GET /api/hotels/search
  def search
    client = BoomNowClient.new(params)
    render json: client.listings
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
