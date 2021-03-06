class User < ActiveRecord::Base
  validate do
    return self.errors.add(:email, "can't be blank") if email.blank?
    unless email.match(/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
      self.errors.add(:email, "must be in the form user@server.com")
    end
  end
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  before_save :ensure_authentication_token

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :display_name, :private, :background, :twitter_name

  has_many :posts, dependent: :destroy
  has_many :text_posts
  has_many :link_posts
  has_many :image_posts
  has_many :authentications

  has_many :awards

  has_many :twitter_feed_items
  has_many :github_feed_items
  has_many :instagram_feed_items

  has_many :friendships
  has_many :friends, :through => :friendships

  has_many :active_friends,
                  :through => :friendships,
                  :source => :friend,
                  :conditions => {'friendships.status' => Friendship::ACTIVE }

  validates :display_name, :presence => true,
              :format => {
              :message => "Must only be letters, numbers, underscore or dashes",
                          :with => /^[a-zA-Z0-9_-]+$/
                          },
              :uniqueness => true

  mount_uploader :background, BackgroundUploader

  MAX_PROVIDERS = 3

  def relation_for(type)
    # child_type_for_name (pass type and get a symbol)
    type = type.gsub(/Item/i, "Post").underscore.pluralize.to_sym
    self.send(type).scoped rescue text_posts.scoped
  end

  def stream(limit, offset=0)
    items = gather_stream_items
    items = items.sort_by { |item| item.posted_at }.reverse
    items.slice(offset, offset + limit)
  end

  def gather_stream_items
    posts + twitter_feed_items + github_feed_items + instagram_feed_items
  end

  def background_image
    background.url || "dashboard.jpg"
  end

  def avatar
    Gravatar.new(self.email).image_url
  end

  def can_view_feed?(user)
    return true if user and (self == user or self.is_friend?(user))
    !self.private
  end

  def is_friend?(user)
    !Friendship.where(:friend_id => user.id, :user_id => self.id).first.nil?
  end

  def send_welcome_message
    UserMailer.welcome_message(self).deliver
  end

  def total_pages
    self.posts.size() / 12 + 1
  end

  def apply_omniauth(omniauth)
    case omniauth['provider']
    when 'twitter'
      self.apply_twitter(omniauth)
    end
    a = authentications.build(hash_from_omniauth(omniauth))
    a.inspect
  end

  def twitter
    auth = twitter_authentication
    if auth
      client = Twitter::Client.new(:oauth_token => auth.login,
                                   :oauth_token_secret => auth.secret)
    end
  end

  def can_award?(post, klass)
    award = self.awards.where(
      :awardable_id => post.id,
      :awardable_type => klass).first

    award == nil
  end

  def twitter_authentication
    self.authentications.where(:provider => 'twitter').first
  end

  def github_authentication
    self.authentications.where(:provider => 'github').first
  end

  def already_refeeded?(original_post)
    posts.where(original_post_id: original_post.original_post_id).any?
  end

  def instagram_authentication
    self.authentications.where(:provider => 'instagram').first
  end

  def get_authentication(provider, uid)
    authentications.find_or_create_by_provider_and_uid(provider, uid)
  end

  # def posts_by_friends
  #   active_friends.map { |friend| friend.posts() }.flatten.uniq
  # end

  private

  def apply_twitter(omniauth)
    if (extra = omniauth['extra']['user_hash'] rescue false)
      # Example fetching extra data. Needs migration to User model:
      # self.firstname = (extra['name'] rescue '')
    end
  end

  def hash_from_omniauth(omniauth)
    {
      :provider => omniauth['provider'],
      :uid => omniauth['uid'],
      :token => (omniauth['credentials']['token'] rescue nil),
      :secret => (omniauth['credentials']['secret'] rescue nil)
    }
  end

  def all_providers?
    authentications.count >= MAX_PROVIDERS
  end
end
