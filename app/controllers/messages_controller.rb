class MessagesController < ApplicationController
  include MessagesHelper

  before_action :set_sender_and_message_type, only: :facebook_messenger
  
  def facebook_messenger
    verify_facebook_request
    message = Message.new(
      user: @sender,
      body: @messaging,
      category: find_category
    )
    if message.save
      render json: { success: true }, status: 200
    else
      render json: { success: false }, status: 100
    end
  end

  def tos; end

  def user_agreement; end

  protected

  def verify_facebook_request
    get_signature = request.headers['X-Hub-Signature'] 
    generate_signature = OpenSSL::HMAC.hexdigest(
      'sha1',
      ENV['FACEBOOK_APP_SECRET'],
      request.body.read
    )
    Rails.logger.debug "get_signature: #{get_signature}"
    Rails.logger.debug "generate_signature: sha1=#{generate_signature}"

    unless Rack::Utils.secure_compare(get_signature, "sha1=#{generate_signature}")
      Rails.logger.debug "Request has missmatch X-Hub-Signature header"
      render json: { success: false, message: 'This request wrong, try anoher one' }, status: 400
      return
    end
  end
  
  def set_sender_and_message_type
    @messaging = request.params[:entry][0][:messaging][0]
    @sender = User.find_or_create_by(facebook_id: @messaging[:sender][:id])
  end

  def find_category
    parse_body_for(postback) || parse_body_for(location) || parse_body_for(plaintext) || 'not_found'
  end

  def postback
    @messaging['postback'] && @messaging['postback']['payload']
  end

  def plaintext
    @messaging['message'] && @messaging['message']['text']
  end

  def location
    @messaging['message'] && @messaging['message']['attachments'] && @messaging['message']['attachments'][0]['type']
  end
 
  def check_fb_marker
    params.dig('hub.verify_token') == ENV['FACEBOOK_CONFIRMATION_MARKER']
  end

end