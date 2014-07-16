# Handles messages for advocates
class Advocate::Account::MessagesController < Advocate::Account::AdvocateAccountApplicationController
  
  #--- filters
  before_filter :set_search_filter_state, :only => :unread
  before_filter :load_messages, :only => [:index, :unread]
  
  #--- actions
  
  def index
  end
  
  def show
    @message = Message.find(params[:id])
    @message.read_by!(current_user.person)
    respond_to do |format|
      format.html { render :template => "advocate/account/messages/show" }
      format.js { render :nothing => true }
    end
  end
  
  def unread
    render :template => "advocate/account/messages/index"
  end

  protected
  
  def load_messages
    @search_filter = MessageSearchFilter.new((@search_filter_state || params[:search_filter] || {}).symbolize_keys.merge({
      :finder_class => Message, :person => logged_in? ? current_user.person : nil}))

    #scoped = @search_filter.scoped
    @search_filter.with_finder_class_scope do
      @messages = current_user.person.received_messages.all.paginate(:page => params[:page] || 1, :per_page => @search_filter.per_page || 15)
      @messages_count = @messages.size
    end
  end
  
  def set_search_filter_state
    @search_filter_state = {:state => "unread"}
  end
  
end
