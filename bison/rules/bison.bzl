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
    if ctx.file.src.extension == "y":
        language = "c"
    else:
        language = "c++"
    result = bison_action(ctx, language)
    return [
        DefaultInfo(files = result.outs),
        OutputGroupInfo(bison_report = result.report_files),
    ]

bison = rule(
    implementation = _bison,
    doc = """Generate source code for a Bison parser.

This rule exists for special cases where the build needs to perform further
modification of the generated `.c` / `.h` before compilation. Most users
will find the [`bison_cc_library`](#bison_cc_library) rule more convenient.

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

The source's file extension will determine whether Bison operates in C or C++
mode:
  - Inputs with file extension `.y` generate outputs `{name}.c` and `{name}.h`.
  - Inputs with file extension `.yy`, `.y++`, `.yxx`, or `.ypp` generate outputs
    `{name}.cc` and `{name}.h`.
""",
            mandatory = True,
            allow_single_file = [".y", ".yy", ".y++", ".yxx", ".ypp"],
        ),
    }),
    provides = [
        DefaultInfo,
        OutputGroupInfo,
    ],
    toolchains = BISON_ACTION_TOOLCHAINS,
)
