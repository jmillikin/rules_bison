load("@rules_bison//bison/internal:toolchain.bzl", "bison_toolchain_info")
load("@rules_bison//bison/internal:versions.bzl", "VERSION_URLS")

[bison_toolchain_info(
    name = "toolchain_v{}".format(version),
    bison = "@bison_v{}//bin:bison".format(version),
    tags = ["manual"],
    visibility = ["//visibility:public"],
) for version in VERSION_URLS]

cc_binary(
    name = "m4_deny_shell",
    srcs = ["m4_deny_shell.cc"],
    visibility = ["//visibility:public"],
)
