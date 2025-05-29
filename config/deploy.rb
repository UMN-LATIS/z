# config valid only for current version of Capistrano
# lock '3.6.1'

set :application, 'z'
set :repo_url, 'git@github.com:UMN-LATIS/z.git'
set :rbenv_ruby, File.read('.ruby-version').strip

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/z'
set :tmp_dir, "/home/latis_deploy/tmp"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, '.env'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'public/packs', '.bundle',
       'node_modules'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
namespace :deploy do
  desc "Phased restart Puma via pumactl"
  task :phased_restart do
    on roles(:app) do
      within current_path do
        execute "sudo /usr/local/bin/pumactl phased-restart -F /etc/puma/puma.rb "
      end
    end
  end
  after :publishing, :phased_restart
end

after 'deploy:symlink:release', 'deploy:phased_restart'


# Compile assets on every deployment
before "deploy:assets:precompile", "deploy:yarn_install"
namespace :deploy do
  desc "Run rake yarn install"
  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute("cd #{release_path} && npm install --silent --no-progress --no-audit --no-optional")
      end
    end
  end
end
