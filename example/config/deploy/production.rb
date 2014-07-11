set :branch, 'v1.0.0'

role :batch, 'prod-slave01.local'
role :batch, 'prod-slave02.local'
role :batch, 'prod-slave03.local'

set :jenkins_host, 'prod-master.local'
set :jenkins_node_config_dir, 'config/jenkins/nodes/production'
set :jenkins_template_vars, {
  slave01: {
    credential_id: 'PRODUCTION-SLAVE01-CREDENTIAL',
  },
  slave02: {
    credential_id: 'PRODUCTION-SLAVE02-CREDENTIAL',
  },
  slave03: {
    credential_id: 'PRODUCTION-SLAVE03-CREDENTIAL',
  }
}
