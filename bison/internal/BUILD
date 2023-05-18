load("//bison/internal:toolchain_info.bzl", "bison_toolchain_info")
load("//bison/internal:versions.bzl", "VERSION_URLS")

[bison_toolchain_info(
    name = "toolchain_v{}".format(version),
    bison_tool = "@bison_v{}//bin:bison".format(version),
    tags = ["manual"],
    visibility = ["//visibility:public"],
) for version in VERSION_URLS]

cc_binary(
    name = "m4_deny_shell",
    srcs = ["m4_deny_shell.cc"],
    visibility = ["//visibility:public"],
)
