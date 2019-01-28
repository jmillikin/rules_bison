# Copyright 2018 the rules_bison authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

"""Bazel build rules for GNU Bison.

```python
load("@io_bazel_rules_m4//m4:m4.bzl", "m4_register_toolchains")
m4_register_toolchains()

load("@io_bazel_rules_bison//bison:bison.bzl", "bison_register_toolchains")
bison_register_toolchains()
```
"""

load(
    "@bazel_tools//tools/build_defs/cc:action_names.bzl",
    _ACTION_COMPILE_C = "C_COMPILE_ACTION_NAME",
    _ACTION_COMPILE_CXX = "CPP_COMPILE_ACTION_NAME",
    _ACTION_LINK_DYNAMIC = "CPP_LINK_DYNAMIC_LIBRARY_ACTION_NAME",
    _ACTION_LINK_STATIC = "CPP_LINK_STATIC_LIBRARY_ACTION_NAME",
)
load("@io_bazel_rules_m4//m4:m4.bzl", _m4_common = "m4_common")

# region Versions {{{

_LATEST = "3.3"

_VERSION_URLS = {
    "3.3": {
        "urls": ["https://ftp.gnu.org/gnu/bison/bison-3.3.tar.xz"],
        "sha256": "162ea71d21e134c44942f4ebb74685e19c942dcf40a7120eba165ba5e2553bb9",
        "copyright_year": "2019",
    },
    "3.2.2": {
        "urls": ["https://ftp.gnu.org/gnu/bison/bison-3.2.2.tar.xz"],
        "sha256": "6f950f24e4d0745c7cc870e36d04f4057133ce0f31d6b4564e6f510a7d3ffafa",
        "copyright_year": "2018",
    },
}

def _check_version(version):
    if version not in _VERSION_URLS:
        fail("GNU Bison version {} not supported by rules_bison.".format(repr(version)))

# endregion }}}

# region Toolchain {{{

_TOOLCHAIN_TYPE = "@io_bazel_rules_bison//bison:toolchain_type"

_ToolchainInfo = provider(fields = ["files", "vars", "bison_executable"])

_Internal = provider()

def _bison_toolchain_info(ctx):
    bison_runfiles = ctx.attr.bison[DefaultInfo].default_runfiles.files
    toolchain = _ToolchainInfo(
        bison_executable = ctx.executable.bison,
        files = depset([ctx.executable.bison]) + bison_runfiles,
        vars = {
            "BISON": ctx.executable.bison.path,
        },
    )
    return [
        platform_common.ToolchainInfo(bison_toolchain = toolchain),
        platform_common.TemplateVariableInfo(toolchain.vars),
    ]

bison_toolchain_info = rule(
    _bison_toolchain_info,
    attrs = {
        "bison": attr.label(
            executable = True,
            cfg = "host",
        ),
    },
)

def _bison_toolchain_alias(ctx):
    toolchain = ctx.toolchains[_TOOLCHAIN_TYPE].bison_toolchain
    return [
        DefaultInfo(files = toolchain.files),
        toolchain,
        platform_common.TemplateVariableInfo(toolchain.vars),
        _Internal(
            m4_deny_shell = ctx.executable._m4_deny_shell,
        ),
    ]

bison_toolchain_alias = rule(
    _bison_toolchain_alias,
    toolchains = [_TOOLCHAIN_TYPE],
    attrs = {
        "_m4_deny_shell": attr.label(
            executable = True,
            default = "//bison/internal:m4_deny_shell",
            cfg = "host",
        ),
    },
)

def bison_register_toolchains(version = _LATEST):
    _check_version(version)
    repo_name = "bison_v{}".format(version)
    if repo_name not in native.existing_rules().keys():
        bison_repository(
            name = repo_name,
            version = version,
        )
    native.register_toolchains("@io_bazel_rules_bison//bison/toolchains:v{}".format(version))

# endregion }}}

bison_common = struct(
    VERSIONS = list(_VERSION_URLS),
    ToolchainInfo = _ToolchainInfo,
    TOOLCHAIN_TYPE = _TOOLCHAIN_TYPE,
)

# region Build Rules {{{

