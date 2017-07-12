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
        # Note that `com.apple.SafariTechnologyPreview` is the name specific
        # to the beta browser provided by Apple, which is required to use
        # Selenium with Safari, as of July 2017.
        # https://github.com/SeleniumHQ/selenium/issues/2904#issuecomment-261736814
        # If this changes, and this gem is changed to support using the
        # golden master Safari, the name of the configuration should be
        # changed to `com.apple.Safari`
        `defaults delete com.apple.SafariTechnologyPreview CustomUserAgent` if safari?(opts)
      end

      private

      def resize_inner_window(driver, width, height)
        target_size = Selenium::WebDriver::Dimension.new(width.to_i, height.to_i)

        case driver.browser
        when :firefox || :chrome
        when :safari
          # The other resizing windows method does not work for Safari
          # and I'm unsure what the purpose of opening the second window is.
          # Regardless, Safari doesn't seem to respond to the script, so
          # closing the driver closes the connection to Safari altogether.
          # Also, driver.manage.window.size = target_size raises an error:
          #   Selenium::WebDriver::Error::WebDriverError: unexpected response, code=400, content-type="text/plain"
          #   Required parameter 'width' has incorrect type: expected number.
          driver.manage.window.resize_to target_size.width, target_size.height
        else
          driver.execute_script("window.open(#{driver.current_url.to_json},'_blank');")
          driver.close
          driver.switch_to.window driver.window_handles.first
          driver.manage.window.size = target_size
        end
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
