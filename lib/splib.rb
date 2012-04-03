module Splib
  LIBS = Dir.glob(
    File.join(
      File.dirname(__FILE__), 'splib', '*.rb'
    )
  ).map{|item|
    File.basename(item).sub('.rb', '').to_sym
  }
  # args:: name of library to load
  # Loads the given library. Currently available:
  # :code_reloader
  # :constants
  # :conversions
  # :exec
  # :human_ideal_random_iterator
  # :priority_queue
  # :url_shorteners
  # :all
  def self.load(*args)
    if(args.include?(:all))
      LIBS.each do |lib|
        require "splib/#{lib}"
      end
    else
      args.each do |lib|
        raise NameError.new("Unknown library name: #{lib}") unless LIBS.include?(lib.to_sym)
        require "splib/#{lib}"
      end
    end
  end
end
