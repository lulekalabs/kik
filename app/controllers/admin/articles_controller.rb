class Admin::ArticlesController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :article do |config|
    #--- columns
    standard_columns = [
      :id,
      :person_id,
      :type,
      :status,
      :title,
      :body,
      :summary,
      :author_name,
      :tag_list_s,
      :blog,
      :law_article,
      :press_release,
      :press_review,
      :faq,
      :dictionary,
      :image_url,
      :image,
      :primary_attachment_name,
      :primary_attachment_url,
      :primary_attachment,
      :secondary_attachment_name,
      :secondary_attachment_url,
      :secondary_attachment,
      :url,
      :client_view,
      :advocate_view,
      :kik_view,
      :advofinder_view,
      :topics,
      :view
    ]
    crud_columns = [
      :title,
      :summary,
      :body,
      :url,
      :image,
      :primary_attachment_name,
      :primary_attachment,
      :secondary_attachment_name,
      :secondary_attachment,
      :tag_list_s,
      :person_id,
      :author_name,

      :law_article,
      :blog,
      :press_release,
      :press_review,
      :faq,
      :dictionary,
      
      :topics
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns - [:type]
    config.show.columns = crud_columns
    config.list.columns = [:image_url, :type, :view, :title, :author_name, :status, :tag_list_s, :created_at]

    config.columns[:law_article].form_ui = :checkbox
    config.columns[:blog].form_ui = :checkbox
    config.columns[:press_release].form_ui = :checkbox
    config.columns[:press_review].form_ui = :checkbox
    config.columns[:faq].form_ui = :checkbox
    config.columns[:dictionary].form_ui = :checkbox

    config.columns[:client_view].form_ui = :checkbox
    config.columns[:advocate_view].form_ui = :checkbox
    config.columns[:kik_view].form_ui = :checkbox
    config.columns[:advofinder_view].form_ui = :checkbox
    
    config.create.multipart = true
    config.update.multipart = true
    
    #--- labels
    config.columns[:person_id].label        = "Herausgeber"
    config.columns[:person_id].description  = "Herausgeberrechte werden <a href=\"/admin/advocates\">hier</a> vergeben"
    config.columns[:tag_list_s].label       = "Stichwörter"
    config.columns[:tag_list_s].description = "Kommasepararierte Stichwortvergabe, <a href='/admin/tags' target='_blank'>Stichwortliste</a>"
    config.columns[:type].label             = "Kategorie"
    config.columns[:title].label            = "Überschrift"
    config.columns[:body].label             = "Inhalt"

    config.columns[:summary].label          = "Introtext"
    config.columns[:summary].description    = "Kurzzusammenfassung als Teaser-Text"

    config.columns[:url].label              = "Link"
    config.columns[:url].description        = "URL Link zum Artikel, wird im Pressespiegel als Link zum Artikel verwendet, z.B. http://www.spiegel.de"

    config.columns[:author_name].label      = "Author"
    config.columns[:author_name].description = "Name des Authors, falls leer, dann erscheint der Names des Herausgebers"

    config.columns[:law_article].label             = "Artikel zu Rechtsthemen"
    config.columns[:law_article].description       = "Ein Artikel zu Rechtsthemen"
    config.columns[:blog].label             = "Blogeintrag"
    config.columns[:blog].description       = "Weist den Artikel dem Blog zu"
    config.columns[:press_release].label    = "Pressemitteilung"
    config.columns[:press_release].description  = "Weist den Artikel den Pressemitteilungen zu"
    config.columns[:press_review].label     = "Pressespiegel"
    config.columns[:press_review].description  = "Weist den Artikel dem Pressespiegel zu"
    config.columns[:faq].label              = "FAQ"
    config.columns[:faq].description        = "Weist den Artikel einer häufig gestellten Frage (FAQ) zu"
    config.columns[:dictionary].label       = "Rechtslexikon"
    config.columns[:dictionary].description = "Weist den Artikel dem Rechtslexikon zu"
    config.columns[:image_url].label        = "Bild"
    config.columns[:image].label            = "Bild"

    config.columns[:primary_attachment_name].label     = "Name Anhang 1"
    config.columns[:primary_attachment_name].description = "Erscheint als Name, falls leer, dann erscheint der Dateiname"
    config.columns[:primary_attachment_url].label      = "Anhang 1"
    config.columns[:primary_attachment].label          = "Anhang 1"
    config.columns[:secondary_attachment_name].label   = "Name Anhang 2"
    config.columns[:secondary_attachment_name].description = "Erscheint als Name, falls leer, dann erscheint der Dateiname"
    config.columns[:secondary_attachment_url].label    = "Anhang 2"
    config.columns[:secondary_attachment].label        = "Anhang 2"

    config.columns[:kik_view].label             = "kann-ich-klagen.de"
    config.columns[:advofinder_view].label      = "advofinder.de"
    config.columns[:client_view].label          = "Für Rechtsuchende"
    config.columns[:advocate_view].label        = "Für Anwälte"

    config.columns[:topics].label               = "Zuweisung von Rechtsthemen"

    #--- groups
    config.update.columns.add_subgroup "Icon" do |group|
      group.add :image
    end

    config.create.columns.add_subgroup "Icon" do |group|
      group.add :image
    end

    config.update.columns.add_subgroup "Erster Anhang" do |group|
      group.add :primary_attachment_name
      group.add :primary_attachment
    end

    config.create.columns.add_subgroup "Erster Anhang" do |group|
      group.add :primary_attachment_name
      group.add :primary_attachment
    end

    config.update.columns.add_subgroup "Zweiter Anhang" do |group|
      group.add :secondary_attachment_name
      group.add :secondary_attachment
    end

    config.create.columns.add_subgroup "Zweiter Anhang" do |group|
      group.add :secondary_attachment_name
      group.add :secondary_attachment
    end

    config.update.columns.add_subgroup "Kategorien" do |group|
      group.add :law_article
      group.add :blog
      group.add :press_release
      group.add :press_review
      group.add :faq
      group.add :dictionary
    end

    config.create.columns.add_subgroup "Kategorien" do |group|
      group.add :law_article
      group.add :blog
      group.add :press_release
      group.add :press_review
      group.add :faq
      group.add :dictionary
    end

    config.update.columns.add_subgroup "Seiten" do |group|
      group.add :kik_view
      group.add :advofinder_view
    end

    config.create.columns.add_subgroup "Seiten" do |group|
      group.add :kik_view
      group.add :advofinder_view
    end

    config.update.columns.add_subgroup "Rechtssuchende oder Anwälte" do |group|
      group.add :client_view
      group.add :advocate_view
    end

    config.create.columns.add_subgroup "Rechtssuchende oder Anwälte" do |group|
      group.add :client_view
      group.add :advocate_view
    end

    
    #--- actions
    toggle_state_link = ActiveScaffold::DataStructures::ActionLink.new 'Publish', 
      :action => 'toggle_state', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post,
      :confirm => "Wirklich den Status ändern?"
    def toggle_state_link.label
      return "[Veröffentlichen]" if record.next_state_for_event(:publish)
      return "[Sperren]" if record.next_state_for_event(:suspend)
      return "[Reaktivieren]" if record.next_state_for_event(:unsuspend)
      ''
    end
    config.action_links.add toggle_state_link

    # search
    config.actions.exclude :search
    config.actions.add :advanced_search
    config.advanced_search.link.page = false
    config.advanced_search.link.inline = true
    
  end  

  #--- actions

  def toggle_state
    @record = Article.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?    
    
    if @record.current_state == :created && @record.next_state_for_event(:publish)
      do_list_action(:publish!) 
      return
    elsif @record.next_state_for_event(:suspend)
      do_list_action(:suspend!)
      return
    elsif @record.next_state_for_event(:unsuspend)
      do_list_action(:unsuspend!) 
      return
    end
    render :nothing => true
  end
  
  def destroy_asset
    if @record = Article.find_by_id(params[:id])
      if params[:select] =~ /^image/
        @record.image.destroy
      elsif params[:select] =~ /^primary_attachment/
        @record.primary_attachment.destroy
        @record.primary_attachment_file_name = nil
      elsif params[:select] =~ /^secondary_attachment/
        @record.secondary_attachment.destroy
        @record.secondary_attachment_file_name = nil
      end
      @record.save
      redirect_to edit_admin_article_path(@record)
    end
  end

  protected 
  
  # workaround for STI problem
  # we save the record manually, then all works fine
  def before_update_save(record)
    @record.attributes = params[:record]
  end
  alias_method :before_create_save, :before_update_save

end
