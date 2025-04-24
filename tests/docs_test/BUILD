load("@rules_shell//shell:sh_test.bzl", "sh_test")

sh_test(
    name = "docs_test",
    srcs = ["docs_test.sh"],
    data = [
        "//docs",
        "//tools/stardoc:stardoc_outputs",
    ],
    tags = ["manual"],
)
