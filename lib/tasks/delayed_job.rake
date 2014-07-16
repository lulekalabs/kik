namespace :jobs do

  desc "Schedule delayed_job for project."
  task :schedule => [:merb_env, :environment] do
    
    #--- schedule jobs
    Delayed::Job.schedule RefreshSitemapJob.new, -1, Time.now.utc.midnight + 1.hour, 1.day
    Delayed::Job.schedule SendClientReminderJob.new, 0, Time.now.utc, 10.minutes
    Delayed::Job.schedule SendAdvocateReminderJob.new, 0, Time.now.utc, 10.minutes
    Delayed::Job.schedule KaseSearchFilterJob.new, 0, Time.now.utc, 5.minutes
    Delayed::Job.schedule CancelQuestionsJob.new, 0, Time.now.utc, 5.minutes
    Delayed::Job.schedule RecurringOrdersJob.new, -1, Time.now.utc, 4.hours

  end

end
