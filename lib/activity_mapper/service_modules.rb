
Dir.open(File.join(File.dirname(__FILE__), 'service_modules')).each do |file|
  require File.join(File.dirname(__FILE__), 'service_modules', file) if File.extname(file) == '.rb'
end
