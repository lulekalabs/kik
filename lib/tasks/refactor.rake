namespace :refactor do

  desc "Refactor items using F=<from text> T=<to text> for *.rb *.js, *.html* files "
  task :replace do
    if ENV['F'] && ENV['T']
      puts 'creating file list for refactoring...'
      cmd = "find . \\( -name \"*.rb\" -or -name \"*.rhtml\" -or -name \"*.erb\" -or -name \"*.js\" \\) | xargs grep -l '#{ENV['F']}'"
      puts cmd
      puts `#{cmd}`
    
      puts "\nconfirm (Y)es to continue:\n"
      confirm = STDIN.gets.chop
    
      if confirm == 'Y'
        # find and replaces
        cmd = "find . \\( -name \"*.rb\" -or -name \"*.rhtml\" -or -name \"*.erb\" -or -name \"*.js\" \\) | xargs grep -l '#{ENV['F']}' | xargs sed -i -e 's/#{ENV['F']}/#{ENV['T']}/g'"
        puts cmd
        puts `#{cmd}`
      
        # removes all file backups ending in *.rb-e or *.rhtml-e
        puts "cleanup..."
        cmd = "find . \\( -name \"*.rb-e\" -or -name \"*.rhtml-e\" -or -name \"*.erb-e\" -or -name \"*.js-e\" \\) | xargs rm -r"
        puts cmd
        puts `#{cmd}`
      
        puts 'complete.'
      else
        puts 'nothing changed.'
      end
    else
      puts "Error: You need to specify F(rom) and T(o) parameters."
    end
  end

  task :find do
    if ENV['F']
      puts 'finding...'
      cmd = "find . \\( -name \"*.rb\" -or -name \"*.rhtml\" -or -name \"*.erb\" -or -name \"*.js\" \\) | xargs grep -l '#{ENV['F']}'"
      puts cmd
      puts `#{cmd}`
    else
      puts "Error: You need to specify F parameter for the search string."
    end
  end


end