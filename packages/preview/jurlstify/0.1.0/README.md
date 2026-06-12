<p align="center">
  <strong>jurlstify</strong><br>
  <em>URL typesetting with line-break opportunities — the url.sty port for Typst</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-0.1.0-blue" alt="version: 0.1.0">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="license: MIT">
  <img src="https://img.shields.io/badge/typst-0.13.0+-orange" alt="minimum typst version: 0.13.0">
</p>

<p align="center">
  <a href="#english">English</a> | <a href="#中文">中文</a>
</p>

---

## English

A Typst package that ports LaTeX's [`url.sty`](https://ctan.org/pkg/url) line-breaking logic. In justified paragraphs, bare URLs either overflow the margin or force ugly gaps into the surrounding text. jurlstify inserts break opportunities at the same character classes as `url.sty` (`/`, `?`, `&`, `:`, etc.) so Typst's line-breaker can wrap URLs naturally without touching word spacing elsewhere in the paragraph.

### Features

- **url.sty-compatible break classes** — breaks after `.` `/` `?` `&` `#` `:` and more, matching `\UrlBreaks` / `\UrlBigBreaks` / `\UrlNoBreaks`
- **Hyphen control** — breaks after `-` are suppressed by default (like url.sty); enable with `hyphens: true`
- **Font inheritance** — defaults to `auto` (inherits body font), avoiding the metric mismatch that monospace causes in CJK text
- **Stretch mode** — opt-in `stretch: true` lets URL-internal lines align to the right margin in justified paragraphs
- **Soft-hyphen fallback** — opt-in `every: N` inserts invisible soft hyphens every N chars within unbroken letter/digit runs, visible only when the line actually breaks there
- **Three usage modes** — standalone `jurlstify()`, hyperlink wrapper `jurl()`, and document-level show rule `jurlstify-links()`
- **Fully customisable** — override break character lists, font, size, color, and hyphen interval per call

### Quick Start

```typst
#import "@preview/jurlstify:0.1.0": jurlstify, jurl, jurlstify-links

// Render a URL string with break opportunities
#jurlstify("https://example.com/very/long/path?query=value&more=stuff#fragment")

// Clickable link — same breaking, wrapped in link()
#jurl("https://example.com/very/long/path?query=value&more=stuff#fragment")

// Apply automatically to every link() in the document
#show: jurlstify-links.with()
#link("https://example.com/automatically/handled")
```

### API Reference

#### `jurlstify(url, ..options)` — core function

Renders `url` as inline content with Unicode break opportunities at url.sty-compatible positions.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `url` | `str` | *(required)* | The URL string to render. |
| `hyphens` | `bool` | `false` | Allow line breaks after `-`. Mirrors url.sty's `hyphens` option. Off by default so `my-domain.com` never breaks mid-word. |
| `stretch` | `bool` | `false` | Make break points stretchable so URL-internal justified lines reach the right margin. Trade-off: small visible gaps may appear at break points. |
| `spaces` | `str` | `"nobreak"` | How to handle literal spaces inside a URL. `"nobreak"` → no-break space; `"break"` → ordinary breakable space; `"strip"` → discard. |
| `breaks` | `array` | *url.sty defaults* | Characters after which a break opportunity is inserted. |
| `big-breaks` | `array` | `(":",)` | Higher-priority break characters (`\UrlBigBreaks`). |
| `no-breaks` | `array` | `("(","[","{","<")` | Characters that suppress the break opportunity immediately before them (`\mathopen` class). |
| `font` | `auto` \| `str` \| `array` | `auto` | URL font. `auto` inherits the surrounding body font. Pass a name or array to override, e.g. a monospace stack. |
| `size` | `auto` \| `length` | `auto` | Font size. `auto` inherits from context. |
| `fill` | `auto` \| `color` | `auto` | Text color. `auto` inherits from context. |
| `every` | `none` \| `int` | `none` | Insert a soft hyphen (U+00AD) after every N consecutive non-break characters. The hyphen is invisible unless the line actually breaks there. Useful for URLs with long unbroken letter/digit runs. Disabled by default. |

```typst
// Inherit body font, break at / ? & : etc.
#jurlstify("https://example.com/path?a=1&b=2")

// Allow hyphen breaks
#jurlstify("https://my-very-long-sub-domain.example.org/path", hyphens: true)

// Justify URL-internal lines to the right margin
#jurlstify("https://example.com/long/path", stretch: true)

// Insert a soft hyphen every 8 chars in long unbroken runs
#jurlstify("https://example.com/averylongpathsegmentwithnobreaks", every: 8)

// Monospace font (classic url.sty look)
#jurlstify("https://example.com/path",
  font: ("DejaVu Sans Mono", "Menlo", "Consolas", "Courier New"))

// Custom color and size
#jurlstify("https://example.com/path", fill: blue, size: 9pt)
```

