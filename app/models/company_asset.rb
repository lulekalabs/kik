# Asset files belonging to lawyer, representing law office images
class CompanyAsset < Asset

  #--- associations
  has_attached_file :file,
    :storage => :filesystem,
    :styles => {:thumb => "80x80#", :normal => "300x200"},
    :url => "/images/application/imageuploads/:class/:attachment/:id/:style_:basename.:extension",
    :path => "#{"#{RAILS_ROOT}/public/"}images/application/imageuploads/:class/:attachment/:id/:style_:basename.:extension"

  #--- validations
  validates_attachment_size :file, :in => 1..3.megabyte
  validates_attachment_content_type :file, :content_type => Project.image_content_types

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