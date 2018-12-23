load("//:bison.bzl", "BISON_VERSIONS")
load("//bison:toolchain.bzl", "bison_toolchain")

[bison_toolchain(
    name = "v{}".format(version),
    bison = "@bison_v{}//bin:bison".format(version),
    tags = ["manual"],
    visibility = ["//visibility:public"],
) for version in BISON_VERSIONS]

[toolchain(
    name = "v{}_toolchain".format(version),
    toolchain = ":v{}".format(version),
    toolchain_type = "//bison:toolchain_type",
) for version in BISON_VERSIONS]
