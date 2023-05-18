# Copyright 2019 the rules_bison authors.
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

"""Supported versions of GNU Bison."""

_MIRRORS = [
    "https://mirrors.kernel.org/gnu/bison/",
    "https://ftp.gnu.org/gnu/bison/",
]

def _urls(filename):
    return [m + filename for m in _MIRRORS]

DEFAULT_VERSION = "3.3.2"

VERSION_URLS = {
    "3.3.2": {
        "urls": _urls("bison-3.3.2.tar.xz"),
        "sha256": "039ee45b61d95e5003e7e8376f9080001b4066ff357bde271b7faace53b9d804",
        "copyright_year": "2019",
    },
    "3.3.1": {
        "urls": _urls("bison-3.3.1.tar.xz"),
        "sha256": "fd22fc5ed02b42c88fa0efc6d5de3face8dfb5e253bf97e632573413969bc900",
        "copyright_year": "2019",
    },
    "3.3": {
        "urls": _urls("bison-3.3.tar.xz"),
        "sha256": "162ea71d21e134c44942f4ebb74685e19c942dcf40a7120eba165ba5e2553bb9",
        "copyright_year": "2019",
    },
    "3.2.4": {
        "urls": _urls("bison-3.2.4.tar.xz"),
        "sha256": "523d44419f4df68286503740c95c7b3400b748d7d8b797209195ee5d67f05634",
        "copyright_year": "0000",
    },
    "3.2.3": {
        "urls": _urls("bison-3.2.3.tar.xz"),
        "sha256": "3cb07a84ff698b205ea244e36eccb4979dd4e10f2120ebbf58c5f1f700023f29",
        "copyright_year": "0000",
    },
    "3.2.2": {
        "urls": _urls("bison-3.2.2.tar.xz"),
        "sha256": "6f950f24e4d0745c7cc870e36d04f4057133ce0f31d6b4564e6f510a7d3ffafa",
        "copyright_year": "2018",
    },
    "3.2.1": {
        "urls": _urls("bison-3.2.1.tar.xz"),
        "sha256": "8ba8bd5d6e935d01b89382fa5c2fa7602e03bbb435575087bfdc3c450d4d9ecd",
        "copyright_year": "0000",
    },
    "3.2": {
        "urls": _urls("bison-3.2.tar.xz"),
        "sha256": "deec377b95aa72ec4e1a33fe2c938d2480749d740b5291a7cc1d77808d3710bf",
        "copyright_year": "0000",
    },
}

def check_version(version):
    if version not in VERSION_URLS:
        fail("GNU Bison version {} not supported by rules_bison.".format(repr(version)))
