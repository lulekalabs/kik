# Sends search filter as digest or individually triggered by the question id
class KaseSearchFilterJob < Struct.new(:kase_id)
  
  def perform
    @kase = Kase.find(kase_id) if kase_id
    
    if @kase
      KaseSearchFilter.digest_immediately.each do |search_filter|
        send_digest(search_filter, @kase)
      end
    else
      KaseSearchFilter.digest_daily.undigested_since_yesterday.each do |search_filter|
        send_digest(search_filter)
      end
    end
  end

  protected
  
  def send_digest(search_filter, kase=nil)
    # find questions
    receiver = search_filter.person
    
    questions = if kase
      search_filter.with_query_scope do |query|
        query.open.since(search_filter.digested_at).find(:all, :conditions => ["kases.id = ?", kase.id])
      end
    else
      search_filter.with_query_scope do |query|
        query.open.since(search_filter.digested_at).created_chronological_descending.find(:all, :limit => 25)
      end
    end

    # send digest mail
    unless questions.empty?
      # SearchFilterMailer.deliver_digest(search_filter, questions)
      SearchFilterMailer.dispatch :digest, search_filter, questions
    end
    
    # update digested at
    search_filter.update_attributes({:digested_at => Time.now.utc})
  end
  
end