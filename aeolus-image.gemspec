Gem::Specification.new do |s|
  s.name        = "aeolus-image"
  s.version     = "0.3.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Red Hat Inc."]
  s.email       = ["aeolus-devel@lists.fedorahosted.org"]
  s.homepage    = "https://github.com/aeolusproject/aeolus-image-rubygem"
  s.summary     = "Ruby library used by Conductor"
  s.description = "aeolus-image-rubygem is a Ruby library used by Conductor to connect with Image Factory and Image Warehouse."

  s.add_dependency "oauth"
  s.add_dependency "activeresource"
  s.add_dependency "rest-client"
  s.add_dependency "nokogiri"

  # If you need to check in files that aren't .rb files, add them here
  s.files        = Dir["{lib}/**/*.rb", "COPYING", "*.md"]
  s.require_path = 'lib'
end
