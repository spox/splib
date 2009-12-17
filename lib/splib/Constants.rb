module Splib
    # c:: constant name (String)
    # things:: Array of Object/Module constants to look in
    # Finds a constant if it exists
    # Example:: Foo::Bar 
    def self.find_const(c, things=[])
        raise ArgumentError.new('Exepcting an array') unless things.is_a?(Array)
        const = nil
        (things + [Object]).each do |base|
            begin
                c.split('::').each do |part|
                    const = const.nil? ? base.const_get(part) : const.const_get(part)
                end
            rescue NameError
                const = nil
            end
            break unless const.nil?
        end
        const.nil? ? c : const
    end
end