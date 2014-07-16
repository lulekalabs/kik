module FrontApplicationHelper
  
  def collect_for_gender_select(select=false, required=true)
    result = [["Frau", 'f'], ["Herr", 'm']]
    result.insert(0, [required ? "Anrede*" : "Anrede", nil]) if select
    result
  end

  def collect_payment_method_for_select(select=false, required=true)
    result = []
    result << ["Zahlung per Lastschrift", 'debit']
    result << ["Zahlung per Rechnung", 'invoice']
    # result << ["Zahlung per Paypal", 'paypal']
    result.insert(0, [required ? "Zahlungsart*" : "Zahlungsart", nil]) if select
    result
  end

  def collect_billing_method_for_select(select=false, required=true)
    result = []
    result << ["Versand per E-Mail als PDF + per Post in Papierform", 'pdf_and_paper']
    result << ["Versand per E-Mail als PDF (Kostenlos)", 'pdf']
    result.insert(0, [required ? "Versandart*" : "Versandart", nil]) if select
    result
  end
  
  def collect_for_academic_title_select(select=false, required=true)
    result = []
    result << [AcademicTitle.no_title, AcademicTitle.no_title.id] if select && required
    result << [AcademicTitle.dr, AcademicTitle.dr.id] 
    result << [AcademicTitle.prof, AcademicTitle.prof.id] 
    result << [AcademicTitle.prof_dr, AcademicTitle.prof_dr.id]
    
    select_text = select.is_a?(String) ? select : "Titel"
    
    result.insert(0, [required ? "#{select_text}*" : "#{select_text}", nil]) if select
    result
  end
  
  def collect_for_search_radius_select(select=false, required=true)
    result = []
    result << ["5 KM", 5] 
    result << ["10 KM", 10] 
    result << ["20 KM", 20] 
    result << ["30 KM", 30] 
    
    select_text = select.is_a?(String) ? select : "Umkreis"
    
    result.insert(0, [required ? "#{select_text}*" : "#{select_text}", nil]) if select
    result
  end

  def collect_for_provinces_select(select=false, required=true)
    result = LocalizedProvinceSelect::localized_provinces_array("DE")
    select_text = select.is_a?(String) ? select : "Bundesland"
    result.insert(0, [required ? "#{select_text}*" : "#{select_text}", nil]) if select
    result
  end
  
  def collect_for_questions_search_order_select(select=false)
    result = []
    result << ["Aktualität (neueste zuerst)", "kases.created_at DESC"] 
    result << ["Aktualität (älteste zuerst)", "kases.created_at ASC"] 
    result << ["Entfernung (näheste zuerst)", "kases.distance DESC"] 
    result << ["Entfernung (weiteste zuerst)", "kases.distance ASC"] 
    result << ["Rechtsgebiet (A-Z aufsteigend)", "topics.name ASC"] 
    result << ["Rechtsgebiet (Z-A absteigend)", "topics.name DESC"] 
    
    select_text = select.is_a?(String) ? select : "Sortierung"
    result.insert(0, ["#{select_text}", nil]) if select
    result
  end

  def collect_for_advocates_search_order_select(select=false)
    result = []
    result << ["Am besten bewertet", "people.grade_point_average IS NOT NULL DESC, people.grade_point_average ASC"] 
    result << ["Am häufigsten bewertet", "reviews_count DESC"] 
#    result << ["Am häufigsten kommentiert", "review_comments_count DESC"] 
    result << ["Am häufigsten empfohlen", "review_recommendations_count DESC"] 
#    result << ["Höchste Weiterempfehlungsquote", "review_comments_grade_average DESC"] 
    result << ["Höchste Weiterempfehlungsquote", "review_recommendation_rate DESC"] 
    result << ["Am häufigsten aufgerufen", "people.visits_count DESC"] 
