load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

bzl_library(
    name = "rules_bison_bzl_srcs",
    srcs = ["//bison:bzl_srcs"],
)

stardoc(
    name = "rules_bison_raw_md",
    out = "rules_bison_raw.md",
    input = "rules_bison_md.bzl",
    deps = [":rules_bison_bzl_srcs"],
)

# https://github.com/bazelbuild/stardoc/issues/78
genrule(
    name = "rules_bison_md",
    srcs = [":rules_bison_raw.md"],
    outs = ["rules_bison.md"],
    cmd = """
sed \\
  -e 's/C or C++ mode:/C or C++ mode:<ul>/' \\
  -e 's/  - \\([^|-]*\\)  /<li>\\1<\\/li>  /' \\
  -e 's/  - \\([^|-]*\\)  /<li>\\1<\\/li>  /' \\
  -e 's/<\\/li>  |/<\\/li>  <\\/ul> |/' \\
  $< > $@
""",
)

filegroup(
    name = "stardoc_outputs",
    srcs = [":rules_bison.md"],
    visibility = ["//:__subpackages__"],
)
