require 'thread'

module Splib
    
    class Monitor
        def initialize
            @threads = []
            @locks = []
            @lock_owner = nil
        end
        # timeout:: Wait for given amount of time
        # Park a thread here
        def wait(timeout=nil)
            @threads << Thread.current
            Thread.stop
            true
        end
        # Park thread while block is true
        def wait_while
            while yield
                wait
            end
        end
        # Park thread until block is true
        def wait_until
            until yield
                wait
            end
        end
        # Wake up earliest thread
        def signal
            lock
            t = @threads.shift
            t.wakeup if t.alive?
            unlock
        end
        # Wake up all threads
        def broadcast
            lock
            @threads.each do |t|
                t.wakeup if t.alive?
            end
            @threads.clear
            unlock
        end
        # Number of threads waiting
        def waiters
            @threads.size
        end
        # Lock the monitor
        def lock
            stop = false
            Thread.exclusive do
                unless(@locks.empty?)
                    @locks << Thread.current
                    stop = true
                else
                    @lock_owner = Thread.current
                end
            end
            Thread.stop if stop
        end
        # Unlock the monitor
        def unlock
            unless(@lock_owner == Thread.current)
                raise ThreadError.new("Not owner attepmting to unlock monitor")
            else
                Thread.exclusive do
                    unless(@locks.empty?)
                        @locks.delete{|t|!t.alive?}
                        @lock_owner = @locks.shift
                        @lock_owner.wakeup
                    else
                        @lock_owner = nil
                    end
                end
            end 
        end
        # Lock the monitor, execute block and unlock the monitor
        def synchronize
            lock
            yield
            unlock
        end
    end
end