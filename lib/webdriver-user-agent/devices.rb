require 'yaml'

module Webdriver
  module UserAgent
    module Devices

      def devices
        string_hash = YAML.safe_load_file devices_file, aliases: true
        JSON.parse(JSON[string_hash], symbolize_names: true)
      end

      def resolution_for(device_name, orientation, user_width, user_height)
        return [user_width.to_i, user_height.to_i] if ((user_width.to_i + user_height.to_i) > 1)

        device = devices[keyify(device_name)][keyify(orientation)]
        [device[:width],device[:height]]
      end

      def agent_string_for(device)
        device = (device ? keyify(device) : :iphone)
        user_agent_string = (device == :random ? random_user_agent : devices[device][:user_agent])
        raise "Unsupported user agent: '#{device}'." unless user_agent_string
        user_agent_string
      end

      private
      
      def keyify(target)
        target.downcase.to_sym
      end

      def random_user_agent
        File.foreach(user_agents_file).each_with_index.reduce(nil) do |picked,pair|
          rand < 1.0/(1+pair[1]) ? pair[0] : picked
        end
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
