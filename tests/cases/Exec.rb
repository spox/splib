require 'splib'
require 'test/unit'

class ExecTest < Test::Unit::TestCase
    def setup
        Splib.load :Exec
    end
    
    def test_exec
        assert_raise(IOError) do
            Splib.exec('echo test', 10, 1)
        end
        assert_raise(Timeout::Error) do
            Splib.exec('while [ true ]; do true; done;', 1)
        end
        assert_equal("test\n", Splib.exec('echo test'))
    end
end