_SRC_EXT = {
    "c": "c",
    "c++": "cc",
    "java": "java",
}

_COMMON_ATTR = {
    "opts": attr.string_list(
        allow_empty = True,
    ),
    "skeleton": attr.label(
        allow_single_file = True,
    ),
    "_bison_toolchain": attr.label(
        default = "//bison:toolchain",
    ),
    "_m4_toolchain": attr.label(
        default = "@io_bazel_rules_m4//m4:toolchain",
    ),
}

def _bison_common(ctx, language):
    m4_toolchain = ctx.attr._m4_toolchain[_m4_common.ToolchainInfo]
    bison_toolchain = ctx.attr._bison_toolchain[bison_common.ToolchainInfo]

    out_src_ext = _SRC_EXT[language]

    out_src = ctx.actions.declare_file("{}.{}".format(ctx.attr.name, out_src_ext))
    out_xml = ctx.actions.declare_file("{}_report.xml".format(ctx.attr.name))
    out_dot = ctx.actions.declare_file("{}_report.dot".format(ctx.attr.name))
    out_txt = ctx.actions.declare_file("{}_report.txt".format(ctx.attr.name))

    parser_files = [out_src]
    report_files = [out_xml, out_dot, out_txt]

    inputs = m4_toolchain.files + bison_toolchain.files + ctx.files.src

    args = ctx.actions.args()
    args.add_all([
        "-Wall",
        "--language=" + language,
        "--output=" + out_src.path,
        "--report=all",
        "--report-file=" + out_txt.path,
        "--graph=" + out_dot.path,
        "--xml=" + out_xml.path,
    ])

    out_hdr = None
    if language != "java":
        out_hdr = ctx.actions.declare_file("{}.h".format(ctx.attr.name))
        parser_files.append(out_hdr)
        args.add("--defines=" + out_hdr.path)

    if ctx.attr.skeleton:
        args.add("--skeleton=" + ctx.file.skeleton.path)
        inputs += ctx.files.skeleton

    args.add_all(ctx.attr.opts)
    args.add(ctx.file.src.path)

    ctx.actions.run(
        executable = bison_toolchain.bison_executable,
        arguments = [args],
        inputs = inputs,
        outputs = parser_files + report_files,
        env = {
            "M4": m4_toolchain.m4_executable.path,
        },
        mnemonic = "Bison",
        progress_message = "Generating {}".format(ctx.label),
    )
    return struct(
        source = out_src,
        header = out_hdr,
        outs = depset(parser_files),
        report_files = depset(report_files),
    )

# region rule(bison) {{{

def _bison(ctx):
    if ctx.file.src.extension == "y":
        language = "c"
    else:
        language = "c++"
    result = _bison_common(ctx, language)
    return [
        DefaultInfo(files = result.outs),
        OutputGroupInfo(bison_report = result.report_files),
    ]

def _default_language(src):
    return "c"

bison = rule(
    _bison,
    attrs = _COMMON_ATTR + {
        "src": attr.label(
            mandatory = True,
            allow_single_file = [".y", ".yy", ".y++", ".yxx", ".ypp"],
        ),
    },
)
"""Generate a Bison parser implementation from Yacc-ish source.

```python
load("@io_bazel_rules_bison//bison:bison.bzl", "bison")
bison(
    name = "hello",
    src = "hello.y",
)
cc_binary(
    name = "hello_bin",
    srcs = [":hello"],
)
```
"""

# endregion }}}

# region rule(bison_cc_library) {{{

# region C++ toolchain integration {{{

