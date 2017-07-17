package = 'gis'
version = 'scm-1'

source  = {
    url    = 'git://github.com/tarantool/gis.git';
    branch = 'master';
}

description = {
    summary  = "GIS module for tarantool";
    detailed = [[
    GIS module for tarantool
    ]];
    homepage = 'https://github.com/tarantool/gis.git';
    license  = 'BSD';
    maintainer = "Roman Tsisyk <roman@tarantool.org>";
}

dependencies = {
    'lua >= 5.1';
}

build = {
    type = 'cmake';
    variables = {
        CMAKE_BUILD_TYPE="RelWithDebInfo";
        TARANTOOL_INSTALL_LIBDIR="$(LIBDIR)";
        TARANTOOL_INSTALL_LUADIR="$(LUADIR)";
    };
}
-- vim: syntax=lua ts=4 sts=4 sw=4 et
