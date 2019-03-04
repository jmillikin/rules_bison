# Bazel buuld rules for GNU Bison

## Overview

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_m4",
    urls = ["https://github.com/jmillikin/rules_m4/releases/download/v0.1/rules_m4-v0.1.tar.xz"],
    sha256 = "7bb12b8a5a96037ff3d36993a9bb5436c097e8d1287a573d5958b9d054c0a4f7",
)
load("@rules_m4//m4:m4.bzl", "m4_register_toolchains")
m4_register_toolchains()

http_archive(
    name = "rules_bison",
    # See https://github.com/jmillikin/rules_bison/releases for copy-pastable
    # URLs and checksums.
)
load("@rules_bison//bison:bison.bzl", "bison_register_toolchains")
bison_register_toolchains()
```

```python
load("@rules_bison//bison:bison.bzl", "bison_cc_library")
bison_cc_library(
    name = "hello",
    src = "hello.y",
)
cc_binary(
    name = "hello_bin",
    deps = [":hello"],
)
```

```python
load("@rules_bison//bison:bison.bzl", "bison_java_library")
bison_java_library(
    name = "HelloJavaParser",
    src = "hello_java.y",
)
java_binary(
    name = "HelloJava",
    srcs = ["HelloJava.java"],
    main_class = "HelloJava",
    deps = [":HelloJavaParser"],
)
```

## Other Rules

```python
load("@rules_bison//bison:bison.bzl", "bison")
bison(
    name = "hello_bin_srcs",
    src = "hello.y",
)
cc_binary(
    name = "hello_bin",
    srcs = [":hello_bin_srcs"],
)
```

```python
genrule(
    name = "hello_gen",
    srcs = ["hello.y"],
    outs = ["hello_gen.c"],
    cmd = "M4=$(M4) $(BISON) --output=$@ $<",
    toolchains = [
        "@rules_bison//bison:toolchain",
        "@rules_m4//m4:toolchain",
    ],
)
```

## Toolchains

```python
load("@rules_flex//bison:bison.bzl", "bison_common")
load("@rules_m4//m4:m4.bzl", "m4_common")

def _my_rule(ctx):
    bison_toolchain = bison_common.bison_toolchain(ctx)
    m4_toolchain = m4_common.m4_toolchain(ctx)
    ctx.actions.run(
        executable = bison_toolchain.bison_executable,
        inputs = depset(transitive = [
            bison_toolchain.files,
            m4_toolchain.files,
        ]),
        env = {"M4": m4_toolchain.m4_executable.path},
        # ...
    )

my_rule = rule(
    _my_rule,
    toolchains = [
        bison_common.TOOLCHAIN_TYPE,
        m4_common.TOOLCHAIN_TYPE,
    ],
)
```
