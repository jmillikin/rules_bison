load("//bison:bison.bzl", "bison_common")

[toolchain(
    name = "v{}".format(version),
    toolchain = "//bison/internal:toolchain_v{}".format(version),
    toolchain_type = bison_common.TOOLCHAIN_TYPE,
) for version in bison_common.VERSIONS]
