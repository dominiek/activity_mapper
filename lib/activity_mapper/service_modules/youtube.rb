
module ActivityMapper
  
  class YoutubeServiceModule < ServiceModule
    ACTIVITY_MAP = {
      'feed/entry' => {
        'activity.occurred_at'          => 'published/$t',
        'activity.caption'              => 'title/$t',
        'activity_object.title'         => 'title/$t',
        'activity_object.body'          => 'media$group/media$description/$t',
        'activity_object.url'           => 'media$group/media$player/url',
        'activity.url'                  => 'media$group/media$player/url',
        'media.thumbnail_url'           => 'media$group/media$thumbnail[0]/url',
        'media.embed_url'               => 'media$group/media$content[0]/url',
        'media.duration'                => 'media$group/yt$duration/seconds',
        'rating_summary.rater_count'    => 'gd$rating/numRaters',
        'rating_summary.min'            => 'gd$rating/min',
        'rating_summary.max'            => 'gd$rating/max',
        'rating_summary.average'        => 'gd$rating/average',
        'rating_summary.view_count'     => 'yt$statistics/viewCount',
        'rating_summary.favorite_count' => 'yt$statistics/favoriteCount'
      }
    }
    ACCEPTED_HOSTS = [/youtube\.com/]

    # TODO use this data:
    # user view statistics
    def create_or_update_summary!(options = {})
      @profile.update_attributes(:username => self.class.username_from_url(@profile.url))
    end
  
    # TODO use this data
    # native id (need to somehow encode this to a big ass number: eg: dyMVZqJk8s4)
    # media.categories
    # media.keywords
    # media.credit
    # (media.uploader)
    def aggregate_activity!(options = {})
      mapper = ActivityDataMapper.new(ACTIVITY_MAP)
    
      mapper.fetch!(
        "http://gdata.youtube.com/feeds/api/users/#{@profile.username}/uploads?v=2&alt=json",
        :format => :json
      )
      mapper.map!
      mapper.entries.each do |entry|
        next if Activity.exists?(@profile.user_id, entry)
        create_activity(entry, ActivityObjectType::VIDEO, ActivityVerb::POST)
      end
    
      mapper.fetch!(
        "http://gdata.youtube.com/feeds/api/users/#{@profile.username}/favorites?v=2&alt=json",
        :format => :json
      )
      mapper.map!
      mapper.entries.each do |entry|
        next if Activity.exists?(@profile.user_id, entry)
        create_activity(entry, ActivityObjectType::VIDEO, ActivityVerb::FAVORITE)
      end
    end
  
  end
end