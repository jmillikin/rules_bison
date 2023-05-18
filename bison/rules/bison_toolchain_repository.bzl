# Copyright 2023 the rules_bison authors.
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

"""Definition of the `bison_toolchain_repository` repository rule."""

_TOOLCHAIN_BUILD = """
load("@rules_bison//bison:toolchain_type.bzl", "BISON_TOOLCHAIN_TYPE")

toolchain(
    name = "toolchain",
    toolchain = {bison_repo} + "//rules_bison_internal:toolchain_info",
    toolchain_type = BISON_TOOLCHAIN_TYPE,
    visibility = ["//visibility:public"],
)
"""

_TOOLCHAIN_BIN_BUILD = """
alias(
    name = "bison",
    actual = {bison_repo} + "//bin:bison",
    visibility = ["//visibility:public"],
)
"""

def _bison_toolchain_repository(ctx):
    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(
        name = repr(ctx.name),
    ))
    ctx.file("BUILD.bazel", _TOOLCHAIN_BUILD.format(
        bison_repo = repr(ctx.attr.bison_repository),
    ))
    ctx.file("bin/BUILD.bazel", _TOOLCHAIN_BIN_BUILD.format(
        bison_repo = repr(ctx.attr.bison_repository),
    ))

bison_toolchain_repository = repository_rule(
    implementation = _bison_toolchain_repository,
    doc = """
Toolchain repository rule for Bison toolchains.

Toolchain repositories add a layer of indirection so that Bazel can resolve
toolchains without downloading additional dependencies.

The resulting repository will have the following targets:
- `//bin:bison` (an alias into the underlying [`bison_repository`]
  (#bison_repository))
- `//:toolchain`, which can be registered with Bazel.

### Example

```starlark
load(
    "@rules_bison//bison:bison.bzl",
    "bison_repository",
    "bison_toolchain_repository",
)

bison_repository(
    name = "bison_v3.3.2",
    version = "3.3.2",
)

bison_toolchain_repository(
    name = "bison",
    bison_repository = "@bison_v3.3.2",
)

register_toolchains("@bison//:toolchain")
```
""",
    attrs = {
        "bison_repository": attr.string(
            doc = "The name of a [`bison_repository`](#bison_repository).",
            mandatory = True,
        ),
    },
)
