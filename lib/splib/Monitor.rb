require 'thread'

module Splib
    
    class Monitor
        def initialize
            @threads = []
            @locks = []
            @lock_owner = nil
            @timers = {}
        end
        # timeout:: Wait for given amount of time
        # Park a thread here
        def wait(timeout=nil)
            if(timeout)
                @timers[Thread.current] = Thread.new(Thread.current) do |t|
                    sleep(timeout)
                    t.wakeup
                end
            end
            @threads << Thread.current
            Thread.stop
            @threads.delete(Thread.current)
            if(timeout)
                if(@timers[Thread.current].alive?)
                    @timers[Thread.current].kill
                end
                @timers.delete(Thread.current)
            end
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
            synchronize do
                t = @threads.shift
                t.wakeup if t.alive?
            end
        end
        # Wake up all threads
        def broadcast
            synchronize do
                @threads.each do |t|
                    t.wakeup if t.alive?
                end
                @threads.clear
            end
        end
        # Number of threads waiting
        def waiters
            @threads.size
        end
        # Lock the monitor
        def lock
            Thread.stop if Thread.exclusive{ do_lock }
        end
        # Unlock the monitor
        def unlock
            Thread.exclusive{ do_unlock }
        end
        # Lock the monitor, execute block and unlock the monitor
        def synchronize
            result = nil
            Thread.exclusive do
                do_lock
                result = yield
                do_unlock
            end
            result
        end

        private

        def do_lock
            stop = false
            unless(@locks.empty?)
                @locks << Thread.current
                stop = true
            else
                @lock_owner = Thread.current
            end
            stop
        end

        def do_unlock
            unless(@lock_owner == Thread.current)
                raise ThreadError.new("Thread #{Thread.current} is not the current owner: #{@lock_owner}")
            end
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