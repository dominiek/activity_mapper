
# For this example, we're using OpenStruct as a storage system.
# Normally one would use DataMapper or ActiveRecord

require 'ostruct'

class PersistentObject < OpenStruct
  
  attr_accessor :id
  
  def self.create(*arg)
    self.new(*arg)
  end
  
  def update_attributes(attrs)
    attrs.each do |name, value|
      self.send("#{name}=", value)
    end
  end
  
end

# -- All objects below need to be defined in order for activity_mapper to function

# Your base user object
class User < PersistentObject; end

# Profile information: username, native_id, url
class ServiceProfile < PersistentObject
  
  # belongs_to :user, implement me!
  # has_many :activities, implement me!
  def initialize(*arg); super(*arg); @activities = []; end
  attr_accessor :activities
  
  # -- All below is code necessary for routing to the proper service module (based on URL)
  
  def create_or_update_summary!(*arg); service_module ? service_module.create_or_update_summary!(*arg) : nil; end
  def aggregate_activity!(*arg); service_module ? service_module.aggregate_activity!(*arg) : nil; end
  def analyze_this(*arg); service_module ? service_module.analyze_this(*arg) : nil; end
  
  def service_module
    return @service_module if @service_module
    if (service_module_klass = ActivityMapper::ServiceModule.klass_for(url))
      @service_module = service_module_klass.new(self)
    else
      nil
    end
  end
  
end

# The actual event that happened: caption, occurred_at, url, reference to ActivityObject
class Activity < PersistentObject

  # has_one :object, implement me!

  # Implement anti-duplication mechanisms here
  def self.exists?(user_id, entry)
    false
  end

end

# The object that's referenced by the event: title, body, url, created_at
class ActivityObject < PersistentObject
  
  def self.fetch(content_identifier, activity_object_type_id)
    nil
  end

  def self.content_identifier(url)
    MD5.hexdigest(url)
  end
  
  # To support space separated tags from APIs
  def spaced_tags=(value)
    self.tag_list = value.to_s.split(' ')
  end
  
end

# Optional object that holds ranking/stats information
class RatingSummary < PersistentObject; end

# Hold media information
class Media < PersistentObject; end

# See activitystrea.ms for more verbs
class ActivityVerb < PersistentObject
  
  # Constant Cache
  POST          = ActivityVerb.new(:id => 1)
  FAVORITE      = ActivityVerb.new(:id => 2)
  RECENTLY_USED = ActivityVerb.new(:id => 3)
  NEWLY_USED    = ActivityVerb.new(:id => 4)
  
end

# See activitystrea.ms for more types
class ActivityObjectType < PersistentObject

  # Constant Cache
  STATUS    = ActivityObjectType.new(:id => 1)
  BOOKMARK  = ActivityObjectType.new(:id => 2)
  PHOTO     = ActivityObjectType.new(:id => 3)
  VIDEO     = ActivityObjectType.new(:id => 4)
  SONG      = ActivityObjectType.new(:id => 5)
  MIXED     = ActivityObjectType.new(:id => 6)
  SOFTWARE  = ActivityObjectType.new(:id => 7)
  SLIDESHOW = ActivityObjectType.new(:id => 8)

end

