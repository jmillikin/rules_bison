load("//bison:bison.bzl", "bison_common", "bison_toolchain_info")

[bison_toolchain_info(
    name = "toolchain_v{}".format(version),
    bison = "@bison_v{}//bin:bison".format(version),
    tags = ["manual"],
    visibility = ["//visibility:public"],
) for version in bison_common.VERSIONS]

cc_binary(
    name = "m4_deny_shell",
    srcs = ["m4_deny_shell.cc"],
    visibility = ["//bison:__pkg__"],
)
