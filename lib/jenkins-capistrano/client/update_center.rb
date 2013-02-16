
module Jenkins
  class Client
    module UpdateCenter

      def installation_jobs
        job = self.class.get("/updateCenter/api/json?tree=jobs[id,type,status[success],plugin[name,version]]")['jobs']
        job.reduce([]) do |mem, job|
          if job['type'] == 'InstallationJob'
            mem << {
              'id'      => job['id'],
              'type'    => job['type'],
              'status'  => job['status']['success'],
              'name'    => job['plugin']['name'],
              'version' => job['plugin']['version']
            }
          end
          mem
        end
      end

      def wait_for_complete(timeout = 60 * 5)
        due = Time.now + timeout
        loop do
          complete = installation_jobs.reduce(true) do |comp, job|
            comp & (block_given? ? yield(job) : job['status'] == true)
          end
          break if complete
          raise TimeoutError, "Installation timeout: #{timeout}" if Time.now > due
          sleep 1
        end
      end

      def restart_required?
        res = self.class.get("/pluginManager/api/json?tree=restartRequiredForCompletion")
        raise ServerError, parse_error_message(res) unless res.code.to_i == 200
        res['restartRequiredForCompletion'] == true
      end

    end
  end
end

