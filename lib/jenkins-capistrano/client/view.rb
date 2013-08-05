# -*- encoding: utf-8 -*-

module Jenkins
  class Client
    module View

      def view_names
        self.class.get("/api/json")['views'].map {|view| view['name'] }.
          select {|name| name != all_view_name }
      end

      def view_config(name)
        res = self.class.get("/view/#{CGI.escape(name)}/config.xml")
        raise ServerError, parse_error_message(res) unless res.code.to_i == 200
        res.body
      end

      def create_view(name, config)
        res = self.class.post("/createView/?name=#{CGI.escape(name)}", xml_body(config))
        raise ServerError, parse_error_message(res) unless res.code.to_i == 200
      rescue => e
        raise ServerError, "Failed to create view: #{name}, make sure you have specified auth info properly"
      end

      def update_view(name, config)
        res = self.class.post("/view/#{CGI.escape(name)}/config.xml", xml_body(config))
        raise ServerError, parse_error_message(res) unless res.code.to_i == 200
      rescue => e
        raise ServerError, "Failed to create view: #{name}, make sure you have specified auth info properly"
      end

      def create_or_update_view(name, config)
        view_names.include?(name) ? update_view(name, config) : create_view(name, config)
      end

      private
      def xml_body(xml_str)
        {
          :body => xml_str,
          :format => :xml,
          :headers => { 'content-type' => 'application/xml' }
        }
      end

    end
  end
end

