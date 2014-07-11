require 'jenkins-capistrano/template'
require 'jenkins_api_client'

module Jenkins
  module Capistrano
    class Configurator

      attr_reader :logger, :client, :job_config_dir, :node_config_dir, :view_config_dir, :template_vars

      def initialize(options = {})
        opts = {:log_location => '/dev/null'}.merge(options)
        @logger = opts.delete(:logger)
        @template_vars = opts.delete(:template_vars)
        @client = JenkinsApi::Client.new(opts)
      end

      def configure_jobs(config_files, disabled_jobs)
        if config_files.empty?
          logger.important "no node configs found."
          return
        end

        config_files.each do |file|
          name = name_for(file)
          client.job.create_or_update(name, config_xml_for(file))
          logger.trace "job #{name} created."
          if disabled_jobs.include? name
            client.job.disable(name)
            logger.trace "  -> disabled"
          end
        end
      end

      def configure_nodes(config_files)
        if config_files.empty?
          logger.important "no node configs found."
          return
        end

        config_files.each do |file|
          name = name_for(file)
          unless client.node.list.include? name
            params =  { :name => name, :slave_host => 'dummy-by-jenkins-capistrano', :private_key_file => 'dummy' }
            client.node.create_dumb_slave(params)
          end
          client.node.post_config(name, config_xml_for(file))
          logger.trace "node #{name} created."
        end
      end

      def configure_views(config_files)
        if config_files.empty?
          logger.important "no view configs found."
          return
        end

        config_files.each do |file|
          name = name_for(file)
          unless client.view.exists? name
            client.view.create name
          end
          client.view.post_config(name, config_xml_for(file))
          logger.trace "view #{name} created."
        end
      end

      private
      def name_for(file_path)
        file_path.basename.to_s.split('.').first
      end

      def config_xml_for(file)
        config_xml = if file.extname == '.erb'
                       Jenkins::Template.new(file, template_vars).evaluate
                     else
                       file.read
                     end
        Nokogiri::XML(config_xml) do |config|
          config.options = Nokogiri::XML::ParseOptions::STRICT
        end.to_xml
      rescue => e
        abort "`#{file}` is not well-formed, put `.erb` as extname if it's erb template: #{e.message}"
      end

    end
  end
end
