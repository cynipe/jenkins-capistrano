
module Jenkins
  class Client
    module PluginManager

      def plugin_names
        self.class.get("/pluginManager/api/json?tree=plugins[shortName]")['plugins'].map {|plugin| plugin['name'] }
      end

      def prevalidate_plugin_config(plugins)
        config = generate_config(plugins)
        res = self.class.post("/pluginManager/prevalidateConfig", xml_body(config))
        raise ServerError, parse_error_message(res) unless res.code.to_i == 200
        # why does HTTParty parses the response as xml?
        JSON.parse(res.body)
      end

      def install_plugin(plugins, timeout = 60)
        config = generate_config(plugins)
        res = self.class.post("/pluginManager/installNecessaryPlugins", xml_body(config))
        raise ServerError, parse_error_message(res) unless res.code.to_i == 302
      end

      private
      def xml_body(xml_str)
        {
          :body => xml_str,
          :format => :xml,
          :headers => { 'content-type' => 'application/xml' }
        }
      end

      def generate_config(config)
        plugins = config.map do |v|
          plugin = case
            when v.instance_of?(String)
              v.include?('@') ? v : v + '@*'
            when v.instance_of?(Hash)
              "#{v['name']}@#{v['version']}"
            else
              raise "Unknown value for plugin config: #{v}"
          end
          "<installation plugin='#{plugin}' />"
        end.join("\n")
        "<installations>#{plugins}</installations>"
      end

    end
  end
end

