class Api::HotelsController < ApplicationController
  # GET /api/hotels/search
  def search
    # Request to BoomNow API with token
    uri = URI("https://app.boomnow.com/open_api/v1/listings")
    # Forming a URI with query parameters (filters)
    uri.query = URI.encode_www_form(valid_query_params(params))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    # NOTE: To fix OpenSSL::SSL::SSLError SSL_connect returned=1 errno=0 peeraddr=104.26.11.65:443
    #  state=error: certificate verify failed (unable to get certificate CRL)
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.ca_file = "/usr/local/etc/openssl@3/cert.pem" if File.exist?("/usr/local/etc/openssl@3/cert.pem")

    request = Net::HTTP::Get.new(uri.path, {
      "Authorization" => "Bearer #{fetch_access_token}",
      "Accept" => "application/json"
    })

    response = http.request(request)

    render json: JSON.parse(response.body)
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def valid_query_params(params)
    city = params[:city].to_s.strip.presence
    adults = params[:adults].to_i
    adults = nil if adults <= 0

    { city: city, adults: adults }.compact
  end

  # Get authentication token from cache or create new
  # @return [String]
  def fetch_access_token
    Rails.cache.fetch("boom_now_access_token") do
      response_data = request_access_token

      # Calculating TTL for cache
      expire_at = response_data["expires_in"].to_i
      ttl = [ expire_at - Time.now.to_i - 60, 60 ].max # minimum 60 seconds

      Rails.cache.write("boom_now_access_token", response_data["access_token"], expires_in: ttl.seconds)

      response_data["access_token"]
    end
  end

  # Create and get authentication token
  # `expires_in` = now + 1 day
  # Example response JSON:
  # {
  #     "token_type": "Bearer",
  #     "expires_in": 1762881494,
  #     "access_token": "eyJhbGciOiJIU..."
  # }
  # @return [Object]
  def request_access_token
    uri = URI("https://app.boomnow.com/open_api/v1/auth/token")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    # NOTE: To fix OpenSSL::SSL::SSLError SSL_connect returned=1 errno=0 peeraddr=104.26.11.65:443
    #  state=error: certificate verify failed (unable to get certificate CRL)
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.ca_file = "/usr/local/etc/openssl@3/cert.pem" if File.exist?("/usr/local/etc/openssl@3/cert.pem")

    request = Net::HTTP::Post.new(uri.path, {
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    })

    request.body = {
      client_id: Rails.application.credentials.boom_now!.client_id!,
      client_secret: Rails.application.credentials.boom_now!.client_secret!
    }.to_json

    response = http.request(request)

    JSON.parse(response.body)
  end
end
