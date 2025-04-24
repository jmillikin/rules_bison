workspace(name = "rules_bison")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_m4",
    sha256 = "49aafc0d41c9258122b10dd4e705d6d8a42830d271e99ca2d6389506d31515c6",
    urls = ["https://github.com/jmillikin/rules_m4/releases/download/v0.2.5/rules_m4-v0.2.5.tar.xz"],
)

load("@rules_m4//m4:m4.bzl", "m4_register_toolchains")

m4_register_toolchains()

load("//bison:bison.bzl", "bison_register_toolchains", "bison_repository")

# buildifier: disable=bzl-visibility
load("//bison/internal:testutil.bzl", "rules_bison_testutil")

# buildifier: disable=bzl-visibility
load("//bison/internal:versions.bzl", "VERSION_URLS")

rules_bison_testutil(name = "rules_bison_testutil")

bison_register_toolchains()

[bison_repository(
    name = "bison_v" + version,
    version = version,
) for version in VERSION_URLS]

http_archive(
    name = "com_google_googletest",
    sha256 = "81964fe578e9bd7c94dfdb09c8e4d6e6759e19967e397dbea48d1c10e45d0df2",
    strip_prefix = "googletest-release-1.12.1",
    urls = ["https://github.com/google/googletest/archive/release-1.12.1.tar.gz"],
)

http_archive(
    name = "rules_cc",
    sha256 = "712d77868b3152dd618c4d64faaddefcc5965f90f5de6e6dd1d5ddcd0be82d42",
    strip_prefix = "rules_cc-0.1.1",
    urls = ["https://github.com/bazelbuild/rules_cc/releases/download/0.1.1/rules_cc-0.1.1.tar.gz"],
)

http_archive(
    name = "rules_java",
    sha256 = "d31b6c69e479ffa45460b64dc9c7792a431cac721ef8d5219fc9f603fa2ff877",
    urls = ["https://github.com/bazelbuild/rules_java/releases/download/8.11.0/rules_java-8.11.0.tar.gz"],
)

http_archive(
    name = "rules_shell",
    sha256 = "3e114424a5c7e4fd43e0133cc6ecdfe54e45ae8affa14fadd839f29901424043",
    strip_prefix = "rules_shell-0.4.0",
    urls = ["https://github.com/bazelbuild/rules_shell/releases/download/v0.4.0/rules_shell-v0.4.0.tar.gz"],
)

http_archive(
    name = "bazel_skylib",
    sha256 = "f7be3474d42aae265405a592bb7da8e171919d74c16f082a5457840f06054728",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.2.1/bazel-skylib-1.2.1.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.2.1/bazel-skylib-1.2.1.tar.gz",
    ],
)

http_archive(
    name = "io_bazel_stardoc",
    sha256 = "ca933f39f2a6e0ad392fa91fd662545afcbd36c05c62365538385d35a0323096",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.8.0/stardoc-0.8.0.tar.gz",
        "https://github.com/bazelbuild/stardoc/releases/download/0.8.0/stardoc-0.8.0.tar.gz",
    ],
)
