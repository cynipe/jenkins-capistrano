set :branch, 'release/1.0.1'

role :batch, 'stg-slave01.local'
# 複数ノードの場合
#role :batch, 'stg-slave02.local'
#role :batch, 'stg-slave03.local'

set :jenkins_host, 'stg-master.local'
set :jenkins_node_config_dir, 'config/jenkins/nodes/staging'

