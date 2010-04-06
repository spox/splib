module Splib
class << self
    # secs:: Number of seconds to sleep (Use float to provide msec sleep)
    # Modified sleep method to use select() to provide msec level
    # sleep times
    def sleep(secs=nil)
        unless(secs.nil?)
            begin
                secs = secs.to_f
            rescue NoMethodError
                raise TypeError.new("can't convert #{secs.class} into time interval")
            end
        end
        start = Time.now.to_f
        select(nil, nil, nil, secs)
        Time.now.to_f - start
    end
end
end
