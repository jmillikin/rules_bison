# Bazel build rules for GNU Bison

This Bazel ruleset allows [GNU Bison] to be integrated into a Bazel build. It
can be used to generate parsers in C, C++, or Java.

API reference: [docs/rules_bison.md](docs/rules_bison.md)

[GNU Bison]: https://www.gnu.org/software/bison/

## Setup

Add the following to your `MODULE.bazel`:

```python
bazel_dep(name = "rules_bison", version = "0.4")
```

To specify a version or build with additional C compiler options, use the
`bison_repository_ext` module extension:

```python
bison = use_extension(
    "@rules_bison//bison/extensions:bison_repository_ext.bzl",
    "bison_repository_ext",
)
bison.repository(
    name = "bison",
    version = "3.3.2",
    extra_copts = ["-O3"],
)
use_repo(bison, "bison")
register_toolchains("@bison//:toolchain")
```

Note that repository names registered with a given bzlmod module extension must
be unique within the scope of that extension. See the [Bazel module extensions]
documentation for more details.

[Bazel module extensions]: https://bazel.build/external/extension

## Examples

Integrating Bison into a C/C++ dependency graph:

```python
load("@rules_bison//bison:bison.bzl", "bison_cc_library")

bison_cc_library(
    name = "hello_parser",
    src = "hello.y",
)

cc_binary(
    name = "hello",
    deps = [":hello_parser"],
)
```

Integrating Bison into a Java dependency graph:

```python
load("@rules_bison//bison:bison.bzl", "bison_java_library")

bison_java_library(
    name = "HelloParser",
    src = "hello.y",
)

java_binary(
    name = "Hello",
    srcs = ["Hello.java"],
    main_class = "Hello",
    deps = [":HelloParser"],
)
```

Generating `.c` / `.h` / `.cc` source files (not as a `CcInfo`):

```python
load("@rules_bison//bison:bison.bzl", "bison")

bison(
    name = "hello_parser_srcs",
    src = "hello.y",
)

cc_binary(
    name = "hello",
    srcs = [":hello_parser_srcs"],
)
```

Running Bison in a `genrule`:

```python
genrule(
    name = "hello_gen",
    srcs = ["hello.y"],
    outs = ["hello_gen.c"],
    cmd = "M4=$(M4) $(BISON) --output=$@ $<",
    toolchains = [
        "@rules_bison//bison:current_bison_toolchain",
        "@rules_m4//m4:current_m4_toolchain",
    ],
)
```

Writing a custom rule that depends on Bison as a toolchain:

```python
load("@rules_bison//bison:bison.bzl", "BISON_TOOLCHAIN_TYPE", "bison_toolchain")
load("@rules_m4//m4:m4.bzl", "M4_TOOLCHAIN_TYPE")

def _my_rule(ctx):
    bison = bison_toolchain(ctx)
    ctx.actions.run(
        executable = bison.bison_tool,
        env = bison.bison_env,
        # ...
    )

my_rule = rule(
    implementation = _my_rule,
    toolchains = [
        BISON_TOOLCHAIN_TYPE,
        M4_TOOLCHAIN_TYPE,
    ],
)
```
