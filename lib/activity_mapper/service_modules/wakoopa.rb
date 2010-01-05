
module ActivityMapper
  
  class WakoopaServiceModule < ServiceModule
    ACTIVITY_MAP = {
      nil => {
        'activity.occurred_at'       => 'software/last_active_at',
        'activity.caption'           => 'software/name',
        'activity_object.native_id'  => 'software/id',
        'activity_object.title'      => 'software/name',
        'activity_object.body'       => 'category/name',
        'activity_object.url'        => 'software/complete_url',
        'media.thumbnail_url'        => 'software/complete_icon_url',
        'rating_summary.rater_count' => 'software/num_users',
        'rating_summary.view_count'  => 'software/active_seconds'
      }
    }
    ACCEPTED_HOSTS = [/wakoopa\.com/]
  
    # most_used
  
    # Available data:
    # software: active-seconds 
    # software: created-at
    # software: description
    # software: id *
    # software: name *
    # software: num-users
    # software: updated-at
    # software: url *
    # software: complete-url
    # software: complete-icon-url
    # software: complete-thumb-url
    # software: developer: id
    # software: developer: name
    # software: developer: complete-url
    # software: category: description *
    # software: category: id
    # software: category: name
    # software: category: complete-url
    # software: os-types
    # activity["most_used"].each do |software|
    #   
    #   occurred_at = DateTime.parse(software['created_at']).to_time
    #   
    #   next if Activity.exists?(self.user_id, software['category']['description'], occurred_at)
    #   
    #   activity            = Activity.create(
    #     :service_profile  => self,
    #     :user_id          => self.user_id,
    #     :native_id        => software['id'].to_i,
    #     :activity_verb_id => ActivityVerb::MOST_USED.id,
    #     :url              => software['complete_url'],
    #     :occurred_at      => occurred_at # UTC OK
    #   )
    # 
    #   activity.object            = ActivityObject.create(
    #     :title                   => software['name'],
    #     :body                    => software['category']['description'],
    #     :url                     => activity.url,
    #     :native_id               => activity.native_id,
    #     :activity_object_type_id => ActivityObjectType::STATUS.id
    #   )
    # 
    #   activity.save
    # end
  
    # comments
  
    # Available data:
    # created-at
    # id
    # text
    # owner: active-seconds
    # owner: country
    # owner: created-at
    # owner: id
    # owner: name
    # owner: updated-at
    # owner: username
    # owner: complete-url
    # owner: complete-icon-url
    # owner: complete-thumb-url
    # owner: os-types
  
  
    # TODO use this data:
    # None, the Wakoopa API calls assume you know the user already and doesn't explicitly provide this data
  
    # TO DO: implement these fields
  
    # contacts
    # NB in de JSON call hebben ze het ineens over user ipv contact
    # Hiermee haal je de eerste 10 contacts/users binnen
  
    # Available data
    #     contact: active-seconds
    #     contact: country
    #     contact: created-at
    #     contact: id
    #     contact: name
    #     contact: updated-at
    #     contact: username
    #     contact: complete-url
    #     contact: complete-icon-url
    #     contact: complete-thumb-url
    #     contact: os-types
  
    # teams
    # Alleen 1e 10 teams
  
    # Available data
    #     team: active seconds
    #     team: created-at
    #     team: description
    #     team: id
    #     team: name
    #     team: num-users
    #     team: complete-url
  
    def create_or_update_summary!(options = {})
      #softwares = WakoopaConnector.most_used_for(attributes[:username]) # Gebeurt er nog wat met softwares? Nee, niet echt :]
      # avatar not (yet) available in the API calls
      # native_user_id not (yet) available in the API calls
      @profile.update_attributes(:username => self.class.username_from_url(@profile.url))
    end
  
    # TODO: since this is a summary, this should be done on create! and update! Need to implement recent activity here
    # TODO use this data:
    # software.complete_icon_url
    # software.complete_thumb_url
    # software.category
    # software.num_users
    # software.developer
    # software.url
    # software.active_seconds
    def aggregate_activity!(options = {})
      # most_used_softwares = WakoopaConnector.most_used_for(username)
      # attributes = attributes_or_url.is_a?(Hash) ? attributes_or_url : {:username => username_from_url(attributes_or_url)}
      #activities = WakoopaConnector.get_all_activity_for(username)
      #activities.each { |activity,data| aggregate_for_activity(activity,data) }
    
      mapper = ActivityDataMapper.new(ACTIVITY_MAP)
      mapper.fetch!("http://api.wakoopa.com/#{@profile.username}/recently_used.json", 
        :format => :json, 
        :strip_callback => true
      )
      mapper.map!
      mapper.entries.each do |entry|
        next if Activity.exists?(@profile.user_id, entry)
        create_activity(entry, ActivityObjectType::SOFTWARE, ActivityVerb::RECENTLY_USED)
      end
    
