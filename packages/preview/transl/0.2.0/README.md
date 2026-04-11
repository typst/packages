# Translator

<div align="center">

<p class="hidden">
Easy and simple translations with support for localization
</p>

<p class="hidden">
  <a href="https://typst.app/universe/package/transl">
    <img src="https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Ftransl&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE&labelColor=%23353c44" /></a>
  <a href="https://github.com/mayconfmelo/transl/tree/dev/">
    <img src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fmayconfmelo%2Ftransl%2Frefs%2Fheads%2Fdev%2Ftypst.toml&query=%24.package.version&logo=github&label=Development&logoColor=%2397978e&color=%23239DAE&labelColor=%23353c44" /></a>
</p>

[![Manual](https://img.shields.io/badge/Manual-%23353c44)](https://raw.githubusercontent.com/mayconfmelo/transl/refs/tags/0.2.0/docs/manual.pdf)
[![Tips](https://img.shields.io/badge/Tips-%23353c44)](https://github.com/mayconfmelo/transl/discussions/categories/tips)
[![Example PDF](https://img.shields.io/badge/Example-.pdf-%23777?labelColor=%23353c44)](https://raw.githubusercontent.com/mayconfmelo/transl/refs/tags/0.2.0/docs/example.pdf)
[![Example SRC](https://img.shields.io/badge/Example-.typ-%23777?labelColor=%23353c44)](https://github.com/mayconfmelo/transl/blob/0.2.0/docs/example/main.typ)
[![Changelog](https://img.shields.io/badge/Changelog-%23353c44)](https://github.com/mayconfmelo/transl/blob/main/docs/changelog.md)
[![Contribute](https://img.shields.io/badge/Contribute-%23353c44)](https://github.com/mayconfmelo/transl/blob/main/docs/contributing.md)


<p class="hidden">
  <a href="https://github.com/mayconfmelo/transl/actions/workflows/tests.yml">
    <img alt="Tests" src="https://github.com/mayconfmelo/transl/actions/workflows/tests.yml/badge.svg" /></a>
  <a href="https://github.com/mayconfmelo/transl/actions/workflows/build.yml">
    <img alt="Build" src="https://github.com/mayconfmelo/transl/actions/workflows/build.yml/badge.svg" /></a>
  <a href="https://github.com/mayconfmelo/transl/actions/workflows/spellcheck.yml">
    <img alt="Spellcheck" src="https://github.com/mayconfmelo/transl/actions/workflows/spellcheck.yml/badge.svg" /></a>
</p>
</div>


## Quick Start

```typ
#import "@preview/transl:0.2.0": transl
#set text(lang: "es")

#transl(data: yaml("database.yaml"))

#transl("I love you")

#show: transl.with("love")
```


## Description

Get comprehensive and localized translations, with support for regular
expressions and [Fluent](https://projectfluent.org/) files. This package
comes with only one `#transl` command used to both set the translation database
and retrieve translations. 

The expressions are the texts to be translated; they can be words, phrases, or
regular expression strings. Multiple expressions can be used in a single command,
where each one will be retrieved and concatenated (separated by space).


## Feature List

- Automatic translation to `#text.lang` language
- Support for `#text.region`
- Language id notation (lang-REGION)
- Robust translation formats
  - YAML/TOML (multilingual)
  - Fluent markup (single language)
  - YAML/TOML + Fluent (multilingual)
- Support for `#show` rules
- Regular expressions
- Multiple ways to obtain values
  - Retrieve opaque `#context()` values
  - Retrieve context-dependent strings
  - Retrieve plain strings
- Localization arguments
  - Standard databases (basic)
  - Fluent databases


## Translation databases
The command needs to be fed with translation database files to function correctly.
These databases can be written in YAML/TOML and/or Fluent each.


#### Standard databases
```yaml
l10n: std
lang:
  expression: Translation
```

Allows to define translations for expressions in various languages. Set as:
```typst
#transl(data: yaml("std.yaml"))
```


#### Fluent databases
```yaml
l10n: ftl
lang: |
  identifier = Translation
```

Allows to define multiple Fluent files (as strings) with translations for
various languages. Set as:
```typst
#transl(data: yaml("ftl.yaml"))
```


#### Fluent files
```fluent
identifier = Translation
```

Allows to define an individual Fluent file with translations for a single language.
Set as:
```typst
#transl(data: read("xy.ftl"), lang: "xy")
```


---------------

Although written from scratch, the conceptual structure of the package is
heavily inspired by the [linguify](https://www.typst.app/universe/package/linguify)
package; the Fluent WASM plugin was derived from this excellent package.