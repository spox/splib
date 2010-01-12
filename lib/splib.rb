module Splib
    LIBS = [:Array,
            :CodeReloader,
            :Constants,
            :Conversions,
            :Exec,
            :HumanIdealRandomIterator,
            :Monitor,
            :PriorityQueue,
            :UrlShorteners
           ]
    # args:: name of library to load
    # Loads the given library. Currently available:
    # :CodeReloader
    # :Constants
    # :Conversions
    # :Exec
    # :HumanIdealRandomIterator
    # :PriorityQueue
    # :UrlShorteners
    # :all
    def self.load(*args)
        if(args.include?(:all))
            LIBS.each do |lib|
                require "splib/#{lib}"
            end
        else
            args.each do |lib|
                raise NameError.new("Unknown library name: #{lib}") unless LIBS.include?(lib)
                require "splib/#{lib}"
            end
        end
    end
end