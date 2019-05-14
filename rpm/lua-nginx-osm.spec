%define lua_version 5.1
%define lua_lib_dir /share/lua/%{lua_version}

Name:      lua-nginx-osm
Version:   0.50
Release:   0
Summary:   Lua Tirex/renderd client drivers for the ngx_lua based on the cosocket API.
URL:       https://github.com/tierpod/lua-nginx-osm
License:   GPLv3

Source:    https://github.com/tierpod/lua-nginx-osm/archive/%{version}.tar.gz
BuildArch: noarch
Requires:  lua >= %{lua_version}
Requires:  nginx
Requires:  nginx-module-lua

%description
Lua Tirex/renderd/http client drivers for the ngx_lua based on the cosocket API.

%prep
%setup -q

%build

%install
#make LUA_LIB_DIR=%{buildroot}/usr/share/lua/%{lua_ver} install
make DESTDIR=%{buildroot}%{_prefix} LUA_LIB_DIR=%{lua_lib_dir} install

%clean
rm -rf %{buildroot}

%post

%files
%defattr(644,root,root,755)
%{_prefix}%{lua_lib_dir}/osm

%changelog
* Mon May 13 2019 Pavel Podkorytov <pod.pavel@gmail.com> 0.50.0
- Initial version

