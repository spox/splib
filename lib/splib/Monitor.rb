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
                timeout = timeout.to_f
                @timers[Thread.current] = Thread.new(Thread.current) do |t|
                    time = 0.0
                    until(time >= timeout) do
                        s = Time.now.to_f
                        sleep(timeout - time)
                        time += Time.now.to_f - s
                    end
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
            do_lock
            t = @threads.shift
            t.wakeup if t && t.alive?
            do_unlock
        end
        # Wake up all threads
        def broadcast
            do_lock
            @threads.each do |t|
                t.wakeup if t.alive?
            end
            @threads.clear
            do_unlock
        end
        # Number of threads waiting
        def waiters
            @threads.size
        end
        # Lock the monitor
        def lock
            if(Thread.exclusive{do_lock})
                until(owner?(Thread.current)) do
                    Thread.stop
                end
            end
        end
        # Unlock the monitor
        def unlock
            Thread.exclusive{ do_unlock }
        end
        # Attempt to lock. Returns true if lock is aquired and false if not.
        def try_lock
            locked = false
            Thread.exclusive do
                unless(locked?)
                    do_lock
                    locked = true
                else
                    locked = owner?(Thread.current)
                end
            end
            locked
        end
        # Is monitor locked
        def locked?
            clean
            @locks.size > 0 || @lock_owner
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

        # This is a simple helper method to help keep threads from ending
        # up stuck waiting for a lock when a thread locks the monitor and
        # then decides to die without unlocking. It is only called when
        # new locks are attempted or a check is made if the monitor is
        # currently locked.
        def clean
            @locks.delete_if{|t|!t.alive?}
            if(@lock_owner && !@lock_owner.alive?)
                @lock_owner = @locks.empty? ? nil : @locks.shift
                @lock_owner.wakeup if @lock_owner
            end
        end

        def owner?(t)
            @lock_owner == t
        end

        def do_lock
            clean
            stop = false
            if(@lock_owner)
                @locks << Thread.current
                stop = true
            else
                @lock_owner = Thread.current
            end
            stop
        end

        def do_unlock
            unless(owner?(Thread.current))
                raise ThreadError.new("Thread #{Thread.current} is not the current owner: #{@lock_owner}")
            end
            @locks.delete_if{|t|!t.alive?}
            unless(@locks.empty?)
                @lock_owner = @locks.shift
                @lock_owner.wakeup
            else
                @lock_owner = nil
            end
        end
    end
end