<p align="center">
  <strong>jurlstify</strong><br>
  <em>URL typesetting with line-break opportunities — the url package port for Typst</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-0.3.0-blue" alt="version: 0.3.0">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="license: MIT">
  <img src="https://img.shields.io/badge/typst-0.13.0+-orange" alt="minimum typst version: 0.13.0">
  <a href="https://github.com/SchrodingerBlume/typst-jurlstify/blob/34ff560e631aab8fe8ef22decda7b1d7e7c91e70/0.3.0/manual/manual.pdf"><img src="https://img.shields.io/badge/📖_manual-PDF-blueviolet" alt="manual (PDF)"></a>
</p>

<p align="center">
  <a href="#english">English</a> | <a href="#中文">中文</a>
</p>

---

## English

A Typst package that ports the line-breaking logic of LaTeX's [`url` package](https://ctan.org/pkg/url) to Typst. Typst breaks bare URLs only at a fixed, non-configurable set of characters: a URL that contains none of them overflows the margin, and the available break points can produce uneven word spacing in justified paragraphs. This package inserts break opportunities at a configurable set of characters, and can add further breaks at a fixed interval inside long runs.

By default it breaks only at delimiter characters and shows no hyphen, matching the `url` package — the copy-safe default (a shown hyphen could be mistaken for part of the URL).

