# Copyright 2026 the rules_bison authors.
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

"""Definition of the `bison_toolchains_ext` module extension."""

_BUILD = """
load("@rules_bison//bison:toolchain_type.bzl", "BISON_TOOLCHAIN_TYPE")
load("@rules_bison//bison/rules:bison_toolchain_info.bzl", "bison_toolchain_info")

bison_toolchain_info(
    name = "toolchain_info",
    bison_tool = {bison_tool},
    bison_env = {bison_env},
)

toolchain(
    name = "toolchain",
    toolchain = ":toolchain_info",
    toolchain_type = BISON_TOOLCHAIN_TYPE,
    visibility = ["//visibility:public"],
)
"""

def _bison_toolchains_repo_impl(ctx):
    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(
        name = repr(ctx.name),
    ))
    ctx.file("BUILD.bazel", "")
    for (toolchain_name, bison_tool) in ctx.attr.bison_tools.items():
        bison_env = ctx.attr.bison_envs.get(toolchain_name, "{}")
        ctx.file(toolchain_name + "/BUILD.bazel", _BUILD.format(
            bison_tool = repr(str(bison_tool)),
            bison_env = json.decode(bison_env),
        ))

_bison_toolchains_repo = repository_rule(
    implementation = _bison_toolchains_repo_impl,
    attrs = {
        "bison_tools": attr.string_keyed_label_dict(),
        "bison_envs": attr.string_dict(),
    },
)

def _bison_toolchains_ext(module_ctx):
    root_direct_dep = False
    root_direct_dev_dep = False

    bison_tools = {}
    bison_envs = {}
    for module in module_ctx.modules:
        for config in module.tags.toolchain:
            bison_tools[config.name] = config.bison_tool
            if config.bison_env:
                bison_envs[config.name] = json.encode(config.bison_env)
            if module.is_root:
                if module_ctx.is_dev_dependency(config):
                    root_direct_dev_dep = True
                else:
                    root_direct_dep = True

    _bison_toolchains_repo(
        name = "bison_toolchains",
        bison_tools = bison_tools,
        bison_envs = bison_envs,
    )

    root_direct_deps = []
    if root_direct_dep:
        root_direct_deps.append("bison_toolchains")
    root_direct_dev_deps = []
    if root_direct_dev_dep:
        root_direct_dev_deps.append("bison_toolchains")

    return module_ctx.extension_metadata(
        reproducible = True,
        root_module_direct_deps = root_direct_deps,
        root_module_direct_dev_deps = root_direct_dev_deps,
    )

_TOOLCHAIN_TAG_ATTRS = {
    "name": attr.string(
        doc = "The name of the toolchain repository to create.",
        mandatory = True,
    ),
    "bison_tool": attr.label(
        doc = "The label of an `bison` executable target.",
        mandatory = True,
    ),
    "bison_env": attr.string_dict(
        doc = "Additional environment variables to set when running `bison_tool`.",
    ),
}

bison_toolchains_ext = module_extension(
    implementation = _bison_toolchains_ext,
    doc = """
Module extension for declaring Bison toolchains with custom target binaries.

The resulting repository will have one subdirectory per named module tag, which
contains a `:toolchain` target that can be registered with Bazel.

### Example

```starlark
bison_toolchains = use_extension(
    "@rules_bison//bison/extensions:bison_toolchains_ext.bzl",
    "bison_toolchain_ext",
)

bison_toolchains.toolchain(
    name = "custom",
    bison_tool = "//custom_bison:bison",
)
use_repo(bison_toolchains, "bison_toolchains")
register_toolchains("@bison_toolchains//custom:toolchain")
```
""",
    tag_classes = {
        "toolchain": tag_class(
            attrs = _TOOLCHAIN_TAG_ATTRS,
        ),
    },
)
