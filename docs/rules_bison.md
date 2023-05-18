<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# rules_bison

Bazel rules for GNU Bison.


<a id="bison"></a>

## bison

<pre>
bison(<a href="#bison-name">name</a>, <a href="#bison-bison_options">bison_options</a>, <a href="#bison-skeleton">skeleton</a>, <a href="#bison-src">src</a>)
</pre>

Generate source code for a Bison parser.

This rule exists for special cases where the build needs to perform further
modification of the generated `.c` / `.h` before compilation. Most users
will find the [`bison_cc_library`](#bison_cc_library) rule more convenient.

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
| <a id="bison-bison_options"></a>bison_options |  Additional options to pass to the <code>bison</code> command.<br><br>These will be added to the command args immediately before the source file.   | List of strings | optional | <code>[]</code> |
| <a id="bison-skeleton"></a>skeleton |  Specify the skeleton to use.<br><br>This file is used as a template for rendering the generated parser. See the Bison documentation regarding the <code>%skeleton</code> directive for more details.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional | <code>None</code> |
| <a id="bison-src"></a>src |  A Bison source file.<br><br>The source's file extension will determine whether Bison operates in C or C++ mode:<ul> <li>Inputs with file extension <code>.y</code> generate outputs <code>{name}.c</code> and <code>{name}.h</code>. </li><li>Inputs with file extension <code>.yy</code>, <code>.y++</code>, <code>.yxx</code>, or <code>.ypp</code> generate outputs     <code>{name}.cc</code> and <code>{name}.h</code>. </li>  </ul> | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


<a id="bison_cc_library"></a>

## bison_cc_library

<pre>
bison_cc_library(<a href="#bison_cc_library-name">name</a>, <a href="#bison_cc_library-bison_options">bison_options</a>, <a href="#bison_cc_library-deps">deps</a>, <a href="#bison_cc_library-include_prefix">include_prefix</a>, <a href="#bison_cc_library-skeleton">skeleton</a>, <a href="#bison_cc_library-src">src</a>, <a href="#bison_cc_library-strip_include_prefix">strip_include_prefix</a>)
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
| <a id="bison_cc_library-bison_options"></a>bison_options |  Additional options to pass to the <code>bison</code> command.<br><br>These will be added to the command args immediately before the source file.   | List of strings | optional | <code>[]</code> |
| <a id="bison_cc_library-deps"></a>deps |  A list of other C/C++ libraries to depend on.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="bison_cc_library-include_prefix"></a>include_prefix |  A prefix to add to the path of the generated header.<br><br>See [<code>cc_library.include_prefix</code>](https://bazel.build/reference/be/c-cpp#cc_library.include_prefix) for more details.   | String | optional | <code>""</code> |
| <a id="bison_cc_library-skeleton"></a>skeleton |  Specify the skeleton to use.<br><br>This file is used as a template for rendering the generated parser. See the Bison documentation regarding the <code>%skeleton</code> directive for more details.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional | <code>None</code> |
| <a id="bison_cc_library-src"></a>src |  A Bison source file.<br><br>The source's file extension will determine whether Bison operates in C or C++ mode:<ul> <li>Inputs with file extension <code>.y</code> generate outputs <code>{name}.c</code> and <code>{name}.h</code>. </li><li>Inputs with file extension <code>.yy</code>, <code>.y++</code>, <code>.yxx</code>, or <code>.ypp</code> generate outputs     <code>{name}.cc</code> and <code>{name}.h</code>. </li>  </ul> | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="bison_cc_library-strip_include_prefix"></a>strip_include_prefix |  A prefix to strip from the path of the generated header.<br><br>See [<code>cc_library.strip_include_prefix</code>](https://bazel.build/reference/be/c-cpp#cc_library.strip_include_prefix) for more details.   | String | optional | <code>""</code> |


<a id="bison_java_library"></a>

## bison_java_library

<pre>
bison_java_library(<a href="#bison_java_library-name">name</a>, <a href="#bison_java_library-bison_options">bison_options</a>, <a href="#bison_java_library-deps">deps</a>, <a href="#bison_java_library-skeleton">skeleton</a>, <a href="#bison_java_library-src">src</a>)
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
| <a id="bison_java_library-bison_options"></a>bison_options |  Additional options to pass to the <code>bison</code> command.<br><br>These will be added to the command args immediately before the source file.   | List of strings | optional | <code>[]</code> |
| <a id="bison_java_library-deps"></a>deps |  A list of other Java libraries to depend on.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="bison_java_library-skeleton"></a>skeleton |  Specify the skeleton to use.<br><br>This file is used as a template for rendering the generated parser. See the Bison documentation regarding the <code>%skeleton</code> directive for more details.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional | <code>None</code> |
| <a id="bison_java_library-src"></a>src |  A Bison source file.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


<a id="bison_repository"></a>

## bison_repository

<pre>
bison_repository(<a href="#bison_repository-name">name</a>, <a href="#bison_repository-extra_copts">extra_copts</a>, <a href="#bison_repository-repo_mapping">repo_mapping</a>, <a href="#bison_repository-version">version</a>)
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
| <a id="bison_repository-extra_copts"></a>extra_copts |  Additional C compiler options to use when building GNU Bison.   | List of strings | optional | <code>[]</code> |
| <a id="bison_repository-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.&lt;p&gt;For example, an entry <code>"@foo": "@bar"</code> declares that, for any time this repository depends on <code>@foo</code> (such as a dependency on <code>@foo//some:target</code>, it should actually resolve that dependency within globally-declared <code>@bar</code> (<code>@bar//some:target</code>).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |
| <a id="bison_repository-version"></a>version |  A supported version of GNU Bison.   | String | required |  |


<a id="bison_toolchain_repository"></a>

## bison_toolchain_repository

<pre>
bison_toolchain_repository(<a href="#bison_toolchain_repository-name">name</a>, <a href="#bison_toolchain_repository-bison_repository">bison_repository</a>, <a href="#bison_toolchain_repository-repo_mapping">repo_mapping</a>)
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
| <a id="bison_toolchain_repository-bison_repository"></a>bison_repository |  The name of a [<code>bison_repository</code>](#bison_repository).   | String | required |  |
| <a id="bison_toolchain_repository-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.&lt;p&gt;For example, an entry <code>"@foo": "@bar"</code> declares that, for any time this repository depends on <code>@foo</code> (such as a dependency on <code>@foo//some:target</code>, it should actually resolve that dependency within globally-declared <code>@bar</code> (<code>@bar//some:target</code>).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |


<a id="BisonToolchainInfo"></a>

## BisonToolchainInfo

<pre>
BisonToolchainInfo(<a href="#BisonToolchainInfo-all_files">all_files</a>, <a href="#BisonToolchainInfo-bison_tool">bison_tool</a>, <a href="#BisonToolchainInfo-bison_env">bison_env</a>)
</pre>

Provider for a Bison toolchain.

**FIELDS**


| Name  | Description |
| :------------- | :------------- |
| <a id="BisonToolchainInfo-all_files"></a>all_files |  A <code>depset</code> containing all files comprising this Bison toolchain.    |
| <a id="BisonToolchainInfo-bison_tool"></a>bison_tool |  A <code>FilesToRunProvider</code> for the <code>bison</code> binary.    |
| <a id="BisonToolchainInfo-bison_env"></a>bison_env |  Additional environment variables to set when running <code>bison_tool</code>.    |


<a id="bison_register_toolchains"></a>

## bison_register_toolchains

<pre>
bison_register_toolchains(<a href="#bison_register_toolchains-version">version</a>, <a href="#bison_register_toolchains-extra_copts">extra_copts</a>)
</pre>

A helper function for Bison toolchains registration.

This workspace macro will create a [`bison_repository`](#bison_repository)
named `bison_v{version}` and register it as a Bazel toolchain.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="bison_register_toolchains-version"></a>version |  A supported version of Bison.   |  <code>"3.3.2"</code> |
| <a id="bison_register_toolchains-extra_copts"></a>extra_copts |  Additional C compiler options to use when building Bison.   |  <code>[]</code> |


<a id="bison_toolchain"></a>

## bison_toolchain

<pre>
bison_toolchain(<a href="#bison_toolchain-ctx">ctx</a>)
</pre>

Returns the current [`BisonToolchainInfo`](#BisonToolchainInfo).

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="bison_toolchain-ctx"></a>ctx |  A rule context, where the rule has a toolchain dependency on [<code>BISON_TOOLCHAIN_TYPE</code>](#BISON_TOOLCHAIN_TYPE).   |  none |

**RETURNS**

A [`BisonToolchainInfo`](#BisonToolchainInfo).


