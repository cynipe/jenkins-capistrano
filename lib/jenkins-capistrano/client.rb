require 'httparty'
require 'cgi/util'

module Jenkins
  class Client
    include HTTParty

    headers 'content-type' => 'application/json'
    format :json

    ServerError = Class.new(Exception)

    def initialize(host, opts = {})
      self.class.base_uri host
      @auth = { :username => opts[:username], :password => opts[:password] }
    end

    def create_job(name, config)
      res = self.class.post("/createItem/api/xml?name=#{CGI.escape(name)}", xml_body(config))
      raise ServerError, parse_error_message(res) unless res.code.to_i == 200
    end

    def update_job(name, config)
      res = self.class.post("/job/#{CGI.escape(name)}/config.xml", xml_body(config))
      raise ServerError, parse_error_message(res) unless res.code.to_i == 200
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

    def parse_error_message(response)
      require "hpricot"
      doc = Hpricot(response.body)
      error_msg = doc.search("td#main-panel p")
      error_msg.inner_text.empty? ? "Server error: code=#{response.code}, #{response.body}" : error_msg
    end
  end
end

