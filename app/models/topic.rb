# Topics are like expertises for lawyers, tagged with keywords, e.g. Agrarrecht
class Topic < ActiveRecord::Base

  #--- associations
  has_and_belongs_to_many :articles, :join_table => "articles_topics"
  has_and_belongs_to_many :kases, :join_table => "kases_topics"
  acts_as_list
  acts_as_taggable
  
  #--- scopes
  named_scope :visible, :conditions => ["topics.expertise_only = ? AND topics.topic_only = ?", false, true]
  named_scope :alphabetical, :order => "topics.name ASC"
  
  #--- class methods
  
  class << self
    
    def find_all_visible(options={})
      find(:all, {:conditions => ["topics.expertise_only != ?", true]}.merge_finder_options(options))
    end
    
  end
  
  #--- instance methods
  
  def tag_list_s=(string)
    self.tag_list = string
  end
  
  def tag_list_s
    self.tag_list.join(", ")
  end

end
