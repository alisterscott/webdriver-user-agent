require 'facets/hash/except'

module Webdriver
  module UserAgent

    MINIMUM_MACOS_VERSION_NUMBER = 12

    class BrowserOptions

      def initialize(opts, user_agent_string)
        @options = opts
        options[:browser] ||= :firefox
        options[:agent] ||= :iphone
        options[:orientation] ||= :portrait
        set_preview_option(options[:safari_technology_preview]) if (@options[:browser] == :safari)

        options[:viewport_width], options[:viewport_height] = parse_viewport_sizes(options[:viewport_width], options[:viewport_height])

        initialize_for_browser(user_agent_string)
      end

      def method_missing(*args, &block)
        m = args.first
        value = options[m]
        super unless value
        value.downcase
      end

      def browser_options
        options.except(:browser, :agent, :orientation, :user_agent_string, :viewport_width, :viewport_height)
      end

      private

      def options
        @options ||= {}
      end

      def set_preview_option(opt)
        @stp = opt
        @stp = false unless @stp.is_a?(TrueClass)
      end

      def initialize_for_browser(user_agent_string)
        case options[:browser]
        when :firefox
          profile ||= Selenium::WebDriver::Firefox::Profile.new
          profile['general.useragent.override'] = user_agent_string

          options[:options] ||= Selenium::WebDriver::Firefox::Options.new
          options[:options].profile = profile
        when :chrome
          options[:options] ||= Selenium::WebDriver::Chrome::Options.new
          options[:options].add_argument "--user-agent=#{user_agent_string}"
        when :safari
          change_safari_user_agent_string(user_agent_string)
          options
        else
          raise "WebDriver UserAgent currently only supports :chrome, :firefox and :safari."
        end
      end

      def parse_viewport_sizes(width, height)
        return ["0","0"] unless "#{width}".to_i > 0 && "#{height}".to_i > 0

        ["#{width}", "#{height}"]
      end

      def change_safari_user_agent_string(user_agent_string)
        raise "Safari requires a Mac" unless OS.mac?

        ua  = "\\\"#{user_agent_string}\\\"" # escape for shell quoting
        if @stp
          Selenium::WebDriver::Safari.technology_preview!
          cmd = "defaults write com.apple.SafariTechnologyPreview CustomUserAgent \"#{ua}\""
        else
          cmd = "defaults write com.apple.Safari CustomUserAgent \"#{ua}\""
        end

        output = `#{cmd}`

        error_message  = "Unable to execute '#{cmd}'. "
        error_message += "Error message reported: '#{output}'"
        error_message += "Please execute the command manually and correct any errors."

        raise error_message unless $?.success?
      end

      # Require a Mac at version 12 (Sierra) or greater
      def require_mac_version
        raise "Safari requires a Mac" unless OS.mac?
        raise "Selenium only works with Safari on Sierra or newer" unless valid_mac_version?
      end

      def valid_mac_version?
        version = "#{`defaults read loginwindow SystemVersionStampAsString`}"
        version_number = "#{version.split(".")[1]}"
        version_number.to_i >= MINIMUM_MACOS_VERSION_NUMBER
      end

    end
  end
end
