
module Jenkins
  class Client
    module Node

      def node_names
        self.class.get("/computer/api/json")['computer'].map {|computer| computer['displayName'] }
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
        node_names.include?(name) ? update_node(name, opts) : add_node(name, opts)
      end

      private
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
              "javaPath"      => options[:java_path],
              "jvmOptions"    => options[:jvm_options]
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
end