#### `jurl(dest, display: none, ..options)` — hyperlink wrapper

Renders a clickable hyperlink whose visible text is formatted by `jurlstify`. Accepts all the same keyword options.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `dest` | `str` | *(required)* | Link destination (URL). |
| `display` | `none` \| `str` \| content | `none` | Custom display. `none` → destination string formatted by `jurlstify`; string → also formatted by `jurlstify`; content → used as-is. |

```typst
#jurl("https://example.com/very/long/path")
#jurl("https://example.com/very/long/path", display: "example site")
#jurl("https://example.com/path", hyphens: true, fill: blue)
```

#### `jurlstify-links(..options, body)` — show-rule helper

Document-level show rule that makes every `#link("http://…")` (where body equals destination) automatically use `jurlstify`. Links with explicit display content (`#link(dest, "click here")`) are left untouched.

```typst
// Declare once near the top of your document
#show: jurlstify-links.with()

The homepage is #link("https://example.com/very/long/path").  // auto-formatted
See #link("https://example.com", "the docs") for details.     // untouched
```

Pass options to apply them document-wide:

```typst
#show: jurlstify-links.with(hyphens: true, fill: blue)
```

### Default Break Characters

| Parameter | Default characters |
|-----------|--------------------|
| `breaks` | `. @ \ / ! _ \| ; > ] ) , ? & ' + = #` |
| `big-breaks` | `:` |
| `no-breaks` | `( [ { <` |

### Notes on Justification

jurlstify inserts `U+200B` (ZERO WIDTH SPACE) at break positions — zero width, not stretchable, faithfully mirroring url.sty's zero-stretch muskips. A line consisting entirely of URL characters may end slightly short of the right margin.

Enable `stretch: true` for invisible-but-stretchable word spaces; the paragraph justifier will then align URL-only lines to the right margin at the cost of small visible gaps at break points.

Break quality depends on Typst's optimizer. jurlstify only inserts declarative markers; improvements to Typst's engine automatically improve output.

### License

MIT License — see [LICENSE](LICENSE) for details.

---

## 中文

