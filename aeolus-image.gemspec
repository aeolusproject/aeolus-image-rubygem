Gem::Specification.new do |s|
  s.name         = "aeolus-image"
  s.version      = "0.6.0"
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Jason Guiditta, Martyn Taylor"]
  s.email        = ["jguiditt@redhat.com, mtaylor@redhat.com"]
  s.license      = "ASL 2.0"
  s.homepage     = "https://github.com/aeolusproject/aeolus-image-rubygem"
  s.summary      = "Ruby Client for Image Warehouse and Image Factory for the Aeolus cloud suite"
  s.description  = "aeolus-image is a Ruby library used by Conductor to connect with Image Factory and Image Warehouse."

  s.files        = Dir["lib/**/*.rb","README.md","COPYING","Rakefile","rake/rpmtask.rb"]
  s.test_files   = Dir["spec/**/*.*",".rspec","examples/aeolus-cli"]
  s.require_path = 'lib'
  s.add_dependency "activeresource"
  s.add_dependency "nokogiri"
  s.add_dependency "oauth", "0.4.4"
  s.add_dependency "rest-client"

  s.add_development_dependency('rspec', '>=1.3.0')
  s.add_development_dependency('rake')
  s.add_development_dependency('vcr', '~> 1.11')
  s.add_development_dependency('webmock')
  s.add_development_dependency('timecop')
end
