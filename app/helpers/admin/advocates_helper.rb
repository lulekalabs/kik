module Admin::AdvocatesHelper

  def gender_column(record)
    case record.gender
      when /f/ then "Frau"
      else "Herr"
    end
  end

  # translates current state
  def state_column(record)
    record.human_current_state_name
  end

  def gender_form_column(record, name)
    select(:record, :gender, collect_for_gender_select(false))
  end
  
  def bar_association_id_form_column(record, name)
    select(:record, :bar_association_id, collect_for_bar_association_select(false))
  end

  def primary_expertise_id_form_column(record, name)
    select(:record, :primary_expertise_id, collect_for_expertise_select(true))
  end

  def secondary_expertise_id_form_column(record, name)
    select(:record, :secondary_expertise_id, collect_for_expertise_select(true))
  end

  def tertiary_expertise_id_form_column(record, name)
    select(:record, :tertiary_expertise_id, collect_for_expertise_select(true))
  end

  def academic_title_id_column(record)
    record.academic_title ? record.academic_title.name : "[Kein Titel]"
  end
  
  def academic_title_id_form_column(record, name)
    select(:record, :academic_title_id, collect_for_academic_title_select(true, false))
  end

  def business_address_show_column(record)
    record.business_address.to_s
  end

  def concession_show_column(record)
    "Ja"
  end

  def terms_of_service_show_column(record)
    "Ja"
  end

  def created_at_show_column(record)
    record && record.user && record.user.created_at ? l(record.user.created_at) : "-"
  end

  def activated_at_show_column(record)
    record && record.user && record.user.activated_at ? l(record.user.activated_at) : "-"
  end
  
  def image_url_column(record)
    if record.image.file?
      image_tag(record.image.url(:small), {:width => '30'})
    else
      record.female? ? 
        '<img src="/images/person/lay_woman_small.jpg" alt="Profilbild" width="30"/>' : 
          '<img src="/images/person/lay_small.jpg" alt="Profilbild" width="30"/>'
    end
  end

  def image_form_column(record, name)
    html = ''
    if record.image.file?
      html << image_tag(record.image.url(:small))
      html << "&nbsp;"
      html << image_tag(record.image.url(:normal))
      html << "&nbsp;"
      html << link_to("Remove", destroy_asset_admin_advocate_path(record, :select => "image"), :confirm => "Wirklich löschen?", :method => :post) 
      html << "<br/>"
    end
    html << file_field(:record, :image)
    html
  end

  def logo_form_column(record, name)
    html = ''
    if record.logo.file?
      html << image_tag(record.logo.url(:normal))
      html << "&nbsp;"
      html << link_to("Remove", destroy_asset_admin_advocate_path(record, :select => "logo"), :confirm => "Wirklich löschen?", :method => :post) 
      html << "<br/>"
    end
    html << file_field(:record, :logo)
    html
  end
  
  def title_and_name_column(record)
    "#{record.title_and_name} (#{record.number})"
  end
  
  def total_contacts_count_column(record)
    "<b>#{record.total_contacts_count}</b> (#{record.premium_contacts_count} #{Advocate.human_attribute_name(:premium_contacts_count)}, #{record.promotion_contacts_count} #{Advocate.human_attribute_name(:promotion_contacts_count)})"
  end

end
