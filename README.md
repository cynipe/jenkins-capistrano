# jenkins-capistrano

The capistrano tasks for Jenkins CI Server. Supports to manage following things:

* Job
* Node
* View
* Plugins(Experimental)

## Installation

Add this line to your application's Gemfile::

  gem 'jenkins-capistrano'

And then execute::

  $ bundle

Or install it yourself as::

  $ gem install jenkins-capistrano

## Example

See [example directory](https://github.com/cynipe/jenkins-capistrano/tree/develop/example>) or following instructions.

### Job Configuration

The following code will creates or updates Jenkins jobs before each deploy task:

config directory structure(name your config.xml as a job name):
```
config
├── deploy.rb
└── jenkins
     └── jobs
         ├── job-name1.xml
         ├── job-name2.xml
         └── job-name3.xml
```

deploy.rb:
```ruby
set :application, "your-awesome-app"
set :scm, :git
set :repository,  "https://github.com/your/repository.git"

set :jenkins_host, 'http://localhost:8080'
#set :jenkins_username, '' # default empty
#set :jenkins_password, '' # default empty
#set :jenkins_job_config_dir, 'config/jenkins/jobs'

before 'deploy', 'jenkins:deploy_jobs'
```

#### Want to disabling some jobs for specific environment?

Since 0.0.5, you can disabling jobs using `disabled_jobs` option.
Use this option with [multistage-extension](<https://github.com/capistrano/capistrano/wiki/2.x-Multistage-Extension>).

Put the following line into `config/deploy/<env>.rb`:
```
set :disabled_jobs, %w(job1 job2)
```


### Node Configuration

config directory structure(name your json file as a node name):
```
config
├── deploy.rb
└── jenkins
     └── nodes
         ├── node1.json
         ├── node2.json
         └── node3.json
```

sample node configuration:
```json
{
  "name"        : "example",
  "type"        : "hudson.slaves.DumbSlave$DescriptorImpl",
  "description" : "some description",
  "executors"   : 2,
  "labels"      : "linux, java, ruby",
  "slave_host"  : "example.com",
  "slave_port"  : 22,
  "slave_user"  : "jenkins",
  "master_key"  : "/var/lib/jenkins/.ssh/id_rsa",
  "slave_fs"    : "/home/jenkins",
  "exclusive"   : true,
  "java_path": "/opt/java/bin/java",
  "jvm_options": "-Xmx512M",
  "env_vars": {
    "key1": "val1",
    "key2": "val2"
  }
}
```

deploy.rb:
```ruby
set :application, "your-awesome-app"
set :scm, :git
set :repository,  "https://github.com/your/repository.git"

set :jenkins_host, 'http://localhost:8080'
# set :jenkins_username, '' # default empty
# set :jenkins_password, '' # default empty
# set :jenkins_node_config_dir, 'config/jenkins/nodes'

before 'deploy', 'jenkins:config_nodes'
```

### View Configuration

config directory structure(name your json file as a node name):
```
config
├── deploy.rb
└── jenkins
     └── views
         ├── view1.xml
         ├── view2.xml
         └── view3.xml
```

sample view configuration:
```xml
<listView>
  <name>view1</name>
  <filterExecutors>false</filterExecutors>
  <filterQueue>false</filterQueue>
  <properties class="hudson.model.View$PropertyList"/>
  <jobNames class="tree-set">
    <comparator class="hudson.util.CaseInsensitiveComparator" reference="../../../hudson.plugins.view.dashboard.Dashboard/jobNames/comparator"/>
  </jobNames>
  <jobFilters/>
  <columns>
    <hudson.views.StatusColumn/>
    <hudson.views.WeatherColumn/>
    <hudson.views.JobColumn/>
    <hudson.views.LastSuccessColumn/>
    <hudson.views.LastFailureColumn/>
    <hudson.views.LastDurationColumn/>
    <hudson.views.BuildButtonColumn/>
  </columns>
  <includeRegex>job.*</includeRegex>
</listView>
```

deploy.rb:
```ruby
set :application, "your-awesome-app"
set :scm, :git
set :repository,  "https://github.com/your/repository.git"

set :jenkins_host, 'http://localhost:8080'
# set :jenkins_username, '' # default empty
# set :jenkins_password, '' # default empty
# set :jenkins_node_config_dir, 'config/jenkins/nodes'

before 'deploy', 'jenkins:config_views'
```

#### Don't know how to write config.xml for view?

Create or configure the view you want to manage via usual operation through the Jenkins UI.
Then, open the `JENKINS_HOME/config.xml` and copy the desired configuration from `<views>` section, and
ommit `<owner class="hudson" reference="../../.."/>` line.

### Plugin Configuration(experimental)

#### Note

This feature is may change its API without any notice.
Use at your own risk.

deploy.rb:
```ruby
set :application, "your-awesome-app"
set :scm, :git
set :repository,  "https://github.com/your/repository.git"

set :jenkins_plugins, %w(cron_column envinject join)
# you can specify version as follows:
#set :jenkins_plugins, %w(cron_column@1.1.2 envinject join@1.0.0)
set :jenkins_install_timeout, 60 * 5      # default: 5min
set :jenkins_plugin_enable_update, false  # dafault: false
set :jenkins_plugin_enable_restart, false # default: false

before 'deploy', 'jenkins:install_plugins'
```

## Release Notes

### 0.0.6
  * Support view management ([726ad3ef](<https://github.com/cynipe/jenkins-capistrano/commit/726ad3ef817ba15a2d66503ce0dd4bc961ed92e2))
  * Support plugin management(Experimental) ([4d9964c0](https://github.com/cynipe/jenkins-capistrano/commit/4d9964c00ff95798915484ceb8b5c837b2aa03e8))

### 0.0.5.2
  * Fix cgi library loading error

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/e76247570c952ad3205ca7d6d3f0f7b5 "githalytics.com")](http://githalytics.com/cynipe/jenkins-capistrano)
