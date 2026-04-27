load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

stardoc(
    name = "bison_md",
    out = "bison.md",
    header_template = ":header.vm",
    input = "//bison:bison_bzl",
    deps = [
        "//bison:bzl_srcs",
        "@rules_cc//cc/common",
        "@rules_java//java/common",
    ],
)

stardoc(
    name = "bison_repository_ext_md",
    out = "bison_repository_ext.md",
    header_template = ":empty.vm",
    input = "//bison/extensions:bison_repository_ext_bzl",
    deps = ["//bison:bzl_srcs"],
)

stardoc(
    name = "bison_toolchains_ext_md",
    out = "bison_toolchains_ext.md",
    header_template = ":empty.vm",
    input = "//bison/extensions:bison_toolchains_ext_bzl",
    deps = ["//bison:bzl_srcs"],
)

# https://github.com/bazelbuild/stardoc/issues/78
genrule(
    name = "rules_bison_md",
    srcs = [
        ":bison_md",
        ":bison_repository_ext_md",
        ":bison_toolchains_ext_md",
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
