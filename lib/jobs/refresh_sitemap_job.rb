# Creates and refreshes the sitemap by pinging all major search engines
require 'rake'
class RefreshSitemapJob

  def perform
    if RAILS_ENV == 'production'
      system("rake sitemap:refresh")
    else
      system("rake sitemap:refresh:no_ping")
    end
  end

end  
