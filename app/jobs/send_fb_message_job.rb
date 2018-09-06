class SendFbMessageJob < ApplicationJob
  queue_as :default

  # to simple message message_hash should be {text: 'Hello User!'}
  # allow to mady any API relted hash
  def perform(facebook_id, message_hash)
    HTTParty.post(
      "#{ENV['FB_API_PATH']}/me/messages",
      query: {
        access_token: ENV['FACEBOOK_MARKER_TESTIAMPOPUP_MESSENGER']
      },
      body: {
        recipient: { id: facebook_id },
        message: message_hash
      },
      headers: { 'Content-Type' => 'application/json' }
    )
  end
end