#    result << ["Neueste Einträge zuerst", "reviews.created_at DESC"] 
    
    select_text = select.is_a?(String) ? select : "Sortierung"
    result.insert(0, ["#{select_text}", nil]) if select
    result
  end

  def collect_for_reviews_search_order_select(select=false)
    result = []
    result << ["Aktualität (neueste zuerst)", "reviews.created_at DESC"] 
    result << ["Aktualität (älteste zuerst)", "reviews.created_at ASC"] 
    result << ["Note (aufsteigend)", "reviews.grade_point_average ASC"] 
    result << ["Note (absteigend)", "reviews.grade_point_average DESC"] 
    select_text = select.is_a?(String) ? select : "Sortierung"
    result.insert(0, ["#{select_text}", nil]) if select
    result
  end
  
  def collect_for_per_page_select(select=false)
    result = []
    result << ["5 auf einer Seite", 5] 
    result << ["10 auf einer Seite", 10] 
    result << ["20 auf einer Seite", 20] 
    result << ["alle", 1000] 
    result
  end

  # collects for select all bar associations, selected means that and empty 
  # "Select..." option is added
  def collect_for_bar_association_select(select=false)
    result = BarAssociation.find(:all, :order => "name ASC").map {|m| [m.name, m.id]}
    # result.insert(0, ["Zuständige Rechtsanwaltskammer*", nil]) if select
    result
  end

  # expertises like which professional area the advocate covers
  def collect_for_expertise_select(select=false)
    result = Expertise.visible.find(:all, :order => "position ASC, name ASC").map {|m| [m.name, m.id]}
    result.insert(0, ["auch Fachanwalt für: BITTE WÄHLEN", nil]) if select
    result
  end

  # topics like which professional area the advocate covers
  def collect_for_topic_select(select=false)
    result = Topic.visible.find(:all, :order => "position ASC, name ASC").map {|m| [m.name, m.id]}
    result.insert(0, [select.is_a?(String) ? select : "Kein #{Topic.human_name}", nil]) if select
    result
  end

  # newsletter collection
  def collect_for_enrollment_type_select(select=false)
    result = [
      ["Rechtsuchende", 'ClientEnrollment'],
      ["Anwälte", 'AdvocateEnrollment']
#      ["", 'JournalistEnrollment']
    ]
    if select && select.class == TrueClass
      result.insert(0, ["Bitte wählen*", nil])
    elsif select && select.class == String
      result.insert(0, [select, nil])
    end
    result
  end

  def collect_for_enrollment_type_select_with_all(select=false)
    result = collect_for_enrollment_type_select(select)
    result << ["Beide Newsletter", 'Enrollment']
  end
  
  def collect_for_contract_period_select(select=true, required=true)
    result = [
      # ["1 Tag", 1], 
      # ["2 Tage", 2],
      # ["3 Tage", 3], 
      # ["5 Tage", 5], 
      ["7 Tage", 7], 
      ["10 Tage", 10], 
      ["14 Tage", 14], 
      ["20 Tage", 20], 
      ["30 Tage", 30]
    ]
    result.insert(0, [required ? "Laufzeit*" : "Laufzeit", nil]) if select
    result
  end
  
  def collect_for_search_reason_select(select=false, required=false)
    result = []
    result << ["Ein (bevorstehendes) Gerichtsverfahren", "proceeding"]
    result << ["Eine (bisher) nur außergerichtliche Streitigkeit", "conflict"]
    result << ["Eine Beratung bei einer Vertragsgestaltung", "contract"]
    result << ["Eine Beratung zu einer rechtlichen Fragestellung", "question"]
    result << ["Ein sonstiger Anlass", "other"]

    select_text = select.is_a?(String) ? select : "Bitte wählen:"
    result.insert(0, [required ? "#{select_text}*" : "#{select_text}", nil]) if select
    result
  end
  
  
  def collect_for_advocate_contact_count_select(select=false)
    result = []
    result << ["keinem", nil]
    result << ["1", "1"]
    result << ["2", "2"]
    result << ["3", "3"]
    result << ["mehr als 3", ">3"]
    result.insert(0, ["Bitte wählen:", nil]) if select
    result
  end
  
  # terms for advocate sign up
  def confirm_advocate_terms_of_service_in_words
    "Ja, ich habe die #{link_to("Nutzungsbedingungen", terms_corporate_path(:popup => true), :popup => ['Nutzungsbedingungen', 'height=300,width=995,scrollbars=yes'])} und #{link_to("Datenschutzerklärung", privacy_corporate_path(:popup => true), :popup => ['Datenschutzerklärung', 'height=300,width=995,scrollbars=yes'])} für Anwälte von #{af_realm? ? "advofinder.de" : "kann-ich-klagen.de"} gelesen und akzeptiere diese."
  end
  
  def confirm_terms_of_service_in_words
    "Ja, ich akzeptiere die #{link_to "Nutzungsbedingungen", terms_corporate_path, {:title => "Nutzungsbedingungen von #{af_realm? ? "advofinder.de" : "kann-ich-klagen.de"}"}} und #{link_to "Datenschutzerklärung", privacy_corporate_path, {:title => "Datenschutzerklärung von #{af_realm? ? "advofinder.de" : "kann-ich-klagen.de"}"}}"
  end
  
  # See the README for an example using tag_cloud.
  def tag_cloud(tags, classes)
    if tags && tags.size > 0
      max_count = tags.sort_by(&:count).last.count.to_f
    
      tags.each do |tag|
        index = ((tag.count / max_count) * (classes.size - 1)).round
        yield tag, classes[index]
      end
    end
  end
  
  def content_type_to_css_class(content_type)
    case content_type
    when "application/pdf" then 'pdf'
    when "application/msword" then 'word'
    else 'blank'
    end
  end

  # link to bookmark service
  #
  # name, options, html_options
  def bookmark_link_to(*args)
    name  = args.first
    options = args.second || {}
    html_options = {:id => "bookmark_link"}.merge(args.third || {})

    url = options.is_a?(String) ? options : url_for(options.merge({:only_path => false}))
    html_options = html_options.symbolize_keys
    
    <<-HTML
      <a href="http://www.seitzeichen.de/bookmark.php" onclick="window.open('http://www.seitzeichen.de/bookmark.php?url='+encodeURIComponent('#{url}')+'&amp;title='+encodeURIComponent(document.title)+'&amp;pub=1bb1619030a2f6b835ced8c67a8986d9','Seitzeichen','scrollbars=yes,menubar=no,width=790,height=670,resizable=yes,toolbar=no,location=no,status=no,screenX=200,screenY=100,left=200,top=100');return false" title="Diese Seite bookmarken" target="_top" class="#{html_options[:class]}" id="#{html_options[:id]}">
        #{name}
      </a>
    HTML
  end

  # facebook link
  def facebook_link_to(name, link="http://www.facebook.com/kannichklagen", options={})
    options = {:title => "Folgen Sie #{af_realm? ? "advofinder.de" : "kann-ich-klagen.de"} auf Facebook", :target=>'blank'}.merge(options)
    link_to name, link, options
  end

  # twitter link
  def twitter_link_to(name, link="http://www.twitter.com/kannichklagen", options={}) 
    options = {:title => "Folgen Sie #{af_realm? ? "advofinder.de" : "kann-ich-klagen.de"} auf Twitter", :target=>'blank'}.merge(options)
    link_to name, link, options
  end

  # adds link to set as startpage, only displayed on IE
  def link_to_set_as_startpage(text, options={})
    <<-HTML
      <!--[if IE]>
      <a href="#" title="#{options[:title]}" onclick="this.style.behavior='url(#default#homepage)';this.setHomePage('#{homepage_url}');">
        #{text}
      </a>
      <![endif]-->
    HTML
  end

  # remote link to feedback form
  def link_to_feedback_modal(*args)
    text = args.first
    if text.is_a?(String)
      html_options = args.last
    else
      html_options = text
      text = ""
    end
    if false
      link_to_function text, "Luleka.Popin.show(lulekaOptions);", 
        {:title => "Schreiben Sie uns Ihre Meinung, Anregungen oder Ideen"}
    else
