# All assets (images, etc.) belonging to a Question
class AttachedAsset < Asset
  
  #--- associations
  has_attached_file :file,
    :storage => :filesystem,
    :styles => {:thumb => "80x80#", :profile => "75x200>", :article => "80x200>"},
    :url => "/images/application/imageuploads/:class/:attachment/:id/:style_:basename.:extension",
    :path => "#{"#{RAILS_ROOT}/public/"}images/application/imageuploads/:class/:attachment/:id/:style_:basename.:extension"

  #--- validations
  validates_attachment_size :file, :in => 1..3.megabyte
  validates_attachment_content_type :file, :content_type => Project.file_asset_content_types

  #--- callbacks
  before_file_post_process :file_image?

  #--- instance methods

  def file_with_details=(f)
    if self.name.blank? && self.file? && (fn = self.file_name_without_ext)
      self.name = fn.humanize.titleize
    end
    self.file_without_details=(f)
  end
  alias_method_chain :file=, :details
  
end