# Typst Rewind Note Template

A Typst template for creating lifestyle social media style notes (similar to Xiaohongshu/RedNote).

<p align="center">
  <img src="assets/thumbnail-cover.png" alt="Preview Cover" width="45%" />
  <img src="assets/thumbnail-article.png" alt="Preview Article" width="45%" />
</p>

[English](https://github.com/Ri-Nai/typst-rewind-note/blob/main/README.md) | [中文](https://github.com/Ri-Nai/typst-rewind-note/blob/main/README_CN.md)

## Introduction

Typst Rewind Note is designed to help users quickly generate beautiful, lifestyle-style images or PDF documents using Typst. It provides preset themes, a cover generator, and layout styles optimized for mobile reading.

## Usage

### 1. Import Template

#### Method 1: From Typst Universe (After Publication)

```typst
#import "@preview/rewind-note:0.1.0": *
```

#### Method 2: Local Import

Clone the repository and import:

```bash
git clone https://github.com/Ri-Nai/typst-rednote.git
```

Then in your Typst file:

```typst
#import "path/to/typst-rednote/lib.typ": *
```

### 2. Apply Theme

Use `rewind-theme` function:

```typst
#show: rewind-theme.with(
  font-family: ("Source Han Serif SC", "Times New Roman"), // Custom font
  // bg-color: rgb("#fff0f0"),  // Custom background
)
```

### 3. Create Cover

Use `cover` function:

```typst
#cover(
  image-content: image("assets/brand.png"),
  title: [Your Title],
  subtitle: [Subtitle],
  author: "@YourName",
)
```

### 4. Write Content

Write your content as usual.

```typst
= What is Typst?

Typst is a new typesetting system...
```

## Example

Check `template/main.typ` for a full example.

## License

MIT
