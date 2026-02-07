# Minimal Manuals

<div align="center">

<p class="hidden">
  Modern yet sober manuals using Typst, Markdown, and documentation comments.
</p>


<p class="hidden">
  <a href="https://typst.app/universe/package/min-manual">
    <img src="https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fmin-manual&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE&labelColor=%23353c44" /></a>
  <a href="https://github.com/mayconfmelo/min-manual/tree/dev/">
    <img src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fmayconfmelo%2Fmin-manual%2Frefs%2Fheads%2Fdev%2Ftypst.toml&query=%24.package.version&logo=github&label=Development&logoColor=%2397978e&color=%23239DAE&labelColor=%23353c44" /></a>
</p>

[![Manual](https://img.shields.io/badge/Manual-%23353c44)](https://raw.githubusercontent.com/mayconfmelo/min-manual/refs/tags/0.3.0/docs/manual.pdf)
[![Example PDF](https://img.shields.io/badge/Example-PDF-%23777?labelColor=%23353c44)](https://raw.githubusercontent.com/mayconfmelo/min-manual/refs/tags/0.3.0/docs/example.pdf)
[![Example SRC](https://img.shields.io/badge/Example-SRC-%23777?labelColor=%23353c44)](https://github.com/mayconfmelo/min-manual/blob/0.3.0/template/manual.typ)
[![Changelog](https://img.shields.io/badge/Changelog-%23353c44)](https://github.com/mayconfmelo/min-manual/blob/main/docs/changelog.md)
[![Contribute](https://img.shields.io/badge/Contribute-%23353c44)](https://github.com/mayconfmelo/transl/blob/main/docs/contributing.md)

<p class="hidden">
  <a href="https://github.com/mayconfmelo/min-manual/actions/workflows/tests.yml">
    <img alt="Tests" src="https://github.com/mayconfmelo/min-manual/actions/workflows/tests.yml/badge.svg" /></a>
  <a href="https://github.com/mayconfmelo/min-manual/actions/workflows/build.yml">
    <img alt="Build" src="https://github.com/mayconfmelo/min-manual/actions/workflows/build.yml/badge.svg" /></a>
  <a href="https://github.com/mayconfmelo/min-manual/actions/workflows/spellcheck.yml">
    <img alt="Spellcheck" src="https://github.com/mayconfmelo/min-manual/actions/workflows/spellcheck.yml/badge.svg" /></a>
</p>
</div>


## Quick Start

```typst
#import "@preview/min-manual:0.3.0": manual
#show: manual.with(
  title: "Package Name",
  manifest: toml("typst.toml"),
)
```


## Description

Create modern and elegant manuals with a clean visual style and a focus on
maintaining attention on the document's content. This package seeks a balance
between new visual trends and the traditional simplicity of older manuals:
there are no abstract designs, colorful sections, diverse themes, or anything
that steals the focus; however, it adopts modern fonts, pleasant spacing, text
layout inspired by web pages, as well as automation tools and practical features.

This was created with Typst in mind, but also aiming for the potential to
universally document code from other languages: all the features of _min-book_
are supported when documenting any type of program or code.

## Feature List

- Universal documentation
  - Typst packages/templates
  - Any other language
- Retrieval of data from _typst.toml_ package manifest
- Documentation for arguments/options
- Extract code snippets from files
- Showcase code examples and its result
- Terminal simulation
- Customizable callout boxes
- Paper-friendly links (attached to footnotes)
- Quick repository reference
  - Typst Universe packages
  - PyPi packages
  - Rust crates
  - GitHub repositories
  - Any package URL
- Documentation retrieval from Markdown files
  - CommonMark Markdown
  - Typst code support
  - Access to _min-manual_ features (Typst mode)
- Documentation retrieval from source code comments
  - Typst code support
  - Access to _min-manual_ features
  - Special syntax for some _min-manual_ features


## Default Fonts

**Text:**
[TeX Gyre Heros](https://www.gust.org.pl/projects/e-foundry/tex-gyre/heros/qhv2.004otf.zip) or
Arial

**Headings:**
[TeX Gyre Adventor](https://www.gust.org.pl/projects/e-foundry/tex-gyre/adventor/qag2_501otf.zip) or 
Century Gothic

**Mono:**
[Fira Mono](https://fonts.google.com/specimen/Fira+Mono) or
[Inconsolata](https://fonts.google.com/specimen/Inconsolata)