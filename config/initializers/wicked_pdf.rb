if RAILS_ENV == "development"
WickedPdf.config = {
  :exe_path => '/opt/local/bin/wkhtmltopdf'
}
elsif RAILS_ENV == "staging"
  WickedPdf.config = {
    :exe_path => '/usr/local/bin/wkhtmltopdf'
  }
elsif RAILS_ENV == "production"
  WickedPdf.config = {
    :exe_path => '/vhome/kann-ich-klagen.de/data/wkhtmltopdf'
  }
end
