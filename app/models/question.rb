# Subclass of Kase, represents a question
class Question < Kase

  @@active_questions_count = nil

  #--- class methods
  class << self

    def active_count
      @@active_questions_count || @@active_questions_count = count({})
    end
    
  end

  # active scaffold
  def to_s
    "#{self.class.human_name} #{self.number} \"#{self.summary}\""
  end

end