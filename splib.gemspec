spec = Gem::Specification.new do |s|
    s.name              = 'splib'
    s.author            = 'spox'
    s.email             = 'spox@modspox.com'
    s.version           = '1.4.3'
    s.summary           = 'Spox Library'
    s.platform          = Gem::Platform::RUBY
    s.files             = %w(LICENSE README.rdoc CHANGELOG Rakefile) + Dir.glob("{bin,lib,spec,test}/**/*")
    s.rdoc_options      = %w(--title splib --main README.rdoc --line-numbers)
    s.extra_rdoc_files  = %w(README.rdoc CHANGELOG)
    s.require_paths     = %w(lib)
    s.required_ruby_version = '>= 1.8.6'
    s.homepage          = %q(http://github.com/spox/splib)
    s.description         = "The spox library contains various useful tools to help you in your day to day life. Like a trusty pocket knife, only more computery."
end
