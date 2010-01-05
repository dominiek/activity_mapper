
require File.join(File.dirname(__FILE__), '../spec_helper')

describe ActivityMapper::TwitterServiceModule do
  
  before(:each) do
    @user = User.new(:id => 3)
  end
    
  it "should accept the proper URL's" do
    ActivityMapper::TwitterServiceModule.accepts?('http://twitter.com/dominiek').should be_true  
    ActivityMapper::TwitterServiceModule.accepts?('http://dominiek.twitter.com').should be_true
    ActivityMapper::TwitterServiceModule.accepts?('http://twieeeeeeeettr.com/dominiek').should be_false
  end
  
  it "should extract the right credentials on create_or_update_summary!" do
    profile = ServiceProfile.create(:url => 'http://twitter.com/dominiek')
    profile.create_or_update_summary!
    
    profile.username.should == 'dominiek'
    profile.avatar_url.should match(/amazon/)
    profile.url.should == 'http://twitter.com/dominiek'
  end
  
  it "should aggregate activity" do
    profile = ServiceProfile.create(:url => 'http://twitter.com/ptegelaar')
    profile.create_or_update_summary!
    profile.aggregate_activity!

    # Assert Peter's latest tweet
    tweet = profile.activities.last
    tweet.native_id.should == 1100430251
    tweet.url.should == "http://twitter.com/ptegelaar/status/1100430251"
    tweet.occurred_at.to_i.should == 1231279375
    
    activity_object = tweet.object
    tweet_body = "Foulmouthed midgets @ Bad Santa! :D"
    activity_object.title.should == tweet_body
    activity_object.body.should == tweet_body
    activity_object.native_id.should == tweet.native_id
    activity_object.url.should == tweet.url
  end

end