📖 **Full API reference:** the [manual (PDF)](https://github.com/SchrodingerBlume/typst-jurlstify/blob/34ff560e631aab8fe8ef22decda7b1d7e7c91e70/0.3.0/manual/manual.pdf), rendered from [`manual/manual.typ`](https://github.com/SchrodingerBlume/typst-jurlstify/blob/34ff560e631aab8fe8ef22decda7b1d7e7c91e70/0.3.0/manual/manual.typ).

### Features

- **Configurable break classes** — `url`-package-compatible defaults (`/`, `?`, `&`, `.`, `#`, …), overridable per call
- **Literal-hyphen & long-run control** — `break-at-literal-hyphens`, plus `extra-break-every` for runs with no delimiter
- **Two hyphen-display switches** — show a `-` at delimiter breaks and/or at the extra breaks, independently (both off by default)
- **Space handling** — `show-spaces-as`: `"nbsp"` / `"normal"` / `none`
- **Font inheritance & stretch** — `font: auto` inherits the body font; `stretch` aligns URL-only lines to the right margin
- **Three usage modes** — `jurlstify()`, the `jurl()` link wrapper, and the `jurlstify-links()` show rule

### Quick Start

```typ
#import "@preview/jurlstify:0.3.0": jurlstify, jurl, jurlstify-links

// Render a URL string with break opportunities
#jurlstify("https://example.com/very/long/path?query=value&more=stuff")

// Clickable link — same breaking, wrapped in link()
#jurl("https://example.com/very/long/path?query=value")

// Apply automatically to every link() in the document
#show: jurlstify-links.with()
#link("https://example.com/automatically/handled")
```

### Options at a glance

| Group | Parameters |
|---|---|
| Where a line may break | `break-chars`, `big-break-chars`, `no-break-chars`, `break-at-literal-hyphens`, `extra-break-every` |
| Show a hyphen at a break | `show-hyphens-after-delimiters`, `show-hyphens-at-extra-breaks` |
| Other | `show-spaces-as`, `stretch`, `font`, `size`, `fill` |

See the [manual](https://github.com/SchrodingerBlume/typst-jurlstify/blob/34ff560e631aab8fe8ef22decda7b1d7e7c91e70/0.3.0/manual/manual.pdf) for every parameter's type, default, and description. The three default character sets are exported as `break-chars-default` / `big-break-chars-default` / `no-break-chars-default` for extending.

### Migration (0.2.x → 0.3.0)

| 0.2.x | 0.3.0 |
|---|---|
| `hyphens` | `break-at-literal-hyphens` |
| `every` | `extra-break-every` |
| `breaks` / `big-breaks` / `no-breaks` | `break-chars` / `big-break-chars` / `no-break-chars` |
| `show-hyphen` (global) | `show-hyphens-after-delimiters` + `show-hyphens-at-extra-breaks` |
| `spaces: "nobreak"/"break"/"strip"` | `show-spaces-as: "nbsp"/"normal"/none` |
| `stretch` `font` `size` `fill` | unchanged |

Old code keeps working by pinning `@preview/jurlstify:0.2.1`.

### License

MIT — see [LICENSE](LICENSE).

---

## 中文

一个把 LaTeX [`url` 宏包](https://ctan.org/pkg/url) 的换行逻辑移植到 Typst 的包。Typst 只在一组固定、不可配置的字符处断开裸 URL:不含这些字符的 URL 会溢出页边距,而可用的断点在两端对齐段落中可能导致词间距不均。本包在一组可配置的字符处插入换行机会,并可在长串内部按固定间隔补充断点。

默认情况下,本包只在分隔符处断行、不显示连字符,与 `url` 宏包一致——这是可安全复制的默认行为(显示连字符可能被误认为是 URL 的一部分)。

📖 **完整 API 参考:** 见[手册 PDF](https://github.com/SchrodingerBlume/typst-jurlstify/blob/34ff560e631aab8fe8ef22decda7b1d7e7c91e70/0.3.0/manual/manual.pdf),由 [`manual/manual.typ`](https://github.com/SchrodingerBlume/typst-jurlstify/blob/34ff560e631aab8fe8ef22decda7b1d7e7c91e70/0.3.0/manual/manual.typ) 渲染。

### 功能特性

- **可配置断点类** — 与 `url` 宏包兼容的默认值(`/`、`?`、`&`、`.`、`#` 等),每次调用可覆盖
- **真实连字符与长串控制** — `break-at-literal-hyphens`,以及给无分隔符长串兜底的 `extra-break-every`
- **两个连字符显示开关** — 独立控制分隔符断点和额外断点换行时是否显示 `-`(默认都关)
- **空格处理** — `show-spaces-as`:`"nbsp"` / `"normal"` / `none`
- **字体继承与拉伸** — `font: auto` 继承正文字体;`stretch` 让纯 URL 行对齐右边距
- **三种使用方式** — `jurlstify()`、超链接包装器 `jurl()`、`jurlstify-links()` show rule

### 快速上手

```typ
#import "@preview/jurlstify:0.3.0": jurlstify, jurl, jurlstify-links

// 渲染带换行机会的 URL 字符串
#jurlstify("https://example.com/very/long/path?query=value&more=stuff")

// 可点击超链接,同样支持换行
#jurl("https://example.com/very/long/path?query=value")

// 全局 show rule:让文档中所有 link() 自动使用
#show: jurlstify-links.with()
#link("https://example.com/automatically/handled")
```

### 参数一览

| 分组 | 参数 |
|---|---|
| 哪里允许断行 | `break-chars`、`big-break-chars`、`no-break-chars`、`break-at-literal-hyphens`、`extra-break-every` |
| 断点处显不显 `-` | `show-hyphens-after-delimiters`、`show-hyphens-at-extra-breaks` |
| 其余 | `show-spaces-as`、`stretch`、`font`、`size`、`fill` |

每个参数的类型、默认值、说明见[手册](https://github.com/SchrodingerBlume/typst-jurlstify/blob/34ff560e631aab8fe8ef22decda7b1d7e7c91e70/0.3.0/manual/manual.pdf)。三个默认字符集导出为 `break-chars-default` / `big-break-chars-default` / `no-break-chars-default`,可用于扩展。

### 迁移(0.2.x → 0.3.0)

| 0.2.x | 0.3.0 |
|---|---|
| `hyphens` | `break-at-literal-hyphens` |
| `every` | `extra-break-every` |
| `breaks` / `big-breaks` / `no-breaks` | `break-chars` / `big-break-chars` / `no-break-chars` |
| `show-hyphen`(全局) | `show-hyphens-after-delimiters` + `show-hyphens-at-extra-breaks` |
| `spaces: "nobreak"/"break"/"strip"` | `show-spaces-as: "nbsp"/"normal"/none` |
| `stretch` `font` `size` `fill` | 不变 |

旧代码只要锁定 `@preview/jurlstify:0.2.1` 即可继续使用。

### 许可

MIT —— 详见 [LICENSE](LICENSE)。
