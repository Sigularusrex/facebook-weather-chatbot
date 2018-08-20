class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :facebook_id, type: Integer
  field :first_name, type: String
  field :last_name, type: String
  field :profile_pic, type: String
  field :long, type: String
  field :lat, type: String
  field :daily_weather_report, type: Boolean

  field :current_temperature, type: Float
  field :current_temperature_update_at, type: DateTime
  field :current_location_name, type: String

  embeds_many :messages

  after_create :data_from_facebook
  after_update :weather_from_api, if: :temperature_need_to_updated?

  def data_from_facebook
    GetUserInfoFromFbJob.perform_later(self)
  end

  def fb_info_path
    "#{ENV['FB_API_PATH']}/#{facebook_id}?access_token=#{ENV['FACEBOOK_MARKER_TESTIAMPOPUP_MESSENGER']}" 
  end

  def send_messsage_to_user_path
    "#{ENV['FB_API_PATH']}/me/messages?access_token=#{ENV['FACEBOOK_MARKER_TESTIAMPOPUP_MESSENGER']}"
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def subscribe_weather_report!
    user.update(daily_weather_report: true)
  end

  def unsubscribe_weather_report!
    user.update(daily_weather_report: false)
  end
    
  def temperature_need_to_updated?
    ( lat.present? && long.present? ) && (
      ( current_temperature.blank? || current_temperature_update_at < Time.now - 10.minutes) || 
      ( lat_changed? || long_changed? ) 
    )
  end

  def weather_from_api
    response = HTTParty.get(
      "#{ENV['WEATHER_API_PATH']}?lat=#{self.lat}&lon=#{self.long}&APPID=#{ENV['WEATHER_KEY']}",
      headers: { 'Content-Type' => 'application/json' }
    )
    temperature = (response['list'].last['main']['temp'].to_f - 273.15).round(2)
    self.update(
      current_temperature: temperature,
      current_temperature_update_at: Time.now,
      current_location_name: response['city']['name']
    )
    temperature
  end

end
