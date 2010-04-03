$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'splib'

class SleepTest < Test::Unit::TestCase
    def setup
        Splib.load :Sleep
    end
    
    def test_sleep_valid
        assert(Kernel.sleep(0.5).between?(0.45, 0.55))
        assert(Kernel.sleep(0.05).between?(0.04, 0.06))
    end

    def test_sleep_invalid
        assert_raise(TypeError) do
            Kernel.sleep(:foo)
        end
        assert_raise(ArgumentError) do
            Kernel.sleep(-1)
        end
    end
end
