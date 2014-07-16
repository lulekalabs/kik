ActionController::Routing::Routes.draw do |map|

  map.resource :session, :as => "sitzung"
  map.resources :users, :as => "benutzer", :only => [], :path_names => {:forgot_password => "passwort-vergessen", :create_new_password => "neues-passwort-erstellen", :forgot_password_complete => "neues-passwort-erstellt",
      :change_password => "passwort-aendern", :update_change_password => "geaendertes-passwort-speichern", :complete_change_password => "passwort-geaendert"},
    :collection => {:forgot_password => :get, :create_new_password => :post, :forgot_password_complete => :get, :change_password => :get, :update_change_password => :put, :change_password_complete => :get}, 
    :member => {}

  #=== admin application
  map.namespace :admin do |admin|
    admin.resource :session
    admin.resource :users, :only => [], :collection => {:forgot_password => :get, :create_new_password => :post, :forgot_password_complete => :get}
    admin.with_options :active_scaffold => true do |admin_with_scaffold|

      admin_with_scaffold.resources :admin_users, :controller => 'admin_users', :member => {
        :toggle_suspend   => :post
      }
      admin_with_scaffold.resources :users, :controller => 'users', :member => {
        :toggle_suspend   => :post,
        :activate         => :post,
        :approve          => :post
      }
      admin_with_scaffold.resources :people
      admin_with_scaffold.resources :clients
      admin_with_scaffold.resources :journalists
      admin_with_scaffold.resources :advocates, :member => {
        :activate => :post,
        :approve => :post,
        :destroy_asset  => :post,
        :show_create_contacts => :get, :create_contacts => :post
      }
      admin_with_scaffold.resources :bar_associations
      admin_with_scaffold.resources :topics
      admin_with_scaffold.resources :expertises
      admin_with_scaffold.resources :tags
      admin_with_scaffold.resources :articles, :member => {
        :toggle_state   => :post,
        :destroy_asset  => :post
      }
      admin_with_scaffold.resources :messages
      admin_with_scaffold.resources :newsletters, :collection => {:export => :get}
      admin_with_scaffold.resources :journalist_enrollments, :collection => {:export => :get}
      admin_with_scaffold.resources :questions, :member => {
        :activate => :post,
        :deactivate => :post,
        :approve => :post
      }
      admin_with_scaffold.resources :responses, :member => {
        :approve => :post,
        :activate => :post
      }
      admin_with_scaffold.resources :comments, :member => {
        :approve => :post,
        :activate => :post
      }
      admin_with_scaffold.resources :reviews, :member => {
        :approve => :post,
        :activate => :post,
        :cancel => :post
      }
      admin_with_scaffold.resources :products
      admin_with_scaffold.resources :orders
      admin_with_scaffold.resources :invoices, :member => {
        :capture_payment => :post, 
        :void_payment => :post,
        :print_invoice => :get
      }
      admin_with_scaffold.resources :delayed_jobs, :collection => {:reset => :get}
      admin_with_scaffold.resources :vouchers, :collection => {:show_create_vouchers => :get, :create_vouchers => :post, :export => :get}
    end
  end
  map.admin '/admin', :controller => 'admin/admin_application'

  #=== client
  map.resource :client, :as => 'rechtsuchender', :controller => 'client/client_application', 
    :path_names => {:benefits => "vorteile"}, :collection => {
    :benefits => :get,
    :overview => :get,
    :kodex => :get,
    :legal_advice_cost => :get
  } do |client|
    client.resource :account, :as => "mein-bereich", :controller => 'client/account/client_account_application', :collection => {
      # :info => :get, 
      :deactivate => :get
    } do |account|
      account.resources :stores, :as => 'anwalts-liste', :controller => "client/account/stores" , :member =>{ :add => :post , :remove => :post}
      account.resources :questions, :as => "fragen-und-bewerbungen", :controller => "client/account/questions", 
      :path_names => {:open => "offen", :closed => 'geschlossen', :show_close => "frage-schliessen", :show_mandate_given => "mandat-erteilen"},
      :member => {:show_close => :get, :close => :put, :show_mandate_given => :get, :mandate_given => :put},
      :collection => { 
         :open => :get,
         :closed => :get
      } do |question|
        question.resources :responses, :as => "erhaltene-bewerbungen", :controller => "client/account/responses",
            :member => {:accept => :put, :decline => :put} do |response|
          response.resources :comments, :as => "erhaltene-antworten", :controller => "client/account/comments"
        end
        question.resources :comments, :as => "erhaltene-antworten", :controller => "client/account/responses"
        question.resources :mandates, :as => "anwalts-mandat", :only => [], :controller => "client/account/mandates",
          :path_names => {:accept => "erteilen", :decline => "ablehnen"},
          :member => {:accept => :get, :decline => :get}
      end
      account.resources :advocates, :as => "anwalts-bewertungen", :controller => "client/account/advocates",
          :path_names => {:profile => "profil", :reviews => "anwaltsbewertungen", :messages => "mitteilungen", :articles => "artikel", :reviewed => "meine-abgegebenen-bewertungen"},
            :collection => {:unreviewed => :get, :reviewed => :get}, 
              :member => {:messages => :get, :reviews => :get, :profile => :get, :articles => :get} do |advocate|
        advocate.resources :reviews, :as => "bewertungen", :controller => "client/account/reviews"
      end
      account.resources :reviews, :as => "bewertungen", :controller => "client/account/reviews", 
        :path_names => {:approved => "bereits-bewertete", :pending => "noch-zu-bewertende", :rate => "bewerten"},
      :member => {:rate => :post},
      :collection => {
        :approved => :get,
        :pending => :get,
        :location => :get, 
        :review => :get,
        :how => :get  
      } do |review|
        review.resources :comments, :as => "bewertungs-kommentare", :controller => "client/account/comments"
      end
      account.resources :messages, :as => "nachrichten", :controller => "client/account/messages"
      account.resource :profile, :as => "profil", :controller => "client/account/profiles",
          :collection => {:create_enrollment => :put, :destroy_enrollment => :put, :destroy_image => :put, :update_password => :put} do |profile|
        profile.resource :deactivation, :as => "deaktivieren", :controller => "client/account/deactivations"
      end
    end
    client.resources :users, :as => "benutzer", :controller => 'client/users', :collection => {
      :confirm => :get,
      :complete => :get
    }, :member => {
      :activate => :get
    }
    client.resources :articles, :as => "artikel-zu-rechtsthemen", :controller => "client/articles", 
      :path_names => {:print => "drucken"},
      :member => {:print => :get}
    client.resources :faqs, :as => "hilfe", :controller => "client/faqs", 
      :path_names => {:print => "drucken"},
      :member => {:print => :get}
    client.resources :dictionaries, :as => "rechtslexikon", :controller => "client/dictionaries", 
      :path_names => {:print => "drucken"},
      :member => {:print => :get}
  end

  #=== advocate
  map.resource :advocate, :as => 'anwalt', :controller => 'advocate/advocate_application', 
    :path_names => {:benefits => "vorteile", :overview => "produktuebersicht", :help => "hilfe"}, :collection => {
    :benefits => :get,
    :overview => :get,
    :overview_log => :get,
    :buy => :get,
    :thank => :get,
    :help => :get
  } do |advocate|
    advocate.resource :account, :as => "mein-bereich", :controller => 'advocate/account/advocate_account_application', 
    :path_names => {:bills => "alle-rechnungen"},
    :collection => {
      :info => :get,
      :profil => :get,
      :contact => :get,
      :conto => :get,
      :deactivate => :get,
      :package => :get, 
      :bills => :get,
      :payment => :get,
      :radar => :get,
      # :articel => :get
    } do |account|
      account.resources :questions, :as => "fragen", :controller => "advocate/account/questions", 
      :path_names => {:contact => "kontaktieren", :open => "offene-kontakte-und-bewerbungen", :closed => "geschlossene-kontakte-und-bewerbungen", :show_mandate_received => "mandat-erhalten"}, :collection => {
        :open => :get, :closed => :get,
        :regard => :get
      }, :member => {
        :contact => :put,
        :show_contact => :get,
        :show_mandate_received => :get, :mandate_received => :put
      } do |question|
        question.resources :responses, :as => "bewerbungen", :controller => "advocate/account/responses",
          :path_names => {:show_close => "bewerbung-schliessen"}, 
            :member => {:show_close => :get, :close => :put} do |response|
          response.resources :comments, :as => "antworten", :controller => "advocate/account/comments"
        end
        question.resources :comments, :as => "antworten", :controller => "advocate/account/comments"
      end
      account.resources :reviews, :as => "bewertungen", :controller => "advocate/account/reviews",
        :path_names => {:rate => "bewerten"},
          :member => {:rate => :post} do |review|
        review.resources :comments, :as => "bewertungs-kommentare", :controller => "advocate/account/comments"
      end
      account.resources :advomessages, :as => "mitteilungen", :controller => "advocate/account/advomessages"
      account.resources :messages, :as => "nachrichten", :controller => "advocate/account/messages",
        :path_names => {:read => "gelesene", :unread => "ungelesene"}, :collection => {:read => :get, :unread => :get}
      account.resources :invoices, :as => "rechnungen", :controller => "advocate/account/invoices"
      account.resources :products, :as => "produkte", :controller => "advocate/account/products"
      account.resources :orders, :as => "bestellungen", :controller => "advocate/account/orders", :collection => {:new => :post}
      account.resources :search_filters, :as => "fragen-radar", :controller => "advocate/account/search_filters"
      account.resources :articles, :as => "artikel", :controller => "advocate/account/articles", 
        :path_names => {:publish => "veroeffentlichen", :suspend => "deaktivieren"},
          :member => {:publish => :put, :suspend => :put, :destroy_attachment => :put}
      account.resource :profile, :as => "profil", :controller => "advocate/account/profiles",
        :path_names => {:details => "profildaten", :contact => "kontaktdaten", :payment => "zahlungsdaten", :package => "guthaben-und-paket", :redeem_voucher => "gutschein-einloesen"},
          :collection => {:create_enrollment => :put, :destroy_enrollment => :put, :destroy_image => :put, :update_password => :put,
            :details => :get, :contact => :get, :payment => :get, :package => :get, :public => :get, :redeem_voucher => :put} do |profile|
        profile.resource :deactivation, :as => "deaktivieren", :controller => "advocate/account/deactivations"
        profile.resource :preview, :as => "profilvorschau", :controller => "advocate/account/previews", 
          :path_names => {:reviews => "meine-bewertungen", :messages => "mitteilungen", :articles => "artikel"},
          :collection => {:reviews => :get, :messages => :get, :articles => :get}
      end
    end
    
    advocate.resources :users, :as => "benutzer", :controller => 'advocate/users', 
    :path_names => {:confirm => "bestaetigen", :activated => "aktiviert", :complete => "fertig", :activate => "aktivieren", :resend => "senden"},
    :collection => {
      :confirm => :get,
      :activated => :get,
      :complete => :get
    }, :member => {
      :activate => :get,
      :resend => :get
    }
    advocate.resources :recommendations, :as => "empfehlungen", :controller => 'advocate/recommendations', 
      :path_names => {:complete => "fertig"},
      :collection => {:complete => :get}
    advocate.resources :faqs, :as => "hilfe", :controller => "advocate/faqs", 
      :path_names => {:print => "drucken"},
      :member => {:print => :get}
    advocate.resource :profile, :only => :show
  end
  
  #=== questions
  map.resources :questions, :as => "fragen", 
    :path_names => {:open => "offene", :toggle_follow => "merken", :follows => "gemerkte", :accessible => "kontaktierte",
      :search_filter => "fragen-radar-ergebnisse", :confirm => "bestaetigen", :activate => "aktivieren", 
        :close => "schliessen", :reopen => "oeffnen", :resend_activate => "aktivierung-versenden"},
  :collection => {
    :new => :post,
    :open => :get,
    :follows => :get,
    :accessible => :get,
    :search_filter => :get,
  }, :member => {
    :confirm => :get,
    :activate => :get,
    :toggle_follow => :put,
    :close => :put,
    :reopen => :put,
    :mandate_given => :put,
    :mandate_received => :put,
    :request_activation => :put,
    :resend_activate => :get
  } do |question|
    question.resources :comments, :as => "ergaenzungen"
  end

  #=== start pages ("Startseite")
  map.with_options :controller => 'start_pages' do |start|
    start.root :action => 'index'
    start.homepage '/', :action => 'index'
  end
  
  #=== press pages
  map.resource :press, :as => "presse", :controller => "press/press_application", 
  :path_names => {:resources => "bilder-und-logos", :company_profile => "firmenprofil", :newsletter => "newsletter"},
  :collection => {
    :newsletter => :get,
    :resources => :get,
    :company_profile => :get
  } do |press|
    press.resources :releases, :as => "mitteilungen", :controller => 'press/releases', :member => {:print => :get}
    press.resources :reviews, :as => "pressespiegel", :controller => 'press/reviews', :member => {:print => :get}
    press.resources :journalists, :as => "journalisten", :controller => 'press/journalists', 
    :path_names => {:complete => "fertig", :cancel => "abbestellen", :remove => "entfernen"}, 
    :collection => {
      :complete => :get, :cancel => :get, :remove => :post
    }
    press.resources :contacts, :as => "kontaktanfrage", :controller => 'press/contacts', 
    :path_names => {:complete => "fertig"},
    :collection => {
      :complete => :get
    }
  end
    
  #=== service pages
  map.resource :service, :as => "service", :controller => "service/service_application", 
  :path_names => {:tags => "stichwortsuche", :newsletter => "newsletter", :recommend => "weiterempfehlen"},
  :collection => {
    :newsletter => :get,
    :recommend => :get,
    :tags => :get
  } do |service|
    service.resources :blogs, :as => "blog", :controller => "service/blogs", 
      :path_names => {:print => "drucken"}, :member => {:print => :get}, :collection => {:feed => :get}
    service.resources :recommendations, :as => "empfehlungen", :controller => 'service/recommendations', 
      :path_names => {:complete => "fertig"}, :collection => {:complete => :get}
    service.resources :newsletters, :as => "newsletter", :controller => 'service/newsletters', 
      :path_names => {:complete => "fertig", :activated => "aktiviert", :deactivated => "deaktiviert", :remove => "entfernen", :cancel => "abbestellen", :activate => "aktivieren", :deactivate => "deaktivieren", :resend => "senden"},
      :collection => {:complete => :get, :activated => :get, :deactivated => :get, :remove => :post, :cancel => :get},
        :member => {:activate => :get, :deactivate => :get, :resend => :get}
  end

  #=== corporate pages
  map.resource :corporate, :as => "unternehmen", :controller => "corporate/corporate_application", 
  :path_names => {:contact => "kontakt", :careers => "karriere", :about => "ueber-uns", :board => "beirat",
    :partners => "kooperationspartner", :advertising => "mediawerbung", :privacy => "datenschutz", :terms => "nutzungsbedingungen",
      :imprint => "impressum"},
  :collection => {
    :contact => :get,
    :careers => :get,
    :about => :get,
    :board => :get,
    :partners => :get,
    :advertising => :get,
    :privacy => :get,
    :terms => :get,
    :imprint => :get,
    :sitemap => :get,
    :home_page => :get, 
    :brochure => :get,
    :video => :get
  } do |corporate|
    corporate.resources :contacts, :as => "kontaktanfrage", :controller => 'corporate/contacts', :collection => {
      :complete => :get
    }
    corporate.resource :feedback, :as => "feedback", :controller => 'corporate/feedbacks'
  end
  
  #=== help pages ("Was ist kann-ich-klagen.de")
  map.with_options :controller => 'help_pages' do |help|
    help.what 'was', :action => 'what'
    help.how 'benutzerhinweise', :action => 'how'
    help.tips_and_infos 'tips-und-infos', :action => 'tips_and_infos'
  end
  
  #=== pages (all other static pages)
  map.with_options :controller => 'pages' do |page|
    page.show 'uebersicht', :action => 'show', :uri => 'show'
    page.pre_launch_splash 'vorlaunch', :action => 'pre_launch_splash', :uri => 'pre_launch_splash'
    # below obsolete after launch
    page.open_sesame 'sesam_oeffne_dich', :action => 'open_sesame', :uri => 'open_sesame'
    page.close_sesame 'sesam_schliesse_dich', :action => 'close_sesame', :uri => 'close_sesame'
    page.close_sesame 'sesam_schliess_dich', :action => 'close_sesame', :uri => 'close_sesame'
    page.open_sesame 'sesam-oeffne-dich', :action => 'open_sesame', :uri => 'open_sesame'
    page.close_sesame 'sesam-schliesse-dich', :action => 'close_sesame', :uri => 'close_sesame'
    page.close_sesame 'sesam-schliess-dich', :action => 'close_sesame', :uri => 'close_sesame'
    page.set_kik_realm 'kik_setzen', :action => 'set_kik_realm', :uri => 'set_kik_realm'
    page.set_kik_realm 'kik-setzen', :action => 'set_kik_realm', :uri => 'set_kik_realm'
    page.set_af_realm 'af_setzen', :action => 'set_af_realm', :uri => 'set_af_realm'
    page.set_af_realm 'af-setzen', :action => 'set_af_realm', :uri => 'set_af_realm'
    page.set_af_realm 'advofinder_setzen', :action => 'set_af_realm', :uri => 'set_af_realm'
    page.set_af_realm 'advofinder-setzen', :action => 'set_af_realm', :uri => 'set_af_realm'
  end

  map.resources :faqs, :as => "hilfe", :controller => "faqs", :member => {:print => :get}
  map.account "mein-bereich", :controller => "front_application", :action => "account"

  #=== advofinder application
  map.resource :advofinder, :as => "advofinder", :controller => 'advofinder/advofinder_application' do |af|
    af.with_options :controller => 'advofinder/pages' do |pages|
      pages.advofinder_home '', :controller => 'pages', :action => 'index'
      pages.what 'was', :controller => 'pages', :action => 'what'
      pages.how 'system', :controller => 'pages', :action => 'how'
    end
    af.resource :search, :as => "suche", :controller => 'advofinder/searches'
    af.resources :reviews, :as => "bewerten", :controller => 'advofinder/reviews'
    
    #=== advofinder client
    af.resource :client, :as => "rechtsuchender", :controller => 'advofinder/client/client_application' do |client|
      client.resources :users, :as => "benutzer", :controller => 'advofinder/client/users'
      client.resources :advocates, :as => "anwalts-bewertungen", :controller => 'advofinder/client/advocates', 
        :path_names => {:profile => "profil", :reviews => "anwaltsbewertungen", :messages => "mitteilungen", :articles => "artikel"},
        :member => {:messages => :get, :reviews => :get, :profile => :get, :articles => :get} do |advocate|
        advocate.resources :reviews, :as => "bewertungen", :controller => 'advofinder/client/reviews'
      end
      client.resources :reviews, :as => "bewertungen", :controller => "advofinder/client/reviews", 
        :path_names => {:rate => "bewerten"},
      :member => {:rate => :post} do |review|
        review.resources :comments, :as => "bewertungs-kommentare", :controller => "advofinder/client/comments"
      end
      
    end
    
    #=== advofinder advocate
    af.resource :advocate, :as => "anwalt", :controller => 'advofinder/advocate/advocate_application' do |advocate|
      advocate.resources :users, :as => "benutzer", :controller => 'advofinder/advocate/users'
      advocate.resources :profiles, :as => "anwalts-profil", :except => [:new, :create], :controller => 'advofinder/advocate/profiles', 
        :path_names => {:profile => "profil", :reviews => "anwaltsbewertungen", :messages => "mitteilungen", :articles => "artikel"},
        :member => {:messages => :get, :reviews => :get, :profile => :get, :articles => :get} do |profile|
        profile.resources :reviews, :as => "bewertungen", :controller => 'advofinder/advocate/reviews'
      end
    end
  end

  #=== widget application
  map.resource :widget, :as => "widgets", :controller => 'widgets/widget_application' do |widget|
    widget.resource :schoener_garten, :as => "schoener-garten", :controller => 'widgets/schoener_gartens'
  end
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
