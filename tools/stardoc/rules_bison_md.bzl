"""# rules_bison

Bazel rules for GNU Bison.
"""

load(
    "//bison:bison.bzl",
    _BisonToolchainInfo = "BisonToolchainInfo",
    _bison = "bison",
    _bison_cc_library = "bison_cc_library",
    _bison_java_library = "bison_java_library",
    _bison_register_toolchains = "bison_register_toolchains",
    _bison_repository = "bison_repository",
    _bison_toolchain = "bison_toolchain",
    _bison_toolchain_repository = "bison_toolchain_repository",
)

# FIXME: Enable when stardoc has been updated to support bzlmod globals.
#
# https://github.com/bazelbuild/stardoc/issues/123
#
# buildifier: disable=no-effect
"""
load(
    "//bison/extensions:bison_repository_ext.bzl",
    _bison_repository_ext = "bison_repository_ext",
)
"""

bison = _bison
bison_cc_library = _bison_cc_library
bison_java_library = _bison_java_library
bison_register_toolchains = _bison_register_toolchains
bison_repository = _bison_repository
bison_toolchain = _bison_toolchain
bison_toolchain_repository = _bison_toolchain_repository
BisonToolchainInfo = _BisonToolchainInfo

# FIXME: Enable when stardoc has been updated to support bzlmod globals.
#
# https://github.com/bazelbuild/stardoc/issues/123
#
# buildifier: disable=no-effect
"""
bison_repository_ext = _bison_repository_ext
"""
