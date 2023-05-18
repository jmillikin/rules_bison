load("//bison:toolchain_type.bzl", "BISON_TOOLCHAIN_TYPE")
load("//bison/internal:versions.bzl", "VERSION_URLS")

[toolchain(
    name = "v{}".format(version),
    toolchain = "@bison_v{}//rules_bison_internal:toolchain_info".format(version),
    toolchain_type = BISON_TOOLCHAIN_TYPE,
) for version in VERSION_URLS]
