# Search filter to use to compose the query and for pre-composed search queries
class KaseSearchFilter < SearchFilter

  #--- attributes
  attr_accessor :select_region
  attr_accessor :select_topic

  #--- associations
  has_and_belongs_to_many :topics, :join_table => "search_filters_topics", :foreign_key => :search_filter_id
    
  #--- validations
  validates_presence_of :province_code, :if => Proc.new {|o| o.persist? && o.select_region == "province"}
  
  #--- scopes
  named_scope :digest_immediately, :conditions => ["search_filters.digest = ?", 'i']
  named_scope :digest_daily, :conditions => ["search_filters.digest = ?", 'd']
  named_scope :digest_never, :conditions => ["search_filters.digest = ? OR search_filters.digest IS NULL", 'n']
  named_scope :undigested_since_yesterday, :conditions => ["(search_filters.digested_at IS NULL AND TIMESTAMPDIFF(DAY, search_filters.created_at , NOW()) >= 1) OR (search_filters.digested_at IS NOT NULL AND TIMESTAMPDIFF(DAY, search_filters.digested_at , NOW()) >= 1)"]
  
  #--- callbacks
  before_save :set_from_select_accessors
  before_save :geocode_postal_code

  #--- instance methods
  
  # collects finder options as hash
  def finder_options(options={})
    clear_default_fields

    select = "#{finder_table_name}.*"
    order = self.sort_order || "#{finder_table_name}.created_at ASC"
    group = "#{finder_table_name}.#{primary_key}"

    conditions = []
    conditions << self.sanitized_tags
    conditions << self.sanitized_topics
    conditions << self.sanitized_radius
    conditions << self.sanitized_province
    
    conditions = conditions.compact.reject(&:blank?).join(" AND ")

    result = {:select => select, :order => order, :group => group, :conditions => conditions,
      :include => :topics}.merge_finder_options(options)

    reset_default_fields
    result
  end
  
  # handles nested topic habtm attributes assignmens
  def topics_attributes=(attributes={})
    if attributes.is_a?(Hash)
      # e.g. [{:id=>""}, {:id=>""}, {:id=>""}]
      attributes.to_a.map(&:last).map(&:symbolize_keys).uniq.each do |tuple|
        if (topic_id = tuple[:id].to_i) > 0
          self.topics << Topic.find_by_id(topic_id) unless self.topics.map(&:id).include?(topic_id)
        end
      end
    end
  end

  def city_and_postal_code
    clear_default_fields
    result = [] 
    result << self.postal_code unless self.postal_code.to_i == 0
    result << self.city.titleize unless self.city.blank?
    result = result.join(" ")
    reset_default_fields
    result
  end

  def province(english=false)
    unless self.province_code.blank?
      I18n.translate("provinces.#{self.country_code}.#{self.province_code}")
    end
  end
  
  def country_code
    "DE"
  end
  
  def country
    "Germany"
  end
  
  # returns an array of tags
  def tag_list(tl=nil)
    #clear_default_fields
    delimiter = ","
    list = (tl || self.tags).to_s
    list.gsub!(/\"(.*?)\"\s*/) {result << $1; ""}
    list.gsub!(/\'(.*?)\'\s*/ ) {result << $1; ""}
    ['<', '>', '@', '$', ';'].reject {|u| u.index(delimiter.to_s.strip)}.each {|u| list.gsub!(u, '')}
    list = list.split(delimiter.to_s.strip)
    list = list.compact.map {|t| t.strip}.reject(&:blank?).uniq
    #reset_default_fields
    list
  end
  
  def topics_count
    self.topics.reject(&:new_record?).size
  end
  
  def blank?
    result = true
    result &&= self.tag_list.blank? || self.tag_list.to_s == "Suchbegriffe" # hack around default field
    result &&= self.topics_count == 0
    result &&= self.city_and_postal_code.blank?
    result &&= self.radius.blank?
    result &&= (self.province.blank? || self.select_region != "all")
    result
  end
  
  # view helper for select
  def select_region
    @select_region || if !self.province_code.blank?
      @select_region = "province"
    elsif !self.radius.blank?
      @select_region = "radius"
    else
      @select_region = "all"
    end
  end

  def select_topic
    @select_topic || if self.topics.reject(&:new_record?).empty?
      "all"
    else
      "some"
    end
  end
  
  def select_digest
    if self[:digest] == "d"
      "daily"
    elsif self[:digest] == "i"
      "immediately"
    elsif self[:digest] == "n"
      "never"
    else
      "never"
    end
  end

  def select_digest=(value)
    if value == "daily"
      self[:digest] = "d"
    elsif value == "immediately"
      self[:digest] = "i"
    elsif value == "never"
      self[:digest] = "n"
    else
      self[:digest] = "n"
    end
  end

  # returns true if the objec has been geo coded with lat/lng attributes
  def geo_coded?
    !!(self.lat && self.lng)
  end

  protected
  
  def sanitized_tags(tl=nil)
    list = tag_list(tl)
    result = []
    list.each do |tag|
      result << self.sanitize_sql(["#{finder_table_name}.summary LIKE ?", "%#{tag}%"])
    end
    result.join(" AND ")
  end
  
  def sanitized_topics
    topic_list = self.topics.reject(&:new_record?)
    unless topic_list.empty?
      self.sanitize_sql(["topics.id IN (?)", topic_list.map(&:id)])
    else
      ""
    end
  end
  
  # add radius finder conditions
  def sanitized_radius
    if self.select_region == "radius" && self.select_region != "province" && self.geo_coded?
      distance_sql = self.finder_class.distance_sql(GeoKit::LatLng.new(self.lat, self.lng))
      self.sanitize_sql(["#{distance_sql} <= ?", self.radius])
    end
  end  
  
  # search for provinces 
  def sanitized_province
    if self.select_region != "radius" && self.select_region == "province"
      self.sanitize_sql(["#{finder_table_name}.province_code = ?", self.province_code])
    end
  end
  
  # make sure we have at least a default finder class
  def after_initialize
    super
    self.finder_class = Kase unless @finder_class
    self.set_from_select_accessors
    self.sort_order = "#{self.finder_table_name}.created_at DESC" unless @sort_order
  end

  def set_from_select_accessors
    # clear topics
    if @select_topic == "all"
      self.topics.clear
    end
    
    # select region
    if @select_region == "radius"
      self.province_code = nil
      # self.postal_code = nil
    elsif @select_region == "province"
      self.radius = nil
    elsif @select_region == "all"
      self.province_code = nil
      self.radius = nil
      self.postal_code = nil
    end
    true
  end

  # geocode search filter based on postal code
  def geocode_postal_code
    if self.select_region == "radius" && self.postal_code && (!self.geo_coded? || !!self.changes.symbolize_keys[:postal_code])
      res = GeoKit::Geocoders::MultiGeocoder.geocode("#{self.postal_code}, DE")
      if res.success
        self.lat = res.lat
        self.lng = res.lng
      end
    end
  rescue GeoKit::Geocoders::GeocodeError => ex
    logger.error "Exception #{ex.message} caught when geocoding #{self.postal_code}, DE"
    return
  end
    
end