def _cc_compile(ctx, cc_toolchain, cc_features, deps, source, header, out_obj, use_pic):
    toolchain_inputs = ctx.attr._cc_toolchain[DefaultInfo].files

    if source.extension == "c":
        cc_action = _ACTION_COMPILE_C
    else:
        cc_action = _ACTION_COMPILE_CXX

    cc = cc_common.get_tool_for_action(
        feature_configuration = cc_features,
        action_name = cc_action,
    )

    cc_vars = cc_common.create_compile_variables(
        cc_toolchain = cc_toolchain,
        feature_configuration = cc_features,
        source_file = source.path,
        output_file = out_obj.path,
        use_pic = use_pic,
        include_directories = deps.compilation_context.includes,
        quote_include_directories = depset([
            ".",
            ctx.genfiles_dir.path,
            ctx.bin_dir.path,
        ]) + deps.compilation_context.quote_includes,
        system_include_directories = deps.compilation_context.system_includes,
        preprocessor_defines = deps.compilation_context.defines,
    )

    cc_argv = cc_common.get_memory_inefficient_command_line(
        feature_configuration = cc_features,
        action_name = cc_action,
        variables = cc_vars,
    )

    cc_env = cc_common.get_environment_variables(
        feature_configuration = cc_features,
        action_name = cc_action,
        variables = cc_vars,
    )

    ctx.actions.run(
        inputs = toolchain_inputs + deps.compilation_context.headers + depset([source, header]),
        outputs = [out_obj],
        executable = cc,
        arguments = cc_argv,
        mnemonic = "CppCompile",
        progress_message = "Compiling {}".format(source.short_path),
        env = cc_env,
    )

def _cc_link_static(ctx, cc_toolchain, cc_features, deps, obj, out_lib):
    toolchain_inputs = ctx.attr._cc_toolchain[DefaultInfo].files

    ar = cc_common.get_tool_for_action(
        feature_configuration = cc_features,
        action_name = _ACTION_LINK_STATIC,
    )

    ar_vars = cc_common.create_link_variables(
        cc_toolchain = cc_toolchain,
        feature_configuration = cc_features,
        output_file = out_lib.path,
        is_using_linker = False,
        is_static_linking_mode = True,
    )

    ar_argv = cc_common.get_memory_inefficient_command_line(
        feature_configuration = cc_features,
        action_name = _ACTION_LINK_STATIC,
        variables = ar_vars,
    )

    ar_env = cc_common.get_environment_variables(
        feature_configuration = cc_features,
        action_name = _ACTION_LINK_STATIC,
        variables = ar_vars,
    )

    ctx.actions.run(
        inputs = toolchain_inputs + depset([obj]),
        outputs = [out_lib],
        executable = ar,
        arguments = ar_argv + [obj.path],
        mnemonic = "CppLink",
        progress_message = "Linking {}".format(out_lib.short_path),
        env = ar_env,
    )

def _cc_link_dynamic(ctx, cc_toolchain, cc_features, deps, obj, out_lib):
    toolchain_inputs = ctx.attr._cc_toolchain[DefaultInfo].files

    ld = cc_common.get_tool_for_action(
        feature_configuration = cc_features,
        action_name = _ACTION_LINK_DYNAMIC,
    )

    ld_vars = cc_common.create_link_variables(
        cc_toolchain = cc_toolchain,
        feature_configuration = cc_features,
        output_file = out_lib.path,
        is_using_linker = True,
        is_static_linking_mode = False,
        is_linking_dynamic_library = True,
    )

    ld_argv = cc_common.get_memory_inefficient_command_line(
        feature_configuration = cc_features,
        action_name = _ACTION_LINK_DYNAMIC,
        variables = ld_vars,
    )

    ld_env = cc_common.get_environment_variables(
        feature_configuration = cc_features,
        action_name = _ACTION_LINK_DYNAMIC,
        variables = ld_vars,
    )

    ctx.actions.run(
        inputs = toolchain_inputs + depset([obj]),
        outputs = [out_lib],
        executable = ld,
        arguments = ld_argv + [obj.path],
        mnemonic = "CppLink",
        progress_message = "Linking {}".format(out_lib.short_path),
        env = ld_env,
    )

def _obj_name(ctx, src, pic):
    ext = src.extension
    base = src.basename[:-len(ext)]
    pic_ext = ""
    if pic:
        pic_ext = "pic."
    return "_objs/{}/{}{}o".format(ctx.attr.name, base, pic_ext)

