module Kernel
class << self
    # secs:: Number of seconds to sleep (Use float to provide msec sleep)
    # Modified sleep method to use select() to provide msec level
    # sleep times
    def sleep(secs)
        start = Time.now.to_f
        unless(secs.nil?)
            begin
                secs = secs.to_f
            rescue NoMethodError
                raise TypeError.new("can't convert #{secs.class} into time interval")
            end
        end
        start = Time.now.to_f
        raise 'Failed to sleep' if select(nil, nil, nil, secs) == -1
        Time.now.to_f - start
    end
end
end
