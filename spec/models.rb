
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

class Activity < PersistentObject

  # Implement anti-duplication mechanisms here
  def self.exists?(user_id, entry)
    false
  end

end

class ActivityVerb < PersistentObject
  
  POST          = ActivityVerb.new(:id => 1)
  FAVORITE      = ActivityVerb.new(:id => 2)
  RECENTLY_USED = ActivityVerb.new(:id => 3)
  NEWLY_USED    = ActivityVerb.new(:id => 4)
  
end

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

class Media < PersistentObject; end
class RatingSummary < PersistentObject; end
class Profile < PersistentObject; end
class User < PersistentObject; end
class ServiceProfile < PersistentObject
  
  def initialize(*arg)
    super(*arg)
    @activities = []
  end
  
  # has_many
  attr_accessor :activities
  
  # ServiceModule method routing
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
