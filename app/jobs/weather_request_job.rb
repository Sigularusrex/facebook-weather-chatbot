class WeatherRequestJob < ApplicationJob
  queue_as :default

  def perform(facebook_id, need_send)
    user = User.find_by(facebook_id: facebook_id)
    response = JSON.parse HTTParty.get(
      ENV['WEATHER_API_PATH'],
      query: {
        lat: user.lat,
        lon: user.long,
        'APPID': ENV['WEATHER_KEY']
      },
      headers: { 'Content-Type' => 'application/json' }
    ).body

    #Rails.logger.debug "Get weather for User: #{user.id} response: #{response}"
    #Rails.logger.debug "test str: #{response['cod']}"

    if response['cod'].to_i == 200
      new_temperature = (response['main']['temp'].to_f - 273.15).round(2)
      user.update_temperature(new_temperature, response['name'])
      user.weather_message!(new_temperature, response['name']) if need_send
    else
      SendFbMessageJob.perform_later(
        facebook_id,
        { text: I18n.t('bot.cant_get_weather_data') }
      )
    end
  end

end