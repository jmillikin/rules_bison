load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

# TODO: Required due to https://github.com/bazelbuild/rules_cc/issues/279
bzl_library(
    name = "rules_cc_bzl_lib",
    srcs = ["@rules_cc//cc:bzl_srcs"],
    deps = [
        "@rules_cc//cc/common",
    ],
)

bzl_library(
    name = "bzl_lib",
    srcs = ["//bison:bzl_srcs"],
    deps = [
        ":rules_cc_bzl_lib",
        "@rules_java//java:rules",
    ],
)

stardoc(
    name = "bison_md",
    out = "bison.md",
    header_template = ":header.vm",
    input = "//bison:bison_bzl",
    deps = [":bzl_lib"],
)

stardoc(
    name = "bison_repository_ext_md",
    out = "bison_repository_ext.md",
    header_template = ":empty.vm",
    input = "//bison/extensions:bison_repository_ext_bzl",
    deps = [":bzl_lib"],
)

# https://github.com/bazelbuild/stardoc/issues/78
genrule(
    name = "rules_bison_md",
    srcs = [
        ":bison_md",
        ":bison_repository_ext_md",
    ],
    outs = ["rules_bison.md"],
    cmd = """
cat $(SRCS) | sed \\
  -e 's/C or C++ mode:/C or C++ mode:<ul>/' \\
  -e 's/  - \\([^|-]*\\)  /<li>\\1<\\/li>  /' \\
  -e 's/  - \\([^|-]*\\)  /<li>\\1<\\/li>  /' \\
  -e 's/<\\/li>  |/<\\/li>  <\\/ul> |/' \\
  > $@
""",
)

filegroup(
    name = "stardoc_outputs",
    srcs = [":rules_bison_md"],
    visibility = ["//:__subpackages__"],
)
