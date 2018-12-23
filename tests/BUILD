load("//:bison.bzl", "bison_parser")

bison_parser(
    name = "hello_c",
    src = "hello.y",
    # default language is "c"
)

cc_binary(
    name = "hello_c_bin",
    srcs = [":hello_c"],
)

bison_parser(
    name = "hello_cc",
    src = "hello.y",
    language = "c++",
)

bison_parser(
    name = "hello_java",
    src = "hello.y",
    language = "java",
)

filegroup(
    name = "testdata",
    srcs = [
        ":hello_c",
        ":hello_cc",
        ":hello_java",
    ],
)

cc_test(
    name = "bison_test",
    srcs = ["bison_test.cc"],
    data = [":testdata"],
    deps = [
        "@com_google_googletest//:gtest",
        "@com_google_googletest//:gtest_main",
    ],
)
