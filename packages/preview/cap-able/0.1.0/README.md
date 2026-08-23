<p align="center">
  <strong>cap-able</strong><br>
  <em>Make it more able to caption — now that is cap-able</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-0.1.0-blue" alt="version: 0.1.0">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="license: MIT">
  <img src="https://img.shields.io/badge/typst-0.13.0+-orange" alt="minimum typst version: 0.13.0">
</p>

<p align="center">
  <a href="#english">English</a> | <a href="#中文">中文</a>
</p>

<p align="center">
  📖 <a href="https://github.com/SchrodingerBlume/typst-cap-able/releases/download/v0.1.0/doc-en.pdf">English Documentation</a> · 📖 <a href="https://github.com/SchrodingerBlume/typst-cap-able/releases/download/v0.1.0/doc-zh.pdf">中文文档</a>
</p>

---

## English

A comprehensive Typst package for creating professional three-line tables and figures with bilingual caption support, continued tables/figures, subfigures, and flexible customization options for academic documents.

### Features

- **Three-line tables** — Academic-standard tables (top, middle, bottom rules) with Markdown syntax
- **Bilingual captions** — Auto-formatted bilingual captions (Chinese/English, German/English, Spanish/English, etc.)
- **Continued tables/figures** — Multi-page tables and figures with automatic numbering
- **Subfigures** — Flexible multi-image grid layouts with overlay labels and subcaptions
- **Notes** — Auto-width-matched notes for tables and figures
- **Multilingual support** — 25+ languages including RTL languages and Traditional/Simplified Chinese
- **Unified configuration** — Configure both via `cap-style`, or override per-type with `captab-style` / `capfig-style`

### Quick Start

```typst
#import "@preview/cap-able:0.1.0": *

// Three-line table
#captab(
  caption: [Experimental Results],
)[
  | Parameter   | Value | Unit |
  | ----------- | ----- | ---- |
  | Temperature |  25   |  °C  |
  | Pressure    |   1   |  atm |
]

// Figure
#capfig(
  image("example.png", width: 50%),
  caption: [System Architecture],
)

// Bilingual caption
#set text(lang: "es")

#captab(
  caption: [Resultados experimentales],
  caption-en: [Experimental Results],
)[
  | A | B |
  | 1 | 2 |
]
```

### Configuration

```typst
// Unified configuration for both tables and figures
#show: cap-style.with(
  numbering-format: "1.1",
  use-chapter: true,
  caption-size: 10.5pt,
)

// Table-specific configuration
#show: captab-style.with(
  caption-above: 1.5em,
  body-size: 10.5pt,
)

// Figure-specific configuration
#show: capfig-style.with(
  label-mode: "overlay",
  label-style: "(a)",
)
```

### Documentation

Full documentation is available in this repository:

- [English Documentation (PDF)](https://github.com/SchrodingerBlume/typst-cap-able/releases/download/v0.1.0/doc-en.pdf)
- [Chinese Documentation (PDF)](https://github.com/SchrodingerBlume/typst-cap-able/releases/download/v0.1.0/doc-zh.pdf)

### License

MIT License — see [LICENSE](LICENSE) for details.

---

## 中文

一个功能全面的 Typst 包，用于创建专业的三线表和图片，支持双语标题、续表/续图、子图及灵活的自定义选项，适用于学术文档。

### 功能特性

- **三线表** — 符合学术规范的表格（顶线、中线、底线），支持 Markdown 语法
- **双语标题** — 自动格式化的双语标题（中英、德英、西英等）
- **续表/续图** — 跨页表格和图片，自动编号
- **子图** — 灵活的多图并排布局，支持覆盖标签和子标题
- **注释** — 自动匹配宽度的表注和图注
- **多语言支持** — 25+ 种语言，包括 RTL 语言及简繁中文区分
- **统一配置** — 通过 `cap-style` 统一配置，或使用 `captab-style` / `capfig-style` 分别覆盖

### 快速开始

```typst
#import "@preview/cap-able:0.1.0": *

// 三线表
#set text(lang: "zh")

#captab(
  caption: [实验结果],
  caption-en: [Experimental Results],
)[
  | 参数 | 数值 | 单位 |
  | ---- | ---- | ---- |
  | 温度 |  25  |  °C  |
  | 气压 |   1  |  atm |
]

// 图片
#capfig(
  image("example.png", width: 50%),
  caption: [系统架构],
  caption-en: [System Architecture],
)

// 子图
#capsubfig(
  (
    (content: image("a.png"), subcaption: [方案一]),
    (content: image("b.png"), subcaption: [方案二]),
  ),
  columns: 2,
  caption: [方案对比],
  caption-en: [Scheme Comparison],
)
```

### 配置

```typst
// 统一配置表格和图片
#show: cap-style.with(
  numbering-format: "1.1",
  use-chapter: true,
  caption-size: 10.5pt,
)

// 表格专用配置
#show: captab-style.with(
  caption-above: 1.5em,
  body-size: 10.5pt,
)

// 图片专用配置
#show: capfig-style.with(
  label-mode: "overlay",
  label-style: "(a)",
)
```

### 文档

完整文档见本仓库：

- [中文文档 (PDF)](https://github.com/SchrodingerBlume/typst-cap-able/releases/download/v0.1.0/doc-zh.pdf)
- [英文文档 (PDF)](https://github.com/SchrodingerBlume/typst-cap-able/releases/download/v0.1.0/doc-en.pdf)

### 许可

MIT 许可证 — 详见 [LICENSE](LICENSE)。
