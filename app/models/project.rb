# class holds meta information about the entire app
class Project

  mattr_writer :pre_launch
  @@pre_launch = true
  mattr_writer :user_optin
  @@user_optin = true
  mattr_accessor :realm
  @@realm = "kik"

  cattr_accessor :default_recurring_options
  @@default_recurring_options = {:interval => {:length => 1, :unit => :month}, 
    :duration => {:occurrences => 999}}

  @@file_extensions_to_content_types = {
    'jpg'  => ['image/jpeg', 'image/pjpeg'],
    'jpeg' => ['image/jpeg', 'image/pjpeg'],
    'bmp'  => ['image/bmp'],
    'png'  => ['image/png', 'image/x-png'],
    'gif'  => ['image/gif'],
    'swf' => "application/x-shockwave-flash",
    'pdf' => ["application/pdf", "application/x-pdf"],
    'sig' => "application/pgp-signature",
    'spl' => "application/futuresplash",
    'doc' => ["application/msword", "application/x-doc", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"],
    'xls' => ["application/ms-excel", "application/x-xls"],
    'ps' => "application/postscript",
    'torrent' => "application/x-bittorrent",
    'dvi' => "application/x-dvi",
    'gz' => "application/x-gzip",
    'pac' => "application/x-ns-proxy-autoconfig",
    'swf' => "application/x-shockwave-flash",
    'tar.gz' => "application/x-tgz",
    'tar' => "application/x-tar",
    'zip' => "application/zip",
    'mp3' => "audio/mpeg",
    'm3u' => "audio/x-mpegurl",
    'wma' => "audio/x-ms-wma",
    'wax' => "audio/x-ms-wax",
    'wav' => "audio/x-wav",
    'xbm' => "image/x-xbitmap",
    'xpm' => "image/x-xpixmap",
    'xwd' => "image/x-xwindowdump",
    'css' => "text/css",
    'html' => "text/html",
    'js' => "text/javascript",
    'txt' => "text/plain",
    'xml' => "text/xml",
    'mpeg' => "video/mpeg",
    'mov' => "video/quicktime",
    'avi' => "video/x-msvideo",
    'asf' => "video/x-ms-asf",
    'wmv' => "video/x-ms-wmv"
  }
  
  class << self

    # returns true for pre launch phase later, false
    def pre_launch?
      !!@@pre_launch
    end

    # returns true for confirmation emails for user signup
    def user_optin?
      !!@@user_optin
    end

    # returns an array of content_type for the given file_name
    #
    # e.g. 
    #
    #   Meta.content_type "ginger.png"  ->  ["image/png", "image/x-png"]
    #   Meta.content_type "test.gif"  ->  ['image/gif']
    #
    def content_type(file_name)
      if file_name =~ /\.([^\.]*)$/
        file_extension = $1.downcase
        return @@file_extensions_to_content_types[file_extension]
      end
    end

    # returns all valid content types for image uploads
    # as array of content types
    def image_content_types
      result = [] + [content_type("test.gif")] + [content_type("test.png")] +
        [content_type("test.jpg")] + [content_type("test.jpeg")]
      result.flatten.uniq
    end

    # returns all valid file asset content types
    def file_asset_content_types
      result = image_content_types + [content_type("example.doc")] + 
        [content_type("example.pdf")] + [content_type("example.xls")]
      result.flatten.uniq
    end
    
    # returns true if ssl is supported
    # used in application_controller and notifiers for ssl_supported?
    def ssl_supported?
      RAILS_ENV == 'production' # || RAILS_ENV == 'staging'
    end
    
    # UUID, e.g. "589393ef-6add-4b87-ad6c-21aac6902017"
    def generate_random_uuid
      defined?(UUIDTools) ? UUIDTools::UUID.random_create.to_s : UUID.random_create.to_s
    end
   
    # Translates a province name to a province code
    #
    # E.g. 
    #
    #  "Baden-Württemberg" -> "BW"
    #  "BW" -> "BW"
    #  "Bavaria" -> "BY"
    #
    def province_name_to_code(name)
      save_locale = I18n.locale
      I18n.locale = :de
      I18n.t("provinces.DE").to_a.find {|p| p.last == name ? (return p.first.to_s) : false}
      I18n.t("provinces.DE").to_a.find {|p| p.first.to_s == name ? (return p.first.to_s) : false}
      I18n.locale = :en
      I18n.t("provinces.DE").to_a.find {|p| p.last == name ? (return p.first.to_s) : false}
      I18n.t("provinces.DE").to_a.find {|p| p.first.to_s == name ? (return p.first.to_s) : false}
    ensure
      I18n.locale = save_locale
    end

   # are we in advofinder?
    def advofinder_realm?
      Project.realm == "advofinder"
    end
    alias_method :af_realm?, :advofinder_realm?

    # are we in kik?
    def kik_realm?
      Project.realm.blank? || Project.realm == "kik"
    end
   
    def name(project=nil)
      if (!project && kik_realm?) || (project && project.to_s =~ /^(kik)$/i)
        "kann-ich-klagen.de"
      elsif (!project && af_realm?) || (project && project.to_s =~ /^(af|advofinder)$/i)
        "advofinder.de"
      end
    end

    def domain(project=nil)
      if (!project && kik_realm?) || (project && project.to_s =~ /^(kik)$/i)
        "kann-ich-klagen.de"
      elsif (!project && af_realm?) || (project && project.to_s =~ /^(af|advofinder)$/i)
        "advofinder.de"
      end
    end

    def host(project=nil)
      if (!project && kik_realm?) || (project && project.to_s =~ /^(kik)$/i)
        "www.kann-ich-klagen.de"
      elsif (!project && af_realm?) || (project && project.to_s =~ /^(af|advofinder)$/i)
        "www.advofinder.de"
      end
    end
    
  end
  
end