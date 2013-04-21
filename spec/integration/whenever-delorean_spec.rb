require 'spec_helper'

#
# TestWhenever.time_travel_to("1 month ago", :only => /uehtnosuao/)
#

describe "WheneverDelorean" do
  
  describe ".time_travel_to" do
    
    it "should take us to the supplied time and trigger all whenever jobbs we pass" do
    
      Rails.should_receive(:root).and_return("/dummy-rails-root")
      File.should_receive(:read).with("/dummy-rails-root/config/schedule.rb").and_return(%{
        every 1.day, :at => '4:30 am' do
          runner "TestHelper.a_dummy_method"
        end
      })
  
      TestHelper.should_receive(:a_dummy_method).exactly(30).times
      
      WheneverDelorean.time_travel_to("30 days from now")
    end
    
    it 'should be able to handle multable runners' do
      
      Rails.should_receive(:root).and_return("/dummy-rails-root")
      File.should_receive(:read).with("/dummy-rails-root/config/schedule.rb").and_return(%{
        every 1.day, :at => '4:30 am' do
          runner "TestHelper.a_dummy_method"
        end
        
        every 1.day, :at => '5:30 am' do
          runner "TestHelper.a_dummy_method"
        end
      })
  
      TestHelper.should_receive(:a_dummy_method).exactly(10).times
      
      WheneverDelorean.time_travel_to("5 days from now")
      
    end
    
    it 'should ignore rake tasks' do
      
      Rails.should_receive(:root).and_return("/dummy-rails-root")
      File.should_receive(:read).with("/dummy-rails-root/config/schedule.rb").and_return(%{
        every 1.day, :at => '4:30 am' do
          rake "TestHelper.a_dummy_method"
        end
        
        every 1.day, :at => '5:30 am' do
          runner "TestHelper.a_dummy_method"
        end
      })
  
      TestHelper.should_receive(:a_dummy_method).exactly(5).times
      
      WheneverDelorean.time_travel_to("5 days from now")
      
    end
    
  end
end
