namespace :project do
  namespace :payments do
    
    desc "remove orders and contacts"
    task :clear => :environment do
      Order.destroy_all
      Invoice.destroy_all
      ContactTransaction.destroy_all
      Advocate.all.each do |advocate|
        advocate.update_attributes(:premium_contacts_count=>0, :promotion_contacts_count=>0, :overdrawn_contacts_count=>0)
      end
      Access.destroy_all
    end
    
  end
  
  desc "geocode instances that are not geocoded but should be"
  task :geocode => :environment do
    puts "Geocoding questions..."
    Kase.open.find(:all, :conditions => ["kases.lat IS NULL AND kases.lng IS NULL"]).each {|record| record.save(false)}
    puts "Geocoding advocates..."
    Advocate.visible.find(:all, :conditions => ["people.lat IS NULL AND people.lng IS NULL"]).each {|record| record.save(false)}
    puts "done."
  end
end

namespace :svn do
  desc "Configure SVN for probono"
  task :configure do
    system 'svn remove log/*'
    system 'svn propset svn:ignore "*.log" log/'
    system 'svn update log/'
    system 'svn commit -m "Ignore all log archives in \/log\/ that match .log"'
    # Ignore tmp
    system 'svn remove tmp/*'
    system 'svn propset svn:ignore "*" tmp/'
    system 'svn update tmp/'
    system 'svn commit -m "Ignore tmp\/ for now" '
    # Ignore test/tmp
    system 'svn remove test/tmp/*'
    system 'svn propset svn:ignore "*" test/tmp/'
    system 'svn update test/tmp/'
    system 'svn commit -m "Ignore test/tmp\/ for now" '
    # Ignore storage/*
    system 'svn remove storage/*'
    system 'svn propset svn:ignore "*" storage/'
    system 'svn update storage/'
    system 'svn commit -m "Ignore storage\/ for now" '
    # Ignore yml's
    system "svn move config\/database.yml config\/database.ejemplo"
    system "copy config\\database.ejemplo config\\database.yml /y"
    system 'svn commit -m "Giving a database.yml with database.ejemplo for others who realize a code check out to have an example"'
  end
  
  namespace :ignore do 
    
    desc "ignores folder name"
    task :folder do
      puts 'Enter folder name (e.g. log/)'
      folder_name = $stdin.gets.chomp
      
      if folder_name
        system "svn propset svn:ignore \"*\" #{folder_name}"
        system "svn update #{folder_name}"
        system "svn commit -m \"ignore folder #{folder_name}\" "
      end
    end

    desc "ignores file name"
    task :file do
      puts 'Enter file name (e.g. config/amazon_s3.yml)'
      file_name = $stdin.gets.chomp
      
      if file_name
        base_name = File.basename(file_name)
        dir_name = File.dirname(file_name)

        system "svn remove #{file_name}"
        system "svn propset svn:ignore \"#{base_name}\" #{dir_name}/"
        system "svn update #{dir_name}/"
        system "svn commit -m \"ignore #{base_name}\""
      end
    end

    desc "ignore application images folder"
    task :images do
      system 'svn remove public/images/application/*'
      system 'svn propset svn:ignore "*" public/images/application/'
      system 'svn update public/images/application/'
      system 'svn commit -m "ignore public/images/application\/"'
    end

    desc "ignore database.yml"
    task :database_yml do
      system 'svn remove config/database.yml'
      system 'svn propset svn:ignore "database.yml" config/'
      system 'svn update config/'
      system 'svn commit -m "ignore database.yml"'
    end

    desc "ignore db/schema.rb"
    task :schema do
      system 'svn remove db/schema.rb'
      system 'svn propset svn:ignore "schema.rb" db/'
      system 'svn update db/'
      system 'svn commit -m "ignore schema.db"'
    end
  end
  
end

