

require File.join(File.dirname(__FILE__), '../spec_helper')

describe ActivityMapper::WakoopaServiceModule do
  
  before(:each) do
    @user = User.new(:id => 3)
  end
    
  it "should accept the proper URL's" do
    ActivityMapper::WakoopaServiceModule.accepts?('http://wakoopa.com/peter').should be_true
    ActivityMapper::WakoopaServiceModule.accepts?('http://wakopa.com/peter').should be_false
  end
  
  it "should extract the right credentials on create_or_update_summary!" do
    profile = ServiceProfile.create(:url => 'http://wakoopa.com/peter')
    profile.create_or_update_summary!
    profile.username.should == 'peter'
    profile.url.should == 'http://wakoopa.com/peter'
  end
  
  it "should aggregate activity" do
    profile = ServiceProfile.create(:url => 'http://wakoopa.com/peter')
    profile.create_or_update_summary!
    profile.aggregate_activity!
    profile.activities.size.should == 10
    
    activity = profile.activities.first
    activity.object.native_id.should == 9917
    activity.object.url.should == "http://wakoopa.com/software/textmate"
    activity.occurred_at.to_i.should == 1232460000
  end

end
