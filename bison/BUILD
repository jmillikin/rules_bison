load(
    "//bison/internal:toolchain_alias.bzl",
    "bison_toolchain_alias",
)

filegroup(
    name = "bzl_srcs",
    srcs = glob(["*.bzl"]) + [
        "//bison/internal:bzl_srcs",
        "//bison/rules:bzl_srcs",
    ],
    visibility = ["//:__subpackages__"],
)

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

bison_toolchain_alias(
    name = "current_bison_toolchain",
    visibility = ["//visibility:public"],
)
