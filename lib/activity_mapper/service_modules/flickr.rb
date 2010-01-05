
module ActivityMapper
  
  class FlickrServiceModule < ServiceModule
    ACTIVITY_MAP = {
      'items' => {
        'activity.occurred_at'          => 'published',
        'activity.caption'              => 'title',
        'activity_object.title'         => 'title',
        'activity_object.body'          => 'description',
        'activity_object.spaced_tags'   => 'tags',
        'activity_object.url'           => 'link',
        'activity.url'                  => 'link',
        'media.thumbnail_url'           => 'media/m',
        'media.embed_url'               => 'media/m'
      }
    }
    ACCEPTED_HOSTS = [/flickr\.com/]
  
    def create_or_update_summary!(options = {})
      @profile.update_attributes(:username => self.class.username_from_url(@profile.url))
      if @profile.native_id.blank?
        response_body = Connector.fetch("http://api.flickr.com/services/rest/?method=flickr.urls.lookupUser&api_key=#{FLICKR_API_KEY}&url=#{CGI.escape(@profile.url)}&format=json&nojsoncallback=1")
        profile = Connector.deserialize(response_body, :json)
        if profile['user']
          @profile.native_id = profile['user']['id']
          @profile.username = profile['user']['username']['_content'] if profile['user']['username']
          @profile.save
        end
      end
    end
  
    def aggregate_activity!(options = {})
      mapper = ActivityDataMapper.new(ACTIVITY_MAP)
    
      mapper.fetch!(
        "http://api.flickr.com/services/feeds/photos_public.gne?id=#{@profile.native_id}&lang=en-us&format=json&nojsoncallback=1",
        :format => :json
      )
      mapper.map!
      mapper.entries.each do |entry|
        next if Activity.exists?(@profile.user_id, entry)
        create_activity(entry, ActivityObjectType::PHOTO, ActivityVerb::POST)
      end
    
      mapper.fetch!(
        "http://api.flickr.com/services/feeds/photos_faves.gne?nsid=#{@profile.native_id}&lang=en-us&format=json&nojsoncallback=1",
        :format => :json
      )
      mapper.map!
      mapper.entries.each do |entry|
        next if Activity.exists?(@profile.user_id, entry)
        create_activity(entry, ActivityObjectType::PHOTO, ActivityVerb::FAVORITE)
      end
    end
  
  end
  
end
