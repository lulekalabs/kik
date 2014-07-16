# Manages file attachments 
class Asset < ActiveRecord::Base

  #--- constants
  MAXIMUM_FILE_SIZE_IN_KB       = 2048

  #--- associations
  belongs_to :person
  belongs_to :assetable, :polymorphic => true

  #--- validations
  validates_presence_of :assetable

  #--- class methods
  class << self

    # Returns the extension in lowercase, like "doc", "ppt", etc.
    def file_ext(filename)
      File.extname(filename).gsub(".", "") rescue nil
    end

    # "Lorem Ipsum.pdf" returns "Lorem Ipsum"
    def file_name_without_ext(filename)
      parse_file_name(filename)[1] rescue nil
    end

    # true for image content types, e.g. "image/jpeg"
    def image?(content_type)
      Project.image_content_types.include?(content_type)
    end
    
    # all other content type other than images, e.g. "application/msword"
    def none_image?(content_type)
      (Project.file_asset_content_types - Project.image_content_types).include?(content_type)
    end

    private
    
    # returns array for filename, like "/public/images", "lebenslauf", "doc"
    def parse_file_name(filename)
      dir = File.dirname(filename.to_s)
      name = File.basename(filename.to_s).gsub(File.extname(filename.to_s), "")
      ext = File.extname(filename.to_s).gsub(".", "")
      return [dir, name, ext]
    end

  end

  #--- instance methods

  def empty?
    self.file?
  end
  alias_method :blank?, :empty?
  
  # Is this asset an image?
  def image?
    self.class.image?(self.file.content_type)
  end

  # returns true if attachment is not an image
  def none_image?
    self.class.none_image?(self.file.content_type)
  end
  
  # accessor for paperclip column
  def file?
    self.file.file?
  end

  # accessor for paperclip column
  def file_name
    self.file_file_name
  end

  # accessor for paperclip column
  def file_size
    self.file_file_size
  end
  
  # accessor for paperclip column
  def content_type
    self.file_content_type
  end
  
  # e.g. "doc", "ppt", etc.
  def file_ext
    self.class.file_ext(self.file_name) if self.file?
  end

  # e.g. "my_great_file"
  def file_name_without_ext
    self.class.file_name_without_ext(self.file_name)
  end
  
  protected
  
  def after_initialize
    self.person = self.assetable.person if !self.person && self.assetable && self.assetable.respond_to?(:person)
  end
  
  def file_image?
    !(file_content_type =~ /^image.*/).nil?
  end
  
end
