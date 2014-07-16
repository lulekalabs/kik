# Provides a model for string representation so academic titles,
# such as Dr., Prof., Prof. Dr. etc.
class AcademicTitle < ActiveRecord::Base
  
  #--- class methods
  class << self
    
    def dr
      @@academic_title_dr ||= find_by_name('Dr.')
    end
    
    def prof
      @@academic_title_prof ||= find_by_name('Prof.')
    end
    
    def prof_dr
      @@academic_title_prof_dr ||= find_by_name('Prof. Dr.')
    end

    def no_title
      @@academic_title_no_title ||= find_by_name('kein Titel')
    end
    
  end
  
  #--- instance methods
  
  # returns the translated string
  def to_s
    self.name
  end
  
end
