require 'json'
require 'os'
require 'selenium-webdriver'
require 'webdriver-user-agent/browser_options'
require 'webdriver-user-agent/devices'

module Webdriver
  module UserAgent
    class Driver
      include Singleton
      include Devices

      def for(opts)
        user_agent_string   = opts[:user_agent_string]
        user_agent_string ||= agent_string_for opts[:agent]
        options = BrowserOptions.new(opts, user_agent_string)
        build_driver_using options
      ensure
        if safari?(opts)
          case
          when opts[:safari_technology_preview].is_a?(TrueClass)
            `defaults delete com.apple.SafariTechnologyPreview CustomUserAgent`
            `defaults delete com.apple.SafariTechnologyPreview AppleLanguages`
          else
            `defaults delete com.apple.Safari CustomUserAgent`
            `defaults delete com.apple.Safari AppleLanguages`
          end
        end
      end

      private

      def resize_inner_window(driver, width, height)
        target_size = Selenium::WebDriver::Dimension.new(width.to_i, height.to_i)
        driver.manage.window.resize_to target_size.width, target_size.height
      end

      def build_driver_using(options)
        driver = Selenium::WebDriver.for options.browser, options.browser_options
        unless options.agent == :random
          resize_inner_window(driver, *resolution_for(options.agent, options.orientation, options.viewport_width, options.viewport_height))
        end
        driver
      end

      def safari?(o = {})
        o[:browser] == :safari
      end
    end
  end
end
