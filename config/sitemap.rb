# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://kann-ich-klagen.de"
controller.request.host = "kann-ich-klagen.de"

SitemapGenerator::Sitemap.add_links do |sitemap|
  #=== static pages

  #--- advocates
  sitemap.add advocate_faqs_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add new_advocate_user_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add kodex_client_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add new_advocate_recommendation_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add advocate_account_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add questions_advocate_account_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add overview_advocate_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add benefits_advocate_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  
  #--- clients
  sitemap.add client_articles_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add client_faqs_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add new_question_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add charter_client_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add client_account_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add legal_advice_cost_client_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add client_dictionaries_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add client_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0

  #--- service
  sitemap.add home_page_corporate_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add service_blogs_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add brochure_corporate_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add video_corporate_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add new_service_newsletter_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add new_service_recommendation_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add service_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0
  sitemap.add what_url, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0

  #=== dynamic pages

end
