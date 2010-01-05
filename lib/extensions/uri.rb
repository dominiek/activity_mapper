
module URI

  class Generic
    
    # Get a friendly name for media_entity.
    # www.flickr.com => flickr
    # flickr.com => flickr
    # iknow.co.jp => iknow
    # www.iknow.co.jp => iknow
    # monkey.iknow.co.jp => iknow
    # news.bbc.co.uk => bbc
    def domain_key
      name = nil
      host = @host
      if host
        host = host.split('.')
        if (host[host.size-2].to_s+host[host.size-1].to_s).size > 4
          offset = (host.size - 2)
        else
          offset = (host.size - 3)
        end
        name = (offset < 0) ? host.first : host[offset]
      end
      name ? name.underscore : nil
    end
    
    def self.domain_for(url)
      uri = URI.parse(url)
      uri.host
    rescue => e
      m = url.match(/http:\/\/([^\/]+)/)
      m ? m[1] : nil
    end
    
    def self.friendly_domain_for(url)
      domain_for(url).to_s.gsub(/^www\./, '')
    end
  
  end
  
end
