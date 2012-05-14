class TextPost < Post
  validates :content, :length => { :maximum => 512 }

  validate do
    self.errors[:base] << "Message is required" if self.content.blank?
  end

  def decorate
    TextPostDecorator.decorate(self)
  end

  def template
    "text_post"
  end
end