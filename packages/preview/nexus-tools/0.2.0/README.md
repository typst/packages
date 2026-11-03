# Nexus Tools

<div align="center">

<p class="hidden">
  Easily implement and reuse tools and components across projects.
</p>

<p class="hidden">
  <a href="https://typst.app/universe/package/nexus-tools">
    <img alt="Typst Universe version" src="https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fnexus-tools&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE&labelColor=%23353c44" /></a>
  <a href="https://github.com/mayconfmelo/nexus-tools/tree/dev/">
    <img alt="GitHub development branch version" src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fmayconfmelo%2Fnexus-tools%2Frefs%2Fheads%2Fdev%2Ftypst.toml&query=%24.package.version&logo=github&label=Development&logoColor=%2397978e&color=%23239DAE&labelColor=%23353c44" /></a>
</p>

[![Read the manual](https://img.shields.io/badge/Manual-%23353c44)](https://raw.githubusercontent.com/mayconfmelo/nexus-tools/refs/tags/0.2.0/docs/manual.pdf)
[![Example PDF](https://img.shields.io/badge/Example-.pdf-%23777?labelColor=%23353c44)](https://raw.githubusercontent.com/mayconfmelo/nexus-tools/refs/tags/0.2.0/docs/example.pdf)
[![Example source code](https://img.shields.io/badge/Example-.typ-%23777?labelColor=%23353c44)](https://github.com/mayconfmelo/nexus-tools/blob/0.2.0/docs/assets/example.typ)
[![Changelog file](https://img.shields.io/badge/Changelog-%23353c44)](https://github.com/mayconfmelo/nexus-tools/blob/0.2.0/docs/changelog.md)
[![Contribute with development](https://img.shields.io/badge/Contribute-%23353c44)](https://github.com/mayconfmelo/nexus-tools/blob/0.2.0/docs/contributing.md)


<p class="hidden">
  <a href="https://github.com/mayconfmelo/nexus-tools/actions/workflows/tests.yml">
    <img alt="General tests badge" src="https://github.com/mayconfmelo/nexus-tools/actions/workflows/tests.yml/badge.svg" /></a>
  <a href="https://github.com/mayconfmelo/nexus-tools/actions/workflows/build.yml">
    <img alt="Build test badge" src="https://github.com/mayconfmelo/nexus-tools/actions/workflows/build.yml/badge.svg" /></a>
  <a href="https://github.com/mayconfmelo/nexus-tools/actions/workflows/spellcheck.yml">
    <img alt="Spellcheck test badge" src="https://github.com/mayconfmelo/nexus-tools/actions/workflows/spellcheck.yml/badge.svg" /></a>
</p>
</div>


## Quick Start

```typ
#import "@preview/nexus-tools:0.2.0": *
```

## Description

Easily implement handy features from a curated collection of frequently used
package functionality, such as data storage or custom defaults. This library was
created as part of the development of [my other Typst projects](https://typst.app/universe/search/?q=author%3A%22Maycon%20F.%20Melo%22);
it contains functionality shared across multiple projects that would otherwise
need to be maintained and updated individually, but is now centralized in a
single place. This is not intended to be a full-fledged development toolset, but
rather a compartmentalization of shared resources.

You can use this library without restrictions as a development aid, especially
for packages.


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
  - Generate datetime using positional and/or named arguments
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

![YAML module structure](https://raw.githubusercontent.com/mayconfmelo/nexus-tools/refs/tags/0.2.0/tests/representation/out/1.png)

This is a YAML representation of the package internal structure and all its
features.