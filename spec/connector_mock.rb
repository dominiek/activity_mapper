
require 'mechanize'

module ActivityMapper

  class Connector
  
    @@simulate_connection_failure = false
    @@simulate_data_failure = false
    @@connect_count = 0
  
    cattr_accessor :simulate_connection_failure, :simulate_data_failure, :connect_count
  
    def self.fetch(url, options = {})
      options[:method] ||= :get
    
      @@connect_count += 1
    
      if @@simulate_data_failure
        return 'INVALIDK(...;'
      end
    
      if @@simulate_connection_failure == true
        raise Connector.error(StandardError.new('FuckyfuckError'), "Error fetching #{url}")
      end
    
      uri = URI.parse(url)
      destination_path = File.dirname(__FILE__) + "/data/#{uri.domain_key}_#{MD5.hexdigest(url)}.#{options[:format].to_s}"
      logger.info("Fetching #{url} (:method=#{options[:method]}) TEST_PATH=#{destination_path}")
      if File.exists?(destination_path)
        File.open(destination_path).read
      else
        agent = WWW::Mechanize.new
        agent.user_agent_alias = 'Mac FireFox'
        response = agent.send(options[:method], url)
        puts "-"*120
        puts "FETCHING #{url}"
        puts "STORING it as #{destination_path}, please run unit test again!"
        puts "-"*120
        fp = File.open(destination_path, 'w+')
        fp.write(response.body)
        fp.close
        response.body
      end
    end
  
  end
  
end