# SDU-Touying-Simpl 使用文档 / Usage Documentation

[中文](#中文) | [English](#english)

---

# 中文

## 目录

- [快速开始](#快速开始)
- [主题配置](#主题配置)
- [幻灯片类型](#幻灯片类型)
- [配色系统](#配色系统)
- [定理环境](#定理环境)
- [代码高亮](#代码高亮)
- [布局组件](#布局组件)
- [渐进式显示](#渐进式显示)

---

## 快速开始

```bash
typst init @preview/sdu-touying-simpl:1.0.1
```

```typst
#import "@preview/sdu-touying-simpl:1.0.1": *

#show: sdu-theme.with(
  config-info(
    title: [演示文稿标题],
    subtitle: [副标题],
    author: [作者姓名],
    institution: [山东大学],
    date: datetime.today(),
    logo: sdu-logo,
  ),
)

#title-slide()
#outline-slide([目录])

= 第一章
== 第一页
内容...
```

---

## 主题配置

`#show: sdu-theme.with(...)` 参数：

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `aspect-ratio` | string | `"16-9"` | 画幅比例：`"16-9"` 或 `"4-3"` |
| `variant` | string | `"light"` | 配色变体：`"light"` 或 `"dark"` |
| `primary` | color | `none` | 自定义主色调，自动派生浅色变体 |
| `header` | function | 当前标题 | 页眉内容函数 |
| `footer-a` | function | 作者 | 页脚左侧内容 |
| `footer-b` | function | 标题 | 页脚中间内容 |
| `footer-c` | function | 页码 | 页脚右侧内容 |
| `background` | string / none | `"img/background.png"` | 背景水印图片路径，设为 `none` 关闭 |
| `background-opacity` | float | `0.4` | 背景图片可见度，`0.0` 全透，`1.0` 不透明 |

所有 [Touying 配置函数](https://touying-typ.github.io/docs/config)（`config-info`、`config-common`、`config-page` 等）均可通过 `..args` 透传。

### config-info

```typst
config-info(
  title: [主标题],
  subtitle: [副标题],
  short-title: [短标题],     // 可选，页脚显示
  author: [作者],
  institution: [机构],
  date: datetime.today(),
  logo: sdu-logo,            // 可选，标题页左上角
)
```

---

## 幻灯片类型

### 标题页 / Title Slide

```typst
#title-slide()
```

显示校徽、标题图片、标题/副标题/作者/机构/日期。

### 目录页 / Outline Slide

```typst
#outline-slide([目录])
#outline-slide([Contents], column: 3, marker: sym.circle.filled)
```

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `title` | content | `[Outline]` | 目录标题 |
| `column` | int | `2` | 列数 |
| `marker` | auto / image / symbol | `auto` | 目录项标记 |

### 内容页 / Content Slide

```typst
#slide[
  左栏内容
][
  右栏内容
]
```

自动显示进度条页眉和当前章节标题。支持多栏。

### 章节页 / Section Slide

```typst
#new-section-slide[章节名称]
```

### 聚焦页 / Focus Slide

```typst
#focus-slide[重点内容]
```

全屏主色背景 + 白色大字。

### 矩阵页 / Matrix Slide

```typst
#matrix-slide[左上][右上][左下][右下]
#matrix-slide(columns: 2)[A][B][C][D]
```

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `columns` | int / array | 自动 | 列数或列宽比例 |
| `rows` | int / array | 自动 | 行数或行高比例 |

### 结束页 / Ending Slide

```typst
#ending-slide[
  #align(center + horizon)[
    #text(size: 3em, weight: "bold", sdu-red)[THANK YOU]
  ]
]
```

---

## 配色系统

### 颜色变量

8 个语义化颜色变量，可通过 `self.colors.xxx` 在回调中访问：

| 变量 | 亮色默认值 | 说明 |
|------|-----------|------|
| `primary` | `#880000` | 主色调 |
| `primary-light` | `primary.lighten(40%)` | 主色浅化 |
| `secondary` | `#2c3e50` | 辅助色 |
| `neutral-lightest` | `#ffffff` | 最浅中性色（背景） |
| `neutral-light` | `#f0f0f0` | 浅中性色 |
| `neutral-dark` | `#666666` | 深中性色 |
| `neutral-darkest` | `#000000` | 最深中性色（正文） |
| `accent` | `#e67e22` | 点缀色 |

### 亮色 / 暗色模式

```typst
#show: sdu-theme.with(variant: "dark", ...)
```

### 自定义主色调

传入 `primary` 后 `primary-light` 自动派生：

```typst
#show: sdu-theme.with(primary: rgb("#1a5276"), ...)  // 蓝色主题
#show: sdu-theme.with(primary: rgb("#27ae60"), ...)  // 绿色主题
```

导出常量：`sdu-red` = `#880000`，`sdu-logo` = 山东大学校徽。

---

## 定理环境

6 种定理环境，自动编号，带主题色样式。

| 函数 | 签名 | 编号 | 说明 |
|------|------|------|------|
| `sdu-theorem` | `(title: none, body)` | 有 | 定理 |
| `sdu-definition` | `(title: none, body)` | 有 | 定义 |
| `sdu-lemma` | `(title: none, body)` | 有 | 引理 |
| `sdu-corollary` | `(title: none, body)` | 有 | 推论 |
| `sdu-proof` | `(body)` | 无 | 证明（末尾 QED） |
| `sdu-example` | `(body)` | 无 | 示例 |

```typst
#sdu-theorem(title: "欧几里得")[素数有无穷多个。]
#sdu-definition[大于 1 且不能被更小自然数乘积表示的自然数。]
#sdu-lemma[任意两个素数互素。]
#sdu-corollary[素数集合是无限集。]
#sdu-proof[假设素数有限... 矛盾。 #qedhere]
#sdu-example[最小的素数：$2, 3, 5, 7, 11$。]
```

视觉样式：
- **定理/引理/推论**：浅主色底 + 左侧 3pt 主色竖线
- **定义**：更浅底色 + 左侧浅化主色竖线
- **证明**：无背景，末尾 QED 符号
- **示例**：橙色系底色 + 左侧橙色竖线

---

## 代码高亮

基于 [Codly](https://typst.app/universe/package/codly)，自动集成。使用标准 `raw` block 即可。

````typst
```python
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)
```
````

自动获得：语法高亮、行号、语言标签栏、圆角卡片。

### 高亮特定行

````typst
#sdu-code(highlight-lines: (2, 4))[```rust
fn main() {
    let x = 42;      // 高亮
    let y = x + 1;
    println!("{y}"); // 高亮
}
```]
````

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `highlight-lines` | array | `none` | 高亮行号列表 |
| `highlight-color` | color | `primary.lighten(90%)` | 高亮颜色 |

---

## 布局组件

### 多栏布局

```typst
#sdu-columns(2)[左栏][右栏]
#sdu-columns(3, divider: true)[*一*][*二*][*三*]
```

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `n` | int | — | 列数 |
| `divider` | bool | `false` | 主色竖线分隔 |
| `primary` | color | `#880000` | 分隔线颜色 |

### 卡片组件

```typst
#sdu-card[卡片内容...]
#sdu-card(title: "标题")[带标题的卡片]
```

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `title` | content | `none` | 标题栏文字 |
| `body` | content | — | 卡片内容 |
| `primary` | color | `#880000` | 装饰色 |

### 高亮块

```typst
#sdu-highlight[*结论：* Typst 比 LaTeX 快 100 倍。]
```

浅主色底 + 左侧 3pt 主色竖线。

### 引用块

```typst
#sdu-quote(
  source: [Donald Knuth],
)[
  预测未来的最好方法是创造未来。
]
```

斜体引用文字 + 大号装饰引号 + 来源署名。

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `body` | content | — | 引用内容 |
| `source` | content | `none` | 来源/作者 |
| `primary` | color | `#880000` | 装饰色 |

### 表格样式

主题自动为表格应用样式：表头主色背景 + 白色粗体文字 + 浅色边框。直接使用标准 `table` 即可：

```typst
#table(
  columns: 3,
  [名称], [速度], [评价],
  [LaTeX], [慢], [经典],
  [Typst], [快], [现代],
)
```

---

## 渐进式显示

```typst
第一行。#pause
第二行。#pause
第三行。

#uncover("2-")[第 2 步起显示（保留空间）]
#only("3-")[第 3 步起显示（不保留空间）]
#alternatives[选项 A][选项 B][选项 C]
```

### 演讲者备注

```typst
#slide[观众看到的][#note[演讲者备注]]
```

启用讲义模式：`config-common(handout: true)`

---

## 依赖 / Dependencies

| 包名 | 版本 | 用途 |
|------|------|------|
| [Touying](https://typst.app/universe/package/touying) | 0.7.3 | 演示文稿框架 |
| [Octique](https://typst.app/universe/package/octique) | 0.1.1 | GitHub Octicons 图标 |
| [Codly](https://typst.app/universe/package/codly) | 1.3.0 | 代码语法高亮 |
| [Codly Languages](https://typst.app/universe/package/codly-languages) | 0.1.10 | 语言定义数据 |

---

# English

## Table of Contents

- [Quick Start](#quick-start)
- [Theme Configuration](#theme-configuration)
- [Slide Types](#slide-types)
- [Color System](#color-system)
- [Theorem Environments](#theorem-environments)
- [Code Highlighting](#code-highlighting)
- [Layout Components](#layout-components)
- [Progressive Display](#progressive-display)

---

## Quick Start

```bash
typst init @preview/sdu-touying-simpl:1.0.1
```

```typst
#import "@preview/sdu-touying-simpl:1.0.1": *

#show: sdu-theme.with(
  config-info(
    title: [Presentation Title],
    subtitle: [Subtitle],
    author: [Your Name],
    institution: [Shandong University],
    date: datetime.today(),
    logo: sdu-logo,
  ),
)

#title-slide()
#outline-slide([Contents])

= Chapter 1
== Page 1
Content...
```

---

## Theme Configuration

`#show: sdu-theme.with(...)` accepts:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `aspect-ratio` | string | `"16-9"` | Aspect ratio: `"16-9"` or `"4-3"` |
| `variant` | string | `"light"` | Color variant: `"light"` or `"dark"` |
| `primary` | color | `none` | Custom primary color (auto-derives light variant) |
| `header` | function | current title | Header content function |
| `footer-a` | function | author | Footer left content |
| `footer-b` | function | title | Footer center content |
| `footer-c` | function | page number | Footer right content |
| `background` | string / none | `"img/background.png"` | Background watermark image path, set to `none` to disable |
| `background-opacity` | float | `0.03` | Background image visibility, `0.0` fully transparent, `1.0` opaque |

All [Touying config functions](https://touying-typ.github.io/docs/config) (`config-info`, `config-common`, `config-page`, etc.) are passed through via `..args`.

### config-info

```typst
config-info(
  title: [Title],
  subtitle: [Subtitle],
  short-title: [Short],     // optional, shown in footer
  author: [Author],
  institution: [Institution],
  date: datetime.today(),
  logo: sdu-logo,            // optional, top-left on title slide
)
```

---

## Slide Types

### Title Slide

```typst
#title-slide()
```

Displays university crest, title image, title/subtitle/author/institution/date.

### Outline Slide

```typst
#outline-slide([Contents])
#outline-slide([Contents], column: 3, marker: sym.circle.filled)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | content | `[Outline]` | Outline title |
| `column` | int | `2` | Number of columns |
| `marker` | auto / image / symbol | `auto` | Outline item marker |

### Content Slide

```typst
#slide[Left column][Right column]
```

Automatically shows progress bar header and current section title. Supports multiple columns.

### Section Slide

```typst
#new-section-slide[Section Name]
```

### Focus Slide

```typst
#focus-slide[Key point]
```

Full-screen primary color background with large white text.

### Matrix Slide

```typst
#matrix-slide[Top-Left][Top-Right][Bottom-Left][Bottom-Right]
#matrix-slide(columns: 2)[A][B][C][D]
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `columns` | int / array | auto | Number of columns or column width ratios |
| `rows` | int / array | auto | Number of rows or row height ratios |

### Ending Slide

```typst
#ending-slide[
  #align(center + horizon)[
    #text(size: 3em, weight: "bold", sdu-red)[THANK YOU]
  ]
]
```

---

## Color System

### Color Variables

8 semantic color variables accessible via `self.colors.xxx` in callbacks:

| Variable | Light Default | Description |
|----------|---------------|-------------|
| `primary` | `#880000` | Primary color |
| `primary-light` | `primary.lighten(40%)` | Lightened primary |
| `secondary` | `#2c3e50` | Secondary color |
| `neutral-lightest` | `#ffffff` | Lightest neutral (background) |
| `neutral-light` | `#f0f0f0` | Light neutral |
| `neutral-dark` | `#666666` | Dark neutral |
| `neutral-darkest` | `#000000` | Darkest neutral (body text) |
| `accent` | `#e67e22` | Accent color |

### Light / Dark Mode

```typst
#show: sdu-theme.with(variant: "dark", ...)
```

### Custom Primary Color

Passing `primary` auto-derives `primary-light`:

```typst
#show: sdu-theme.with(primary: rgb("#1a5276"), ...)  // Blue theme
#show: sdu-theme.with(primary: rgb("#27ae60"), ...)  // Green theme
```

Exported constants: `sdu-red` = `#880000`, `sdu-logo` = SDU crest image.

---

## Theorem Environments

6 theorem environments with automatic numbering and themed styling.

| Function | Signature | Numbered | Description |
|----------|-----------|----------|-------------|
| `sdu-theorem` | `(title: none, body)` | Yes | Theorem |
| `sdu-definition` | `(title: none, body)` | Yes | Definition |
| `sdu-lemma` | `(title: none, body)` | Yes | Lemma |
| `sdu-corollary` | `(title: none, body)` | Yes | Corollary |
| `sdu-proof` | `(body)` | No | Proof (ends with QED symbol) |
| `sdu-example` | `(body)` | No | Example |

```typst
#sdu-theorem(title: "Euclid")[There are infinitely many primes.]
#sdu-definition[A natural number greater than 1 that cannot be expressed as a product of smaller naturals.]
#sdu-lemma[Any two primes are coprime.]
#sdu-corollary[The set of primes is infinite.]
#sdu-proof[Assume finitely many primes... contradiction. #qedhere]
#sdu-example[The smallest primes: $2, 3, 5, 7, 11$.]
```

Visual style:
- **Theorem/Lemma/Corollary**: Light primary fill + 3pt left primary stroke
- **Definition**: Lighter fill + lighter left stroke
- **Proof**: No background, QED symbol at end
- **Example**: Orange-tinted fill + orange left stroke

---

## Code Highlighting

Powered by [Codly](https://typst.app/universe/package/codly), auto-integrated. Use standard `raw` blocks.

````typst
```python
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)
```
````

Automatically provides: syntax highlighting, line numbers, language tag, rounded card container.

### Highlight Specific Lines

````typst
#sdu-code(highlight-lines: (2, 4))[```rust
fn main() {
    let x = 42;      // highlighted
    let y = x + 1;
    println!("{y}"); // highlighted
}
```]
````

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `highlight-lines` | array | `none` | Line numbers to highlight |
| `highlight-color` | color | `primary.lighten(90%)` | Highlight color |

---

## Layout Components

### Multi-Column Layout

```typst
#sdu-columns(2)[Left][Right]
#sdu-columns(3, divider: true)[*One*][*Two*][*Three*]
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `n` | int | — | Number of columns |
| `divider` | bool | `false` | Show primary-color vertical dividers |
| `primary` | color | `#880000` | Divider color |

### Card Component

```typst
#sdu-card[Card content...]
#sdu-card(title: "Title")[Card with title]
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | content | `none` | Title bar text |
| `body` | content | — | Card content |
| `primary` | color | `#880000` | Decorative color |

### Highlight Block

```typst
#sdu-highlight[*Conclusion:* Typst is 100x faster than LaTeX.]
```

Light primary fill + 3pt left primary stroke.

### Quote Block

```typst
#sdu-quote(
  source: [Donald Knuth],
)[
  The best way to predict the future is to invent it.
]
```

Italic quote text + large decorative quotation mark + source attribution.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `body` | content | — | Quote content |
| `source` | content | `none` | Source / author |
| `primary` | color | `#880000` | Decorative color |

### Table Styling

The theme automatically styles tables: primary-color header background + white bold text + light borders. Use standard `table` directly:

```typst
#table(
  columns: 3,
  [Name], [Speed], [Rating],
  [LaTeX], [Slow], [Classic],
  [Typst], [Fast], [Modern],
)
```

---

## Progressive Display

```typst
First line. #pause
Second line. #pause
Third line.

#uncover("2-")[Visible from step 2 (space preserved)]
#only("3-")[Visible from step 3 (no space)]
#alternatives[Option A][Option B][Option C]
```

### Speaker Notes

```typst
#slide[What the audience sees][#note[Speaker notes]]
```

Enable handout mode: `config-common(handout: true)`

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| [Touying](https://typst.app/universe/package/touying) | 0.7.3 | Presentation framework |
| [Octique](https://typst.app/universe/package/octique) | 0.1.1 | GitHub Octicons |
| [Codly](https://typst.app/universe/package/codly) | 1.3.0 | Code syntax highlighting |
| [Codly Languages](https://typst.app/universe/package/codly-languages) | 0.1.10 | Language definitions |
