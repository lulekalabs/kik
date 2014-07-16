namespace :expertises do

  desc "Expertise from topic"
  task :fix => [:merb_env, :environment] do

    # Make all topics expertises
    Topic.all.each do |topic|
      topic.update_attribute(:type, "Expertise") unless topic.is_a?(Expertise)
    end
    
    # add Kein Fachanwalt
    if e = Topic.find_by_name("Kein Fachanwalt")
      e.update_attributes({:position => 0, :expertise_only => true})
    else
      e = Expertise.create(:name => "Kein Fachanwalt", :position => 0, :expertise_only => true)
      e.update_attributes({:position => 0, :expertise_only => true})
    end
    
  end

end
