$LOAD_PATH.unshift(File.expand_path("#{__FILE__}/../../lib"))

require 'test/unit'
require 'splib'

Dir.glob(File.join(File.dirname(__FILE__), 'cases', '**', '*.rb')).each do |file|
  require File.expand_path(file)
end

