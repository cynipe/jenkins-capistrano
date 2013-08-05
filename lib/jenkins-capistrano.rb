require 'jenkins-capistrano/version'
require 'jenkins-capistrano/client'

def _cset(name, *args, &block)
  unless exists?(name)
    set(name, *args, &block)
  end
end

# Capistrano task for Jenkins.
#
# Just add "require 'jenkins-capistrano'" in your Capistrano deploy.rb
Capistrano::Configuration.instance(:must_exist).load do

  _cset(:jenkins_host) { abort "Please specify the host of your jenkins server, set :jenkins_host, 'http://localhost:8080'" }

  _cset(:jenkins_username) { '' }
  _cset(:jenkins_password) { '' }

  _cset(:jenkins_job_config_dir) { 'config/jenkins/jobs' }
  _cset(:jenkins_node_config_dir) { 'config/jenkins/nodes' }
  _cset(:jenkins_view_config_dir) { 'config/jenkins/views' }
  _cset(:jenkins_all_view_name)   { 'All' }

  _cset(:jenkins_plugins) { [] }
  _cset(:jenkins_install_timeout) { 60 * 5 }
  _cset(:jenkins_plugin_enable_update) { false }
  _cset(:jenkins_plugin_enable_restart) { false }

  _cset(:disabled_jobs) { [] }

  def client
    @client ||= Jenkins::Client.new(jenkins_host, { :username => jenkins_username,  :password => jenkins_password, :all_view_name => jenkins_all_view_name })
  end

  def job_configs
    abort "Please create the jenkins_job_config_dir first: #{jenkins_job_config_dir}" unless Dir.exists? jenkins_job_config_dir
    Dir.glob("#{jenkins_job_config_dir}/*.xml")
  end

  def node_configs
    abort "Please create the jenkins_node_config_dir first: #{jenkins_node_config_dir}" unless Dir.exists? jenkins_node_config_dir
    Dir.glob("#{jenkins_node_config_dir}/*.json")
  end

  def view_configs
    abort "Please create the jenkins_view_config_dir first: #{jenkins_node_config_dir}" unless Dir.exists? jenkins_node_config_dir
    Dir.glob("#{jenkins_view_config_dir}/*.xml")
  end

  def missing_plugins
    installed = client.plugin_names
    jenkins_plugins.select do |plugin|
      missing = !installed.include?(plugin.split('@'))
      logger.info "#{plugin} is already installed." unless missing
      missing
    end
  end

  # minimum configurations
  #
  #   role :jenkins, 'localhost:8080'
  namespace :jenkins do

    desc <<-DESC
      Deploy the jobs to Jenkins server -- meaning create or update --

      Configuration
      -------------
      jenkins_job_config_dir
          the directory path where the config.xml stored.
          default: 'config/jenkins/jobs'

      disabled_jobs
          job names array which should be disabled after deployment.
          default: []

    DESC
    task :deploy_jobs do
      logger.info "deploying jenkins jobs to #{jenkins_host}"
      logger.important "no job configs found." if job_configs.empty?
      job_configs.each do |file|
        name = File.basename(file, '.xml')
        msg = StringIO.new

        client.create_or_update_job(name, File.read(file))
        msg << "job #{name} created"

        if disabled_jobs.include? name
          client.disable_job(name)
          msg << ", but was set to disabled"
        end
        msg << "."
        logger.trace msg.string
      end
    end

    desc <<-DESC
      Configure the nodes to Jenkins server -- meaning create or update --

      Configuration
      -------------
      jenkins_node_config_dir
          the directory path where the node's configuration stored.
          default: 'config/jenkins/nodes'
    DESC
    task :config_nodes do
      logger.info "configuring jenkins nodes to #{jenkins_host}"
      logger.important "no node configs found." if node_configs.empty?
      node_configs.each do |file|
        name = File.basename(file, '.json')
        opts = JSON.parse(File.read(file)).to_hash.
          inject({}) { |mem, (key, val)| mem[key.to_sym] = val; mem }
        client.config_node(name, opts)
        logger.trace "node #{name} created."
      end
    end

    desc <<-DESC
      Configure the views to Jenkins server -- meaning create or update --

      Configuration
      -------------
      jenkins_view_config_dir
          the directory path where the view's configuration stored.
          default: 'config/jenkins/views'
    DESC
    task :config_views do
      logger.info "configuring jenkins views to #{jenkins_host}"
      logger.important "no view configs found." if view_configs.empty?
      view_configs.each do |file|
        name = File.basename(file, '.xml')
        msg = StringIO.new
        client.create_or_update_view(name, File.read(file))
        logger.trace "view #{name} created."
      end
    end

    desc <<-DESC
      Install plugins to Jenkins server

      Configuration
      -------------
      jenkins_plugins
          the hash array contains plugin's name and version.

      jenkins_install_timeout
        a timeout seconds to wait for plugin installation.
        default: 5 min

      jenkins_plugin_enable_update
        whether to update or ignore when the plugin already installed.
        default: false

      jenkins_plugin_enable_restart
        whether to restart or ignore when the plugin installation requires restarting.
        default: false
    DESC
    task :install_plugins do
      logger.important "installing plugins to #{jenkins_host}"
      if jenkins_plugins.empty?
        logger.info "no plugin config found."
        next
      end

      logger.info "calcurating plugins to install..."
      candidates = client.prevalidate_plugin_config(missing_plugins)
      plugins_to_install = candidates.reduce([]) do |mem, candidate|
        plugin = "#{candidate['name']}@#{candidate['version']}"
        mode = candidate['mode']
        case
        when mode == 'missing'
          logger.debug "#{plugin} marked to be installed."
          mem << candidate
        when mode == 'old'
          if jenkins_plugin_enable_update
            logger.debug "#{plugin} marked to be updated."
            mem << candidate
          end
        end
        mem
      end
      if plugins_to_install.empty?
        logger.info "all plugins already installed."
        next
      end

      logger.info "installing the plugins, this could be take a while..."
      client.install_plugin(plugins_to_install)

      names = plugins_to_install.map {|v| v['name'] }
      client.wait_for_complete(jenkins_install_timeout) do |job|
        result = job['status'] == true
        # skip unknown jobs
        if result and names.include?(job['name'])
          names.delete job['name']
          logger.debug "#{job['name']}@#{job['version']} installed."
        end
        result
      end
      logger.info "all plugins successfully installed."

      if client.restart_required?
        if jenkins_plugin_enable_restart
          logger.important "restarting jenkins."
          client.safe_restart! do
            logger.debug "waiting for Jenkins to restart..."
          end
          logger.info "Jenkins is successfully restarted."
        else
          logger.important "restarting is disabled, please restart the jenkins manually for complete the installation."
        end
      end
    end

    namespace :reverse do

      desc <<-DESC
        Reverse all configs from Jenkins.
      DESC
      task :default do
        job
        node
        view
      end

      %w(job node view).each do |kind|

        instance_eval <<-RUBY, __FILE__, __LINE__ + 1
          desc <<-DESC
            Reverse #{kind} configs from Jenkins into `jenkins_#{kind}_config_dir`
          DESC
          task :#{kind} do |task_name|
            logger.important "reverse #{kind} config from \#{jenkins_host}"
            unless File.exists? jenkins_#{kind}_config_dir and File.directory? jenkins_#{kind}_config_dir
              logger.info "\#{task_name} needs a \#{jenkins_#{kind}_config_dir} directory."
              logger.info "I'll make one for you."
              FileUtils.mkdir_p jenkins_#{kind}_config_dir
            end

            #{kind}_names = client.#{kind}_names
            unless #{kind}_names.size > 0
              logger.info "No #{kind}s found at \#{jenkins_host}."
              next
            end

            #{kind}_names.each do |name|
              #{kind}_config = "\#{jenkins_#{kind}_config_dir}/\#{name}.xml"
              File.open(#{kind}_config, 'w') do |f|
                f.puts client.#{kind}_config(name)
                logger.debug "\#{name}'s config.xml reversed in \#{#{kind}_config}."
              end
            end
            logger.info "All #{kind} configs reversed successfully."
          end
        RUBY
      end

    end

  end

end
