xml.instruct! :xml, :version => "1.0"
xml.rss "version" => "2.0" do
  xml.channel do
    xml.title(@title)
    xml.description h(@description)
    xml.link formatted_service_blogs_url(:rss)

    @posts.each do |post|
      xml.item do
        xml.title h(post.title)
        xml.link service_blogs_url

        xml.description simple_format(h(post.summary))
        xml.pubDate post.created_at.to_s(:rfc822)
        xml.link service_blog_url(post)
      end
    end
    
  end
end