<<-HTML
  #{link_to_remote(text, :url => new_corporate_feedback_path, :method => :get, 
    :html => {:class  => "" , :title => "Schreiben Sie uns Ihre Meinung, Anregungen oder Ideen"})}
  <a title="Feedback" style="display:none;" class="feedback_modal_hidden" href="#feedback">Feedback</a>
HTML
    end
  end

  # Feedback link with link text
  def link_to_feedback(name, html_options={})
    link_to_remote(
      name,          
      :url  => new_corporate_feedback_path,
      :method => :get,
      :html => {:class => "", :title => "Schreiben Sie uns Ihre Meinung, Anregungen oder Ideen"}
    )
  end

  # draws flash messages
  def form_flash_messages
    html = ""
    draw_flash_message do |type, message|
      html += content_tag :div, message, :class => type
    end
    html
  end

  # returns article location based on type of article
  def polymorphic_article_url(article, options={})
    if article.blog 
      service_blog_path(article, options)
    elsif article.press_release
      press_release_path(article, options)
    elsif article.law_article
      client_article_path(article, options)
    elsif article.press_review
      press_review_path(article, options)
    elsif article.faq
      if article.advocate_view && article.client_view
        faq_path(article, options)
      elsif article.advocate_view
        advocate_faq_path(article, options)
      elsif article.client_view
        client_faq_path(article, options)
      else
        faq_path(article, options)
      end
    elsif article.dictionary
      client_dictionary_path(article, options)
    else 
      "#"
    end
  end
  alias_method :polymorphic_article_path, :polymorphic_article_url

  # Does not behave identical to current Rails truncate method i.e. you must pass options as a hash not just values
  # Sample usage: <%= html_truncate(category.description, :length => 120, :omission => "(continued...)" ) -%>...
  def truncate_html(html, options={})
    previous_tag = ""
    text, result = [], []

    # get all text (including punctuation) and tags and stick them in a hash
    html.scan(/<\/?[^>]*>|[A-Za-zÖÄÜöäüß.,;!"'?]+/).each { |t| text << t }

    text.each do |str|
      if options[:length] > 0
        if str =~ /<\/?[^>]*>/
          previous_tag = str
          result << str
        else
          result << str
          options[:length] -= str.length
        end
      else
        # now stick the next tag with a </> that matches the previous open tag on the end of the result 
        if str =~ /<\/([#{previous_tag}]*)>/
          result << str
        else
        end
      end
    end
    return result.join(" ") + options[:omission].to_s
  end

  def link_to_open_close_toggle(text, dom_id, open=true, html_options={})
    open_text = (text.is_a?(Array) ? text.last : text) + "&nbsp;" + image_tag('quest_open.gif')
    open_link_dom_id = "#{dom_id}-open-link"
    close_text = (text.is_a?(Array) ? text.first : text) + "&nbsp;" + image_tag('quest_close.gif')
    close_link_dom_id = "#{dom_id}-close-link"
    
    html = ""
    # open link
    html += link_to_function(open_text, nil, html_options.merge(:id => open_link_dom_id, :style => "#{open ? 'display:none;' : ''}")) do |page|
      page[dom_id].show
      page[open_link_dom_id].hide
      page[close_link_dom_id].show
    end
    # close link
    html += link_to_function(close_text, nil, html_options.merge(:id => close_link_dom_id, :style => "#{open ? '' : 'display:none;' }")) do |page|
      page[dom_id].hide
      page[open_link_dom_id].show
      page[close_link_dom_id].hide
    end
    html
  end

  # shows profile avatar for person
  # 
  # E.g.
  #
  #   profile_image_tag @person, :size => :small
  #
  def profile_image_tag(person, options={}, html_options={})
    options.symbolize_keys!
    size = (options.delete(:size) || "normal").to_s
    html = ""
    if person && person.image?
      html += image_tag(person.image.url(size.to_sym), :alt => "Profilbild", :title => "Profilbild")
    else
      if af_realm?
        # advofinder realm
        if size == "small"
          html += person.female? ? 
            '<img src="/images/advofinder/person/lay_woman_small.jpg" alt="Profilbild" />' : 
              '<img src="/images/advofinder/person/lay_small.jpg" alt="Profilbild" />'
        else
          html += person.female? ? 
            '<img src="/images/advofinder/person/lay_woman.jpg" alt="Profilbild" />' :
              '<img src="/images/advofinder/person/lay.jpg" alt="Profilbild" />'
        end
      else
        # kik realm
        if size == "small"
          html += person.female? ? 
            '<img src="/images/person/lay_woman_small.jpg" alt="Profilbild" />' : 
              '<img src="/images/person/lay_small.jpg" alt="Profilbild" />'
        else
          html += person.female? ? 
            '<img src="/images/person/lay_woman.jpg" alt="Profilbild" />' :
              '<img src="/images/person/lay.jpg" alt="Profilbild" />'
        end
      end
    end
    html
  end

  # shows profile logo of company
  # 
  # E.g.
  #
  #   profile_logo_tag @person, :size => :small
  #
  def profile_logo_tag(person, options={}, html_options={})
    options.symbolize_keys!
    empty = options.delete(:empty)
    size = (options.delete(:size) || "normal").to_s
    html = ""
    if person && person.logo.file?
      html += image_tag(person.logo.url(size.to_sym), :alt => "Kanzleilogo", :title => "Kanzleilogo")
    else
      html += empty
#      html += '<img src="/images/logos/presse_logo_SW.jpg" width="150" height="19" alt="Presse Logo SW">'
    end
    html
  end
  
  # lists the topics comma separated
  def topics_list_in_words(kase)
    kase.topics.empty? ? "Keine zugewiesen" : h(kase.topics.map(&:name).join(", "))
  end

  def line_break(string)
    string.gsub("\n", '<br/>')
  end 

  def adovocate_professions_in_words(person)
    result = []
    result << person.class.human_attribute_name(:profession_advocate) if person.profession_advocate
    result << person.class.human_attribute_name(:profession_mediator) if person.profession_mediator
    result << person.class.human_attribute_name(:profession_notary) if person.profession_notary
    result << person.class.human_attribute_name(:profession_tax_accountant) if person.profession_tax_accountant
    result << person.class.human_attribute_name(:profession_patent_attorney) if person.profession_patent_attorney
    result << person.class.human_attribute_name(:profession_cpa) if person.profession_cpa
    result << person.class.human_attribute_name(:profession_affiant_accountant) if person.profession_affiant_accountant
    result.compact.join(", ")
  end

  def adovocate_expertises_in_words(person, line_break=false)
    result = []
    if person.is_a?(Advocate)
      result << person.primary_expertise.name if person.primary_expertise
      result << person.secondary_expertise.name if person.secondary_expertise
      result << person.tertiary_expertise.name if person.tertiary_expertise
    end
    if line_break
      result.compact.join("<br />")
    else
      result.compact.join(", ")
    end
  end

  def adovocate_topics_in_words(person, line_break=false)
    result = []
    if person.is_a?(Advocate)
      result = person.topics.map(&:name)
    end
    if line_break
      result.compact.join("<br />")
    else
      result.compact.join(", ")
    end
  end

  def adovocate_spoken_languages_in_words(person, line_break=false)
    result = []
    if person.is_a?(Advocate)
      result = person.spoken_languages.map(&:name)
    end
    if line_break
      result.compact.join("<br />")
    else
      result.compact.join(", ")
    end
  end

  def address_in_overview(address)
    result = []
    if address
      result << content_tag(:div, h("#{address.street} #{address.street_number}")) if !address.street.blank? || !address.street_number.blank?
      result << content_tag(:div, h("#{address.postal_code} #{address.city}")) if !address.postal_code.blank? || !address.city.blank?
      result << content_tag(:div, h("#{address.phone}")) if !address.phone.blank?
      result << content_tag(:div, h("#{address.fax}")) if !address.fax.blank?
    end
    result.compact.join("")
  end
  
  # e.g. 10%
  def percent(count, total)
    precision = (total == count) ? 0 : 1
    total.to_f != 0.0 && count.to_f >= 0.0 ? number_to_percentage((count.to_f / total.to_f * 100), :precision => precision) : "0%"
  end

  def link_to_review_sub_toggle(text, dom_id, open=true, html_options={})
    open_text = (text.is_a?(Array) ? text.last : text) + "&nbsp;"
    open_link_dom_id = "#{dom_id}-open-link"
    close_text = (text.is_a?(Array) ? text.first : text) + "&nbsp;"
    close_link_dom_id = "#{dom_id}-close-link"
    
    html = ""
    # open link
    html += link_to_function(open_text, nil, html_options.merge(:id => open_link_dom_id, 
      :class => "yellow_open", :style => "#{open ? 'display:none;' : ''}")) do |page|
      page[dom_id].show
      page[open_link_dom_id].hide
      page[close_link_dom_id].show
    end
    # close link
    html += link_to_function(close_text, nil, html_options.merge(:id => close_link_dom_id, 
      :class => "yellow_close", :style => "#{open ? '' : 'display:none;' }")) do |page|
      page[dom_id].hide
      page[open_link_dom_id].show
      page[close_link_dom_id].hide
    end
    html
  end

  def grade_point_average(advocate)
    if advocate.gpa
      number_with_precision(advocate.gpa, :precision => 1) 
    else
      "&#8211;,&#8211;"
    end
  end
  
  def grade_image_tag(review, attribute)
    if grade = review.send(attribute)
      image_tag("z_#{grade}.png", :title => grade_human_name(grade), :alt => grade_human_name_as_number(grade))
    end
  end
  
  def grade_image_and_human_name_tag(review, attribute)
    if grade = review.send(attribute)
      grade_image_tag(review, attribute) + " = #{grade_human_name(grade)}"
    end
  end
  
  def grade_human_name(grade)
    case grade.to_i
      when 1 then "sehr gut"
      when 2 then "gut"
      when 3 then "befriedigend"
      when 4 then "ausreichend"
      when 5 then "mangelhaft"
      when 6 then "ungenügend"
    end
  end
  
  def grade_human_name_as_number(grade)
    case grade.to_i
      when 1 then "Note 1"
      when 2 then "Note 2"
      when 3 then "Note 3"
      when 4 then "Note 4"
      when 5 then "Note 5"
      when 6 then "Note 6"
    end
  end
  
  def review_search_reason_in_words(review)
    case review.search_reason.to_s
    when /proceeding/ then "Ein (bevorstehendes) Gerichtsverfahren"
    when /conflict/ then "Eine (bisher) nur außergerichtliche Streitigkeit"
    when /contract/ then "Eine Beratung bei einer Vertragsgestaltung"
    when /question/ then "Eine Beratung zu einer rechtlichen Fragestellung"
    when /other/ then "Ein sonstiger Anlass"
    end
  end
  
  def boolean_in_words(bool)
    if bool.is_a?(TrueClass)
      "Ja"
    else # if bool.is_a?(FalseClass)
      "Nein"
    end
  end
  
  def review_advocate_contact_count_in_words(review)
    case review.advocate_contact_count.to_s
    when /1/ then "1"
    when /2/ then "2"
    when /3/ then "3"
    else
      "Mehr als 3"
    end
  end

  def review_lawsuit_won_in_words(review)
    case review.laswsuit_won.to_s
    when /yes/ then "Ja"
    when /no/ then "Nein"
    else
      "Nicht relevant"
    end
  end

  # Deutsch, Englisch
  def spoken_languages_in_words(person, select=false)
    result = person.spoken_languages.map(&:name).join(", ")
    result = select if select && result.empty?
    result
  end

  # render content with break
  def br_tag(text, options={})
    html = ""
    unless text.blank?
      html += text
      html += "<br />"
    end
    html
  end

  # add <br /> if condition is true
  def br_tag_if(condition, text, options={})
    br_tag(text, options) if condition
  end

  def br_tag_unless(condition, text, options={})
    br_tag(text, options) unless condition
  end

  # render content with <p>content</p> tag
  def p_tag(text, options={})
    html = ""
    unless text.blank?
      html += content_tag(:p, text, options)
    end
    html
  end

  # add <p> if condition is true
  def p_tag_if(condition, text, options={})
    p_tag(text, options) if condition
  end

  # add <p> unless condition is true
  def p_tag_unless(condition, text, options={})
    p_tag(text, options) unless condition
  end

  # escape some html, like javascript tags, allow <b>, <i>, etc.
  def escape_some_html(*args)
    h(*args)
  end
  alias_method :sh, :escape_some_html

  # wrapper to auto_link adding nofollow
  def auto_link_all(text, &block)
    auto_link(text, :all, {:rel => "nofollow", :target => "_blank"}, &block)
  end

  def entry_link_to(text=nil, person=nil, url=nil, empty=nil, html_options={}, &block)
    html = ""
    if block_given?
      text = capture(&block)
    end
    empty = empty.is_a?(NilClass) ? text.blank? : empty
    html += (empty ? "Kein Eintrag vorhanden." : text)
    if empty && logged_in? && person && current_user.person == person
      html += "&nbsp;"
      html += link_to("Hier ergänzen »", url, html_options)
    end
    block_given? ? concat(html) : html
  end
  
end
