module Admin::QuestionsHelper
  
  def topics_form_column(record, name)
    collection_select :record, :topics, Topic.visible.find(:all, :order => "topics.name ASC"), :id, :name, 
      {:selected => @record.topic_ids}, {:multiple => true, :name => 'record[topic_ids][]'}
  end
  
  # translates current state
  def status_column(record)
    result = record.human_current_state_name
    if record.closed? && record.client_cancel?
      result += " (Rechtsuchender: hat sich erledigt)"
    end
    result
  end

  def id_column(record)
    record.number
  end
  
  def comments_form_column(record, name)
    html = ""
#    html += '<iframe src="/admin/comments">'
#    html += render(:active_scaffold => "admin/comments", :constraints => {:commentable_id => record.id})
#    html += "</iframe>"
    html
  end

  def referrer_column(record)
    record.referrer? ? record.referrer_name : "-" 
  end

  def person_column(record)
    h(record.person.user.login)
  end
  
  def mandated_column(record)
    if record.mandated?
      if record.mandated =~ /^listed$/
        if record.mandated_advocate
          "Ja, #{link_to(h(record.mandated_advocate.title_and_name), admin_advocate_path(record.mandated_advocate))}"
        else
          # should not be the case as we assign an advocate
          "Ja, hmm, war da nochwas mit 'listed'...?"
        end
      elsif record.mandated =~ /^listed_response$/
        if record.mandated_advocate
          "Ja, #{link_to(h(record.mandated_advocate.title_and_name), admin_advocate_path(record.mandated_advocate))}"
        else
          # should not be the case as we assign an advocate
          "Ja, hmm, war da nochwas mit 'listed_response'...?"
        end
      elsif record.mandated =~ /^(1|true)/ || record.mandated == "unlisted"
        "Ja, keiner aus Liste"
      else
        # Did we forget a mandated state?
        record.mandated
      end
    else
      if record.mandated_advocate
        "Nein, aber Rechtsanwalt hat das Mandat als zugewiesen markiert #{link_to(h(record.mandated_advocate.title_and_name), admin_advocate_path(record.mandated_advocate))}"
      else
        "Nein"
      end
    end
  end

end