将 LaTeX [`url.sty`](https://ctan.org/pkg/url) 的换行逻辑移植到 Typst 的排版包。在两端对齐的段落中，裸露的 URL 要么溢出页边距，要么迫使周围文字产生大块空白。jurlstify 在与 `url.sty` 相同的字符类（`/`、`?`、`&`、`:` 等）后插入换行机会，使 Typst 的断行器能在这些位置自然换行，而不影响段落其余部分的字间距。

### 功能特性

- **url.sty 兼容断点** — 在 `.` `/` `?` `&` `#` `:` 等字符处断行，对应 `\UrlBreaks` / `\UrlBigBreaks` / `\UrlNoBreaks`
- **连字符控制** — 默认抑制 `-` 处的换行（与 url.sty 一致）；可通过 `hyphens: true` 开启
- **字体继承** — 默认 `auto`，继承正文字体，避免等宽字体在中文段落中造成字距错位
- **拉伸模式** — 可选 `stretch: true`，让整行 URL 也能对齐两端对齐段落的右边距
- **软连字符兜底** — 可选 `every: N`，在连续字母/数字段每隔 N 个字符插入不可见的软连字符，仅在该处实际换行时才显示为 `-`
- **三种使用方式** — 独立函数 `jurlstify()`、超链接包装器 `jurl()`、文档级 show rule `jurlstify-links()`
- **完全可定制** — 可按需覆盖断点字符列表、字体、字号、颜色和软连字符间隔

### 快速上手

```typst
#import "@preview/jurlstify:0.1.0": jurlstify, jurl, jurlstify-links

// 渲染带换行机会的 URL 字符串
#jurlstify("https://example.com/very/long/path?query=value&more=stuff#fragment")

// 可点击超链接，同样支持换行
#jurl("https://example.com/very/long/path?query=value&more=stuff#fragment")

// 全局 show rule：让文档中所有 link() 自动使用 jurlstify
#show: jurlstify-links.with()
#link("https://example.com/automatically/handled")
```

### API 参考

#### `jurlstify(url, ..options)` — 核心函数

将 `url` 渲染为行内内容，在与 url.sty 兼容的位置插入 Unicode 换行机会。

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `url` | `str` | *必填* | 要渲染的 URL 字符串。 |
| `hyphens` | `bool` | `false` | 是否允许在 `-` 后换行。对应 url.sty 的 `hyphens` 选项。默认关闭，防止 `my-domain.com` 在单词中间断行。 |
| `stretch` | `bool` | `false` | 让换行点参与两端对齐的拉伸，使纯 URL 行也能对齐右边距。代价：这些行的换行点处可能出现小间隙。 |
| `spaces` | `str` | `"nobreak"` | URL 内部空格的处理方式。`"nobreak"` → 不换行空格；`"break"` → 普通可换行空格；`"strip"` → 删除空格。 |
| `breaks` | `array` | *url.sty 默认值* | 插入换行机会的字符列表。 |
| `big-breaks` | `array` | `(":",)` | 高优先级断点字符（对应 `\UrlBigBreaks`）。 |
| `no-breaks` | `array` | `("(","[","{","<")` | 禁止在其之前断行的字符（对应 `\mathopen` 类）。 |
| `font` | `auto` \| `str` \| `array` | `auto` | URL 字体。`auto` 继承正文字体（中文段落推荐）。传入字体名或数组可指定其他字体，例如等宽字体栈。 |
| `size` | `auto` \| `length` | `auto` | 字号。`auto` 继承上下文。 |
| `fill` | `auto` \| `color` | `auto` | 文字颜色。`auto` 继承上下文。 |
| `every` | `none` \| `int` | `none` | 在连续的非断点字符序列中每隔 N 个字符插入一个软连字符（U+00AD）。软连字符平时不可见，仅在该处实际换行时显示为 `-`。适用于含有长段字母/数字序列、缺乏自然断点的 URL。默认禁用。 |

```typst
// 继承正文字体，在 / ? & : 等处断行
#jurlstify("https://example.com/path?a=1&b=2")

// 允许连字符处断行
#jurlstify("https://my-very-long-sub-domain.example.org/path", hyphens: true)

// 使纯 URL 行对齐右边距
#jurlstify("https://example.com/long/path", stretch: true)

// 每隔 8 个字符插入软连字符，处理长段无断点路径
#jurlstify("https://example.com/averylongpathsegmentwithnobreaks", every: 8)

// 等宽字体（经典 url.sty 风格）
#jurlstify("https://example.com/path",
  font: ("DejaVu Sans Mono", "Menlo", "Consolas", "Courier New"))

// 自定义颜色与字号
#jurlstify("https://example.com/path", fill: blue, size: 9pt)
```

#### `jurl(dest, display: none, ..options)` — 超链接包装器

渲染可点击的超链接，可见文字由 `jurlstify` 格式化。支持与 `jurlstify` 相同的所有关键字选项。

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `dest` | `str` | *必填* | 链接目标（URL）。 |
| `display` | `none` \| `str` \| content | `none` | 自定义显示内容。`none` → 显示目标 URL 本身（经 `jurlstify` 格式化）；字符串 → 同样经 `jurlstify` 处理；content → 原样显示。 |

```typst
#jurl("https://example.com/very/long/path")
#jurl("https://example.com/very/long/path", display: "示例网站")
#jurl("https://example.com/path", hyphens: true, fill: blue)
```

#### `jurlstify-links(..options, body)` — show rule 辅助函数

文档级 show rule，让所有 body 与目标相同的 `#link("http://…")` 自动使用 `jurlstify` 断行。有显式显示内容的链接（如 `#link(dest, "点击这里")`）不受影响。

```typst
// 在文档顶部声明一次
#show: jurlstify-links.with()

项目主页为 #link("https://example.com/very/long/path")。   // 自动格式化
详见 #link("https://example.com", "文档")。                // 不受影响
```

全局传入选项：

```typst
#show: jurlstify-links.with(hyphens: true, fill: blue)
```

### 默认断点字符

| 参数 | 默认字符 |
|------|----------|
| `breaks` | `. @ \ / ! _ \| ; > ] ) , ? & ' + = #` |
| `big-breaks` | `:` |
| `no-breaks` | `( [ { <` |

### 关于两端对齐的说明

jurlstify 在断点位置插入 `U+200B`（零宽空格）——宽度为零且不可拉伸，忠实还原了 url.sty 的零伸缩粘连。因此，整行都是 URL 字符的行可能无法对齐右边距。

开启 `stretch: true` 可改为插入不可见但可拉伸的字间距，使段落排版器在纯 URL 行也能对齐右边距，代价是这些行的换行点处可能出现小间隙。

断行质量取决于 Typst 引擎的优化器。jurlstify 只插入声明式标记，Typst 引擎的改进会自动改善输出，无需修改本包。

### 许可

MIT 许可证 — 详见 [LICENSE](LICENSE)。
