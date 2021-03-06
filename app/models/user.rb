class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  extend Enumerize
  include Shared::BeautifulText

  has_many :authorizations, dependent: :destroy
  has_and_belongs_to_many :events
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :communities
  has_and_belongs_to_many :expert_groups

  validates :name, presence: true
  before_validation do
    add_url_protocol_to(['facebook_url', 'twitter_url', 'google_plus_url', 'github_url', 'linkedin_url'])
  end

  mount_uploader :image, AvatarUploader

  acts_as_taggable

  beautiful_text_for [:bio]

  enumerize :profile_type, in: { user: 0, connector: 1, advisor: 2 }

  scope :connectors, ->{ where(profile_type: 1) }
  scope :advisors, ->{ where(profile_type: 2) }

  def self.new_with_session(params, session)
    super.tap do |user|
      if auth = session[:omniauth]
        user.email = auth.info.email if auth.info.email.present?
        user.name = auth.info.name
        user.remote_image_url = auth.info.image
        user.authorizations.build(provider: auth.provider, uid: auth.uid)
      end
    end
  end

  def update_image(url)
    unless self.image.present?
      self.remote_image_url = url if url.present?
      self.save!
    end
  end

  def avatar_url(size = 200)
    if size < 100
      return image.small if image.present?
    elsif size < 150
      return image.normal if image.present?
    else
      return image if image.present?
    end
    "http://gravatar.com/avatar/#{Digest::MD5.new.update(email)}.jpg?s=#{size}"
  end

  def is_admin?
    self.admin? || self.profile_type == 1
  end

  protected
  def add_url_protocol_to(field)
    if field.kind_of?(Array)
      field.each { |f| add_url_protocol_to(f) }
    else
      if self.send(field).present?
        self.send("#{field}=", "http://#{self.send(field)}") unless self.send(field)[/\Ahttp:\/\//] || self.send(field)[/\Ahttps:\/\//]
      end
    end
  end
end
