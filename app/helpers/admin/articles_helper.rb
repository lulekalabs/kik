module Admin::ArticlesHelper

  def person_id_form_column(record, name)
    select(:record, :person_id, collect_for_publisher_select(true), :name => "record[person_id]")
  end

  def collect_for_publisher_select(select=false)
    result = Person.find(:all, :conditions => {:publisher => true}).uniq.map {|r| [r.name, r.id]}
    result.insert(0, ["Herausgeber auswählen...", nil])
    result
  end

  def type_form_column(record, name)
    select(:record, :type, collect_for_type_select, :name => "record[type]")
  end
  
  def collect_for_type_select(select=false)
    [
      ["Artikel", 'Article'],
      ["Lexikoneintrag", 'DictionaryEntry']
    ]
  end
  
  def status_column(record)
    case "#{record.current_state}"
      when /created/ then "neu"
      when /published/ then "öffentlich"
      when /suspended/ then "gesperrt"
      else "#{record.current_state}"
    end
  end
  
  def title_column(record)
    truncate("#{record.title}")
  end

  def image_url_column(record)
    if record.image.file?
      image_tag(record.image.url(:thumb), {:size => '80x80'})
    else
      '[Kein Bild]'
    end
  end
  
  def image_form_column(record, name)
    html = ''
    if record.image.file?
      html << image_tag(record.image.url(:thumb), {:size => '80x80'})
      html << "&nbsp;"
      html << link_to("Remove", destroy_asset_admin_article_path(record, :select => "image"), :confirm => "Wirklich löschen?", :method => :post) 
      html << "<br/>"
    end
    html << file_field(:record, :image)
    html
  end

  def primary_attachment_form_column(record, name)
    html = ''
    if record.primary_attachment.file? && Asset.image?(record.primary_attachment.content_type)
      html << image_tag(record.primary_attachment.url(:thumb), {:size => '80x80'})
      html << "&nbsp;"
      html << link_to("Remove", destroy_asset_admin_article_path(record, :select => "primary_attachment"), :confirm => "Wirklich löschen?", :method => :post) 
      html << "<br/>"
    else
      html << record.primary_attachment_file_name if record.primary_attachment_file_name
      html << "<br/>"
    end
    html << file_field(:record, :primary_attachment)
    html
  end

  def secondary_attachment_form_column(record, name)
    html = ''
    if record.secondary_attachment.file? && Asset.image?(record.secondary_attachment.content_type)
      html << image_tag(record.secondary_attachment.url(:thumb), {:size => '80x80'})
      html << "&nbsp;"
      html << link_to("Remove", destroy_asset_admin_article_path(record, {:select => "secondary_attachment"}), :confirm => "Wirklich löschen?", :method => :post) 
      html << "<br/>"
    else
      html << record.secondary_attachment_file_name if record.secondary_attachment_file_name
      html << "<br/>"
    end
    html << file_field(:record, :secondary_attachment)
    html
  end
  
  def body_form_column(record, name)
    html = ""
    html += text_area(:record, :body, :id => "markdownDescription",
      :size => "80x10", :style => "font-family:courier,serif;")
    html += javascript_tag("$('#markdownDescription').markItUp(mySettings);")
    html
  end

  def summary_form_column(record, name)
    html = ""
    html += text_area(:record, :summary, :id => "markdownSummary",
      :size => "80x3", :style => "font-family:courier,serif;")
#    html += javascript_tag("$('#markdownSummary').markItUp(mySettings);")
    html
  end

  def view_column(record)
    result = []
    result << "KIK" if record.kik_view?
    result << "Advofinder" if record.advofinder_view?
    result.join(", ")
  end

  def topics_form_column(record, name)
    collection_select :record, :topics, Topic.visible.find(:all, :order => "topics.name ASC"), :id, :name, 
      {:selected => @record.topic_ids}, {:multiple => true, :name => 'record[topic_ids][]'}
  end

end
