require 'webdriver-user-agent/core_ext/symbol'
require 'webdriver-user-agent/driver'

module Webdriver
  module UserAgent
    def self.driver options={}
      Driver.instance.for options
    end

    def self.devices
      Driver.instance.devices
    end

    def self.resolution_for device_name, orientation
      Driver.instance.resolution_for device_name, orientation
    end

    def self.agent_string_for device
      Driver.instance.agent_string_for device
    end 

  end
end
