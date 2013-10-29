set :application, 'hello'
set :repository, 'http://example.org/your/repository.git'
set :scm, :git
set :branch, 'develop' # デフォルトブランチの設定
set :deploy_via, :copy # ローカルクローンしてリモートにコピー(リモートでクローンしないように)
set :deploy_to, "/opt/#{application}"
set :use_sudo, false
set :keep_releases, 5

set :stages, %w(develop staging production)
set :default_stage, 'develop'

set :user, 'jenkins'
# 公開鍵認証を推奨
#set :password do
#  ENV['DEPLOY_PASSWORD'] || Capistrano::CLI.password_prompt("linux user password[#{user}]: ")
#end

set :jenkins_username, user
# 必要であれば
#set :jenkins_password do
#  ENV['DEPLOY_PASSWORD'] || Capistrano::CLI.password_prompt("jenkins server password[#{user}]: ")
#end

before 'deploy', 'deploy:check'
after  'deploy', 'jenkins:deploy_jobs'
after  'deploy', 'jenkins:deploy_jobs'
after  'deploy', 'deploy:cleanup'

# ローカルにgitコマンドがあること
depend :local, :command, 'git'
# リモートにデプロイ用ディレクトリがあること
depend :remote, :directory, deploy_to
# jenkinsユーザで書き込みができること
depend :remote, :writable, deploy_to
