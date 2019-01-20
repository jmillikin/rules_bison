workspace(name = "io_bazel_rules_bison")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "io_bazel_rules_m4",
    commit = "73f7c0d56eadf8649291d561439470914718bb3d",
    remote = "https://github.com/jmillikin/rules_m4",
)

load("@io_bazel_rules_m4//m4:m4.bzl", "m4_register_toolchains")

m4_register_toolchains()

load("@io_bazel_rules_bison//bison:bison.bzl", "bison_register_toolchains")

bison_register_toolchains()

http_archive(
    name = "com_google_googletest",
    sha256 = "9bf1fe5182a604b4135edc1a425ae356c9ad15e9b23f9f12a02e80184c3a249c",
    strip_prefix = "googletest-release-1.8.1",
    urls = ["https://github.com/google/googletest/archive/release-1.8.1.tar.gz"],
)
