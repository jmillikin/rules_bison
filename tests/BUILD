load(
    "//bison:bison.bzl",
    "bison_cc_library",
    "bison_java_library",
)

cc_library(
    name = "hello_common",
    srcs = ["hello_common.c"],
    hdrs = ["hello_common.h"],
)

genrule(
    name = "genrule_test",
    srcs = ["hello_c.y"],
    outs = ["genrule_output.c"],
    cmd = """
export M4=$(M4)
$(BISON) $(location hello_c.y) -o $@
""",
    toolchains = [
        "//bison:current_bison_toolchain",
        "@rules_m4//m4:current_m4_toolchain",
    ],
)

bison_cc_library(
    name = "hello_c",
    src = "hello_c.y",
    deps = [":hello_common"],
)

cc_binary(
    name = "hello_c_bin",
    srcs = ["hello_c.c"],
    deps = [":hello_c"],
)

bison_cc_library(
    name = "hello_cc",
    src = "hello_cc.yy",
    deps = [":hello_common"],
)

cc_binary(
    name = "hello_cc_bin",
    srcs = ["hello_cc.cc"],
    deps = [":hello_cc"],
)

bison_java_library(
    name = "HelloJavaParser",
    src = "hello_java.y",
)

java_binary(
    name = "HelloJavaMain",
    srcs = ["HelloJavaMain.java"],
    main_class = "HelloJavaMain",
    deps = [":HelloJavaParser"],
)

filegroup(
    name = "testdata",
    srcs = [
        ":HelloJavaMain.jar",
        ":genrule_test",
        ":hello_c_bin",
        ":hello_cc_bin",
    ],
)

cc_test(
    name = "bison_test",
    srcs = ["bison_test.cc"],
    data = [":testdata"],
    linkstatic = True,
    deps = [
        "@bazel_tools//tools/cpp/runfiles",
        "@com_google_googletest//:gtest",
        "@com_google_googletest//:gtest_main",
    ],
)

alias(
    name = "all_versions",
    actual = "@rules_bison_testutil//:all_versions",
    tags = ["manual"],
)

sh_test(
    name = "docs_test",
    srcs = ["docs_test.sh"],
    data = [
        "//docs",
        "//tools/stardoc:stardoc_outputs",
    ],
    tags = ["manual"],
)
