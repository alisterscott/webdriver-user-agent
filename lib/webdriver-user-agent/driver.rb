require 'yaml'
require 'json'
require 'selenium-webdriver'
require 'facets/hash/except'
require 'webdriver-user-agent/browser_options'

module Webdriver
  module UserAgent
    class Driver
      include Singleton

      def for(opts)
        user_agent_string = agent_string_for opts[:agent]
        options = BrowserOptions.new(opts, user_agent_string)
        build_driver_using options
      end

      def devices
        YAML.load_file devices_file
      end


      def resolution_for(device_name, orientation)
        device = devices[device_name.downcase][orientation.downcase]
        [device[:width],device[:height]]
      end

      def agent_string_for(device)
        device = (device ? device.downcase : :iphone)
        user_agent_string = (device == :random ? random_user_agent : devices[device][:user_agent])
        raise "Unsupported user agent: '#{device}'." unless user_agent_string
        user_agent_string
      end

      private

      def random_user_agent
        File.foreach(user_agents_file).each_with_index.reduce(nil) do |picked,pair|
          rand < 1.0/(1+pair[1]) ? pair[0] : picked
        end
      end

      def resize_inner_window(driver, width, height)
        if driver.browser == :firefox or :chrome
          driver.execute_script("window.open(#{driver.current_url.to_json},'_blank');")
          driver.close
          driver.switch_to.window driver.window_handles.first
        end
        driver.execute_script("window.innerWidth = #{width}; window.innerHeight = #{height};")
      end

      def build_driver_using(options)
        driver = Selenium::WebDriver.for options.browser, options.browser_options
        unless options.agent == :random
          resize_inner_window(driver, *resolution_for(options.agent, options.orientation))
        end
        driver
      end

      def user_agents_file
        File.expand_path("../../device-info/user_agents.txt", __FILE__)
      end

      def devices_file
        File.expand_path("../../device-info/devices.yaml", __FILE__)
      end
    end
  end
end
