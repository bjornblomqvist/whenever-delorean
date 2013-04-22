require 'spec_helper'

describe "WheneverDelorean" do
  
  before(:each) do
    Delorean.back_to_the_present
    WheneverDelorean.any_instance.stub(:parse_date)
  end

  describe ".time_travel_to" do
    
    it "should create a new instance with the given arguments and call time_travel" do
      
      whenever_delorean = mock("WheneverDelorean")
      whenever_delorean.should_receive(:time_travel)
      
      WheneverDelorean.should_receive(:new).with("3 days from now").and_return(whenever_delorean)
      
      WheneverDelorean.time_travel_to("3 days from now")
      
      whenever_delorean.should_receive(:time_travel)
      WheneverDelorean.should_receive(:new).with("3 days from now", :only => /something/).and_return(whenever_delorean)
      
      WheneverDelorean.time_travel_to("3 days from now", :only => /something/)
      
    end
  end
  
  describe "#time_travel" do
    
    subject { WheneverDelorean.new(nil,{:only => /./}) }
    
    it 'should run all the jobs at the correct time and then time travel to the given time' do
      
      dummy_time = mock("A dummy time")
      
      subject.should_receive(:run_jobs)
      subject.should_receive(:destination_time).and_return(dummy_time)
      Delorean.should_receive(:time_travel_to).with(dummy_time)
      
      subject.time_travel
      
    end
    
  end
  
  describe "#parse_date" do
    
    subject { WheneverDelorean.new(nil,{:only => /./}) }
    
    it 'should covert string to time when posible' do
      
      WheneverDelorean.any_instance.unstub(:parse_date)
      WheneverDelorean.any_instance.stub(:initialize)
      
      Chronic.should_receive(:parse).with("1 days ago").and_return("dummy result")
      subject.send(:parse_date,"1 days ago").should == "dummy result"
      
    end
    
    it 'should let instances of time pass throu' do
      
      WheneverDelorean.any_instance.unstub(:parse_date)
      WheneverDelorean.any_instance.stub(:initialize)
      
      t = Time.now
      
      subject.send(:parse_date,t).should == t
      
    end
    
    it 'should convert date instances to time' do
      
      WheneverDelorean.any_instance.unstub(:parse_date)
      WheneverDelorean.any_instance.stub(:initialize)
      
      date = Date.new
      
      subject.send(:parse_date,date).class.should == Time
      
    end
    
  end
  
  describe '#destination_time' do
    
    it 'should return the the supplied destination_time in new' do
      
      time_mock = mock("time mock")
      
      WheneverDelorean.any_instance.should_receive(:parse_date).with(time_mock).and_return("result")
      WheneverDelorean.new(time_mock, :only => //).send(:destination_time).should == "result"
      
    end
    
  end
  
  describe "#run_jobs" do
    
    subject { WheneverDelorean.new(nil,{:only => /./}) }
    
    it 'should iterate all the jobs and run time at the correct time' do
      
      jobs = [{:runner => "TestHelper.dummy_method1", :time => Time.new(2010,01,01)}, {:runner => "TestHelper.dummy_method1", :time => Time.new(2010,01,01)}]

      subject.should_receive(:jobs).and_return(jobs)

      jobs.each do |job|
        Delorean.should_receive(:time_travel_to).with(job[:time])
        TestHelper.should_receive(job[:runner].match(/\.(.+)/)[1])
      end

      subject.send(:run_jobs)
      
    end
  end
  
  describe "#jobs" do
    
    subject { WheneverDelorean.new(nil,{:only => /./}) }
    
    it 'should return all whenever jobs that should be run sorted acording to time' do
      
      subject.should_receive(:whenever_jobs).and_return([
        {:runner => "dummy1", :cron_time => "dummy_cron_time_1"},
        {:runner => "dummy2", :cron_time => "dummy_cron_time_2"}
      ])
      
      subject.should_receive(:get_run_times).with("dummy_cron_time_1").and_return([Time.new(2010,01,01),Time.new(2010,01,02)])
      subject.should_receive(:get_run_times).with("dummy_cron_time_2").and_return([Time.new(2010,01,01),Time.new(2010,01,02)])
      
      subject.send(:jobs).should == [
        {:runner => "dummy1", :time => Time.new(2010,01,01)},
        {:runner => "dummy2", :time => Time.new(2010,01,01)},
        {:runner => "dummy1", :time => Time.new(2010,01,02)},
        {:runner => "dummy2", :time => Time.new(2010,01,02)}
      ]
      
    end
    
  end
  
  describe '#get_run_times' do
    
    subject { WheneverDelorean.new(nil,{:only => /./}) }
    
    it 'should return all the run times for a cron time between now and destination_time' do
      
      Time.should_receive(:now).and_return(Time.new(2010,01,01))
      
      subject.should_receive(:destination_time).exactly(7).times.and_return(Time.new(2010,01,03))
      
      cron_parser_dummy = mock("cron_parser_dummy")
      CronParser.should_receive(:new).with("dummy_cron_time").and_return(cron_parser_dummy)
      
      cron_parser_dummy.should_receive(:next).with(Time.new(2010,01,01)).and_return(Time.new(2010,01,01,01))
      cron_parser_dummy.should_receive(:next).with(Time.new(2010,01,01,01)).and_return(Time.new(2010,01,02,01))
      cron_parser_dummy.should_receive(:next).with(Time.new(2010,01,02,01)).and_return(Time.new(2010,01,03,01))
      
      
      subject.send(:get_run_times,"dummy_cron_time").should == [Time.new(2010,01,01,01),Time.new(2010,01,02,01)]
      
    end
    
  end
  
  describe "should_include" do
    
    subject { WheneverDelorean.new(nil, :only => /foo/) }
    
    it 'should return true when the given string matches the regex given at init' do
    
      subject.send(:should_include,"boo").should be_false
      subject.send(:should_include,"foo").should be_true
      
    end 
    
  end
  
  describe '#whenever_jobs' do
    
    subject { WheneverDelorean.new(nil,{:only => /./}) }
    
    it 'should get the whenever jobs and return them as simple hashes' do
      
      raw_jobs = {:month => [mock('job1'),mock('job2')]}
      
      subject.should_receive(:raw_whenever_jobs).and_return(raw_jobs)
      
      raw_jobs.each_pair do |time,jobs|
        jobs.each_with_index do |job,index| 
          job.should_receive(:instance_variable_get).with("@template").and_return("runner")
          job.should_receive(:instance_variable_get).with("@options").and_return({:task => "dummy#{index+1}"})
          job.should_receive(:instance_variable_set).with("@job_template",'')
          subject.should_receive(:should_include).with("dummy#{index+1}").and_return(true)
          Whenever::Output::Cron.should_receive(:output).with(time,job).and_yield("dummy_cron_time_#{index+1}")
        end
      end
      
      subject.send(:whenever_jobs).should == [
        {:runner => "dummy1", :cron_time => "dummy_cron_time_1"},
        {:runner => "dummy2", :cron_time => "dummy_cron_time_2"}
      ]
      
    end
    
    it 'should skip all jobs that does not match the supplied regex ' do
      
      raw_jobs = {:month => [mock('job1'),mock('job2')]}
      
      subject.should_receive(:raw_whenever_jobs).and_return(raw_jobs)
      
      raw_jobs.each_pair do |time,jobs|
        jobs.each_with_index do |job,index| 
          job.should_receive(:instance_variable_get).with("@template").and_return("runner")
          job.should_receive(:instance_variable_get).with("@options").and_return({:task => "dummy#{index+1}"})
          job.should_receive(:instance_variable_set).with("@job_template",'')
          subject.should_receive(:should_include).with("dummy#{index+1}").and_return(false)
          Whenever::Output::Cron.should_receive(:output).with(time,job).and_yield("dummy_cron_time_#{index+1}")
        end
      end
      
      subject.send(:whenever_jobs).should == []
      
    end
    
    it 'should skip none runner jobs' do
      
      raw_jobs = {:month => [mock('job1'),mock('job2')]}
      
      subject.should_receive(:raw_whenever_jobs).and_return(raw_jobs)
      
      raw_jobs.each_pair do |time,jobs| 
        jobs.each_with_index do |job,index| 
          job.should_receive(:instance_variable_get).with("@template").and_return("some thing else")
        end
      end
      
      subject.send(:whenever_jobs).should == []
      
    end
    
  end
  
  describe "#raw_whenever_jobs" do
    
    subject { WheneverDelorean.new(nil,{:only => /./}) }
    
    it 'should return the raw whenever jobs' do
      
      subject.should_receive(:schedule_data).and_return("dummy_schdule_data")
      
      dummy_jobs_list = mock("jobs_list")
      Whenever::JobList.should_receive(:new).with("job_type :runner, 'runner'\n"+"dummy_schdule_data").and_return(dummy_jobs_list)
      
      dummy_jobs = mock("jobs")
      dummy_jobs_list.should_receive(:instance_variable_get).with("@jobs").and_return(dummy_jobs)
      
      subject.send(:raw_whenever_jobs).should == dummy_jobs
      
    end
  end
  
  describe "#schedule_data" do
    
    subject { WheneverDelorean.new(nil,{:only => /./}) }
    
    it 'should return the data from the config/schedule.rb file' do
      
      Rails.should_receive(:root).and_return("/dummy_root")
      File.should_receive(:read).with("/dummy_root/config/schedule.rb").and_return("dummy data")
      
      subject.send(:schedule_data).should == "dummy data"
      
    end
    
  end

end
