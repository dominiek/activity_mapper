
module ActivityMapper
  module Version
    MAJOR = 0
    MINOR = 1
    REVISION = 0
    class << self
      def to_version
        "#{MAJOR}.#{MINOR}.#{REVISION}"
      end
 
      def to_name
        "#{MAJOR}_#{MINOR}_#{REVISION}"
      end
    end
  end
end

require 'json'
require 'xmlsimple'
require 'activesupport'
require 'mechanize'

require 'logger'
require 'cgi'
require 'md5'


require File.join(File.dirname(__FILE__), 'extensions/uri')

require File.join(File.dirname(__FILE__), 'activity_mapper/linguistics')
require File.join(File.dirname(__FILE__), 'activity_mapper/connector')
require File.join(File.dirname(__FILE__), 'activity_mapper/activity_data_mapper')
require File.join(File.dirname(__FILE__), 'activity_mapper/service_module')
require File.join(File.dirname(__FILE__), 'activity_mapper/service_modules')
