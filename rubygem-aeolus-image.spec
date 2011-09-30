%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname aeolus-image
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}
%global rubyabi 1.8

Summary: Ruby Client for interacting with Image Warehouse and Image Factory
Name: rubygem-aeolus-image
Version: 0.1.0
Release: 3%{?extra_release}%{?dist}
Group: Development/Languages
License: ASL 2.0
URL: http://aeolusproject.org

# The source for this packages was pulled from the upstream's git repo.
# Use the following commands to generate the gem
# git clone  git://git.fedorahosted.org/aeolus/conductor.git
# git checkout next
# cd services/image_factory/aeolus-image
# rake gem
# grab image_factory_console-0.0.1.gem from the pkg subdir
Source0: %{gemname}-%{version}.gem

Requires: ruby(abi) = %{rubyabi}
Requires: rubygems
Requires: rubygem(nokogiri) >= 1.4.0
Requires: rubygem(rest-client)
Requires: rubygem(imagefactory-console) >= 0.4.0

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
%dir %{geminstdir}
%{geminstdir}/Rakefile
%{geminstdir}/lib
%{geminstdir}/spec
%{gemdir}/cache/%{gemname}-%{version}.gem
%{gemdir}/specifications/%{gemname}-%{version}.gemspec

%changelog
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
