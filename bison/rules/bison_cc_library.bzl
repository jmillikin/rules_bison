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

"""Definition of the `bison_cc_library` build rule."""

load(
    "//bison/internal:bison_action.bzl",
    "BISON_ACTION_TOOLCHAINS",
    "bison_action",
    "bison_action_attrs",
)

def _cc_library(ctx, bison_result):
    cc_toolchain = ctx.attr._cc_toolchain[cc_common.CcToolchainInfo]

    cc_deps = cc_common.merge_cc_infos(cc_infos = [
        dep[CcInfo]
        for dep in ctx.attr.deps
    ])

    cc_feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.attr.features,
    )

    compile_kwargs = {}
    if ctx.attr.include_prefix:
        compile_kwargs["include_prefix"] = ctx.attr.include_prefix
    if ctx.attr.strip_include_prefix:
        compile_kwargs["strip_include_prefix"] = ctx.attr.strip_include_prefix

    (cc_compilation_context, cc_compilation_outputs) = cc_common.compile(
        name = ctx.attr.name,
        actions = ctx.actions,
        cc_toolchain = cc_toolchain,
        feature_configuration = cc_feature_configuration,
        srcs = [bison_result.source],
        public_hdrs = [bison_result.header],
        compilation_contexts = [cc_deps.compilation_context],
        **compile_kwargs
    )

    (cc_linking_context, cc_linking_outputs) = cc_common.create_linking_context_from_compilation_outputs(
        name = ctx.attr.name,
        actions = ctx.actions,
        feature_configuration = cc_feature_configuration,
        cc_toolchain = cc_toolchain,
        compilation_outputs = cc_compilation_outputs,
        linking_contexts = [cc_deps.linking_context],
    )

    outs = []
    if cc_linking_outputs.library_to_link.static_library:
        outs.append(cc_linking_outputs.library_to_link.static_library)
    if cc_linking_outputs.library_to_link.dynamic_library:
        outs.append(cc_linking_outputs.library_to_link.dynamic_library)

    return struct(
        outs = depset(direct = outs),
        cc_info = CcInfo(
            compilation_context = cc_compilation_context,
            linking_context = cc_linking_context,
        ),
    )

def _bison_cc_library(ctx):
    if ctx.file.src.extension == "y":
        language = "c"
    else:
        language = "c++"
    result = bison_action(ctx, language)
    cc_lib = _cc_library(ctx, result)
    return [
        DefaultInfo(files = cc_lib.outs),
        cc_lib.cc_info,
        OutputGroupInfo(bison_report = result.report_files),
    ]

bison_cc_library = rule(
    implementation = _bison_cc_library,
    doc = """Generate a C/C++ library for a Bison parser.

Verbose descriptions of the parser are available in output group `bison_report`.

### Example

```starlark
load("@rules_bison//bison:bison.bzl", "bison_cc_library")

bison_cc_library(
    name = "hello_lib",
    src = "hello.y",
)

cc_binary(
    name = "hello",
    srcs = ["hello_main.c"],
    deps = [":hello_lib"],
)
```
""",
    attrs = bison_action_attrs({
        "src": attr.label(
            doc = """A Bison source file.

The source's file extension will determine whether Bison operates in C or C++
mode:
  - Inputs with file extension `.y` generate outputs `{name}.c` and `{name}.h`.
  - Inputs with file extension `.yy`, `.y++`, `.yxx`, or `.ypp` generate outputs
    `{name}.cc` and `{name}.h`.
""",
            mandatory = True,
            allow_single_file = [".y", ".yy", ".y++", ".yxx", ".ypp"],
        ),
        "deps": attr.label_list(
            doc = "A list of other C/C++ libraries to depend on.",
            providers = [CcInfo],
        ),
        "include_prefix": attr.string(
            doc = """A prefix to add to the path of the generated header.

See [`cc_library.include_prefix`](https://bazel.build/reference/be/c-cpp#cc_library.include_prefix)
for more details.
""",
        ),
        "strip_include_prefix": attr.string(
            doc = """A prefix to strip from the path of the generated header.

See [`cc_library.strip_include_prefix`](https://bazel.build/reference/be/c-cpp#cc_library.strip_include_prefix)
for more details.
""",
        ),
        "_cc_toolchain": attr.label(
            default = "@bazel_tools//tools/cpp:current_cc_toolchain",
        ),
    }),
    provides = [
        CcInfo,
        DefaultInfo,
        OutputGroupInfo,
    ],
    toolchains = BISON_ACTION_TOOLCHAINS,
    fragments = ["cpp"],
)
