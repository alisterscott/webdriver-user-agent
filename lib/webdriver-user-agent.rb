require 'webdriver-user-agent/core_ext/symbol'
require 'webdriver-user-agent/driver'

module Webdriver
  module UserAgent
    class << self
      def driver(options = {})
        Driver.instance.for options
      end

      def devices
        Driver.instance.devices
      end

      def resolution_for(device_name, orientation)
        Driver.instance.resolution_for device_name, orientation
      end

      def agent_string_for(device)
        Driver.instance.agent_string_for device
      end
    end
  end
end
