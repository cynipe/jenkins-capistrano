require 'httparty'
require 'cgi/util'
require 'json'

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

    def add_node(name, opts = {})
      options = default_node_options.merge(opts)
      options[:name] = name
      options[:labels] = options[:labels].split(/\s*,\s*/).join(' ') if options[:labels]
      options[:env_vars] = options[:env_vars].map { |k, v| { :key => k, :value => v } }

      response = post_form("/computer/doCreateItem", node_form_fields(options))
      case response
      when Net::HTTPFound
        { :name => name, :slave_host => options[:slave_host] }
      else
        raise ServerError, parse_error_message(response)
      end
    end

    def update_node(name, opts = {})
      options = default_node_options.merge(opts)
      options[:name] = name
      options[:labels] = options[:labels].split(/\s*,\s*/).join(' ') if options[:labels]
      options[:env_vars] = options[:env_vars].map { |k, v| { :key => k, :value => v } }

      response = post_form("/computer/#{CGI::escape(name)}/configSubmit", node_form_fields(options))
      case response
      when Net::HTTPFound
        { :name => name, :slave_host => options[:slave_host] }
      else
        raise ServerError, parse_error_message(response)
      end
    end

    def config_node(name, opts = {})
      begin
        add_node(name, opts)
      rescue ServerError => e
        update_node(name, opts)
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

    def post_form(path, fields)
      url = URI.parse("#{self.class.base_uri}/#{path}")
      req = Net::HTTP::Post.new(url.path)

      basic_auth = self.class.default_options[:basic_auth]
      req.basic_auth basic_auth[:username], basic_auth[:password] if basic_auth

      req.set_form_data(fields)
      http = Net::HTTP.new(url.host, url.port)
      http.request(req)
    end

    def default_node_options
      {
        :slave_port  => 22,
        :slave_user  => 'jenkins',
        :master_key  => "/var/lib/jenkins/.ssh/id_rsa",
        :slave_fs    => "/data/jenkins-slave/",
        :description => "Automatically created by capistrano-jenkins",
        :executors   => 2,
        :exclusive   => true
      }
    end

    def node_form_fields(options = {})
      {
        "name" => options[:name],
        "type" => "hudson.slaves.DumbSlave$DescriptorImpl",
        "json" => {
          "name"              => options[:name],
          "type"              => "hudson.slaves.DumbSlave$DescriptorImpl",
          "nodeDescription"   => options[:description],
          "numExecutors"      => options[:executors],
          "remoteFS"          => options[:slave_fs],
          "labelString"       => options[:labels],
          "mode"              => options[:exclusive] ? "EXCLUSIVE" : "NORMAL",
          "retentionStrategy" => { "stapler-class"  => "hudson.slaves.RetentionStrategy$Always" },
          "launcher"          => {
            "stapler-class" => "hudson.plugins.sshslaves.SSHLauncher",
            "host"          => options[:slave_host],
            "port"          => options[:slave_port],
            "username"      => options[:slave_user],
            "privatekey"    => options[:master_key],
          },
          "nodeProperties"    => {
            "stapler-class-bag" => "true",
            "hudson-slaves-EnvironmentVariablesNodeProperty" => {
              "env" => options[:env_vars]
            }
          }
        }.to_json
      }
    end

  end
end

