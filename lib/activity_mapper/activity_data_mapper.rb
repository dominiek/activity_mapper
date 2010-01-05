
module ActivityMapper
  
  class ActivityDataMapper
  
    attr_reader :entries, :data
  
    def initialize(map)
      @map = map
    end
  
    def fetch!(url, options = {})
      response_body = fetch_url(url, options)
    
      # Some sites only provide a JSONP response
      if options[:strip_callback]
        response_body = strip_callback(response_body)
      end
    
      @data = Connector.deserialize(response_body, options[:format])
    
    end
  
    def map!
      @entries = map(@data)
    end
  
    protected
  
    def fetch_url(url, options)
      Connector.fetch(url, options)
    end
  
    class CouldNotMapError < StandardError; end
  
    ARRAY_RE = /^([^\[]+)\[(\d+)\]$/
  
    def map(data)
      mapped_entries = []
      path_to_entries = @map.keys.first
      entries = path_to_entries.blank? ? data : element_by_path(data, path_to_entries.split('/').dup)
    
      # If we couldn't nest, something fishy is going on
      if !entries.is_a?(Array) && path_to_entries.split('/').size == 1
        raise CouldNotMapError.new("Expected #{path_to_entries} to be an Array (Invalid Data)")
      end
    
      # If we are already in the deep, the feed probably has a weird way of showing emptyness
      if entries.is_a?(Array)
        entry_map = @map[path_to_entries]
        entries.each do |entry|
          mapped_entry = {}
          entry_map.each do |destination, path|
            mapped_entry[destination] = determine_value(element_by_path(entry, path.split('/').dup), destination)
          end
          mapped_entries << mapped_entry
        end
      end
      mapped_entries
    end
  
    def element_by_path(data, path)
      key = path.shift
    
      if key.include?('[') && (md = key.match(ARRAY_RE))
        ndata = data[md[1]]
        if ndata.is_a?(Array)
          ndata = ndata[md[2].to_i]
        end
      else
        ndata = data[key]
      end
    
      return nil if ndata.nil?
      path.blank? ? ndata : element_by_path(ndata, path)
    end
  
    # Delete everything until the start of the array, i.e. the first '['.
    # Remove the next to last character, i.e. the ')'
    def strip_callback(json)
      json[json.index('(')+1..-2]
    end
  
    def determine_value(data, destination)
      if destination[-3,3]  == '_at'
        data = DateTime.parse(data).to_time
      end
      data
    end
  
  end

end