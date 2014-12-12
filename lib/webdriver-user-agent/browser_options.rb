require 'facets/hash/except'

module Webdriver
  module UserAgent
    class BrowserOptions

      def initialize(opts, user_agent_string)
        @options = opts
        options[:browser] ||= :firefox
        options[:agent] ||= :iphone
        options[:orientation] ||= :portrait
        initialize_for_browser(user_agent_string)
      end

      def method_missing(*args, &block)
        m = args.first
        value = options[m]
        super unless value
        value.downcase
      end

      def browser_options
        options.except(:browser, :agent, :orientation, :user_agent_string)
      end

      private

      def options
        @options ||= {}
      end

      def initialize_for_browser(user_agent_string)
        case options[:browser]
        when :firefox
          options[:profile] ||= Selenium::WebDriver::Firefox::Profile.new
          options[:profile]['general.useragent.override'] = user_agent_string
        when :chrome
          options[:switches] ||= []
          options[:switches] << "--user-agent=#{user_agent_string}"
        else
          raise "WebDriver UserAgent currently only supports :firefox and :chrome."
        end
        
      end
    end
  end
end
