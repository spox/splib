require 'splib'
require 'test/unit'

class MonitorTest < Test::Unit::TestCase
    def setup
        Splib.load :Monitor
        @monitor = Splib::Monitor.new
    end

    def test_wait
        t = []
        5.times{ t << Thread.new{ @monitor.wait } }
        sleep(0.01) # give threads a chance to wait
        t.each do |thread|
            assert(thread.alive?)
            assert(thread.stop?)
        end
    end

    def test_wait_timeout
        t = []
        o = []
        5.times{|i| t << Thread.new{ @monitor.wait((i+1)/100.0); o << 1 } }
        sleep(0.01)
        Thread.pass
        assert(!t.shift.alive?)
        assert_equal(1, o.size)
        sleep(0.1)
        assert_equal(5, o.size)
        t.each do |th|
            assert(!th.alive?)
        end
    end

    def test_signal
        output = []
        t = []
        5.times{ t << Thread.new{ @monitor.wait; output << 1 } }
        sleep(0.01)
        t.each do |thread|
            assert(thread.alive?)
            assert(thread.stop?)
        end
        assert(output.empty?)
        @monitor.signal
        sleep(0.01)
        assert_equal(4, t.select{|th|th.alive?}.size)
        assert_equal(1, output.size)
        assert_equal(1, output.pop)
    end

    def test_broadcast
        output = []
        t = []
        5.times{ t << Thread.new{ @monitor.wait; output << 1 } }
        sleep(0.01)
        t.each do |thread|
            assert(thread.alive?)
            assert(thread.stop?)
        end
        assert(output.empty?)
        @monitor.broadcast
        sleep(0.01)
        assert_equal(5, output.size)
        5.times{ assert_equal(1, output.pop) }
        assert_equal(5, t.select{|th|!th.alive?}.size)
    end

    def test_wait_while
        stop = true
        t = Thread.new{ @monitor.wait_while{ stop } }
        sleep(0.01)
        assert(t.alive?)
        assert(t.stop?)
        @monitor.signal
        sleep(0.01)
        assert(t.alive?)
        assert(t.stop?)
        @monitor.broadcast
        sleep(0.01)
        assert(t.alive?)
        assert(t.stop?)
        stop = false
        @monitor.signal
        sleep(0.01)
        assert(!t.alive?)
        assert(t.stop?)
    end

    def test_wait_until
        stop = false
        t = Thread.new{ @monitor.wait_until{ stop } }
        sleep(0.01)
        assert(t.alive?)
        assert(t.stop?)
        @monitor.signal
        sleep(0.01)
        assert(t.alive?)
        assert(t.stop?)
        @monitor.broadcast
        sleep(0.01)
        assert(t.alive?)
        assert(t.stop?)
        stop = true
        @monitor.signal
        sleep(0.01)
        assert(!t.alive?)
        assert(t.stop?)
    end

    def test_waiters
        t = []
        (rand(20)+1).times{ t << Thread.new{ @monitor.wait } }
        sleep(0.01)
        assert_equal(t.size, @monitor.waiters)
        @monitor.broadcast
        sleep(0.01)
        assert_equal(0, @monitor.waiters)
    end

    def test_lock_unlock
        t = []
        output = []
        5.times{|i| t << Thread.new{ @monitor.lock; sleep((i+1)/100.0); output << i; @monitor.unlock;}}
        sleep(0.051)
        assert_equal(5, t.size)
        assert(!t.any?{|th|th.alive?})
        5.times{|i|assert_equal(i, output.shift)}
    end

    def synchronize
        t = []
        output = []
        5.times{|i| t << Thread.new{ @monitor.lock; sleep(i/100.0); output << i; @monitor.unlock;}}
        @monitor.synchronize{ output << :done }
        sleep(0.5)
        assert_equal(6, output.size)
    end

end