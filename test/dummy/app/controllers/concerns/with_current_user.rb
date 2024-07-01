# frozen_string_literal: true

module WithCurrentUser
  extend ActiveSupport::Concern
  included do
    before_action :authenticate_user!
  end
  def authenticate_user!
    raise "not-authenticated" unless current_user
  end

  def current_user
    current_jwt_user(nil_on_failure: true) || (session[:current_user_id] && User.find(session[:current_user_id]))
  end

  def user_with(email:, id:)
    User.find_or_create_by!(id: id, email: email)
  end

  def extract_token_from(headers:)
    header = headers["Authorization"]
    header&.split(" ")&.last
  end

  def current_jwt_user(nil_on_failure: false)
    return nil unless request.authorization&.downcase&.start_with?("bearer ")

    token = extract_token_from(headers: request.headers)
    begin
      user = jwk_user_from(jwt: token)
      user_with(email: user[:email], id: user[:id])
    rescue ActiveRecord::RecordNotFound => e
      logger.error("User NOT found in DB, make sure to run Kafka consumer")
      return nil if nil_on_failure
      raise e
    rescue JWT::JWKError => e
      logger.error "ApplicationController current_jwt_user JWT::JWKError " + e.message
      return nil if nil_on_failure
      raise e
    rescue JWT::DecodeError => e
      logger.error "ApplicationController current_jwt_user JWT::DecodeError " + e.message
      return nil if nil_on_failure
      raise e
    end
  end

  def jwk_user_from(jwt:)
    jwk_loader = ->(options) do
      @cached_keys = nil if options[:invalidate] # need to reload the keys
      return @cached_keys if @cached_keys

      keycloak = ENV.fetch("KEYCLOAK_SERVER_URL", "http://localhost:8080")
      realm = ENV.fetch("KEYCLOAK_AUTH_CLIENT_REALM_NAME", "dummy")
      uri = URI("#{keycloak}/realms/#{realm}/protocol/openid-connect/certs")
      req = Net::HTTP::Get.new uri
      res = Rails.cache.fetch("jwk_loader-certs") do
        Net::HTTP.start(uri.host, uri.port, open_time: 1, read_timeout: 1, write_timeout: 1) { |http| http.request(req) }
      end
      unless res.is_a?(Net::HTTPSuccess)
        logger.warn res.body
        raise "JWKS #{uri} FAILED"
      end
      @cached_keys ||= JSON.parse(res.body)
    end

    decoded = JWT.decode(jwt, nil, !Rails.env.test?, {algorithms: ["RS256"], jwks: jwk_loader})

    email = decoded[0]["email"] || decoded[0]["preferred_username"]
    id = decoded[0]["sub"]
    logger.debug("found (email:#{email}, id: #{id})")
    {email: email, id: id}
  end



end