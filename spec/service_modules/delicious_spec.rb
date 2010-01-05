
require File.join(File.dirname(__FILE__), '../spec_helper')

describe ActivityMapper::DeliciousServiceModule do
  
  before(:each) do
    @user = User.new(:id => 1)
  end
    
  it "should accept the proper URL's" do
    ActivityMapper::DeliciousServiceModule.accepts?('http://delicious.com/dominiekth/').should be_true  
    ActivityMapper::DeliciousServiceModule.accepts?('http://del.icio.us/dominiekth/').should be_true
  end
  
  it "should extract the right credentials on create_or_update_summary!" do
    profile = ServiceProfile.create(:url => 'http://delicious.com/dominiekth/')
    profile.create_or_update_summary!
    profile.username.should == 'dominiekth'
  end
  
  it "should aggregate activity" do
    profile = ServiceProfile.create(:url => 'http://delicious.com/dominiekth/', :user => @user)
    profile.create_or_update_summary!
    profile.aggregate_activity!
    profile.activities.size.should == 20
    activity = profile.activities.first
    activity.occurred_at.to_i.should == 1238138051
    activity.object.tag_list.should include('ruby')
  end

end

