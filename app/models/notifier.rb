# The mother of all mailer subclasses
class Notifier < ActionMailer::Base
  helper :notifier

  #--- accessors
  # set in environment.rb
  cattr_accessor :site_url

  cattr_accessor :signup_email
  cattr_accessor :admin_email
  cattr_accessor :info_email
  cattr_accessor :contact_email
  cattr_accessor :feedback_email
  cattr_accessor :newsletter_email
  cattr_accessor :press_email
  cattr_accessor :help_email
  cattr_accessor :search_filter_email
  cattr_accessor :message_email
  cattr_accessor :signaturportal_email
  attr_accessor :body_instances

  #--- class methods
  class << self
    
    # tries to return a regular email address from a pretty printed email
    #
    # e.g.
    #
    #   "John Smith <j@s.com>" -> "j@s.com"
    #
    def unprettify(email)
      email && email.match(/\<(.*)\>/) ? $1 : email
    end

    # Sends a mailer and creates a message that is readable inside the account/messages UI
    #
    # E.g.
    #
    #   CommentMailer.dispatch(:posted, @comment)
    #
    def dispatch(name, *args)
      mailer = send("instantiate_#{name}".to_sym, *args)
      mail = mailer.mail
      message = Email.create(:sender => mailer.body_instances[:sender], :sender_email => mailer.from,
        :receiver => mailer.body_instances[:receiver], :receiver_email => mail.to.to_a.flatten.first,
          :subject => mail.subject, :message => mail.body)
      message.deliver!
    end
    
    # override from Mailer to add instantiate
    #
    # E.g.
    #
    #   CommentMailer.instantiate_posted @comment
    #
    def method_missing(method_symbol, *parameters) #:nodoc:
      if match = matches_dynamic_method?(method_symbol)
        case match[1]
          when 'create'  then new(match[2], *parameters).mail
          when 'deliver' then new(match[2], *parameters).deliver!
          when 'instantiate' then new(match[2], *parameters)
          when 'new'     then nil
          else super
        end
      else
        super
      end
    end
    
    private
    
    # override to add "instantiate" option
    def matches_dynamic_method?(method_name) #:nodoc:
      method_name = method_name.to_s
      /^(create|deliver|instantiate)_([_a-z]\w*)/.match(method_name) || /^(new)$/.match(method_name)
    end
    
  end

  #--- instance methods

  # override ActionMailer to store instance variables, that would otherwise be overwritten
  def create!(method_name, *parameters) #:nodoc:
    initialize_defaults(method_name)
    __send__(method_name, *parameters)

    # If an explicit, textual body has not been set, we check assumptions.
    unless String === @body
      # First, we look to see if there are any likely templates that match,
      # which include the content-type in their file name (i.e.,
      # "the_template_file.text.html.erb", etc.). Only do this if parts
      # have not already been specified manually.
      if @parts.empty?
        Dir.glob("#{template_path}/#{@template}.*").each do |path|
          template = template_root["#{mailer_name}/#{File.basename(path)}"]

          # Skip unless template has a multipart format
          next unless template && template.multipart?

          @parts << Part.new(
            :content_type => template.content_type,
            :disposition => "inline",
            :charset => charset,
            :body => render_message(template, @body)
          )
        end
        unless @parts.empty?
          @content_type = "multipart/alternative" if @content_type !~ /^multipart/
          @parts = sort_parts(@parts, @implicit_parts_order)
        end
      end

      # Then, if there were such templates, we check to see if we ought to
      # also render a "normal" template (without the content type). If a
      # normal template exists (or if there were no implicit parts) we render
      # it.
      template_exists = @parts.empty?
      template_exists ||= template_root["#{mailer_name}/#{@template}"]
      
      # begin patch
      @body_instances = @body
      # end patch
      
      @body = render_message(@template, @body) if template_exists

      # Finally, if there are other message parts and a textual body exists,
      # we shift it onto the front of the parts and set the body to nil (so
      # that create_mail doesn't try to render it in addition to the parts).
      if !@parts.empty? && String === @body
        @parts.unshift Part.new(:charset => charset, :body => @body)
        @body = nil
      end
    end

    # If this is a multipart e-mail add the mime_version if it is not
    # already set.
    @mime_version ||= "1.0" if !@parts.empty?

    # build the mail object itself
    @mail = create_mail
  end
  
  # are we in advofinder?
  def advofinder_realm?
    @user ? @user.af_realm? : Project.af_realm?
  end
  alias_method :af_realm?, :advofinder_realm?
  helper_method :af_realm?
  helper_method :advofinder_realm?

  # are we in kik?
  def kik_realm?
    @user ? @user.kik_realm? : Project.kik_realm?
  end
  helper_method :kik_realm?

  def project_name
    @user ? @user.project_name : Project.name
  end

  def project_domain
    @user ? @user.project_domain : Project.domain
  end

  def project_host
    @user ? @user.project_host : Project.host
  end
  
  protected

  def setup_email(user)
    load_settings
    @from        = self.admin_email
    @sent_on     = Time.now
    @body[:user] = @user = user
  end
  
  def load_settings(site = Project.realm)
    config = YAML.load_file("#{RAILS_ROOT}/config/action_mailer.yml")
    if config && config[RAILS_ENV].is_a?(Hash)
      options = config[RAILS_ENV][site]
      if options.is_a?(Hash)
        # SMTP settings
        @@smtp_settings = {
          :address              => options["address"],
          :port                 => options["port"],
          :domain               => options["domain"],
          :authentication       => options["authentication"],
          :user_name            => options["user_name"],
          :password             => options["password"],
          :perform_deliveries   => options["perform_deliveries"].to_s =~ /^(true|1)/i ? true : false
        }

        # Default host for url helpers
        @@default_url_options[:host] = options["host"] || Project.host
        
        # Email settings
        @@site_url = options['site_url']
        @@signup_email = options['signup_email']
        @@newsletter_email = options['newsletter_email']
        @@admin_email = options['admin_email']
        @@contact_email = options['contact_email']
        @@feedback_email = options['feedback_email']
        @@press_email = options['press_email']
        @@help_email = options['help_email']
        @@search_filter_email = options['search_filter_email']
        @@message_email = options['message_email']
        @@signaturportal_email = options['signaturportal_email']
      end
    end
  end    
  
end
