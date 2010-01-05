
require File.join(File.dirname(__FILE__), '../spec_helper')

FLICKR_API_KEY = '60c760aadec73cb5f2a85d9fc12a2b81' unless defined?(FLICKR_API_KEY)

describe ActivityMapper::FlickrServiceModule do
  
  before(:each) do
    @user = User.new(:id => 1)
  end
    
  it "should extract the right credentials on create_or_update_summary!" do
    user = User.new(:id => 1)
    profile = ServiceProfile.new(:url => 'http://www.flickr.com/photos/dominiekterheide/', :user => @user)
    profile.create_or_update_summary!
    profile.username.should == 'dominiekth'
    profile.native_id.should == '71386598@N00'


    profile = ServiceProfile.new(:url => 'http://www.flickr.com/photos/71386598@N00/', :user => @user)
    profile.create_or_update_summary!
    profile.username.should == 'dominiekth'
    profile.native_id.should == '71386598@N00'
  end
  
  it "should aggregate activity" do
    profile = ServiceProfile.new(:url => 'http://www.flickr.com/photos/dominiekterheide/', :user => @user)
    profile.create_or_update_summary!
    profile.aggregate_activity!
    profile.activities.size.should == 37
    activity = profile.activities.first
    activity.caption.should == "かに！"
    activity.object.tag_list.should include('wharf')
  end
  
  it "should be able to aggregate an empty set of favorites" do
    profile = ServiceProfile.new(:url => "http://www.flickr.com/photos/14594137@N04/", :user => @user)
    profile.create_or_update_summary!
    profile.aggregate_activity!
    profile.activities.size.should == 12
  end

end
