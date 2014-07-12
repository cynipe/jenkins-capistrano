Capistrano::Configuration.instance(:must_exist).load do

  def _cset(name, *args, &block)
    unless exists?(name)
      set(name, *args, &block)
    end
  end

  _cset(:jenkins_host) { abort "Please specify the host of your jenkins server, set :jenkins_host, 'http://localhost:8080'" }

  _cset(:jenkins_username) { '' }
  _cset(:jenkins_password) { '' }

  _cset(:jenkins_job_config_dir) { 'config/jenkins/jobs' }
  _cset(:jenkins_node_config_dir) { 'config/jenkins/nodes' }
  _cset(:jenkins_view_config_dir) { 'config/jenkins/views' }

  _cset(:disabled_jobs) { [] }

  _cset(:jenkins_template_vars) { {} }

  def configurator
    @configurator ||= Jenkins::Capistrano::Configurator.new(
      :logger        => logger,
      :server_url    => jenkins_host,
      :username      => jenkins_username,
      :password      => jenkins_password,
      :template_vars => jenkins_template_vars
    )
  end

  %w(job node view).each do |name|
    instance_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{name}_configs
        config_dir = fetch('jenkins_#{name}_config_dir'.to_sym)
        abort "Please create the jenkins_#{name}_config_dir first: \#{config_dir}" unless Dir.exists? config_dir
        Pathname.glob(File.join(config_dir, '/*.{xml,erb}'))
      end
    RUBY
  end

  # minimum configurations
  #
  #   role :jenkins, 'localhost:8080'
  namespace :jenkins do

    desc <<-DESC
      Configure the jobs to Jenkins server.

      Configuration
      -------------
      jenkins_job_config_dir
          the directory path where the config.xml stored.
          default: 'config/jenkins/jobs'

      disabled_jobs
          job names array which should be disabled after deployment.
          default: []
    DESC
    task :config_jobs do
      logger.info "deploying jenkins jobs to #{jenkins_host}"
      configurator.configure_jobs(job_configs, disabled_jobs)
    end


    desc <<-DESC
      [DEPRECATED] Use jenkins:config_jobs instead.
    DESC
    task :deploy_jobs do
      logger.important '[DEPRECATED] Use jenkins:config_jobs instead.'
      config_jobs
    end

    desc <<-DESC
      Configure the nodes to Jenkins server.

      Configuration
      -------------
      jenkins_node_config_dir
          the directory path where the node's configuration stored.
          default: 'config/jenkins/nodes'
    DESC
    task :config_nodes do
      logger.info "configuring jenkins nodes to #{jenkins_host}"
      abort <<-MSG.gsub(/^ +/, '') unless Dir.glob(File.join(jenkins_node_config_dir, '*.json')).empty?
        Configuring the node using json is not supported anymore, use config.xml instead.
        You could get the node's config.xml from a running Jenkins with following command:

        $ curl -o config/jenkins/nodes/<node_name>.xml http://<jenkins-host>/computer/<node_name>/config.xml
      MSG
      configurator.configure_nodes(node_configs)
    end

    desc <<-DESC
      Configure the views to Jenkins server.

      Configuration
      -------------
      jenkins_view_config_dir
          the directory path where the view's configuration stored.
          default: 'config/jenkins/views'
    DESC
    task :config_views do
      logger.info "configuring jenkins views to #{jenkins_host}"
      configurator.configure_views(view_configs)
    end

  end

end
