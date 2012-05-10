class Post < ActiveRecord::Base
  attr_accessible :comment, :title, :content, :type, :file
  belongs_to :user
  mount_uploader :file, FileUploader
  
  validates_presence_of :user_id
  validates :comment, :length => { :maximum => 256 }
  validates_presence_of :content, :if => :validate_presence_of_content?
  
  def validate_presence_of_content?
    true
  end


  default_scope :order => 'created_at DESC'

  # def self.class_for(type)
  #   type.to_s.constantize rescue TextPost
  # end

end