# Nexus Tools

<div align="center">

<p class="hidden">
  Faster and easier development using commonly used features.
</p>

<p class="hidden">
  <a href="https://typst.app/universe/package/nexus-tools">
    <img alt="Typst Universe version" src="https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fnexus-tools&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE&labelColor=%23353c44" /></a>
  <a href="https://github.com/mayconfmelo/nexus-tools/tree/dev/">
    <img alt="GitHub development branch version" src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fmayconfmelo%2Fnexus-tools%2Frefs%2Fheads%2Fdev%2Ftypst.toml&query=%24.package.version&logo=github&label=Development&logoColor=%2397978e&color=%23239DAE&labelColor=%23353c44" /></a>
</p>

[![Read the manual](https://img.shields.io/badge/Manual-%23353c44)](https://raw.githubusercontent.com/mayconfmelo/nexus-tools/refs/tags/0.3.0/docs/manual.pdf)
[![Example PDF](https://img.shields.io/badge/Example-.pdf-%23777?labelColor=%23353c44)](https://raw.githubusercontent.com/mayconfmelo/nexus-tools/refs/tags/0.3.0/docs/example.pdf)
[![Example source code](https://img.shields.io/badge/Example-.typ-%23777?labelColor=%23353c44)](https://github.com/mayconfmelo/nexus-tools/blob/0.3.0/docs/assets/example.typ)
[![Changelog file](https://img.shields.io/badge/Changelog-%23353c44)](https://github.com/mayconfmelo/nexus-tools/blob/0.3.0/docs/changelog.md)
[![Contribute with development](https://img.shields.io/badge/Contribute-%23353c44)](https://github.com/mayconfmelo/nexus-tools/blob/0.3.0/docs/contributing.md)


<p class="hidden">
  <a href="https://github.com/mayconfmelo/nexus-tools/actions/workflows/tests.yml">
    <img alt="General tests badge" src="https://github.com/mayconfmelo/nexus-tools/actions/workflows/tests.yml/badge.svg" /></a>
  <a href="https://github.com/mayconfmelo/nexus-tools/actions/workflows/build.yml">
    <img alt="Build test badge" src="https://github.com/mayconfmelo/nexus-tools/actions/workflows/build.yml/badge.svg" /></a>
  <a href="https://github.com/mayconfmelo/nexus-tools/actions/workflows/spellcheck.yml">
    <img alt="Spellcheck test badge" src="https://github.com/mayconfmelo/nexus-tools/actions/workflows/spellcheck.yml/badge.svg" /></a>
  <a href="https://github.com/mayconfmelo/nexus-tools/actions/workflows/plugin.yml">
    <img alt="Spellcheck test badge" src="https://github.com/mayconfmelo/nexus-tools/actions/workflows/plugin.yml/badge.svg" /></a>
</p>
</div>


## Brief Showcase

```typ
#import "@preview/nexus-tools:0.3.0": *

#let size = default(when: size == 11pt, value: 12pt, true)
#content2str[ *Foo* #emph[Bar] Baz ]

#storage.namespace("name")
#storage.add("three", 3)
#storage.remove("three")
#context storage.get("three")
#context storage.final()
#storage.reset((:))

#comp.url("https://example.com")
#comp.pkg("https://repo.com/pkg-name")
#comp.callout(title: "Title", lorem(50))

#get.null
#get.auto-val(auto, "Replace auto")
#get.date(2026, 8, 18)
#get.date-diff("2000-01-01", "2026-08-18")
#get.relative-luminance(blue)
#get.dynamic-color(red)

#has.field([A B], "text")
#has.key((foo: 1), "foo")
#has.item((0, 1), 1)

#its.none-val(none)
#its.null(get.null)
#its.empty("")
#its.context-val(context())
#its.sequence[*A* _B_]
#its.space[ ]
#its.func([*Strong*], strong)
#its.type("String", str)
```

## Description

Gain development agility by using carefully curated, useful features, such as
data storage or custom defaults. This library was created as part of the
development of [my other Typst projects](https://typst.app/universe/search/?q=author%3A%22Maycon%20F.%20Melo%22);
it contains functionality shared across multiple projects that would otherwise
need to be maintained and updated individually, but is now centralized in a
single place. This is not intended to be a full-fledged development toolset
--- although someday it might end up becoming that ---, but rather a
compartmentalization of shared resources and a repository of potentially useful
development feature.


## Feature List

- Custom defaults that can be overridden by _set_ rules
- General data storage
  - Storage compartmentalization (namespaces)
  - Add, append, and remove data
  - Retrieve individual data or whole namespaces
  - Reset namespaces
- Visual components
  - Paper-friendly links (attached to footnotes)
  - General package URLs
  - Customizable callout box
- Get Typst values
  - Generate datetime using arguments, array, or dictionary
  - Calculate time between two dates
  - Null value
  - Replacement of auto values
  - Relative luminance of a color
  - Dynamic colors based on relative luminance
- Attribute checks
  - Content fields
  - Dictionary keys
  - Dictionary values
  - Array items
- Specific tests
  - None values
  - Null values
  - Empty values
  - Context values
  - Content sequences
  - Content spaces
  - Content functions
  - Any value types


### Internal Structure

![YAML module structure](https://raw.githubusercontent.com/mayconfmelo/nexus-tools/refs/tags/0.3.0/tests/representation/out/1.png)

This is a YAML representation of the package internal structure and all its
features.