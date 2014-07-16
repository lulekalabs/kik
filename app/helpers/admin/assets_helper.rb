module Admin::AssetsHelper

  def file_url_column(record)
    if record.file.file?
      image_tag(record.file.url(:thumb), {:size => '80x80'})
    else
      '[Kein Bild]'
    end
  end

  def file_form_column(record, name)
    html = ''
    if record.file.file? && record.image?
      html << image_tag(record.file.url(:thumb), {:size => '80x80'})
      html << "<br/>"
    end
    html << file_field(:record, :file)
    html
  end

end