=begin
    data.each do |software|
    
      occurred_at = (software['software']['created_at'])
    
      next if Activity.exists?(self.user_id, software['software']['name'], occurred_at)
    
      activity            = Activity.create(
        :service_profile  => self,
        :user_id          => self.user_id,
        :native_id        => software['software']['id'].to_i,
        :activity_verb_id => ActivityVerb::RECENTLY_USED.id,
        :url              => software['software']['complete_url'],
        :occurred_at      => occurred_at # UTC OK
      )
    
      body = (software['software']['category'].class == NilClass) ? "" : software['software']['category']['description']
    
      activity.object            = ActivityObject.create(
        :title                   => software['software']['name'],
        :body                    => body,
        :url                     => activity.url,
        :native_id               => activity.native_id,
        :activity_object_type_id => ActivityObjectType::STATUS.id
      )
    
      activity.save
    end
=end
    
    end
=begin
  def aggregate_for_activity(activity,data)
    case activity
      when "recently_used"
        recently_used(data)
      when "newly_used"
        newly_used(data)
      when "comments"
        comments(data)
      when "reviews"
        reviews(data)
      else puts "error"
    end
  end
  
  def recently_used(data)
    # Available data is the same as for most_used.
    data.each do |software|
    
      occurred_at = (software['software']['created_at'])
    
      next if Activity.exists?(self.user_id, software['software']['name'], occurred_at)
    
      activity            = Activity.create(
        :service_profile  => self,
        :user_id          => self.user_id,
        :native_id        => software['software']['id'].to_i,
        :activity_verb_id => ActivityVerb::RECENTLY_USED.id,
        :url              => software['software']['complete_url'],
        :occurred_at      => occurred_at # UTC OK
      )
    
      body = (software['software']['category'].class == NilClass) ? "" : software['software']['category']['description']
    
      activity.object            = ActivityObject.create(
        :title                   => software['software']['name'],
        :body                    => body,
        :url                     => activity.url,
        :native_id               => activity.native_id,
        :activity_object_type_id => ActivityObjectType::STATUS.id
      )
    
      activity.save
    end
  end

  def newly_used(data)
    # Available data is the same as for most_used.
    data.each do |software|
      # occurred_at = DateTime.parse(software['software']['updated_at']).to_time
      # JSON converter automatically makes it into a time
      occurred_at = software['software']['updated_at'] # Is this the proper field?
    
      next if Activity.exists?(self.user_id, software['software']['name'], occurred_at)
    
      activity            = Activity.create(
        :service_profile  => self,
        :user_id          => self.user_id,
        :native_id        => software['software']['id'].to_i,
        :activity_verb_id => ActivityVerb::NEWLY_USED.id,
        :url              => software['software']['complete_url'],
        :occurred_at      => occurred_at # UTC OK
      )
    
      body = (software['software']['category'].class == NilClass) ? "" : software['software']['category']['description']
    
      activity.object            = ActivityObject.create(
        :title                   => software['software']['name'],
        :body                    => body,
        :url                     => activity.url,
        :native_id               => activity.native_id,
        :activity_object_type_id => ActivityObjectType::STATUS.id
      )
    
      activity.save
    end
  end

  # COMMENTS
  # NB Get the 10 most recent comments. This can be adjusted to [1..30]

  # Available data:
  # created-at *
  # id *
  # text *
  # owner: active-seconds
  # owner: country
  # owner: created-at
  # owner: id
  # owner: name
  # owner: updated-at
  # owner: username
  # owner: complete-url
  # owner: complete-icon-url
  # owner: complete-thumb-url
  # owner: os-types
  def comments(data)
    data.each do |comment|
      # JSON converter automatically makes it into a time
      occurred_at = comment['user_comment']['created_at']
    
      next if Activity.exists?(self.user_id, comment['user_comment']['text'], occurred_at)
    
      activity            = Activity.create(
        :service_profile  => self,
        :user_id          => self.user_id,
        :native_id        => comment['user_comment']['id'].to_i,
        :activity_verb_id => ActivityVerb::COMMENT.id,
        :url              => "http://wakoopa.com/#{username}/comments?page=1",
        :occurred_at      => occurred_at # UTC OK
      )
    
      activity.object            = ActivityObject.create(
        :title                   => comment['user_comment']['text'],
        :body                    => comment['user_comment']['text'],
        :url                     => activity.url,
        :native_id               => activity.native_id,
        :activity_object_type_id => ActivityObjectType::STATUS.id
      )
    
      activity.save
    end
  end


  # REVIEWS

  # Available data: same as most_used, plus:
  # created-at *
  # id *
  # rating TO DO
  # text *
  def reviews(data)
  
    data.each do |review|
    
      occurred_at = review['review']['created_at']
    
      next if Activity.exists?(self.user_id, review['review']['text'], occurred_at)
    
      activity            = Activity.create(
        :service_profile  => self,
        :user_id          => self.user_id,
        :native_id        => review['review']['id'].to_i,
        :activity_verb_id => ActivityVerb::REVIEW.id,
        :url              => review['review']['software']['complete_url'] + "/review/#{review['id']}",
        :occurred_at      => occurred_at # UTC OK
      )
    
      activity.object            = ActivityObject.create(
        :title                   => review['review']['text'],
        :body                    => review['review']['text'],
        :url                     => activity.url,
        :native_id               => activity.native_id,
        :activity_object_type_id => ActivityObjectType::STATUS.id
      )
    
      activity.save
    end
  end

=end

  end
  
end