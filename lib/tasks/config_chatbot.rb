# frozen_string_literal: true

namespace :config_chatbot do
  desc 'Setup chatbot get started & menu'
  task get_started: :environment do
    HTTParty.post(
      "#{ENV['FB_API_PATH']}me/messenger_profile",
      query: {
        access_token: ENV['FACEBOOK_MARKER_TESTIAMPOPUP_MESSENGER']
      },
      body: {
        get_started: {
          payload: 'get_started'
        },
        persistent_menu: [
          {
            locale: 'default',
            composer_input_disabled: false,
            call_to_actions: [
              {
                title: 'Weather Report',
                type: 'postback',
                payload: 'weather_report'
              },
              {
                title: 'Edit Locationt',
                type: 'postback',
                payload: 'edit_location'
              }
            ]
          }
        ]
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end
end