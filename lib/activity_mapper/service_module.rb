
module ActivityMapper

  class ServiceModule
  
    COMMON_DIRECTIVES = ['user', 'users', 'person', 'people', 'traveller', 'in', 'profile', 'profiles']
  
    def initialize(profile)
      @profile = profile
    end
  
    def self.all_accepted_hosts
      host_expressions = []
      self.subclasses.each do |service_module_klass|
        host_expressions << eval("#{service_module_klass.to_s}::ACCEPTED_HOSTS")
      end
      host_expressions.flatten!
    end
  
    def self.klass_for(url)
      self.subclasses.each do |service_module_klass|
        if service_module_klass.accepts?(url)
          return service_module_klass
        end
      end
      nil
    end
    
    # http://groups.google.com/group/comp.lang.ruby/browse_thread/thread/e812c7cef446a96?pli=1
    def self.subclasses
      class_hash = {}
      ObjectSpace.each_object do |obj|
        if Class == obj.class
          if obj.ancestors.include? self
            class_hash[obj] = true
          end
        end
      end
      class_hash.keys.reject { |ch| ch == self }
    end
  
    # Based on a profile url, decide if I need to be responsible for this
    def self.accepts?(url)  
      u = uri(url)
      return false unless u
      
      self::ACCEPTED_HOSTS.each do |host_re|
        if (u.host =~ host_re)
          return true
        end
      end
      false
    end
  
    def self.detect_username(profiles)
      usernames = {}
      profiles.each do |me_url|
        username = username_from_url(me_url)
        if username
          usernames[username] ||= 0
          usernames[username] += 1
        end
      end
    
      usernames = usernames.to_a
      return [] if usernames.blank?
    
      usernames.sort! { |b,a| a.last <=> b.last }
    
      # Factor in the shortest username if top 2 matches have the same score
      top_score = usernames[0].last
      if (usernames[1] && usernames[1].last == top_score)
        usernames = [usernames[0], usernames[1]]
        usernames.sort! { |a,b| a.first.size <=> b.first.size }
      end
    
      usernames.collect(&:first)
    end
  
    # -- Implementables

    # Update the long term data (eg top used software, biography)
    def create_or_update_summary!(options = {}); raise "Method not implemented"; end
  
    # This is called as often as possible, this is to passively aggregate the latest activity
    def aggregate_activity!(options = {}); raise "Method not implemented"; end
  
    # -- Optional Implementables
  
    # Analyze an individual activity object (eg photo, bookmark, book, software, slide...)
  
    def shallow_analysis_on(activity_object)
      return unless activity_object.shallowly_analyzed_at.blank?
    
      # Extract social connections from body
      #unless activity_object.body.blank?
      #  SocialConnection.generate_from_nanoformats(@profile, activity_object.body)
      #end
    
      # Extract tags from title
      unless activity_object.title.blank?
        tags = Linguistics::Tagger.keywords_for_caption(activity_object.title)
        activity_object.tag_list = (activity_object.tag_list || []) + tags
        activity_object.shallowly_analyzed_at = Time.now
        activity_object.save
      end
    end
  
    def deep_analysis_on(activity_object)
      return unless activity_object.deeply_analyzed_at.blank?
      return unless activity_object.body.size > 100
      unless activity_object.body.blank?
        @extractor = ZemantaExtractor.new
        tags = @extractor.extract_tags(activity_object.body)
        activity_object.tag_list = activity_object.tag_list + tags
        activity_object.save
      end
    end
  
    protected
  
    def self.username_from_url(url)
      # Check for http://:host/COMMON_DIRECTIVES/:username
      username_after_directive = url.match(/^http\:\/\/([^\/]+)\/([^\/]+)\/([^\/]+)/)
      if username_after_directive && 
         username_after_directive[3] && 
         COMMON_DIRECTIVES.include?(username_after_directive[2])
        return username_after_directive[3]
      end
    
      # Check for http://:host/COMMON_DIRECTIVES?:var=:username
      username_after_directive = url.match(/^http\:\/\/([^\/]+)\/([^\/]+)\?\w+\=([^\/]+)/)
      if username_after_directive && 
         username_after_directive[3] && 
         COMMON_DIRECTIVES.include?(username_after_directive[2])
        return username_after_directive[3]
      end
    
      # Check for http://:host/username
      username_ending = url.match(/^http\:\/\/([^\/]+)\/([^\/]+)\/*$/)
      if username_ending
        return username_ending[2]
      end
    
      nil
    end
  
    def self.uri(url)
      URI.parse(url)
    rescue => e
      nil
    end
  
    def create_activity(mapped_entry, activity_object_type, activity_verb, additional_activity_parameters = {}, &block)
      @object_names ||= mapped_entry.keys.collect { |oa| oa.split('.').first }
    
      return unless mapped_entry['activity_object.url'] # Need proper warning here
    
      # Create entity pool
      activity = Activity.create(additional_activity_parameters.merge(
        :user_id         => @profile.user_id,
        :verb            => activity_verb
      ))
      content_identifier = ActivityObject.content_identifier(mapped_entry['activity_object.url'])
      activity_object = ActivityObject.fetch(content_identifier, activity_object_type.id)
      activity_object ||= ActivityObject.create(:activity_object_type_id => activity_object_type.id)
      media = @object_names.include?('media') ? Media.create : nil
      rating_summary = @object_names.include?('rating_summary') ? RatingSummary.create : nil
    
      # Auto-populate attributes
      mapped_entry.each do |destination, value|
        eval("#{destination} = value")
      end
    
      if block
        block.call(activity, activity_object)
      end
    
      shallow_analysis_on(activity_object)
    
      # Save all
      activity_object.media = media unless media.blank?
      activity_object.rating_summary = rating_summary unless rating_summary.blank?
      activity_object.save
      activity.object = activity_object
      activity.save
      
      @profile.activities << activity
      @profile.save
    end
  
  end

end