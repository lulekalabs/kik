module ActiveScaffold
  module Helpers

    module AdvancedSearchViewHelpers

      def self.included(base)
        base.send :alias_method_chain, :active_scaffold_includes, :advanced_search
      end

      def active_scaffold_includes_with_advanced_search(*args)
        frontend = args.first.is_a?(Symbol) ? args.shift : :default
        options = args.first.is_a?(Hash) ? args.shift : {}

        css = stylesheet_link_tag(ActiveScaffold::Config::Core.asset_path('advanced_search.css', frontend))
        # ie_css = stylesheet_link_tag(ActiveScaffold::Config::Core.asset_path("export-stylesheet-ie.css", frontend))
        ie_css = ""
        js = javascript_include_tag(ActiveScaffold::Config::Core.asset_path('advanced_search.js', frontend))
        active_scaffold_includes_without_advanced_search + "\n" + css + "\n<!--[if IE]>" + ie_css + "<![endif]-->\n" + js
      end

    end

  end
end
