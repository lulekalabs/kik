# Host model for articles, blogs, lexcial entries (dictionary)
class Article < ActiveRecord::Base
  include DefaultFields
  
  attr_accessor :assigned
  attr_accessor :view
  
  #--- associations
  belongs_to :person, :class_name => "Person", :foreign_key => :person_id
  has_and_belongs_to_many :topics, :join_table => "articles_topics"
  
  has_attached_file :image, 
    :storage => :filesystem,
    :styles => {:thumb => "80x80#", :profile => "75x200>", :article => "80x200>"},
    :url => "/images/application/imageuploads/:class/:attachment/:id/:style_:basename.:extension",
    :path => "#{"#{RAILS_ROOT}/public/"}images/application/imageuploads/:class/:attachment/:id/:style_:basename.:extension"

  has_attached_file :primary_attachment,
    :storage => :filesystem,
    :styles => {:thumb => "80x80#", :profile => "75x200>", :article => "80x200>"},
    :url => "/images/application/imageuploads/:class/:attachment/:id/:style_:basename.:extension",
    :path => "#{"#{RAILS_ROOT}/public/"}images/application/imageuploads/:class/:attachment/:id/:style_:basename.:extension"

  has_attached_file :secondary_attachment,
    :storage => :filesystem,
    :styles => {:thumb => "80x80#", :profile => "75x200>", :article => "80x200>"},
    :url => "/images/application/imageuploads/:class/:attachment/:id/:style_:basename.:extension",
    :path => "#{"#{RAILS_ROOT}/public/"}images/application/imageuploads/:class/:attachment/:id/:style_:basename.:extension"

  acts_as_taggable

  #--- validations
  validates_presence_of :person
  validates_presence_of :title, :body
  validates_attachment_size :image, :in => 1..1.megabyte
  validates_attachment_content_type :image, :content_type => Project.image_content_types

  validates_attachment_size :primary_attachment, :in => 1..3.megabyte
  validates_attachment_content_type :primary_attachment, :content_type => Project.file_asset_content_types
  validates_attachment_size :secondary_attachment, :in => 1..3.megabyte
  validates_attachment_content_type :secondary_attachment, :content_type => Project.file_asset_content_types
  
  #--- scopes
  named_scope :editable, :conditions => ["articles.status IN (?)", ["created", "published", "suspended"]]
  named_scope :published, :conditions => {:status => "published"}
  named_scope :press_release, :conditions => {:press_release => true}
  named_scope :not_press_release, :conditions => ["articles.press_release = ?", false]
  named_scope :press_review, :conditions => {:press_review => true}
  named_scope :not_press_review, :conditions => ["articles.press_review = ?", false]
  named_scope :faq, :conditions => {:faq => true}
  named_scope :not_faq, :conditions => ["articles.faq = ?", false]
  named_scope :law_article, :conditions => {:law_article => true}
  named_scope :not_law_article, :conditions => ["articles.law_article = ?", false]
  named_scope :blog, :conditions => {:blog => true}
  named_scope :not_blog, :conditions => ["articles.blog = ?", false]
  named_scope :dictionary, :conditions => {:dictionary => true}
  named_scope :not_dictionary, :conditions => ["articles.dictionary = ?", false]
  named_scope :kik_view, :conditions => {:kik_view => true}
  named_scope :advofinder_view, :conditions => {:advofinder_view => true}
  named_scope :client_view, :conditions => {:client_view => true}
  named_scope :advocate_view, :conditions => {:advocate_view => true}
  named_scope :created_chronological_descending, :order => "articles.created_at DESC"
  named_scope :created_chronological_ascending, :order => "articles.created_at ASC"
  named_scope :published_chronological_descending, :order => "articles.published_at DESC"
  named_scope :published_chronological_ascending, :order => "articles.published_at ASC"
  
  #--- state machine
  acts_as_state_machine :initial => :created, :column => :status
  state :created
  state :published, :enter => :do_publish
  state :suspended
  state :deleted, :enter => :do_delete

  event :publish do
    transitions :from => :created, :to => :published
  end
  
  event :suspend do
    transitions :from => [:created, :published], :to => :suspended
  end
  
  event :delete do
    transitions :from => [:created, :published, :suspended], :to => :deleted
  end

  event :unsuspend do
    transitions :from => :suspended, :to => :published,   :guard => Proc.new {|u| !u.published_at.blank?}
    transitions :from => :suspended, :to => :created
  end
  
  #--- callbacks
  before_primary_attachment_post_process :primary_attachment_image?
  before_secondary_attachment_post_process :secondary_attachment_image?
  
  #--- class methods
  
  class << self
    
    # type casts to the class specified in :type parameter
    #
    # E.g.
    #
    #   a = Article.new(:type => :blog_post)  ->  BlogPost.new
    #   a = Article.new(:type => "DictionaryEntry")
    #
    def new_with_cast(*a, &b)  
      if (h = a.first).is_a? Hash and (type = h[:type] || h['type']) and 
        (k = type.class == Class ? type : (type.class == Symbol ? klass(type) : type.constantize)) != self
        raise "type not descendent of Article" unless k < self  # klass should be a descendant of us  
        return k.new(*a, &b)  
      end  
      new_without_cast(*a, &b)  
    end  
    alias_method_chain :new, :cast

    # returns class for symbol, e.g. :article -> Article
    def klass(kind=nil)
      [BlogPost, DictionaryEntry, PressRelease].each do |sc|
        return sc if kind && sc.name.underscore.to_sym == kind.to_sym
      end
      Article
    end
    
    # returns the finder options to find articles by topic name
    def find_options_for_find_by_topic_name(name, options={})
      {
        :conditions => ["topics.name LIKE ?", name],
        :joins => "LEFT OUTER JOIN articles_topics ON articles_topics.article_id = articles.id " +
          "LEFT OUTER JOIN topics ON topics.id = articles_topics.topic_id",
        :group => "articles.id"
      }.merge_finder_options(options)
    end

    # returns {2009=>[10, 11], 2010=>[1]} for building archive
    def archive_range(articles)
      times = articles.map(&:created_at).compact
      years = times.map(&:year).uniq
      result = {}
      years.each do |year|
        months = times.select {|t| t >= Time.parse("01/01/#{year}") && t <= Time.parse("01/01/#{year}").end_of_year}.map(&:month).uniq
        result[year] = months unless months.empty?
      end
      result
    end
    
  end
  
  #--- instance methods
  
  def author_name 
    self[:author_name] || (self.person ? self.person.name : nil)
  end  
  
  def tag_list_s=(string)
    self.tag_list = string
  end
  
  def tag_list_s
    self.tag_list.join(", ")
  end
  
  # is an image assigned?
  def image?
    self.image.file?
  end
  
  # name of primary attachment, if none is user assigned, infer from file name
  def primary_attachment_name
    self[:primary_attachment_name] || (self.primary_attachment.file? ? Asset.file_name_without_ext(self.primary_attachment_file_name) : nil)
  end

  # name of secondary attachment, if none is user assigned, infer from file name
  def secondary_attachment_name
    self[:secondary_attachment_name] || (self.secondary_attachment.file? ? Asset.file_name_without_ext(self.secondary_attachment_file_name) : nil)
  end

  # true if has attachment?
  def attachments?
    self.primary_attachment.file? || self.secondary_attachment.file?
  end
  
  def assets?
    self.attachments? || self.image?
  end
  
  def assigned?
    !!@assigned
  end
  
  protected
  
  def do_publish
    self.published_at = Time.now.utc
  end
  
  def do_delete
    self.deleted_at = Time.now.utc
  end

  def primary_attachment_image?
    !(primary_attachment_content_type =~ /^image.*/).nil?
  end

  def secondary_attachment_image?
    !(secondary_attachment_content_type =~ /^image.*/).nil?
  end
  
end