def _build_cc_info(ctx, source, header):
    cc_toolchain = ctx.attr._cc_toolchain[cc_common.CcToolchainInfo]

    cc_features = cc_common.configure_features(
        cc_toolchain = cc_toolchain,
    )
    ar_features = cc_common.configure_features(
        cc_toolchain = cc_toolchain,
    )
    ld_features = cc_common.configure_features(
        cc_toolchain = cc_toolchain,
        requested_features = ["dynamic_linking_mode"],
    )

    use_pic = cc_toolchain.needs_pic_for_dynamic_libraries(
        feature_configuration = ld_features,
    )

    deps = cc_common.merge_cc_infos(cc_infos = [
        dep[CcInfo]
        for dep in ctx.attr.deps
    ])

    out_obj = ctx.actions.declare_file(_obj_name(ctx, source, use_pic))
    out_lib = ctx.actions.declare_file("lib{}.a".format(ctx.attr.name))
    out_dylib = ctx.actions.declare_file("lib{}.so".format(ctx.attr.name))

    _cc_compile(ctx, cc_toolchain, cc_features, deps, source, header, out_obj, use_pic)
    _cc_link_static(ctx, cc_toolchain, ar_features, deps, out_obj, out_lib)
    _cc_link_dynamic(ctx, cc_toolchain, ld_features, deps, out_obj, out_dylib)

    cc_compile_info = CcInfo(
        compilation_context = cc_common.create_compilation_context(
            headers = depset([header]),
        ),
    )
    cc_link_info = CcInfo(
        linking_context = cc_common.create_linking_context(
            libraries_to_link = [
                cc_common.create_library_to_link(
                    actions = ctx.actions,
                    feature_configuration = ar_features,
                    cc_toolchain = cc_toolchain,
                    static_library = None if use_pic else out_lib,
                    pic_static_library = out_lib if use_pic else None,
                ),
                cc_common.create_library_to_link(
                    actions = ctx.actions,
                    feature_configuration = ld_features,
                    cc_toolchain = cc_toolchain,
                    dynamic_library = out_dylib,
                ),
            ],
        ),
    )

    return struct(
        cc_info = cc_common.merge_cc_infos(cc_infos = [
            cc_link_info,
            cc_compile_info,
            deps,
        ]),
        outs = depset([out_lib, out_dylib]),
    )

# endregion }}}

def _bison_cc_library(ctx):
    if ctx.file.src.extension == "y":
        language = "c"
    else:
        language = "c++"
    result = _bison_common(ctx, language)
    cc = _build_cc_info(ctx, result.source, result.header)
    return [
        DefaultInfo(files = cc.outs),
        cc.cc_info,
        OutputGroupInfo(bison_report = result.report_files),
    ]

bison_cc_library = rule(
    _bison_cc_library,
    attrs = _COMMON_ATTR + {
        "src": attr.label(
            mandatory = True,
            allow_single_file = [".y", ".yy", ".y++", ".yxx", ".ypp"],
        ),
        "deps": attr.label_list(
            allow_empty = True,
            providers = [CcInfo],
        ),
        "_cc_toolchain": attr.label(
            default = "@bazel_tools//tools/cpp:current_cc_toolchain",
        ),
    },
)

# endregion }}}

# region rule(bison_java_library) {{{

def _bison_java_library(ctx):
    result = _bison_common(ctx, "java")
    out_jar = ctx.actions.declare_file("lib{}.jar".format(ctx.attr.name))
    java_info = java_common.compile(
        ctx,
        java_toolchain = ctx.attr._java_toolchain,
        host_javabase = ctx.attr._host_javabase,
        source_files = [result.source],
        output = out_jar,
        deps = ctx.attr.deps,
    )
    return [
        DefaultInfo(files = depset([out_jar])),
        java_info,
        OutputGroupInfo(bison_report = result.report_files),
    ]

bison_java_library = rule(
    _bison_java_library,
    attrs = _COMMON_ATTR + {
        "src": attr.label(
            mandatory = True,
            allow_single_file = [".y"],
        ),
        "deps": attr.label_list(
            allow_empty = True,
            providers = [JavaInfo],
        ),
        "_host_javabase": attr.label(
            default = "@bazel_tools//tools/jdk:current_host_java_runtime",
        ),
        "_java_toolchain": attr.label(
            default = "@bazel_tools//tools/jdk:toolchain",
        ),
    },
    fragments = ["java"],
)

# endregion }}}

# endregion }}}

# region Repository Rules {{{

