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

"""Definition of the `bison` build rule."""

load(
    "//bison/internal:bison_action.bzl",
    "BISON_ACTION_TOOLCHAINS",
    "bison_action",
    "bison_action_attrs",
)

def _bison(ctx):
    language = ctx.attr.language
    if language == "":
        if ctx.file.src.extension == "y":
            language = "c"
        else:
            language = "c++"
    result = bison_action(ctx, language)
    cc_srcs = []
    cc_hdrs = []
    java_srcs = []
    if language == "java":
        java_srcs = [result.source]
    else:
        cc_srcs = [result.source]
        cc_hdrs = [result.header]
    return [
        DefaultInfo(files = result.outs),
        OutputGroupInfo(
            bison_report = result.report_files,
            cc_srcs = depset(direct = cc_srcs),
            cc_hdrs = depset(direct = cc_hdrs),
            java_srcs = depset(direct = java_srcs),
        ),
    ]

bison = rule(
    implementation = _bison,
    doc = """Generate source code for a Bison parser.

This rule exists for special cases where the build needs to perform further
modification of the generated `.c` / `.h` before compilation. Most users
will find the [`bison_cc_library`](#bison_cc_library) rule more convenient.

When generating a C/C++ parser the output groups `cc_srcs` and `cc_hdrs`
provide access to the generated `{name}.c` / `{name}.cc` source and
`{name}.h` header.

When generating a Java parser the output group `java_srcs` provides access
to the generated `{name}.java` source.

### Example

```starlark
load("@rules_bison//bison:bison.bzl", "bison")

bison(
    name = "hello",
    src = "hello.y",
)
```
""",
    attrs = bison_action_attrs({
        "src": attr.label(
            doc = """A Bison source file.

Unless `language` is set, the source's file extension determines whether
Bison operates in C or C++ mode:
  - Inputs with file extension `.y` generate outputs `{name}.c` and `{name}.h`.
  - Inputs with file extension `.yy`, `.y++`, `.yxx`, or `.ypp` generate outputs
    `{name}.cc` and `{name}.h`.
""",
            mandatory = True,
            allow_single_file = [".y", ".yy", ".y++", ".yxx", ".ypp"],
        ),
        "language": attr.string(
            doc = "Which language to generate the parser in.",
            values = ["c", "c++", "java"],
        ),
    }),
    provides = [
        DefaultInfo,
        OutputGroupInfo,
    ],
    toolchains = BISON_ACTION_TOOLCHAINS,
)
