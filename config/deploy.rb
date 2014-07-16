set :application, "kik"
set :repository,  "svn+ssh://jf@kik.codecuisine.de/var/repos_kik/kik/trunk"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

task :staging do
  role :app, "deploy@kik.codecuisine.de"
  role :web, "deploy@kik.codecuisine.de"
  role :db,  "deploy@kik.codecuisine.de", :primary => true
  
  set :stage, :staging
  set :rails_env, :staging
  set :deploy_to, "/var/railsapp/#{application}"
end

task :production do
  role :app, "kann-ich-klagen.de@kann-ich-klagen.de"
  role :web, "kann-ich-klagen.de@kann-ich-klagen.de"
  role :db,  "kann-ich-klagen.de@kann-ich-klagen.de", :primary => true
  
  set :user, "kann-ich-klagen.de"
  set :stage, :production
  set :rails_env, :production
  set :deploy_to, "/vhome/kann-ich-klagen.de/htdocs"
end

task :new_production do
  role :app, "kann-ich-klagen.de@crystal.progra.de"
  role :web, "kann-ich-klagen.de@crystal.progra.de"
  role :db,  "kann-ich-klagen.de@crystal.progra.de", :primary => true
  
  set :user, "kann-ich-klagen.de"
  set :stage, :production
  set :rails_env, :production
  set :deploy_to, "/vhome/kann-ich-klagen.de/home/production"
end

#############################################################
# Deploy Settings
#############################################################

default_run_options[:pty] = true
set :use_sudo, true


namespace :deploy do
  
  desc "Restart the servers."
  task :restart, :roles => :app do
    if rails_env == :staging
      passenger.restart
    else
      fastcgi.restart
    end
  end
end

#############################################################
# Passenger
#############################################################

namespace :passenger do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

#############################################################
# Fastcgi
#############################################################

namespace :fastcgi do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "cd /vhome/kann-ich-klagen.de/htdocs/current; rake rails:update:generate_dispatchers RAILS_ENV=production"
    sleep 2
    run "/vhome/kann-ich-klagen.de/fastcgi-server-ror restart production"
  end
end

#############################################################
# Delayed Job
#############################################################

after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"
after "deploy:update_code", "delayed_job:stop"

namespace :delayed_job do
  def rails_env
    fetch(:rails_env, false) ? "RAILS_ENV=#{fetch(:rails_env)}" : ''
  end
  
  desc "Stop the delayed_job process"
  task :stop, :roles => :app do
    run "cd #{current_path};#{rails_env} script/delayed_job stop"
  end

  desc "Start the delayed_job process"
  task :start, :roles => :app do
    run "cd #{current_path};#{rails_env} script/delayed_job start"
  end

  desc "Restart the delayed_job process"
  task :restart, :roles => :app do
    # delayed job restart requirs the worker running.. so better use stop and restart
    #run "cd #{current_path};#{rails_env} script/delayed_job restart"
    run "cd #{current_path};#{rails_env} script/delayed_job stop; #{rails_env} script/delayed_job start"
  end
end

task :after_symlink, :roles => :app do
  run "ln -nfs #{shared_path}/imageuploads #{current_path}/public/images/application"

  # write .rvmrc file
  system %(echo '. "/usr/local/rvm/environments/ruby-1.8.7-p330@kik"' > #{current_path}/.rvmrc)
end
