%if 0%{?fedora} >= 25
%bcond_without doc
%else
%bcond_with doc
%endif
%{!?_pkgdocdir: %global _pkgdocdir %{_docdir}/%{name}-%{version}}

Name: tarantool-gis
Version: 0.1.0
Release: 1%{?dist}
Summary: Full-featured geospatial extension for Tarantool Database
Group: Applications/Databases
License: BSD
URL: https://github.com/tarantool/%{name}
Source0: https://github.com/tarantool/%{name}/archive/%{version}/%{name}-%{version}.tar.gz
BuildRequires: cmake >= 2.8
BuildRequires: gcc >= 4.5
BuildRequires: tarantool-devel >= 1.6.8.0
BuildRequires: geos-devel >= 3.4.0
BuildRequires: proj-devel >= 4.8.0
%if %{with doc}
BuildRequires: python-sphinx >= 1.2
%endif
Requires: tarantool >= 1.6.8.0

%description
Tarantool/GIS is a full-featured geospatial extension for Tarantool Database
It's like PostGIS, but for Tarantool.

%if %{with doc}
%package doc
Summary: Documentation files for %{name}
Group: Applications/Databases
Requires: %{name}%{?_isa} = %{version}-%{release}

%description doc
Tarantool/GIS is a full-featured geospatial extension for Tarantool Database
It's like PostGIS, but for Tarantool.

This package provides html documentation.
%endif

%prep
%setup -q -n %{name}-%{version}

%build
%cmake . -DCMAKE_BUILD_TYPE=RelWithDebInfo
make %{?_smp_mflags}
%if %{with doc}
make doc-html
%endif

%check
make %{?_smp_mflags} test

%install
%make_install
install -d %{buildroot}%{_pkgdocdir}
cp -pR examples/ %{buildroot}%{_pkgdocdir}
ls -l %{buildroot}%{_pkgdocdir}
ls -l %{buildroot}%{_pkgdocdir}/examples
%if %{with doc}
cp -pR doc/html %{buildroot}%{_pkgdocdir}
%endif

%files
%{_libdir}/tarantool/*/
%{_datarootdir}/tarantool/*/
%doc README.md
%{!?_licensedir:%global license %doc}
%license COPYING
%{_pkgdocdir}/examples/*

%if %{with doc}
%files doc
%{_pkgdocdir}/html/*
%{_pkgdocdir}/html/.buildinfo
%endif

%changelog
* Sat Jul 2 2016 Roman Tsisyk <roman@tsisyk.com> 0.1.0-1
- Initial version of the RPM spec
