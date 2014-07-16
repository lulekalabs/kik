# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # renders the block with the given template format
  #
  # e.g.
  #
  #   with_format :html do 
  #     render ...
  #   end
  #
  def with_format(format, &block)
    old_format = @template_format
    @template_format = format
    result = block.call
    @template_format = old_format
    return result
  end

  def draw_flash_message
    if block_given?
      [:notice , :flash , :error, :warning].each do |value|
        yield value , flash[value] if flash[value]
      end
    end
  end
  
  def link_to_expect_pre_launch *args
    if expect_pre_launch
      args[1]="#pre_launch"
      args[2][:class]="pre_launch_modal"
    end
    link_to args[0],args[1],args[2]
  end
  
  # returns true if locked
  def expect_pre_launch?
    Project.pre_launch? && (Rails.env == "production" || !session[:open_sesame]) 
  end
  alias_method :expect_pre_launch, :expect_pre_launch?
  
  # javascript for luleka feedback widget
  def feedback_javascript(options={})
    options = {
      :key => 'kann-ich-klagen',
      :locale => "de",
      :show_tab => false,
      :tab_top => '45%',
      :tab_type => 'support',
      :tab_alignment => 'left',
      :tab_background_color => '#0069B5',
      :tab_text_color => 'white',
      :tab_hover_color => '#00AFE6'
    }.merge(options)

    js_location = "www.luleka.com/javascripts/widgets/boot.js"

    <<-JS
var lulekaOptions = #{options.to_json};
function _loadLuleka() {
  var s = document.createElement('script');
  s.setAttribute('type', 'text/javascript');
  s.setAttribute('src', ("https:" == document.location.protocol ? "https://" : "http://") + "#{js_location}");
  document.getElementsByTagName('head')[0].appendChild(s);
}
_loadSuper = window.onload;
window.onload = (typeof window.onload != 'function') ? _loadLuleka : function() { _loadSuper(); _loadLuleka(); };
    JS
  end
  
  # javascript tag for luleka feedback widget
  def feedback_javascript_tag(options={})
    javascript_tag(feedback_javascript(options))
  end

  # returns javascript for google analytics
  def ga_async_javascript(id)
    <<-JS
var _gaq = _gaq || [];
_gaq.push(['_setAccount', '#{id}']);
_gaq.push(['_setDomainName', '.kann-ich-klagen.de']);
_gaq.push(['_gat._anonymizeIp']);
_gaq.push(['_trackPageview']);

(function() {
  var ga = document.createElement('script');
  ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
  ga.setAttribute('async', 'true');
  document.documentElement.firstChild.appendChild(ga);
})();
    JS
  end

  # wraps ga code in a script tag
  def ga_async_javascript_tag(id)
    javascript_tag(ga_async_javascript(id)) if RAILS_ENV == "production"
  end

  # <li class='select'><a href='/admin'>Home</a></li>
  # 
  # E.g.
  #
  #   tab_list_item_link_to("Hi!", questions_path, @acond && @bcond, :class => "bla")  # multiple conditions
  #   tab_list_item_link_to("Hi!", questions_path, {:class => "mini"}) # current page path condition
  #
  def tab_list_item_link_to(name, url, *args)
    if args.first.is_a?(Hash)
      selected = nil
      html_list_options = args.first || {}
      html_link_options= args.second || {}
    elsif args.first.is_a?(NilClass) || args.first.is_a?(TrueClass) || args.first.is_a?(FalseClass)
      selected = args.first
      html_list_options = args.second || {}
      html_link_options= args.third || {}
    end
    
    if selected.nil?
      html_list_options[:class] = "select #{html_list_options[:class]}" if current_page?(url)
    else
      html_list_options[:class] = "select #{html_list_options[:class]}" if selected
    end
    content_tag(:li, link_to(name, url, html_link_options), html_list_options)
  end
  
  # <li class='select'><a href='/admin'>Home</a></li>
  def tab_list_item_link_to_unless_current(name, url, html_list_options={}, html_link_options={})
    html_list_options[:class] = "select #{html_list_options[:class]}" if current_page?(url)
    content_tag(:li, link_to(name, url, html_link_options), html_list_options)
  end
  
  
end
