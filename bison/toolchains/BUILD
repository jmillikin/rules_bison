load("@rules_bison//bison/internal:toolchain.bzl", "BISON_TOOLCHAIN_TYPE")
load("@rules_bison//bison/internal:versions.bzl", "VERSION_URLS")

[toolchain(
    name = "v{}".format(version),
    toolchain = "@rules_bison//bison/internal:toolchain_v{}".format(version),
    toolchain_type = BISON_TOOLCHAIN_TYPE,
) for version in VERSION_URLS]
