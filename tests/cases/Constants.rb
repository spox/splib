require 'splib'
require 'test/unit'

module Foo
    module Bar
        class Fubar
        end
    end
end

class ConstantsTest < Test::Unit::TestCase
    def setup
        Splib.load :Constants
    end
    def test_find_const
        mod = Module.new
        mod.class_eval("
            module Fu
                class Bar
                end
            end"
        )
        assert_equal(String, Splib.find_const('String'))
        assert_equal(Foo::Bar::Fubar, Splib.find_const('Foo::Bar::Fubar'))
        assert_match(/<.+?>::Fu::Bar/, Splib.find_const('Fu::Bar', [mod]).to_s)
    end
end