require 'splib'
require 'test/unit'

class PriorityQueueTest < Test::Unit::TestCase
    def setup
        Splib.load :PriorityQueue
    end

    def test_direct
        queue = Splib::PriorityQueue.new
        queue.direct_queue(1)
        assert_equal(1, queue.pop)
        queue.direct_queue(2)
        queue.direct_queue(3)
        assert_equal(2, queue.pop)
        assert_equal(3, queue.pop)
        assert(queue.empty?)
    end

    def test_prioritizer
        queue = Splib::PriorityQueue.new
        5.times{queue.push('slot1', 'test')}
        5.times{queue.push('slot2', 'fubar')}
        queue.direct_queue('first')
        assert_equal('first', queue.pop)
        5.times do
            assert_equal('test', queue.pop)
            assert_equal('fubar', queue.pop)
        end
        assert(queue.empty?)
    end

    def test_whocares
        queue = Splib::PriorityQueue.new{|s| s == :last }
        queue.push(:last, 'last')
        2.times{ queue.push(:slot1, 'test') }
        2.times{ queue.push(:slot2, 'fubar') }
        2.times do
            assert_equal('test', queue.pop)
            assert_equal('fubar', queue.pop)
        end
        assert_equal('last', queue.pop)
        assert(queue.empty?)
    end
end