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
    attrs = bison_action_attrs({
        "src": attr.label(
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
