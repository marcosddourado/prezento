class KalibroConfiguration < KalibroClient::Entities::Configurations::KalibroConfiguration
  include KalibroRecord
  attr_writer :attributes

  def self.public_or_owned_by_user(user=nil)
    kalibro_configuration_attributes = KalibroConfigurationAttributes.where(public: true)
    kalibro_configuration_attributes += KalibroConfigurationAttributes.where(user_id: user.id, public: false) if user

    kalibro_configuration_attributes.map { |kalibro_configuration_attribute|
      begin
        self.find(kalibro_configuration_attribute.kalibro_configuration_id)
      rescue Likeno::Errors::RecordNotFound
        nil
      end
    }.compact
  end

  def self.public
    self.public_or_owned_by_user
  end

  def self.latest(count = 1)
    all.sort { |one, another| another.id <=> one.id }.select { |kalibro_configuration|
      attributes = kalibro_configuration.attributes
      attributes && attributes.public
    }.first(count)
  end

  def attributes
    @attributes ||= KalibroConfigurationAttributes.find_by(kalibro_configuration_id: self.id)
  end

  def destroy
    attributes.destroy unless attributes.nil?
    @attributes = nil
    super
  end
end
