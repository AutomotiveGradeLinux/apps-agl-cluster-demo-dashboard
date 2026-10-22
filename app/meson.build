# SPDX-License-Identifier: Apache-2.0

cpp = meson.get_compiler('cpp')
qt_dep = dependency('qt6', modules: ['Core', 'Qml', 'Quick', 'Gui'])
dep_wayland_client = dependency('wayland-client', version: '>= 1.20.0')
dep_qtappfw = [
    dependency('qtappfw-vehicle-signals'),
]
dep_glib = [
    dependency('glib-2.0'),
]

qt_defines = []
qpa_header_path = join_paths(qt_dep.version(), 'QtGui')
qpa_header = join_paths(qpa_header_path, 'qpa/qplatformnativeinterface.h')
# we pass this QT_QPA_HEADER straight in the code as there's no easy
# way to pass the correct header
if cpp.has_header(qpa_header, dependencies : qt_dep)
  qt_defines += [ '-DQT_QPA_HEADER=<@0@>'.format(qpa_header) ]
  message('Found QtGui QPA header in ' + qpa_header_path)
endif

dep_scanner = dependency('wayland-scanner')
prog_scanner = find_program('wayland-scanner')
agl_compositor_version = '0.0.24'
agl_compositor_dep = dependency('agl-compositor-' + agl_compositor_version + '-protocols')
dir_agl_compositor_base = agl_compositor_dep.get_variable(pkgconfig: 'pkgdatadir')


dashboard_dep = [
    qt_dep,
    dep_wayland_client,
    dep_qtappfw,
    dep_glib,
]

dashboard_resources = [
  'cluster-dashboard.qrc',
  'images/images.qrc',
  'widgets/widgets.qrc',
]

resource_files = qt.compile_resources(sources: dashboard_resources)

protocols = [
        [ 'agl-shell', 'agl-compositor' ],
]

foreach proto: protocols
        proto_name = proto[0]
        if proto[1] == 'agl-compositor'
                base_file = proto_name
                xml_path = join_paths(dir_agl_compositor_base, '@0@.xml'.format(base_file))
        endif

        foreach output_type: [ 'client-header', 'server-header', 'private-code' ]
                if output_type == 'client-header'
                        output_file = '@0@-client-protocol.h'.format(base_file)
                elif output_type == 'server-header'
                        output_file = '@0@-server-protocol.h'.format(base_file)
                else
                        output_file = '@0@-protocol.c'.format(base_file)
                        if dep_scanner.version().version_compare('< 1.14.91')
                                output_type = 'code'
                        endif
                endif

                var_name = output_file.underscorify()
                target = custom_target(
                        '@0@ @1@'.format(base_file, output_type),
                        command: [ prog_scanner, output_type, '@INPUT@', '@OUTPUT@' ],
                        input: xml_path,
                        output: output_file,
                )
                message('protocol name is ' + var_name)
                set_variable(var_name, target)
        endforeach
endforeach

moc_files = []

dashboard_src = [
  'main.cpp',
  agl_shell_client_protocol_h,
  agl_shell_protocol_c,
]

executable('cluster-dashboard', dashboard_src, resource_files, moc_files,
            cpp_args: qt_defines,
            dependencies : dashboard_dep,
            install: true)
