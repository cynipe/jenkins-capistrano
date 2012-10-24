require 'httparty'
require 'cgi/util'
require 'json'
require 'jenkins-capistrano/client/node'
require 'jenkins-capistrano/client/job'

module Jenkins
  class Client
    include HTTParty

    headers 'content-type' => 'application/json'
    format :json

    ServerError = Class.new(Exception)

    def initialize(host, opts = {})
      self.class.base_uri host
      self.class.basic_auth opts[:username], opts[:password] if opts[:username] and opts[:password]
    end

    def parse_error_message(response)
      require "hpricot"
      doc = Hpricot(response.body)
      error_msg = doc.search("td#main-panel p")
      error_msg.inner_text.empty? ? doc.search("body").text : error_msg
    end

    include Node
    include Job

  end
end

