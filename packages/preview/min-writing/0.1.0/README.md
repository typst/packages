# Minimal Writings

<div align="center">

<p class="hidden">
  Quick and simple general-purpose notes with extended syntax
</p>

<p class="hidden">
  <a href="https://typst.app/universe/package/min-writing">
    <img alt="Typst Universe version" src="https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fmin-writing&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE&labelColor=%23353c44" /></a>
  <a href="https://github.com/mayconfmelo/min-writing/tree/dev/">
    <img alt="GitHub development branch version" src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fmayconfmelo%2Fmin-writing%2Frefs%2Fheads%2Fdev%2Ftypst.toml&query=%24.package.version&logo=github&label=Development&logoColor=%2397978e&color=%23239DAE&labelColor=%23353c44" /></a>
</p>

[![Get Manual](https://img.shields.io/badge/Manual-%23353c44)](https://raw.githubusercontent.com/mayconfmelo/min-writing/refs/tags/0.1.0/docs/manual.pdf)
[![Example PDF](https://img.shields.io/badge/Example-.pdf-%23777?labelColor=%23353c44)](https://raw.githubusercontent.com/mayconfmelo/min-writing/refs/tags/0.1.0/docs/example.pdf)
[![Example source code](https://img.shields.io/badge/Example-.typ-%23777?labelColor=%23353c44)](https://github.com/mayconfmelo/min-writing/blob/0.1.0/template/main.typ)
[![Changelog file](https://img.shields.io/badge/Changelog-%23353c44)](https://github.com/mayconfmelo/min-writing/blob/0.1.0/docs/changelog.md)
[![Contribute with development](https://img.shields.io/badge/Contribute-%23353c44)](https://github.com/mayconfmelo/min-writing/blob/0.1.0/docs/contributing.md)

<p class="hidden">
  <a href="https://github.com/mayconfmelo/min-writing/actions/workflows/tests.yml">
    <img alt ="General tests badge" src="https://github.com/mayconfmelo/min-writing/actions/workflows/tests.yml/badge.svg"></a>
  <a href="https://github.com/mayconfmelo/min-writing/actions/workflows/build.yml">
    <img alt="Build test badge" src="https://github.com/mayconfmelo/min-writing/actions/workflows/build.yml/badge.svg"></a>
  <a href="https://github.com/mayconfmelo/min-writing/actions/workflows/spellcheck.yml">
    <img alt ="Spellcheck test badge" src="https://github.com/mayconfmelo/min-writing/actions/workflows/spellcheck.yml/badge.svg"></a>
</p>
</div>


## Quick Start

```typst
#import "@preview/min-writing:0.1.0": writing

#set document(
  title: "Title",
  author: "Author",
  description: "Description",
)

#show: writing

// Write typst with expanded syntax (see manual)
```


## Description
Create quick notes intuitively and rapidly, using syntactic sugar that extends the markup supported by Typst.
By default, new documents are created in quick-note mode—which ignores page breaks and optimizes the layout
for screens—though you can also select the classic paged mode.

This package was designed to make creating documents as easy as possible, without requiring extensive initial
configuration—in fact, you simply need to import the package and apply the `#show` rule to access its
features—yet it still offers various options for fine-tuning.


## Feature List

- Quick-note mode (no page breaks)
- Extended syntax sugar
  - Unnumbered headings
  - Highlighted texts
  - Boxed texts
  - Inline quotes
  - Block quotes
  - Tables
  - Paragraph breaks
  - Page breaks
  - Mermaid diagrams
  - Dividers
  - Check lists
- Additional commands
  - Boxed texts
  - Mermaid diagrams
  - Figures (with source)
- Catppuccin colors
- Embedded help page


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