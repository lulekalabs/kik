# Search filter to use in Advofinder lawyer search to compose the query 
class AdvocateSearchFilter < SearchFilter

  ALPHABET = %w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z Ä Ö Ü)

  #--- attributes
  attr_accessor :select_region
  attr_accessor :select_topic
  attr_accessor :alphabetic_filter
  # attr_accessor :province_code
  # attr_accessor :city_name

  #--- associations
  has_and_belongs_to_many :topics, :join_table => "search_filters_topics", :foreign_key => :search_filter_id
    
  #--- validations
  validates_presence_of :province_code, :if => Proc.new {|o| o.persist? && o.select_region == "province"}
  
  #--- callbacks
  before_save :set_from_select_accessors
  before_save :geocode_postal_code

  #--- instance methods
  
  # collects finder options as hash
  def finder_options(options={})
    clear_default_fields

    self.geocode_postal_code

    select = []
    select << "#{finder_table_name}.*"
    if self.sort_order && self.sort_order.include?("reviews_count")
      select << "(SELECT COUNT(*) FROM reviews WHERE reviews.reviewee_id = #{finder_table_name}.id AND reviews.status = #{quote_value('open')}) AS reviews_count"
    end
    if self.sort_order && self.sort_order.include?("review_recommendations_count")
      select << "(SELECT COUNT(*) FROM reviews WHERE reviews.reviewee_id = #{finder_table_name}.id AND reviews.friend_recommend = 1 AND reviews.status = #{quote_value('open')}) AS review_recommendations_count"
    end
    if self.sort_order && self.sort_order.include?("review_comments_count")
      select << "(SELECT COUNT(*) FROM comments " +
        "LEFT OUTER JOIN reviews ON comments.commentable_id = reviews.id AND comments.commentable_type = #{quote_value("ReviewComment")}" +
        "WHERE comments.type = #{quote_value("ReviewComment")} AND comments.commentable_id = reviews.id AND comments.commentable_type = #{quote_value("ReviewComment")} AND reviews.reviewee_id = #{finder_table_name}.id" +
        " AND reviews.status = #{quote_value('open')}) AS review_comments_count"
    end
    if self.sort_order && self.sort_order.include?("review_recommendation_rate")
      select << "(SELECT SUM(IF(reviews.friend_recommend = 1,1,0))/COUNT(*) FROM reviews WHERE reviews.reviewee_id = #{finder_table_name}.id AND reviews.status = #{quote_value('open')}) AS review_recommendation_rate"
    end
    if self.sort_order && self.sort_order.include?("review_comments_grade_average")
      select << "(SELECT AVG(comments.grade) FROM comments " +
        "LEFT OUTER JOIN reviews ON comments.commentable_id = reviews.id AND comments.commentable_type = #{quote_value("ReviewComment")}" +
        "WHERE comments.type = #{quote_value("ReviewComment")} AND comments.commentable_id = reviews.id AND comments.commentable_type = #{quote_value("ReviewComment")} AND reviews.reviewee_id = #{finder_table_name}.id" +
        " AND reviews.status = #{quote_value('open')}) AS review_comments_grade_average"
    end

    select = select.compact.reject(&:blank?).join(", ")
    order = self.sort_order || "#{finder_table_name}.created_at ASC"
    group = "#{finder_table_name}.#{primary_key}"

    and_conditions = []
    or_conditions = []
    and_conditions << self.sanitize_sql(["users.state IN (?)", ["active"]])
    and_conditions << self.sanitized_tags
    and_conditions << self.sanitized_topics
    and_conditions << self.sanitized_radius
    and_conditions << self.sanitized_person_name
    and_conditions << self.sanitized_alphabetic_filter
    or_conditions << self.sanitized_city
    or_conditions << self.sanitized_postal_code
    or_conditions << self.sanitized_province
    or_conditions << self.sanitized_province_code
    or_conditions = or_conditions.compact.reject(&:blank?).join(" OR ")
    or_conditions = "(#{or_conditions})" unless or_conditions.blank? 
    and_conditions = and_conditions.compact.reject(&:blank?).join(" AND ")
    conditions = [and_conditions, or_conditions].compact.reject(&:blank?).join(" AND ")

    # Note: we are adding a outer join on users here, to filter active advocates. Before we added
    # :user in the include below and using a finder with a named scope such as Advocate.visible.all.
    # This resulted in an error that is likely caused by ActiveRecord in combination with :select, 
    # named scopes and :include. In that case, what happened was that the select counter fields were
    # being ignored and the query did not run through anymore, throwing an error on the order statement
    # e.g. reviews_count.
    joins = []
    joins << "LEFT OUTER JOIN users ON users.person_id = people.id"
    joins = joins.compact.reject(&:blank?).join(" ")

    result = {:select => select, :order => order, :group => group, :conditions => conditions, :joins => joins,
      :include => [:reviews, :business_address, :topics]}.merge_finder_options(options)

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
  
  # check to see if we have an empty query
  def blank?
    result = true
    result &&= self.tag_list.blank? || self.tag_list.to_s == "Suchbegriffe" # hack around default field
    result &&= self.topics_count == 0
    result &&= self.city_and_postal_code.blank?
    result &&= self.radius.blank?
    result &&= (self.province.blank? || self.select_region != "all")
    result &&= self.person_name.blank?
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
      result << self.sanitize_sql(["#{finder_table_name}.bio LIKE ?", "%#{tag}%"])
      result << self.sanitize_sql(["#{finder_table_name}.company_name LIKE ?", "%#{tag}%"])
      result << self.sanitize_sql(["#{finder_table_name}.anglo_title_type LIKE ?", "%#{tag}%"])
      result << self.sanitize_sql(["#{finder_table_name}.anglo_title LIKE ?", "%#{tag}%"])
      result << self.sanitize_sql(["#{finder_table_name}.occupational_title LIKE ?", "%#{tag}%"])
      result << self.sanitize_sql(["#{finder_table_name}.professional_indemnity LIKE ?", "%#{tag}%"])
      result << self.sanitize_sql(["#{finder_table_name}.company_information LIKE ?", "%#{tag}%"])
    end
    result.blank? ? "" : "(#{result.join(" OR ")})"
  end
  
  def sanitized_topics
    topic_list = self.topics.reject(&:new_record?)
    unless topic_list.empty?
      tids = topic_list.map(&:id)
      self.sanitize_sql(["topics.id IN (?)", tids])
    else
      ""
    end
  end

  def sanitized_expertises
    topic_list = self.topics.reject(&:new_record?)
    unless topic_list.empty?
      tids = topic_list.map(&:id)
      self.sanitize_sql(["(#{finder_table_name}.primary_expertise_id IN (?) OR #{finder_table_name}.secondary_expertise_id IN (?) OR #{finder_table_name}.tertiary_expertise_id IN (?))", tids, tids, tids])
    else
      ""
    end
  end

  def sanitized_person_name
    list = tag_list(self.person_name)
    result = []
    list.each do |tag|
      result << self.sanitize_sql(["(#{finder_table_name}.first_name LIKE ? OR #{finder_table_name}.last_name LIKE ?)", "%#{tag}%", "%#{tag}%"])
    end
    result.join(" AND ")
  end
  
  def sanitized_alphabetic_filter
    unless self.alphabetic_filter.blank?
      self.sanitize_sql(["#{finder_table_name}.last_name LIKE ?", "#{self.alphabetic_filter}%"])
    else
      ""
    end
  end

  def sanitized_province_code
    unless self.province_code.blank?
      self.sanitize_sql(["#{finder_table_name}.province_code LIKE ? OR addresses.province_code LIKE ?", 
        self.province_code, self.province_code])
    else
      ""
    end
  end

  def sanitized_city
    unless self.city.blank?
      self.sanitize_sql(["addresses.city LIKE ?", "%#{self.city}%"])
    else
      ""
    end
  end
  
  def sanitized_postal_code
    if self.postal_code.to_i > 0
      self.sanitize_sql(["addresses.postal_code LIKE ?", "%#{self.postal_code}%"])
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
      self.sanitize_sql(["#{finder_table_name}.province_code = ? OR addresses.province_code = ?", 
        self.province_code, self.province_code])
    end
  end
  
  # make sure we have at least a default finder class
  def after_initialize
    super
    self.finder_class = Advocate unless @finder_class
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
