# ブランチはconfig/deploy.rbの設定に従う
role :batch, 'localhsot:22222'
set :jenkins_host, 'localhost:8080'
set :jenkins_node_config_dir, 'config/jenkins/nodes/develop'
set :jenkins_template_vars, {
  credential_id: 'AAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA'
}
