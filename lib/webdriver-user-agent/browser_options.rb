require 'facets/hash/except'

module Webdriver
  module UserAgent

    MINIMUM_MACOS_VERSION_NUMBER = 12
    DEFAULT_BROWSER = :firefox
    DEFAULT_AGENT = :iphone
    DEFAULT_ORIENTATION = :portrait

    class BrowserOptions

      def initialize(opts, user_agent_string)
        @options = opts
        options[:browser] ||= :firefox
        options[:agent] ||= :iphone
        options[:orientation] ||= :portrait
        set_preview_option(options[:safari_technology_preview]) if (@options[:browser] == :safari)

        options[:viewport_width], options[:viewport_height] = parse_viewport_sizes(options[:viewport_width], options[:viewport_height])

        initialize_for_browser(user_agent_string, opts[:accept_language_string], opts[:options])
      end

      def method_missing(*args, &block)
        m = args.first
        value = options[m]
        super unless value
        value.downcase
      end

      def browser_options
        options.except(:browser, :agent, :orientation, :user_agent_string, :accept_language_string, :viewport_width, :viewport_height, :safari_technology_preview)
      end

      private

      def options
        @options ||= {}
      end

      def set_preview_option(opt)
        @stp = opt
        @stp = false unless @stp.is_a?(TrueClass)
      end

      def initialize_for_browser(user_agent_string, accept_language_string, driver_options = nil)
        options[:options] ||= driver_options

        case options[:browser]
        when :firefox
          options[:options] ||= Selenium::WebDriver::Firefox::Options.new

          profile ||= options[:options].profile || Selenium::WebDriver::Firefox::Profile.new
          set_keys = profile.instance_variable_get(:@additional_prefs).keys

          profile['general.useragent.override'] = user_agent_string if !set_keys.include?('general.useragent.override')
          profile['intl.accept_languages'] = accept_language_string if accept_language_string && !set_keys.include?('intl.accept_languages')

          options[:options].profile = profile
        when :chrome
          options[:options] ||= Selenium::WebDriver::Chrome::Options.new

          set_args = options[:options].args.map{|s| "#{s}"}.join(" ")
          options[:options].add_argument "--user-agent=#{user_agent_string}" if !set_args.include?("--user-agent=")

          set_prefs = options[:options].prefs.keys
          options[:options].add_preference("intl.accept_languages", accept_language_string) if accept_language_string && !set_prefs.include?("intl.accept_languages")
        when :safari
          options[:options] ||= Selenium::WebDriver::Safari::Options.new
          change_safari_user_agent_string(user_agent_string)
          change_safari_language(accept_language_string) if accept_language_string
        else
          raise "WebDriver UserAgent currently only supports :chrome, :firefox and :safari."
        end
      end

      def parse_viewport_sizes(width, height)
        return ["0","0"] unless "#{width}".to_i > 0 && "#{height}".to_i > 0

        ["#{width}", "#{height}"]
      end

      def change_safari_user_agent_string(user_agent_string)
        ua  = "\"\\\"#{user_agent_string}\\\"\"" # escape for shell quoting

        safari_command_runner(ua, "CustomUserAgent")
      end

      def change_safari_language(accept_language_string)
        parsed_safari_string = prepare_safari_string(accept_language_string)

        safari_command_runner(parsed_safari_string, "AppleLanguages")
      end

      def safari_command_runner(setting, pref)
        raise "Safari requires a Mac" unless OS.mac?

        cmd = "defaults write com.apple.#{safari_version} #{pref} #{setting}"
        output = `#{cmd}`

        raise prepare_safari_error_message(cmd, output) unless safari_command_success?(setting, safari_version, pref, $?)
      end

      def safari_command_success?(setting, safari_version, pref, result)
        setting_chars = "#{setting}".gsub(/\W/, '')
        read_chars = `defaults read com.apple.#{safari_version} #{pref}`.gsub(/\W/, '')

        setting_match = (setting_chars == read_chars)
        setting_match && result.success?
      end

      def safari_version
        if @stp
          Selenium::WebDriver::Safari.technology_preview!
          return "SafariTechnologyPreview"
        end

        "Safari"
      end

      def prepare_safari_error_message(cmd, output)
        error_message  = "Unable to execute '#{cmd}'. "
        error_message += "Error message reported: '#{output}'"
        error_message += "Please execute the command manually and correct any errors."

        error_message
      end

      def prepare_safari_string(accept_language_string)
        ["'(", accept_language_string.split(",").map{|l|
          "\"#{l.gsub(/\s+/,'')}\""
        }.join(", "), ")'"].join('')
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
