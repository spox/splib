module Splib
    # While not a big fan of monkeypatching, I want to be
    # lazy getting to this
    class ::Float
        def within_delta?(args={})
            raise ArgumentError.new('Missing required argument: :expected') unless args[:expected]
            raise ArgumentError.new('Missing required argument: :delta') unless args[:delta]
            e = args[:expected].to_f
            d = args[:delta].to_f
            mult = 0
            if(pos = d.to_s.index('.'))
                mult = (d.to_s.length - (pos + 1))
            end
            mult = 10 ** mult
            ((e*mult) - (self*mult)).abs <= (d*mult)
        end
    end
end