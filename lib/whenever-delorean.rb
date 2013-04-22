require 'whenever'
require 'time'
require 'date'
require 'parse-cron'

class WheneverDelorean
  
  def initialize(time, options)
    @destination_time = parse_date(time)
    @match = options[:only]
    raise 'must set the :only => //, option' unless @match
  end
  
  def self.time_travel_to(*arguments)
    WheneverDelorean.new(*arguments).time_travel
  end
  
  def time_travel
    run_jobs
    Delorean.time_travel_to(destination_time)
  end
  
  private
  
  def parse_date(time)
    time = Chronic.parse(time) if time.is_a?(String)
    time = Time.local(time.year, time.month, time.day) if time.is_a?(Date) && !time.is_a?(DateTime)
    
    time
  end
  
  def destination_time
    @destination_time
  end
  
  def run_jobs
    jobs.each do |job|
      Delorean.time_travel_to(job[:time])
      eval(job[:runner])
    end
  end
  
  def jobs
    
    jobs = []
    
    whenever_jobs.each do |whenever_job|
      get_run_times(whenever_job[:cron_time]).each do |time|
        jobs << {:runner => whenever_job[:runner], :time => time}
      end
    end
    
    jobs.sort {|a,b| a[:time] <=> b[:time] }
  end
  
  def whenever_jobs
    
    to_return = []
    
    raw_whenever_jobs.each_pair do |time,jobs|
      jobs.each do |job|
        if job.instance_variable_get("@template") == "runner"
          job.instance_variable_set("@job_template","")
          Whenever::Output::Cron.output(time,job) do |cron|
            task = job.instance_variable_get("@options")[:task]
            if should_include(task)
              to_return << {:runner => task, :cron_time => cron}
            end
          end
        end
      end
    end
    
    to_return
  end
  
  def should_include(string)
    string.match(@match)
  end
  
  def raw_whenever_jobs
    Whenever::JobList.new("job_type :runner, 'runner'\n"+schedule_data).instance_variable_get("@jobs")
  end
  
  def schedule_data
    File.read(Rails.root+"config/schedule.rb")
  end
  
  def get_run_times(cron_time)
    
    last_time = Time.now
    times = []
    
    cp = CronParser.new(cron_time)
    while (last_time < destination_time)
      last_time = cp.next(last_time)
      times << last_time if last_time < destination_time
    end
    
    times
  end
  
end