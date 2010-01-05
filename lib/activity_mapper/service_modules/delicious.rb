
module ActivityMapper

  class DeliciousServiceModule < ServiceModule
    ACTIVITY_MAP = {
      nil => {
        'activity.occurred_at'          => 'dt',
        'activity.caption'              => 'd',
        'activity_object.title'         => 'd',
        'activity_object.body'          => 'd',
        'activity_object.tag_list'      => 't',
        'activity_object.url'           => 'u',
        'activity.url'                  => 'u'
      }
    }
    ACCEPTED_HOSTS = [/delicious\.com/, /del\.icio\.us/]
  
    def create_or_update_summary!(options = {})
      @profile.update_attributes(:username => self.class.username_from_url(@profile.url))
    end
  
    def aggregate_activity!(options = {})
      mapper = ActivityDataMapper.new(ACTIVITY_MAP)
    
      mapper.fetch!(
        "http://feeds.delicious.com/v2/json/#{@profile.username}?count=20",
        :format => :json
      )
      mapper.map!
      mapper.entries.sort! { |e2,e1|
        e1['activity.occurred_at'] <=> e2['activity.occurred_at']
      }
      mapper.entries.each do |entry|
        break if Activity.exists?(@profile.user_id, entry)
        create_activity(entry, ActivityObjectType::BOOKMARK, ActivityVerb::POST)
      end
    end
  
  end
  
end