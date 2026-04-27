<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# rules_bison

Bazel rules for GNU Bison.

<a id="bison"></a>

## bison

<pre>
load("@rules_bison//bison:bison.bzl", "bison")

bison(<a href="#bison-name">name</a>, <a href="#bison-src">src</a>, <a href="#bison-bison_options">bison_options</a>, <a href="#bison-language">language</a>, <a href="#bison-skeleton">skeleton</a>)
</pre>

Generate source code for a Bison parser.

This rule exists for special cases where the build needs to perform further
modification of the generated `.c` / `.h` before compilation. Most users
will find the [`bison_cc_library`](#bison_cc_library) rule more convenient.

When generating a C/C++ parser the output groups `cc_srcs` and `cc_hdrs`
provide access to the generated `{name}.c` / `{name}.cc` source and
`{name}.h` header.

When generating a Java parser the output group `java_srcs` provides access
to the generated `{name}.java` source.

### Example

```starlark
load("@rules_bison//bison:bison.bzl", "bison")

bison(
    name = "hello",
    src = "hello.y",
)
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="bison-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="bison-src"></a>src |  A Bison source file.<br><br>Unless `language` is set, the source's file extension determines whether Bison operates in C or C++ mode:<ul> <li>Inputs with file extension `.y` generate outputs `{name}.c` and `{name}.h`. </li><li>Inputs with file extension `.yy`, `.y++`, `.yxx`, or `.ypp` generate outputs     `{name}.cc` and `{name}.h`. </li>  </ul> | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="bison-bison_options"></a>bison_options |  Additional options to pass to the `bison` command.<br><br>These will be added to the command args immediately before the source file.   | List of strings | optional |  `[]`  |
| <a id="bison-language"></a>language |  Which language to generate the parser in.   | String | optional |  `""`  |
| <a id="bison-skeleton"></a>skeleton |  Specify the skeleton to use.<br><br>This file is used as a template for rendering the generated parser. See the Bison documentation regarding the `%skeleton` directive for more details.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


<a id="bison_cc_library"></a>

## bison_cc_library

<pre>
load("@rules_bison//bison:bison.bzl", "bison_cc_library")

bison_cc_library(<a href="#bison_cc_library-name">name</a>, <a href="#bison_cc_library-deps">deps</a>, <a href="#bison_cc_library-src">src</a>, <a href="#bison_cc_library-bison_options">bison_options</a>, <a href="#bison_cc_library-conlyopts">conlyopts</a>, <a href="#bison_cc_library-copts">copts</a>, <a href="#bison_cc_library-cxxopts">cxxopts</a>, <a href="#bison_cc_library-include_prefix">include_prefix</a>,
                 <a href="#bison_cc_library-language">language</a>, <a href="#bison_cc_library-linkstatic">linkstatic</a>, <a href="#bison_cc_library-skeleton">skeleton</a>, <a href="#bison_cc_library-strip_include_prefix">strip_include_prefix</a>)
</pre>

Generate a C/C++ library for a Bison parser.

Verbose descriptions of the parser are available in output group `bison_report`.

### Example

```starlark
load("@rules_bison//bison:bison.bzl", "bison_cc_library")

bison_cc_library(
    name = "hello_lib",
    src = "hello.y",
)

cc_binary(
    name = "hello",
    srcs = ["hello_main.c"],
    deps = [":hello_lib"],
)
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="bison_cc_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="bison_cc_library-deps"></a>deps |  A list of other C/C++ libraries to depend on.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="bison_cc_library-src"></a>src |  A Bison source file.<br><br>Unless `language` is set, the source's file extension determines whether Bison operates in C or C++ mode:<ul> <li>Inputs with file extension `.y` generate outputs `{name}.c` and `{name}.h`. </li><li>Inputs with file extension `.yy`, `.y++`, `.yxx`, or `.ypp` generate outputs     `{name}.cc` and `{name}.h`. </li>  </ul> | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="bison_cc_library-bison_options"></a>bison_options |  Additional options to pass to the `bison` command.<br><br>These will be added to the command args immediately before the source file.   | List of strings | optional |  `[]`  |
| <a id="bison_cc_library-conlyopts"></a>conlyopts |  Add these options to the C compilation command.<br><br>See [`cc_library.conlyopts`](https://bazel.build/reference/be/c-cpp#cc_library.conlyopts) for more details.   | List of strings | optional |  `[]`  |
| <a id="bison_cc_library-copts"></a>copts |  Add these options to the C/C++ compilation command.<br><br>See [`cc_library.copts`](https://bazel.build/reference/be/c-cpp#cc_library.copts) for more details.   | List of strings | optional |  `[]`  |
| <a id="bison_cc_library-cxxopts"></a>cxxopts |  Add these options to the C++ compilation command.<br><br>See [`cc_library.cxxopts`](https://bazel.build/reference/be/c-cpp#cc_library.cxxopts) for more details.   | List of strings | optional |  `[]`  |
| <a id="bison_cc_library-include_prefix"></a>include_prefix |  A prefix to add to the path of the generated header.<br><br>See [`cc_library.include_prefix`](https://bazel.build/reference/be/c-cpp#cc_library.include_prefix) for more details.   | String | optional |  `""`  |
| <a id="bison_cc_library-language"></a>language |  Which language to generate the parser in.   | String | optional |  `""`  |
| <a id="bison_cc_library-linkstatic"></a>linkstatic |  Disable creation of a shared library output.<br><br>See [`cc_library.linkstatic`](https://bazel.build/reference/be/c-cpp#cc_library.linkstatic) for more details.   | Boolean | optional |  `False`  |
| <a id="bison_cc_library-skeleton"></a>skeleton |  Specify the skeleton to use.<br><br>This file is used as a template for rendering the generated parser. See the Bison documentation regarding the `%skeleton` directive for more details.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="bison_cc_library-strip_include_prefix"></a>strip_include_prefix |  A prefix to strip from the path of the generated header.<br><br>See [`cc_library.strip_include_prefix`](https://bazel.build/reference/be/c-cpp#cc_library.strip_include_prefix) for more details.   | String | optional |  `""`  |


<a id="bison_java_library"></a>

## bison_java_library

<pre>
load("@rules_bison//bison:bison.bzl", "bison_java_library")

bison_java_library(<a href="#bison_java_library-name">name</a>, <a href="#bison_java_library-deps">deps</a>, <a href="#bison_java_library-src">src</a>, <a href="#bison_java_library-bison_options">bison_options</a>, <a href="#bison_java_library-skeleton">skeleton</a>)
</pre>

Generate a Java library for a Bison parser.

Verbose descriptions of the parser are available in output group `bison_report`.

### Example

```starlark
load("@rules_bison//bison:bison.bzl", "bison_java_library")

bison_java_library(
    name = "HelloParser",
    src = "hello.y",
)

java_binary(
    name = "HelloMain",
    srcs = ["HelloMain.java"],
    main_class = "HelloMain",
    deps = [":HelloParser"],
)
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="bison_java_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="bison_java_library-deps"></a>deps |  A list of other Java libraries to depend on.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="bison_java_library-src"></a>src |  A Bison source file.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="bison_java_library-bison_options"></a>bison_options |  Additional options to pass to the `bison` command.<br><br>These will be added to the command args immediately before the source file.   | List of strings | optional |  `[]`  |
| <a id="bison_java_library-skeleton"></a>skeleton |  Specify the skeleton to use.<br><br>This file is used as a template for rendering the generated parser. See the Bison documentation regarding the `%skeleton` directive for more details.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


<a id="bison_toolchain_info"></a>

## bison_toolchain_info

<pre>
load("@rules_bison//bison:bison.bzl", "bison_toolchain_info")

bison_toolchain_info(<a href="#bison_toolchain_info-name">name</a>, <a href="#bison_toolchain_info-bison_env">bison_env</a>, <a href="#bison_toolchain_info-bison_tool">bison_tool</a>)
</pre>

Provides `ToolchainInfo` and `TemplateVariableInfo` for the Bison toolchain.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="bison_toolchain_info-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="bison_toolchain_info-bison_env"></a>bison_env |  Additional environment variables to set when running `bison_tool`.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="bison_toolchain_info-bison_tool"></a>bison_tool |  A `FilesToRunProvider` for the `bison` binary.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


<a id="BisonToolchainInfo"></a>

## BisonToolchainInfo

<pre>
load("@rules_bison//bison:bison.bzl", "BisonToolchainInfo")

BisonToolchainInfo(<a href="#BisonToolchainInfo-all_files">all_files</a>, <a href="#BisonToolchainInfo-bison_tool">bison_tool</a>, <a href="#BisonToolchainInfo-bison_env">bison_env</a>)
</pre>

Provider for a Bison toolchain.

**FIELDS**

| Name  | Description |
| :------------- | :------------- |
| <a id="BisonToolchainInfo-all_files"></a>all_files |  A `depset` containing all files comprising this Bison toolchain.    |
| <a id="BisonToolchainInfo-bison_tool"></a>bison_tool |  A `FilesToRunProvider` for the `bison` binary.    |
| <a id="BisonToolchainInfo-bison_env"></a>bison_env |  Additional environment variables to set when running `bison_tool`.    |


<a id="bison_register_toolchains"></a>

## bison_register_toolchains

<pre>
load("@rules_bison//bison:bison.bzl", "bison_register_toolchains")

bison_register_toolchains(<a href="#bison_register_toolchains-version">version</a>, <a href="#bison_register_toolchains-extra_copts">extra_copts</a>)
</pre>

A helper function for Bison toolchains registration.

This workspace macro will create a [`bison_repository`](#bison_repository)
named `bison_v{version}` and register it as a Bazel toolchain.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="bison_register_toolchains-version"></a>version |  A supported version of Bison.   |  `"3.3.2"` |
| <a id="bison_register_toolchains-extra_copts"></a>extra_copts |  Additional C compiler options to use when building Bison.   |  `[]` |


<a id="bison_toolchain"></a>

## bison_toolchain

<pre>
load("@rules_bison//bison:bison.bzl", "bison_toolchain")

bison_toolchain(<a href="#bison_toolchain-ctx">ctx</a>)
</pre>

Returns the current [`BisonToolchainInfo`](#BisonToolchainInfo).

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="bison_toolchain-ctx"></a>ctx |  A rule context, where the rule has a toolchain dependency on [`BISON_TOOLCHAIN_TYPE`](#BISON_TOOLCHAIN_TYPE).   |  none |

**RETURNS**

A [`BisonToolchainInfo`](#BisonToolchainInfo).


<a id="bison_repository"></a>

## bison_repository

<pre>
load("@rules_bison//bison:bison.bzl", "bison_repository")

bison_repository(<a href="#bison_repository-name">name</a>, <a href="#bison_repository-extra_copts">extra_copts</a>, <a href="#bison_repository-extra_http_mirrors">extra_http_mirrors</a>, <a href="#bison_repository-extra_linkopts">extra_linkopts</a>, <a href="#bison_repository-http_mirrors">http_mirrors</a>,
                 <a href="#bison_repository-version">version</a>)
</pre>

Repository rule for GNU Bison.

The resulting repository will have a `//bin:bison` executable target.

### Example

```starlark
load("@rules_bison//bison:bison.bzl", "bison_repository")

bison_repository(
    name = "bison_v3.3.2",
    version = "3.3.2",
)
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="bison_repository-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="bison_repository-extra_copts"></a>extra_copts |  Additional C compiler options to use when building GNU Bison.   | List of strings | optional |  `[]`  |
| <a id="bison_repository-extra_http_mirrors"></a>extra_http_mirrors |  Additional HTTP mirrors of the GNU Bison source archives.<br><br>These mirrors will be appended to the list of default GNU mirrors.   | List of strings | optional |  `[]`  |
| <a id="bison_repository-extra_linkopts"></a>extra_linkopts |  Additional linker options to use when building GNU Bison.   | List of strings | optional |  `[]`  |
| <a id="bison_repository-http_mirrors"></a>http_mirrors |  If set then this value will be used instead of the default HTTP mirror list.<br><br>The `extra_http_mirrors` attribute will be appended to this list.   | List of strings | optional |  `[]`  |
| <a id="bison_repository-version"></a>version |  A supported version of GNU Bison.   | String | required |  |


<a id="bison_toolchain_repository"></a>

## bison_toolchain_repository

<pre>
load("@rules_bison//bison:bison.bzl", "bison_toolchain_repository")

bison_toolchain_repository(<a href="#bison_toolchain_repository-name">name</a>, <a href="#bison_toolchain_repository-bison_repository">bison_repository</a>)
</pre>

Toolchain repository rule for Bison toolchains.

Toolchain repositories add a layer of indirection so that Bazel can resolve
toolchains without downloading additional dependencies.

The resulting repository will have the following targets:
- `//bin:bison` (an alias into the underlying [`bison_repository`]
  (#bison_repository))
- `//:toolchain`, which can be registered with Bazel.

### Example

```starlark
load(
    "@rules_bison//bison:bison.bzl",
    "bison_repository",
    "bison_toolchain_repository",
)

bison_repository(
    name = "bison_v3.3.2",
    version = "3.3.2",
)

bison_toolchain_repository(
    name = "bison",
    bison_repository = "@bison_v3.3.2",
)

register_toolchains("@bison//:toolchain")
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="bison_toolchain_repository-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="bison_toolchain_repository-bison_repository"></a>bison_repository |  The name of a [`bison_repository`](#bison_repository).   | String | required |  |



<a id="bison_repository_ext"></a>

## bison_repository_ext

<pre>
bison_repository_ext = use_extension("@rules_bison//bison/extensions:bison_repository_ext.bzl", "bison_repository_ext")
bison_repository_ext.repository(<a href="#bison_repository_ext.repository-name">name</a>, <a href="#bison_repository_ext.repository-extra_copts">extra_copts</a>, <a href="#bison_repository_ext.repository-extra_http_mirrors">extra_http_mirrors</a>, <a href="#bison_repository_ext.repository-extra_linkopts">extra_linkopts</a>, <a href="#bison_repository_ext.repository-http_mirrors">http_mirrors</a>,
                                <a href="#bison_repository_ext.repository-version">version</a>)
</pre>

Module extension for declaring dependencies on GNU Bison.

The resulting repository will have the following targets:
- `//bin:bison` (an alias into the underlying [`bison_repository`]
  (#bison_repository))
- `//:toolchain`, which can be registered with Bazel.

### Example

```starlark
bison = use_extension(
    "@rules_bison//bison/extensions:bison_repository_ext.bzl",
    "bison_repository_ext",
)

bison.repository(name = "bison", version = "3.3.2")
use_repo(bison, "bison")
register_toolchains("@bison//:toolchain")
```


**TAG CLASSES**

<a id="bison_repository_ext.repository"></a>

### repository

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="bison_repository_ext.repository-name"></a>name |  An optional name for the repository.<br><br>The name must be unique within the set of names registered by this extension. If unset, the repository name will default to `"bison_v{version}"`.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | optional |  `""`  |
| <a id="bison_repository_ext.repository-extra_copts"></a>extra_copts |  Additional C compiler options to use when building GNU Bison.   | List of strings | optional |  `[]`  |
| <a id="bison_repository_ext.repository-extra_http_mirrors"></a>extra_http_mirrors |  Additional HTTP mirrors of the GNU Bison source archives.<br><br>These mirrors will be appended to the list of default GNU mirrors.   | List of strings | optional |  `[]`  |
| <a id="bison_repository_ext.repository-extra_linkopts"></a>extra_linkopts |  Additional linker options to use when building GNU Bison.   | List of strings | optional |  `[]`  |
| <a id="bison_repository_ext.repository-http_mirrors"></a>http_mirrors |  If set then this value will be used instead of the default HTTP mirror list.<br><br>The `extra_http_mirrors` attribute will be appended to this list.   | List of strings | optional |  `[]`  |
| <a id="bison_repository_ext.repository-version"></a>version |  A supported version of GNU Bison.   | String | optional |  `"3.3.2"`  |



<a id="bison_toolchains_ext"></a>

## bison_toolchains_ext

<pre>
bison_toolchains_ext = use_extension("@rules_bison//bison/extensions:bison_toolchains_ext.bzl", "bison_toolchains_ext")
bison_toolchains_ext.toolchain(<a href="#bison_toolchains_ext.toolchain-name">name</a>, <a href="#bison_toolchains_ext.toolchain-bison_env">bison_env</a>, <a href="#bison_toolchains_ext.toolchain-bison_tool">bison_tool</a>)
</pre>

Module extension for declaring Bison toolchains with custom target binaries.

The resulting repository will have one subdirectory per named module tag, which
contains a `:toolchain` target that can be registered with Bazel.

### Example

```starlark
bison_toolchains = use_extension(
    "@rules_bison//bison/extensions:bison_toolchains_ext.bzl",
    "bison_toolchain_ext",
)

bison_toolchains.toolchain(
    name = "custom",
    bison_tool = "//custom_bison:bison",
)
use_repo(bison_toolchains, "bison_toolchains")
register_toolchains("@bison_toolchains//custom:toolchain")
```


**TAG CLASSES**

<a id="bison_toolchains_ext.toolchain"></a>

### toolchain

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="bison_toolchains_ext.toolchain-name"></a>name |  The name of the toolchain repository to create.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="bison_toolchains_ext.toolchain-bison_env"></a>bison_env |  Additional environment variables to set when running `bison_tool`.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="bison_toolchains_ext.toolchain-bison_tool"></a>bison_tool |  The label of an `bison` executable target.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


