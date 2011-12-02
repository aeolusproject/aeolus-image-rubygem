%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname aeolus-image
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}
%global rubyabi 1.8

Summary: Ruby Client for interacting with Image Warehouse and Image Factory
Name: rubygem-aeolus-image
Version: 0.3.0
Release: 0%{?extra_release}%{?dist}
Group: Development/Languages
License: ASL 2.0
URL: http://aeolusproject.org

Source0: %{gemname}-%{version}.gem

Requires: ruby(abi) = %{rubyabi}
Requires: rubygems
Requires: rubygem(nokogiri) >= 1.4.0
Requires: rubygem(rest-client)
Requires: rubygem(imagefactory-console) >= 0.4.0
Requires: rubygem(oauth)
Requires: rubygem(vcr)
Requires: rubygem(webmock)
Requires: rubygem(timecop)

BuildRequires: ruby
BuildRequires: rubygems

BuildArch: noarch
Provides: rubygem(%{gemname}) = %{version}

%description
Ruby Client for Image Warehouse and Image Factory

%prep
%setup -q -c -T
mkdir -p ./%{gemdir}
gem install --local --install-dir ./%{gemdir} --force --rdoc %{SOURCE0}

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{gemdir}
cp -a .%{gemdir}/* %{buildroot}%{gemdir}/

rm -rf %{buildroot}%{gemdir}/gems/%{gemname}-%{version}/.yardoc

%files
%doc %{geminstdir}/COPYING
%doc %{gemdir}/doc/%{gemname}-%{version}
%dir %{geminstdir}
%{geminstdir}/Rakefile
%{geminstdir}/lib
%{geminstdir}/spec
%{gemdir}/cache/%{gemname}-%{version}.gem
%{gemdir}/specifications/%{gemname}-%{version}.gemspec

%changelog
* Thu Dec  1 2011 Steve Linabery <slinaber@redhat.com> - 0.2.0-1
- d451628 Fixed creation of a bucket when saving a bucket object
- 289dcbf Added builder helper methods
- 4f708c8 Added couple of helper methods to image model
- 6ae089c Added convenience methods for checking providerimages on image/build
- 90154e0 Updated models to use iwhd query syntax
- 1cba777 Fixed comparing of two warehouse objects
- 2e2d735 Commented out couple of tests
- 4b6408d Updated fetching of template for an image
- 424c117 Added create method and enabled access to body
- dd829cd BZ#752494 Handle 404 for status in rubygem
- 5d4cdc0 Add tests for aeolus-image-rubygem
- 0706f29 Fixed request_without_oauth method
- a121b34 Fixed template body initialize
- 105420b Updated warehouse models initialize method and fixed image body
- cd55966 adding icicle support
- 3aa588a Fixes formatting of README.md
- 0cf1a58 Adds README file

* Tue Nov 29 2011 Steve Linabery <slinaber@redhat.com> - 0.2.0-0
- Bump release, set version to 0

* Mon Oct 17 2011 Matt Wagner <matt.wagner@redhat.com> - 0.0.1-4
- Adds OAuth support for Factory client
- Add vcr and webmock dependencies

* Tue Sep 20 2011 Martyn Taylor  <mtaylor@redhat.com>  - 0.0.1-3
- split out command line tools

* Wed Jul 20 2011 Mo Morsi <mmorsi@redhat.com>  - 0.0.1-3
- more updates to conform to fedora guidelines

* Fri Jul 15 2011 Mo Morsi <mmorsi@redhat.com>  - 0.0.1-2
- updated package to conform to fedora guidelines

* Mon Jul 04 2011  <mtaylor@redhat.com>  - 0.0.1-1
- Added man files

* Wed Jun 15 2011  <jguiditt@redhat.com> - 0.0.1-1
- Initial package
