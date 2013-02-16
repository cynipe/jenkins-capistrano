require 'httparty'
require 'cgi'
require 'json'
require 'jenkins-capistrano/client/node'
require 'jenkins-capistrano/client/job'
require 'jenkins-capistrano/client/view'
require 'jenkins-capistrano/client/update_center'
require 'jenkins-capistrano/client/plugin_manager'

module Jenkins
  class Client
    include HTTParty

    headers 'content-type' => 'application/json'
    format :json
    follow_redirects false

    ServerError = Class.new(Exception)
    TimeoutError = Class.new(Exception)

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

    def session
      self.class.get('/api/json?tree=nothing').headers['X-JENKINS-SESSION']
    rescue Errno::ECONNRESET, Errno::ECONNREFUSED => e
      nil
    end

    def safe_restart!(timeout = 60 * 5)
      if block_given?
        due = Time.now + timeout
        origin = session
      end

      res = self.class.post("/safeRestart")
      raise ServerError, parse_error_message(res) unless res.code.to_i == 302
      return unless block_given?

      loop do
        new = session
        break if new and new != origin
        yield
        raise TimeoutError, "Restating timeout: #{timeout}" if Time.now > due
        sleep 5
      end
    end

    include Node
    include Job
    include View
    include UpdateCenter
    include PluginManager

  end
end

