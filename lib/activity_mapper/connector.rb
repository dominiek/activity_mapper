
module ActivityMapper
  
  class Connector
  
    def self.fetch(url, options = {})
      options[:method] ||= :get
    
      warning_in_test_env(url)
    
      agent = WWW::Mechanize.new
      agent.user_agent_alias = 'Mac FireFox'
      begin
        logger.info("Fetching #{url} (:method=#{options[:method]})")
        response = agent.send(options[:method], url)
      rescue => e
        raise error(e, "Unable to fetch #{url}")
      end
      # TODO deal with redirects n stuff
      if response.code.to_i != 200
        raise error(e, "Got invalid HTTP response (#{response.code}) for #{url}")
      end
    
      response.body
    end
  
    def self.deserialize(response_body, format)
      # Convert response data to Hash
      begin
        case format
          when :xml
            XmlSimple.xml_in(response_body)
          else
            JSON.parse(response_body)
        end 
      rescue JSON::ParserError => e
        raise Connector.error(e, "Unable to decode JSON response, got: '#{response_body.to_s.slice(0, 400)}'")
      end
    end
  
    protected

    class Error < StandardError; end
  
    def self.error(e, message = nil)
      full_message = "#{self} error: #{message} (#{e.to_s})"
      logger.warn(full_message)
      logger.error(e)
      Error.new(full_message)
    end
  
    class ConnectorLogger < Logger
      def format_message(severity, timestamp, progname, msg)
        "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n" 
      end
    end
  
    def self.logger
      env_appendix = "_#{RAILS_ENV}" if defined?(RAILS_ENV)
      @@logger ||= ConnectorLogger.new(File.join(File.dirname(__FILE__), "../../log/#{self.to_s.underscore.split('/').last}#{env_appendix}.log"))
    end
  
    def self.warning_in_test_env(url = 'something')
      if (defined?(RAILS_ENV) && RAILS_ENV['test']) || (defined?(TEST) && TEST)
        $stderr.puts("Warning, doing an actual HTTP GET request to #{url}")
      end
    end
  
  end

end