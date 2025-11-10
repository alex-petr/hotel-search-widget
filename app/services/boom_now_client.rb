# BoomNow API integration
class BoomNowClient
  TOKEN_CACHE_KEY = "boom_now_access_token".freeze
  TOKEN_CACHE_MARGIN = 60 # seconds

  def initialize(params = {})
    @params = params
  end

  # GET /listings
  def listings
    uri = URI("https://app.boomnow.com/open_api/v1/listings")
    uri.query = URI.encode_www_form(valid_query_params)

    response = http_request(:get, uri) do |request|
      request["Authorization"] = "Bearer #{access_token}"
      request["Accept"] = "application/json"
    end

    JSON.parse(response.body)
  end

  private

  def valid_query_params
    city = @params[:city].to_s.strip.presence
    adults = @params[:adults].to_i
    adults = nil if adults <= 0

    { city: city, adults: adults }.compact
  end

  # Fetch cached token or request new
  def access_token
    Rails.cache.fetch(TOKEN_CACHE_KEY) do
      data = request_access_token
      ttl = [ data["expires_in"].to_i - Time.now.to_i - TOKEN_CACHE_MARGIN, TOKEN_CACHE_MARGIN ].max
      Rails.cache.write(TOKEN_CACHE_KEY, data["access_token"], expires_in: ttl.seconds)

      data["access_token"]
    end
  end

  def request_access_token
    uri = URI("https://app.boomnow.com/open_api/v1/auth/token")
    response = http_request(:post, uri) do |request|
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
      request.body = {
        client_id: Rails.application.credentials.boom_now.client_id,
        client_secret: Rails.application.credentials.boom_now.client_secret
      }.to_json
    end

    JSON.parse(response.body)
  end

  def http_request(method, uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.ca_file = "/usr/local/etc/openssl@3/cert.pem" if File.exist?("/usr/local/etc/openssl@3/cert.pem")

    request = case method
    when :get then Net::HTTP::Get.new(uri)
    when :post then Net::HTTP::Post.new(uri)
    else raise "Unsupported HTTP method: #{method}"
    end

    yield(request) if block_given?

    http.request(request)
  end
end
