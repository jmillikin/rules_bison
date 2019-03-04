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

load(
    "@bazel_tools//tools/build_defs/cc:action_names.bzl",
    _ACTION_COMPILE_C = "C_COMPILE_ACTION_NAME",
    _ACTION_COMPILE_CXX = "CPP_COMPILE_ACTION_NAME",
    _ACTION_LINK_DYNAMIC = "CPP_LINK_DYNAMIC_LIBRARY_ACTION_NAME",
    _ACTION_LINK_STATIC = "CPP_LINK_STATIC_LIBRARY_ACTION_NAME",
)

def cc_library(ctx, source, header):
    cc_toolchain = ctx.attr._cc_toolchain[cc_common.CcToolchainInfo]

    cc_features = cc_common.configure_features(
        cc_toolchain = cc_toolchain,
        requested_features = ["supports_pic"],
    )
    ar_features = cc_common.configure_features(
        cc_toolchain = cc_toolchain,
        requested_features = ["static_linking_mode"],
    )
    ld_features = cc_common.configure_features(
        cc_toolchain = cc_toolchain,
        requested_features = ["dynamic_linking_mode"],
    )

    outputs = _declare_outputs(ctx, cc_toolchain, cc_features, source)

    use_pic = cc_toolchain.needs_pic_for_dynamic_libraries(
        feature_configuration = ld_features,
    )

    deps = cc_common.merge_cc_infos(cc_infos = [
        dep[CcInfo]
        for dep in ctx.attr.deps
    ])

    _cc_compile(ctx, cc_toolchain, cc_features, deps, source, header, outputs.obj, use_pic = False)
    _cc_link_static(ctx, cc_toolchain, ar_features, deps, outputs.obj, outputs.lib)

    if outputs.pic_obj:
        _cc_compile(ctx, cc_toolchain, cc_features, deps, source, header, outputs.pic_obj, use_pic = True)
    if outputs.pic_lib:
        _cc_link_static(ctx, cc_toolchain, ar_features, deps, outputs.pic_obj, outputs.pic_lib)

    _cc_link_dynamic(ctx, cc_toolchain, ld_features, deps, outputs)

    cc_info = CcInfo(
        compilation_context = cc_common.create_compilation_context(
            headers = depset(direct = [header]),
        ),
        linking_context = cc_common.create_linking_context(
            libraries_to_link = [
                cc_common.create_library_to_link(
                    actions = ctx.actions,
                    feature_configuration = ld_features,
                    cc_toolchain = cc_toolchain,
                    dynamic_library = outputs.dylib,
                    interface_library = outputs.iflib,
                ),
                cc_common.create_library_to_link(
                    actions = ctx.actions,
                    feature_configuration = ar_features,
                    cc_toolchain = cc_toolchain,
                    static_library = outputs.lib,
                    pic_static_library = outputs.pic_lib,
                ),
            ],
        ),
    )

    return struct(
        cc_info = cc_common.merge_cc_infos(cc_infos = [
            cc_info,
            deps,
        ]),
        outs = depset(direct = [outputs.lib, outputs.dylib]),
    )

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
        quote_include_directories = depset(
            direct = [
                ".",
                ctx.genfiles_dir.path,
                ctx.bin_dir.path,
            ],
            transitive = [
                deps.compilation_context.quote_includes,
            ],
        ),
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
        inputs = depset(
            direct = [source, header],
            transitive = [
                toolchain_inputs,
                deps.compilation_context.headers,
            ],
        ),
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
        inputs = depset(
            direct = [obj],
            transitive = [toolchain_inputs],
        ),
        outputs = [out_lib],
        executable = ar,
        arguments = ar_argv + [obj.path],
        mnemonic = "CppLink",
        progress_message = "Linking {}".format(out_lib.short_path),
        env = ar_env,
    )

def _cc_link_dynamic(ctx, cc_toolchain, cc_features, deps, outputs):
    toolchain_inputs = ctx.attr._cc_toolchain[DefaultInfo].files

    dylib_pic = cc_toolchain.needs_pic_for_dynamic_libraries(
        feature_configuration = cc_features,
    )

    linker_inputs = []
    if dylib_pic:
        linker_inputs = [outputs.pic_obj]
    else:
        linker_inputs = [outputs.obj]
    for library_to_link in deps.linking_context.libraries_to_link:
        if dylib_pic:
            if library_to_link.pic_static_library:
                linker_inputs.append(library_to_link.pic_static_library)
        elif library_to_link.static_library:
            linker_inputs.append(library_to_link.static_library)

    ld = cc_common.get_tool_for_action(
        feature_configuration = cc_features,
        action_name = _ACTION_LINK_DYNAMIC,
    )

    ld_vars = cc_common.create_link_variables(
        cc_toolchain = cc_toolchain,
        feature_configuration = cc_features,
        output_file = outputs.dylib.path,
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
        inputs = depset(
            direct = linker_inputs,
            transitive = [toolchain_inputs],
        ),
        outputs = [outputs.dylib],
        executable = ld,
        arguments = ld_argv + [obj.path for obj in linker_inputs],
        mnemonic = "CppLink",
        progress_message = "Linking {}".format(outputs.dylib.short_path),
        env = ld_env,
    )

def _declare_outputs(ctx, cc_toolchain, cc_features, source):
    # TODO: Inspect cc_toolchain instead of guessing, once
    # https://github.com/bazelbuild/bazel/issues/7170 is fixed.
    target_name = cc_toolchain.target_gnu_system_name
    targets_windows = cc_common.is_enabled(
        feature_configuration = cc_features,
        feature_name = "targets_windows",
    )
    if targets_windows:
        obj_tmpl = "{}.obj"
        lib_tmpl = "{}.lib"
        dylib_tmpl = "{}.dll"
    elif target_name.endswith("-apple-macosx"):
        obj_tmpl = "{}.o"
        lib_tmpl = "lib{}.a"
        dylib_tmpl = "lib{}.dylib"
    else:
        obj_tmpl = "{}.o"
        lib_tmpl = "lib{}.a"
        dylib_tmpl = "lib{}.so"

    src_ext = source.extension
    src_basename = source.basename[:-len(src_ext)]

    out_obj = ctx.actions.declare_file(obj_tmpl.format(
        "_objs/{}/{}".format(
            ctx.attr.name,
            src_basename,
        ),
    ))
    out_lib = ctx.actions.declare_file(lib_tmpl.format(
        ctx.attr.name,
    ))

    out_pic_obj = None
    out_pic_lib = None
    needs_pic = cc_toolchain.needs_pic_for_dynamic_libraries(
        feature_configuration = cc_features,
    )
    supports_pic = cc_common.is_enabled(
        feature_configuration = cc_features,
        feature_name = "supports_pic",
    )
    if needs_pic or supports_pic:
        out_pic_obj = ctx.actions.declare_file(obj_tmpl.format(
            "_objs/{}/{}.pic".format(
                ctx.attr.name,
                src_basename,
            ),
        ))
        out_pic_lib = ctx.actions.declare_file(lib_tmpl.format(
            ctx.attr.name + ".pic",
        ))

    out_dylib = ctx.actions.declare_file(dylib_tmpl.format(
        ctx.attr.name,
    ))

    out_iflib = None
    if targets_windows:
        out_iflib = out_lib

    return struct(
        obj = out_obj,
        lib = out_lib,
        pic_obj = out_pic_obj,
        pic_lib = out_pic_lib,
        dylib = out_dylib,
        iflib = out_iflib,
    )
