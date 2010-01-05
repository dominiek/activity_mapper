

require File.join(File.dirname(__FILE__), '../spec_helper')

describe ActivityMapper::YoutubeServiceModule do
  
  before(:each) do
    @user = User.new(:id => 1)
  end
  
  it "should extract the right credentials on create_or_update_summary!" do
    profile = ServiceProfile.create(:url => 'http://youtube.com/dominiekth', :user => @user)
    profile.create_or_update_summary!
    profile.username.should == 'dominiekth'
    profile.url.should == 'http://youtube.com/dominiekth'
    
    profile = ServiceProfile.create(:url => 'http://www.youtube.com/profile?user=dominiekth')
    profile.create_or_update_summary!
    profile.username.should == 'dominiekth'
  end
  
  it "should aggregate activity" do
    profile = ServiceProfile.create(:url => 'http://youtube.com/dominiekth')
    profile.create_or_update_summary!
    profile.user = @user
    profile.aggregate_activity!
    profile.activities.size.should == 27
    activity = profile.activities[2]
    activity.url.should == "http://www.youtube.com/watch?v=gNWhPffhKf8"
    #activity.verb.id.should == ActivityVerb::POST.id

    activity_object = activity.object
    activity_object.title.should == "the Hong Kong Dutchies"
    activity_object.body.should match(/trip/)
    #activity_object.type.id.should == ActivityObjectType::VIDEO.id

    media = activity_object.media
    media.duration.to_i.should == 28
    media.embed_url.should match(/youtube.com\/v\//)
    media.thumbnail_url.should match("i.ytimg.com")

    rating_summary = activity_object.rating_summary
    rating_summary.view_count.to_i.should == 35
  end

end

