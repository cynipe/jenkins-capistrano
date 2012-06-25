
module Jenkins
  class Client
    module Job

      def create_job(name, config)
        res = self.class.post("/createItem/api/xml?name=#{CGI.escape(name)}", xml_body(config))
        raise ServerError, parse_error_message(res) unless res.code.to_i == 200
      rescue => e
        raise ServerError, "Failed to create job: #{name}, make sure you have specified auth info properly"
      end

      def update_job(name, config)
        res = self.class.post("/job/#{CGI.escape(name)}/config.xml", xml_body(config))
        raise ServerError, parse_error_message(res) unless res.code.to_i == 200
      rescue => e
        raise ServerError, "Failed to create job: #{name}, make sure you have specified auth info properly"
      end

      def create_or_update_job(name, config)
        begin
          create_job(name, config)
        rescue ServerError => e
          update_job(name, config)
        end
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

