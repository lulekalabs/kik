module Client::ArticlesHelper
  
  def articles_header_in_words
    if @topic
      "Artikel zu Rechtsthemen: #{h(@topic.name)}"
    elsif @search_tag_list && !@search_tag_list.blank?
      "Artikel zu Rechtsthemen #{search_tag_list_in_words}"
    elsif (year = params[:year]) && (month = params[:month])
      "Artikel zu Rechtsthemen im #{I18n::t("date.month_names")[month.to_i]} #{year.to_i}"
    else
      "Artikel zu Rechtsthemen"
    end
  end
  
end