def _bison_repository(ctx):
    version = ctx.attr.version
    _check_version(version)
    source = _VERSION_URLS[version]

    ctx.download_and_extract(
        url = source["urls"],
        sha256 = source["sha256"],
        stripPrefix = "bison-{}".format(version),
    )

    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(name = repr(ctx.name)))
    ctx.symlink(ctx.attr._overlay_BUILD, "BUILD.bazel")
    ctx.symlink(ctx.attr._overlay_bin_BUILD, "bin/BUILD.bazel")
    ctx.template("stub-config/configmake.h", ctx.attr._overlay_configmake_h, {
        "{WORKSPACE_ROOT}": "external/" + ctx.attr.name,
    })
    ctx.template("stub-config/gnulib_common_config.h", ctx.attr._common_config_h, {
        "{VERSION}": version,
        "{COPYRIGHT_YEAR}": source["copyright_year"],
    })

    ctx.symlink(ctx.attr._darwin_config_h, "gnulib-darwin/config/config.h")
    ctx.symlink(ctx.attr._linux_config_h, "gnulib-linux/config/config.h")
    ctx.symlink(ctx.attr._windows_config_h, "gnulib-windows/config/config.h")

    ctx.template("lib/error.c", "lib/error.c", substitutions = {
        # error.c depends on the gnulib libc shims to inject gnulib macros. Fix this
        # by injecting explicit include directives.
        '#include "error.h"\n': "\n".join([
            '#include "error.h"',
            '#include "arg-nonnull.h"',
        ]),
        # Hardcode getprogname() to "bison" to avoid digging into the gnulib shims.
        "#define program_name getprogname ()": '#define program_name "bison"',
    }, executable = False)

    # Force isnanl() to be defined in terms of standard isnan() macro,
    # instead of compiler-specific __builtin_isnan().
    ctx.file("lib/isnanl-nolibm.h", """
#include <math.h>
#define isnanl isnan
""")

    # Fix a mismatch between _Noreturn and __attribute_noreturn__ when
    # building with a C11-aware GCC.
    ctx.template("lib/obstack.c", "lib/obstack.c", substitutions = {
        "static _Noreturn void": "static _Noreturn __attribute_noreturn__ void",
    })

    # Ambiguous include path of timevar.def confuses Bazel's C++ header dependency
    # checker. Work around this by using non-ambiguous paths.
    ctx.template("lib/timevar.c", "lib/timevar.c", substitutions = {
        '"timevar.def"': '"lib/timevar.def"',
    })
    ctx.template("lib/timevar.h", "lib/timevar.h", substitutions = {
        '"timevar.def"': '"lib/timevar.def"',
    })

    # gnulib tries to detect the maximum file descriptor count by passing
    # an invalid value to an OS API and seeing what happens. Well, what happens
    # in debug mode is the binary is aborted.
    #
    # Per https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/setmaxstdio
    # the maximum limit of this value is 2048. Lets hope that's good enough.
    ctx.template("lib/getdtablesize.c", "lib/getdtablesize.c", substitutions = {
        "for (bound = 0x10000;": "for (bound = 2048;",
    })

bison_repository = repository_rule(
    _bison_repository,
    attrs = {
        "version": attr.string(mandatory = True),
        "_overlay_BUILD": attr.label(
            default = "//bison/internal:overlay/bison.BUILD",
            single_file = True,
        ),
        "_overlay_bin_BUILD": attr.label(
            default = "//bison/internal:overlay/bison_bin.BUILD",
            single_file = True,
        ),
        "_overlay_configmake_h": attr.label(
            default = "//bison/internal:overlay/configmake.h",
            single_file = True,
        ),
        "_common_config_h": attr.label(
            default = "//bison/internal:overlay/gnulib_common_config.h",
            single_file = True,
        ),
        "_darwin_config_h": attr.label(
            default = "//bison/internal:overlay/gnulib-darwin/config.h",
            single_file = True,
        ),
        "_linux_config_h": attr.label(
            default = "//bison/internal:overlay/gnulib-linux/config.h",
            single_file = True,
        ),
        "_windows_config_h": attr.label(
            default = "//bison/internal:overlay/gnulib-windows/config.h",
            single_file = True,
        ),
    },
)

# endregion }}}
