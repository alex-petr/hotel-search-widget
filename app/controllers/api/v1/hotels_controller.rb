class Api::V1::HotelsController < ApplicationController
  # GET /api/v1/hotels/search
  def search
    Rails.logger.debug "=> search" # TODO: remove debug

    # Receive a token
    token_data = fetch_auth_token

    return render json: token_data # TODO: remove debug JSON.parse(token_data)

    city = params[:city]
    adults = params[:adults] || 2

    # TODO: auth by API keys
    uri = URI("https://api.boomnow.com/search?city=#{city}&adults=#{adults}")
    response = Net::HTTP.get(uri)

    render json: JSON.parse(response)
  end

  private

  # Get authentication token from cache or create new
  # @return [String]
  def fetch_auth_token
    Rails.logger.debug "=> fetch_auth_token" # TODO: remove debug

    Rails.cache.fetch('boom_now_access_token') do
      response_data = request_auth_token

      # Calculating TTL for cache
      expire_at = response_data['expires_in'].to_i
      ttl = [expire_at - Time.now.to_i - 60, 60].max # minimum 60 seconds

      Rails.cache.write('boom_now_access_token', response_data['access_token'], expires_in: ttl.seconds)

      response_data['access_token']
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
  def request_auth_token
    Rails.logger.debug "=> request_auth_token" # TODO: remove debug

    uri = URI('https://app.boomnow.com/open_api/v1/auth/token')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    # NOTE: To fix OpenSSL::SSL::SSLError SSL_connect returned=1 errno=0 peeraddr=104.26.11.65:443
    #  state=error: certificate verify failed (unable to get certificate CRL)
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    # Specify the path to system certificates
    http.ca_file = '/usr/local/etc/openssl@3/cert.pem' if File.exist?('/usr/local/etc/openssl@3/cert.pem')

    request = Net::HTTP::Post.new(uri.path, {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    })

    request.body = {
      client_id: Rails.application.credentials.boom_now!.client_id!,
      client_secret: Rails.application.credentials.boom_now!.client_secret!
    }.to_json

    response = http.request(request)

    JSON.parse(response.body)
  end
end
