namespace :admin do
  namespace :user do

    #--- create user
    desc "create admin user account"
    task :create => :environment do
      puts "Login:\n"
      login = STDIN.gets.chop

      puts "Email:\n"
      email = STDIN.gets.chop

      puts "Password:\n"
      `stty -echo`
      password = STDIN.gets.chop

      puts "Password confirm:\n"
      password_confirmation = STDIN.gets.chop

      `stty echo`  
  
      puts "Creating admin user..."
      @user = AdminUser.new({
        :login => login,
        :email => email,
        :password => password,
        :password_confirmation => password_confirmation
      })
      if @user.save
        @user.register!
        @user.activate!
        puts "Admin user #{@user.name} registered and activated"
      else
        puts "Errors creating admin user:"
        puts @user.errors.full_messages.join("\n")
      end
    end

    #--- destroy user
    desc "destroy admin user account"
    task :destroy => :environment do
      puts "Login:\n"
      login = STDIN.gets.chop

      `stty echo`  
  
      puts "Searching for '#{login}'..."
      @user = AdminUser.find_by_login(login)
      if @user
        puts "Deleting #{@user.name}..."
        @user.delete!
        @user.destroy
        puts "#{@user.name} deleted and destroyed."
      else
        puts "Admin user '#{login}' not found."
      end
    end

    #--- suspend user
    desc "suspend admin user account"
    task :suspend => :environment do
      puts "Login:\n"
      login = STDIN.gets.chop

      `stty echo`  
  
      puts "Searching for '#{login}'..."
      @user = AdminUser.find_by_login(login)
      if @user
        puts "Suspending #{@user.name}..."
        @user.suspend!
        puts "#{@user.name} suspended."
      else
        puts "Admin user '#{login}' not found."
      end
    end

    #--- un-suspend user
    desc "unsuspend admin user account"
    task :unsuspend => :environment do
      puts "Login:\n"
      login = STDIN.gets.chop

      `stty echo`  
  
      puts "Searching for '#{login}'..."
      @user = AdminUser.find_by_login(login)
      if @user
        puts "Un-suspending #{@user.name}..."
        @user.unsuspend!
        puts "#{@user.name} un-suspended."
      else
        puts "Admin user '#{login}' not found."
      end
    end
    
    #--- un-suspend user
    desc "set password admin user account"
    task :password => :environment do
      puts "Login:\n"
      login = STDIN.gets.chop

      puts "Current password:\n"
      current_password = STDIN.gets.chop

      puts "New password:\n"
      new_password = STDIN.gets.chop

      puts "New password repeat:\n"
      repeat_password = STDIN.gets.chop

      `stty echo`  
  
      puts "Authenticating admin user '#{login}'..."
      @user = AdminUser.authenticate(login, current_password)
      if @user
        puts "Setting new password for #{@user.name}..."
        @user.password = new_password
        @user.password_confirmation = repeat_password
        @user.save!
        puts "#{@user.name} new password set."
      else
        puts "Admin user '#{login}' could not be authenticated."
      end
    end
    
  end
end