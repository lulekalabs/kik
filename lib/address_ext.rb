# extends acts_as_addressable address class
Address.class_eval do
  include DefaultFields
  
  #--- class variables
  @@middle_name_column = :middle_name

  #--- associations
  belongs_to :academic_title, :class_name => "::AcademicTitle"

  #--- advocate validations
  validates_presence_of :postal_code, :city, :street, :street_number,
    :if => Proc.new {|u| u.addressable.is_a?(Advocate) && [:business, :billing].include?(u.kind)}

  #--- postal code format
  validates_format_of :postal_code, :with => /^[0-9]{5}$/i, :message => I18n.t("activerecord.errors.messages.postal_code_format"),
    :if => Proc.new {|u| (u.addressable.is_a?(Journalist) || u.addressable.is_a?(Advocate)) && [:business, :billing].include?(u.kind)}
    
  #--- journalist validations
  validates_presence_of :city, :postal_code, :street, :street_number,
    :if => Proc.new {|u| (u.addressable.is_a?(Journalist) || u.addressable.is_a?(Advocate)) && [:business].include?(u.kind)}

  #--- generic country validation
  validates_presence_of :country_code, :if => Proc.new {|a| a.country.nil? &&
    [:personal, :business, :billing].include?(a.kind)}
  validates_presence_of :country, :if => Proc.new {|a| a.country_code.nil? &&
      [:personal, :business, :billing].include?(a.kind)}

  #--- class methods
  class << self

    # created new personal address
    def new_personal(attributes = {})
      defaults = { :kind => 'personal' } 
      attributes = attributes.merge(defaults).symbolize_keys    # defaults override attributes
      Address.new( attributes )
    end

    # creates new business address
    def new_business(attributes = {})
      defaults = { :kind => 'business' }
      attributes = attributes.merge(defaults).symbolize_keys    # defaults override attributes
      Address.new( attributes )
    end

    # creates new billing address
    def new_billing(attributes = {})
      defaults = { :kind => 'billing' } 
      attributes = attributes.merge(defaults).symbolize_keys    # defaults override attributes
      Address.new( attributes )
    end

    # string rep
    def kind_s
      kind ? "#{kind.to_s.humanize.downcase} address" : ''
    end

    # translated string rep
    def kind_t
      kind_s.t
    end
    
  end

  #--- instance methods
  
  def kind_s
    self.class.kind_s
  end
  
  def kind_t
    self.class.kind_t
  end
  
  # lookup country name from country code, but only if country name is not assigend
  def country
    @country_cache ||= self[:country] || if self.country_code
      if match = I18n.translate(:countries).map {|key, value| [key.to_s.upcase, value]}.find {|a| a[0] == self.country_code.upcase}
        @country_cache = match.last
      end
    end
  end
  
  # creates a name string 
  #
  # e.g.
  #
  #   Adam Smith
  #
  #  Note: if a name is not available, the username will be returned instead
  #
  def name
    result = []
    result << self.first_name
    result << self.last_name
    result.compact.map {|m| m.to_s.strip}.reject {|i| i.blank?}.join(' ')
  end

  # e.g. "Herr" or "Frau" or dative "Herrn" or "Frau"
  def salutation(dative=false)
    result = []
    if dative
      result << "Frau" if self.female?
      result << "Herrn" if self.male?
    else
      result << "Frau" if self.female?
      result << "Herr" if self.male?
    end
    result.compact.map {|m| m.to_s.strip}.reject {|i| i.blank?}.join(' ')
  end

  # e.g.
  #
  #   Herr Prof. Dr. Schmiedl   
  #   Herr Meier
  #
  def salutation_and_title_and_last_name(dative=false)
    result = []
    result << self.salutation(dative)
    result << self.academic_title.name if self.academic_title && self.academic_title != ::AcademicTitle.no_title
    result << self.last_name || (self.user ? self.user.login : "anonym")
    result.compact.map {|m| m.to_s.strip}.reject {|i| i.blank?}.join(' ')
  end

  # e.g.
  #
  #   Herr Prof. Dr. Arndt Schmiedl   
  #   Herr Peter Meier
  #
  def salutation_and_title_and_name(dative=false)
    result = []
    result << self.salutation(dative)
    result << self.academic_title.name if self.academic_title && self.academic_title != ::AcademicTitle.no_title
    result << self.first_name
    result << self.last_name
    result.compact.map {|m| m.to_s.strip}.reject {|i| i.blank?}.join(' ')
  end

  # e.g.
  #
  #   Prof.
  #
  def title
    result = []
    result << ::AcademicTitle.find(self.academic_title_id).name if self.academic_title_id && self.academic_title_id != ::AcademicTitle.no_title.id
    result.compact.map {|m| m.to_s.strip}.reject {|i| i.blank?}.join(' ')
  end

  # e.g.
  #
  #   Herr Prof.
  #
  def salutation_and_title(dative=false)
    result = []
    result << self.salutation(dative)
    result << self.title
    result.compact.map {|m| m.to_s.strip}.reject {|i| i.blank?}.join(' ')
  end

  # e.g.
  #
  #   Prof. Dr. Hans Schmiedl   
  #   Peter Meier
  #
  def title_and_name
    result = []
    result << self.title
    result << self.name
    result.compact.map {|m| m.to_s.strip}.reject {|i| i.blank?}.join(' ')
  end

  # returns true for female
  def female?
    self.gender == 'f'
  end

  # returns true for male
  def male?
    self.gender == 'm'
  end
  
  # province full name if in DB otherwise lookup from province_code if given
  def province
    unless self[:province]
      if self[:province_code]
        I18n.translate("provinces.#{"DE"}")[self[:province_code].to_sym]
      end
    else
      self[:province]
    end
  end
  
  # override from acts as addressable
  def to_s
    result = []
    result << self.street + (self.street_number ? " #{self.street_number}" : "")
    result << self.province_or_province_code
    result << self.postal_code
    result << self.city
    result << self.country_or_country_code
    result.compact.map {|m| m.to_s.strip }.reject {|i| i.empty? }.join(", ")
  end
  
end