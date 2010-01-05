
module ActivityMapper
  
  class TwitterServiceModule < ServiceModule
    ACTIVITY_MAP = {
      nil => {
        'activity.occurred_at'      => 'created_at',
        'activity.native_id'        => 'id',
        'activity_object.native_id' => 'id',
        'activity.caption'          => 'text',
        'activity_object.title'     => 'text',
        'activity_object.body'      => 'text'
      }
    }
    ACCEPTED_HOSTS = [/twitter\.com/]
  
    # TODO use this data:
    # user.name
    # user.description
    # user.location
    # user.url
    def create_or_update_summary!(options = {})
      attributes = {}
      attributes[:username] = @profile.username || self.class.username_from_url(@profile.url)
    
      mapper = ActivityDataMapper.new(ACTIVITY_MAP)
      mapper.fetch!("http://twitter.com/statuses/user_timeline/#{attributes[:username]}.json", :format => :json)
      tweets = mapper.data
    
      attributes[:avatar_url] = tweets.blank? ? nil : tweets.first['user']['profile_image_url']
      attributes[:native_user_id] = tweets.first['user']['id'].to_i
      @profile.update_attributes(attributes)
    end
  
    # TODO use this data:
    # tweet.favorited
    # tweet.source # = what application was used to tweet (Wakoopa?)
    # (tweet.in_reply_to_screen_name)
    # (tweet.in_reply_to_status_id)
    def aggregate_activity!(options = {})
      mapper = ActivityDataMapper.new(ACTIVITY_MAP)
      mapper.fetch!("http://twitter.com/statuses/user_timeline/#{@profile.username}.json", :format => :json)
      mapper.map!
      mapper.entries.sort! { |e2,e1|
        e1['activity.occurred_at'] <=> e2['activity.occurred_at']
      }
      mapper.entries.each do |entry|
        entry['activity_object.url'] = entry['activity.url'] = "http://twitter.com/#{@profile.username}/status/#{entry['activity.native_id']}"
        break if Activity.exists?(@profile.user_id, entry)
        create_activity(entry, ActivityObjectType::STATUS, ActivityVerb::POST) do |activity, activity_object|
        end
      
      end
    end
  
  end
end