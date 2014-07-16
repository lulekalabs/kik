class SearchFilterMailer < Notifier

  # trac #381
  def digest(search_filter, questions=nil)
    setup_email(search_filter, questions)
    @subject    = "#{search_filter.person.title_and_name}, Ihr persönlicher kann-ich-klagen.de Fragen-Radar!"
  end
  
  protected
  
  def setup_email(search_filter, questions=nil, receiver=nil, sender=nil)
    load_settings
    receiver            = receiver || search_filter.person
    @recipients         = receiver
    @from               = self.search_filter_email
    @subject            = "#{self.site_url} "
    @sent_on            = Time.now
    @body[:receiver]    = receiver
    @body[:search_filter] = search_filter

    # query all questions based on the search filter or use given questions for the digest list
    questions ||= @search_filter.with_query_scope do |query|
      query.open.since(@search_filter.digested_at).created_chronological_descending.find(:all, :limit => 25)
    end
    @body[:questions]   = questions
  end
    
end
