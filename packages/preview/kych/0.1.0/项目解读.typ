// =============================================================================
// 跨越晨昏 项目全面解读
// =============================================================================
// 基于 Typst 实验性 HTML 导出功能的静态网站模板
// 结合 Tufte CSS 框架，实现具有宽页边距、优雅侧注和克制排版的响应式网页布局。
// =============================================================================

#import "@preview/ori:0.2.5": *
#set heading(numbering: numbly("{1:一}、", default: "1.1 "))
#set math.equation(numbering: "(1)")
#show: ori.with(
  title: "项目解读",          // [!code highlight]
  author: "跨越晨昏",            // [!code highlight]
  subject: "AI生成",   // [!code highlight]
  semester: "-",       // [!code highlight]
  date: datetime.today(),    // [!code highlight]
  // maketitle: true,
  // makeoutline: true,
  // theme: "dark",
  // media: "screen",
)

= 跨越晨昏 项目全面解读

*跨越晨昏* — 基于 Typst 实验性 HTML 导出功能的静态网站模板 \
结合 Tufte CSS 框架，实现具有宽页边距、优雅侧注和克制排版的响应式网页布局。

#outline( indent: 2em, depth: 3, )

== 1. 项目概述

跨越晨昏 是一个 *Typst 包 (package)*，也是一个 *项目模板 (template)*。用户通过 `typst init @preview/kych:0.1.1` 命令初始化一个网站项目，获得完整的内容结构和构建工具链。

=== 核心特性

#table(
  columns: (auto, auto),
  align: (left, left),
  table.header(
    [*特性*], [*说明*],
  ),
  [*Tufte 风格排版*], [宽页边距、侧注、全宽内容、克制的字体大小],
  [*响应式布局*], [宽屏时侧注浮动在右边距，窄屏（≤760px）时内联显示],
  [*HTML 语义化*], [使用 `article`、`section`、`figure`、`nav` 等语义化标签],
  [*数学公式支持*], [行内/块级公式自动包装为语义化 HTML，深色模式自动反色],
  [*脚注→侧注转换*], [Typst 标准脚注自动转为 Tufte 风格边注，带双向导航链接],
  [*Markdown 嵌入*], [通过 cmarker 包将外部 `.md` 文件渲染为页面内容],
  [*BibTeX 文献*], [支持 `#bibliography()` 命令加载 BibTeX 格式的参考文献],
  [*零依赖构建*], [除 `make` 和 `typst` 外无需任何外部依赖],
  [*PDF 导出*], [同一份 `.typ` 源文件可编译为 HTML 网站或 PDF 文档],
  [*GitHub Pages 部署*], [一键配置 GitHub Actions 自动部署],
)

=== 技术栈

```text
Typst 0.14+ (.typ 源码)
  └── HTML 导出 (实验性 --features html)
       ├── Tufte CSS 1.8.0 (CDN 加载，基础排版框架)
       ├── kych.css (跨越晨昏 项目自定义样式)
       └── custom.css (用户覆盖样式)

构建工具:
  └── GNU Make (跨平台构建系统)
```

== 2. 项目架构

```text
KYCH/                              # 项目根目录 (= 包根目录)
│
├── typst.toml                     # 📋 包清单：元数据、入口点、模板配置
├── Makefile                       # 🔧 项目级构建：符号链接、打包、调用子构建
├── README.md                      # 📖 项目说明
├── LICENSE                        # 📜 MIT 许可证
│
├── assets/                        # 🖼 包级资源（Typst Universe 缩略图等）
│   ├── thumbnail.png              #    模板缩略图（在 typst.toml 中引用）
│   └── devices.webp               #    项目截图
│
├── src/                           # 📦 核心包源码（6 个 .typ 模块）
│   ├── kych.typ                 #    ⭐ 主入口 + 主模板函数 kych-web()
│   ├── layout.typ                 #    布局辅助：margin-note(), full-width()
│   ├── math.typ                   #    数学公式渲染规则
│   ├── notes.typ                  #    脚注 → 侧注转换规则
│   ├── refs.typ                   #    交叉引用渲染规则
│   └── figures.typ                #    图表标题渲染规则
│
└── template/                      # 👤 用户项目模板（typst init 时复制）
    ├── config.typ                 #    用户配置入口（导航、标题、CSS）
    ├── Makefile                   #    网站构建系统（.typ → .html）
    ├── README.md                  #    模板说明（与根 README 相同）
    │
    ├── assets/                    #    静态资源
    │   ├── kych.css             #       跨越晨昏 自定义样式（核心 CSS）
    │   ├── custom.css             #       用户自定义样式（初始为空）
    │   └── devices.webp           #       设备截图
    │
    └── content/                   #    网站内容（.typ 源文件）
        ├── index.typ              #       首页（嵌入 README.md）
        ├── imgs/                  #       首页图片
        │   ├── kych-duck-female-with-duckling.webp
        │   └── kych-duck-male.webp
        ├── blog/                  #       博客
        │   ├── index.typ          #          博客列表页
        │   ├── 2024-10-04-iterators-generators/index.typ  # 文章1
        │   ├── 2025-04-16-monkeys-apes/index.typ           # 文章2
        │   └── 2025-10-30-normal-distribution/index.typ    # 文章3
        ├── cv/                    #       简历
        │   └── index.typ          #          简历页（含 BibTeX 著作列表）
        └── docs/                  #       文档
            ├── index.typ          #          文档目录
            ├── 01-quick-start/index.typ      # 快速入门
            ├── 02-configuration/index.typ    # 配置指南
            ├── 03-styling/index.typ          # 样式自定义
            ├── 04-deploy/index.typ           # 部署指南
            └── embedding-markdown/index.typ  # Markdown 嵌入
```

=== 模块依赖关系

```text
                          kych.typ (主入口)
                          │
          ┌───────────────┼───────────────┐
          │               │               │
     layout.typ       math.typ         notes.typ
          │
     figures.typ
          │
       refs.typ
```

- `kych.typ` 导入所有子模块并协调它们
- `layout.typ` 是最底层的基础模块，被 `figures.typ` 依赖
- 各模块通过 `show` 规则独立工作，互不干扰

== 3. 核心源码详解

=== 3.1 包入口 — `typst.toml`

```toml
[package]
name = "kych"
version = "0.1.1"
entrypoint = "src/kych.typ"
compiler = "0.14.0"          # 需要 Typst 0.14+

[template]
path = "template"             # 模板目录
entrypoint = "config.typ"     # 用户配置入口
thumbnail = "assets/thumbnail.png"
```

*关键设计*：
- `entrypoint = "src/kych.typ"` 是包的导入入口，用户 `#import "@preview/kych:0.1.1"` 时加载此文件
- `template.entrypoint = "config.typ"` 是模板初始化入口，`typst init` 后用户首先看到此文件
- `compiler = "0.14.0"` 因为 HTML 导出是 Typst 0.14+ 的实验性功能

=== 3.2 主模板 — `src/kych.typ`

这是整个包的*核心入口文件*，定义了两个关键组件：

==== `make-header(links)` — 导航栏生成器

```typst
#let make-header(links) = html.header(
  if links != none {
    html.nav(
      for (href, title) in links {
        html.a(href: href, title)
      },
    )
  },
)
```

- 接受 `(href, title)` 元组数组
- 生成 `header > nav > a` HTML 结构
- `links = none` 时不渲染导航栏

==== `kych-web()` — 主模板函数

*参数签名*：

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  table.header(
    [*参数*], [*默认值*], [*说明*],
  ),
  [`header-links`], [`none`], [导航栏链接列表],
  [`title`], [`"跨越晨昏"`], [页面标题 (`<title>`)],
  [`lang`], [`"en"`], [页面语言 (`<html lang>`)],
  [`css`], [`(CDN, kych, custom)`], [CSS 样式表列表],
  [`content`], [(必需)], [页面主体内容],
)

*执行流程*：

```text
1. 应用 show 规则 (template-math, template-refs, template-notes, template-figures)
2. 设置文本语言 (set text(lang: lang))
3. 构建 HTML 文档:
   ┌─ html.html(lang)
   │  ├─ html.head
   │  │  ├─ meta charset="utf-8"
   │  │  ├─ meta viewport (响应式)
   │  │  ├─ title
   │  │  └─ for css-link → link rel="stylesheet"
   │  └─ html.body
   │     ├─ header (导航栏)
   │     └─ article > section (主内容)
```

*CSS 加载顺序*（优先级从低到高）：
+ `tufte.min.css` — Tufte CSS 框架基础
+ `kych.css` — 跨越晨昏 项目增强样式
+ `custom.css` — 用户自定义覆盖（最高优先级）

=== 3.3 布局辅助 — `src/layout.typ`

提供两个 Tufte 风格核心布局元素：

==== `margin-note(content)`

```typst
#let margin-note(content) = {
  html.span(class: "marginnote", content)
}
```

- 生成 `span class="marginnote"` HTML 元素
- *宽屏*：通过 Tufte CSS 的 `float: right` + 负 `margin-right` 定位到右侧边距
- *窄屏* (`≤760px`)：`display: block; float: none; position: static` 内联显示
- 内容可以是文本、图片、公式等任意 Typst 内容

==== `full-width(content)`

```typst
#let full-width(content) = {
  html.div(class: "fullwidth", content)
}
```

- 生成 `div class="fullwidth"` HTML 元素
- 跨越正文区和边距区，适合展示大图、宽表格
- *注意*：此功能标记为 TODO，实现受限

=== 3.4 数学公式 — `src/math.typ`

定义数学公式在 HTML 输出中的渲染规则：

```text
行内公式 (block: false)  →  span role="math"
  例：段落中的 $x^2 + y^2 = z^2$

块级公式 (block: true)   →  figure role="math"
  例：独占一行的 $ x^2 + y^2 = z^2 $
```

*关键实现细节*：

```typst
#let template-math(content) = {
  set math.equation(numbering: "(1)")  // 公式编号格式

  show math.equation.where(block: false): it => {
    if target() == "html" {
      html.span(role: "math", html.frame(it))
    } else { it }  // PDF 等非 HTML 输出保持默认
  }

  show math.equation.where(block: true): it => {
    if target() == "html" {
      html.figure(role: "math", html.frame(it))
    } else { it }
  }
  content
}
```

*为什么用 `html.frame()`？*
- 提供独立的渲染边界
- 确保公式 SVG/HTML 被正确封装在 DOM 中
- `role="math"` 属性提供 ARIA 语义化信息，方便 CSS 和 JS 选择

*CSS 配合*（`kych.css`）：
- `figure[role="math"]` 放大到 `1.4em` 提高可读性
- 深色模式自动应用 `filter: invert(1) hue-rotate(180deg)` 反转颜色

=== 3.5 脚注转换 — `src/notes.typ`

这是 跨越晨昏 *最精妙的设计*之一，将 Typst 标准脚注转换为 Tufte 侧注系统。

==== HTML 结构示意

```html
<!-- 正文中的数字引用标记 -->
<sup class="footnote-ref">
  <a id="fnref-1" href="#fn-1" class="footnote-ref-link">1</a>
</sup>

<!-- 边距中的完整注释内容 -->
<span class="marginnote" id="fn-1">
  <sup><a href="#fnref-1" class="footnote-ref-link">1</a></sup>
  注释内容正文...
</span>
```

==== 关键实现

```typst
show footnote: it => {
  if target() == "html" {
    let number = counter(footnote).display(it.numbering)
    let fn-id = "fn-" + number    // 侧注容器 ID
    let ref-id = "fnref-" + number // 引用标记 ID

    // 正文中的上标数字链接
    html.sup(class: "footnote-ref", html.a(
      class: "footnote-ref-link",
      href: "#" + fn-id,   // 点击跳转到侧注
      id: ref-id,           // 接收反向跳转
      number,
    ))

    // 边距中的完整注释（含返回链接）
    html.span(class: "marginnote", id: fn-id,
      html.sup(html.a(class: "footnote-ref-link", href: "#" + ref-id, number))
      + [ ] + it.body,
    )
  }
}
```

*双向导航*：
- 点击正文中的 `¹` → 页面滚动到侧注 `fn-1`
- 点击侧注中的 `¹` → 页面滚动回正文 `fnref-1`
- 通过 HTML 锚点 `id` + `href` 实现，无需 JavaScript

*CSS 悬停联动*（详见 §7.4）：
- 悬停引用标记 → 对应侧注高亮
- 悬停侧注 → 对应引用标记高亮
- 使用 CSS `:has()` 伪类和 `--highlight` 自定义属性

=== 3.6 交叉引用 — `src/refs.typ`

自定义 Typst `@reference` 引用的 HTML 输出格式：

```text
@eq-label    →  link → "(1)"            (可点击公式编号)
@sec-label   →  smartquote + "标题"     (带智能引号的标题)
@fig-label   →  默认行为                (保持 Typst 默认)
```

*公式引用处理*：

```typst
if el != none and el.func() == eq {
  return link(el.location(), numbering(
    el.numbering,
    ..counter(eq).at(el.location()),
  ))
}
```

- `el.location()` — 公式在文档中的位置（用于生成超链接锚点）
- `el.numbering` — 公式编号格式（如 `"(1)"`）
- `counter(eq).at(el.location())` — 该公式的实际计数值
- `numbering()` 将格式 + 计数值合并，生成 `"(1)"` 字符串
- `link()` 将编号变成可点击的超链接

=== 3.7 图表处理 — `src/figures.typ`

将图表标题从正文底部移到页面边距中（Tufte 风格）。

==== 标题渲染

```typst
show figure.caption: it => html.span(
  class: "marginnote",
  it.supplement + sym.space.nobreak
    + it.counter.display() + it.separator + it.body,
)
```

最终输出示例：`图 1: 正态分布曲线`

- `it.supplement` = 图表类型前缀 ("图" / "Fig.")
- `it.counter.display()` = 编号 ("1")
- `it.separator` = 分隔符 (": ")
- `it.body` = 标题文字

==== 子元素重排

```typst
show figure: it => if target() == "html" {
  html.figure({
    it.caption   // 先输出标题 → 出现在侧注位置
    it.body      // 再输出图片 → 作为正文内容
  })
}
```

*为什么先输出标题？*
- 标题在 DOM 中先出现，带有 `class="marginnote"`
- Tufte CSS 通过 `float: right` 将其定位到右侧边距
- 图片作为正文内容正常排列

== 4. 构建系统

=== 4.1 项目级 Makefile

位于项目根目录，用于包开发和发布：

```makefile
VERSION := $(shell grep '^version = ' typst.toml | sed 's/version = "\(.*\)"/\1/')
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
```

#table(
  columns: (auto, auto),
  align: (left, left),
  table.header(
    [*目标*], [*说明*],
  ),
  [`link`], [创建符号链接到 Typst 包缓存，使编译器能通过 `@preview/kych` 引用本地开发版],
  [`link-macos`], [macOS 符号链接：`~/Library/Caches/typst/packages/preview/kych/{VERSION}`],
  [`link-linux`], [Linux 符号链接：`~/.cache/typst/packages/preview/kych/{VERSION}`],
  [`link-windows`], [Windows 符号链接（TODO: 未充分测试）],
  [`sync-assets`], [将 `template/assets/` 的资源同步到根 `assets/`],
  [`html`], [`link` + 调用 `template/Makefile html` 构建网站],
  [`build`], [`sync-assets` + `clean` + 打包为 `kych-{VERSION}.zip`],
  [`check`], [运行 `typst-package-check` 检查包格式],
  [`clean`], [删除 `_site/` 和 `.DS_Store`],
)

*符号链接原理*：

```text
typst init 时，编译器在包缓存中查找:
  ~/Library/Caches/typst/packages/preview/kych/0.1.1/

通过符号链接:
  该路径 → 项目根目录

结果:
  修改本地源码 → 无需重新安装 → 模板立即可用
```

=== 4.2 模板级 Makefile

位于 `template/` 目录，用于将 Typst 源码编译为 HTML 网站：

```makefile
TYP_FILES  := $(shell find content -name '*.typ' -not -path '*/_*')
HTML_FILES := $(patsubst content/%.typ,_site/%.html,$(TYP_FILES))
```

*构建流程*：

```text
content/index.typ              →  _site/index.html
content/blog/index.typ         →  _site/blog/index.html
content/blog/2024-10-04...typ  →  _site/blog/2024-10-04-iterators-generators/index.html
content/cv/index.typ           →  _site/cv/index.html
content/docs/index.typ         →  _site/docs/index.html
...

assets/*                       →  _site/assets/* (直接复制)
```

*关键路径映射规则*：
- `content/` → `_site/`
- `*.typ` → `*.html`
- 以下划线 `_` 开头的文件/目录被排除（约定为私有文件）

*Typst 编译参数*：
```bash
typst compile --root .. --features html --format html $< $@
```
- `--root ..` — 设包根目录为 template/ 的父目录（使 `@preview/kych` 能够被解析）
- `--features html` — 启用 HTML 导出（实验性功能）
- `--format html` — 输出 HTML 格式

== 5. 模板层

=== 5.1 用户配置 — `config.typ`

```typst
#import "@preview/kych:0.1.1"

#let template = kych.kych-web.with(
  header-links: (
    "/": "Home",
    "/docs/": "Docs",
    "/blog/": "Blog",
    "/cv/": "CV",
  ),
  title: "跨越晨昏",
)
```

*`.with()` 方法的工作原理*：
- `kych.kych-web` 是完整的主模板函数
- `.with()` 预设部分参数，返回一个只接受剩余参数的新函数 `template`
- 用户在内容文件中使用 `#show: template` 即可应用所有预设配置
- 子页面可以通过 `template.with(title: "Blog")` 进一步覆盖参数

=== 5.2 CSS 样式表

==== `kych.css` — 核心样式文件

#table(
  columns: (auto, auto),
  align: (left, left),
  table.header(
    [*区块*], [*功能*],
  ),
  [*CSS 变量*], [`--highlight-weak`, `--highlight-strong`, `--radius-sm`],
  [*基础样式*], [`font-size: 10pt`, `max-height: 80vh` 限制图片],
  [*响应式布局*], [`@media (max-width: 760px)` — 侧注内联、图片限宽、连字符],
  [*导航栏*], [Flexbox 布局、悬停高亮、去除 Tufte CSS 默认链接样式],
  [*脚注联动*], [`--highlight` 变量 + `:has()` 伪类实现悬停联动高亮],
  [*数学公式*], [`figure[role="math"]` 放大、深色模式反转],
  [*文章磁贴*], [`.post-tile` 卡片式布局],
)

==== `custom.css` — 用户自定义样式

```css
/* 修改此文件以添加您自己的自定义样式 */
```

- 初始为空文件
- 因为在 CSS 列表中最后加载，所以可以覆盖所有之前的样式
- 用户在这里添加个性化样式，不会影响模板升级

== 6. 示例内容

=== 6.1 首页 (`content/index.typ`)

展示了 跨越晨昏 的核心用法：

+ *侧注图片*：
  ```typst
  #kych.margin-note({
    image("imgs/kych-duck-female-with-duckling.webp")
    image("imgs/kych-duck-male.webp")
  })
  ```

+ *侧注文字*：凤头潜鸭科普内容

+ *Markdown 嵌入*：
  ```typst
  let md-content = read("../README.md")
  md-content = md-content.trim(regex("\s*#.+?\n"))  // 移除一级标题
  cmarker.render(md-content, scope: (...))
  ```
  读取 `README.md` 并渲染为页面内容，通过 `scope` 参数自定义图片路径

=== 6.2 博客文章

三篇博客文章分别演示了不同特性：

#table(
  columns: (auto, auto),
  align: (left, left),
  table.header(
    [*文章*], [*演示特性*],
  ),
  [*Iterators vs Generators*], [脚注→侧注、Python 代码块、`figure` 插图],
  [*Monkeys vs Apes*], [`margin-note` 图片、脚注链],
  [*Normal Distribution*], [行内公式 `$mu$`、块级公式 PDF、`@citation` 引用、`#bibliography()` 参考文献、lilaq 绘图],
)

=== 6.3 简历页 (`content/cv/index.typ`)

以 Edward R. Tufte 为例展示简历布局：

- 使用 `margin-note` 放置个人信息卡片
- 侧注图片 + 图片说明
- 使用 `citegeist` 包从 `.bib` 文件加载著作和论文列表
- 侧注与正文内容交错排列

=== 6.4 文档页 (`content/docs/`)

#table(
  columns: (auto, auto),
  align: (left, left),
  table.header(
    [*文档*], [*内容*],
  ),
  [`01-quick-start`], [安装和构建流程],
  [`02-configuration`], [项目结构、API、配置、页面继承],
  [`03-styling`], [默认样式表、自定义样式、完全覆盖],
  [`04-deploy`], [GitHub Actions + GitHub Pages 部署],
  [`embedding-markdown`], [cmarker + mitex 嵌入 Markdown],
)

== 7. 核心技术原理

=== 7.1 HTML 导出机制

```text
用户编写的 .typ 文件
         │
         ▼
  Typst 编译器 (--features html --format html)
         │
         ├──▶ 解析 Typst 语法 → AST
         ├──▶ 应用 show 规则 → 重写元素
         ├──▶ 遍历文档树 → 生成 HTML 元素
         └──▶ 序列化输出 → .html 文件
```

*关键约束*：
- HTML 导出是 Typst 0.14+ 的*实验性功能*
- 需要显式开启 `--features html`
- 使用 `html.*` 函数族（`html.html`, `html.head`, `html.body`, `html.span`, `html.div` 等）构造 HTML 元素
- `target() == "html"` 用于条件判断，确保 PDF 输出不受影响

=== 7.2 Show 规则体系

跨越晨昏 通过 4 个 show 规则覆盖 Typst 的默认渲染行为：

```text
用户内容 (Typst 语法)
    │
    ├─▶ show: template-math     → 拦截 math.equation
    │      ├─ 行内公式 → span role="math"
    │      └─ 块级公式 → figure role="math"
    │
    ├─▶ show: template-refs     → 拦截 ref
    │      ├─ 公式引用 → link(编号)
    │      └─ 标题引用 → smartquote(标题)
    │
    ├─▶ show: template-notes    → 拦截 footnote
    │      └─ 侧注结构 → sup 引用 + span class="marginnote" 注释
    │
    └─▶ show: template-figures  → 拦截 figure / figure.caption
           ├─ 标题 → span class="marginnote"
           └─ 图片 → figure{标题}{图片}
```

*Show 规则的特点*：
- 每个规则是一个函数，接受 `content` 并返回处理后的 `content`
- 规则在 `kych-web()` 的作用域内生效，不影响外部代码
- 通过 `target() == "html"` 只影响 HTML 输出，PDF 输出原样保留

=== 7.3 Tufte 侧注布局原理

*宽屏 (>760px) 布局*：

```text
┌────────────────────────────────────────────────────────┐
│                       article                         │
│  ┌─────────────────────────┐  ┌──────────────────────┐│
│  │      section            │  │     marginnote       ││
│  │     正文内容...         │  │  (float: right,      ││
│  │     正文内容...         │  │   margin-right: -50%) ││
│  │     正文内容...         │  │  侧注内容             ││
│  └─────────────────────────┘  └──────────────────────┘│
└────────────────────────────────────────────────────────┘
```

- `section` 占约 50% 宽度（正文区）
- `.marginnote` 通过 `float: right` + 负 `margin-right` 定位到右侧边距
- 这是 Tufte CSS 的核心布局技术

*窄屏 (≤760px) 布局*：

```text
┌──────────────────────┐
│      section         │
│     正文内容...       │
│     正文内容...       │
├──────────────────────┤
│     marginnote       │  ← display: block
│     (内联显示)       │     float: none
│                      │     width: 100%
└──────────────────────┘
```

- 侧注变为内联显示，带左侧缩进区分
- 图片限宽 `calc(760px / 3)`
- 段落启用自动连字符 `hyphens: auto`

=== 7.4 脚注-侧注双向高亮

跨越晨昏 使用了一个精巧的 CSS 技术实现脚注引用与侧注之间的悬停联动：

```css
/* 默认状态 */
.footnote-ref, .footnote-ref + .marginnote {
  --highlight: transparent;
  background-color: var(--highlight);
  box-shadow: 0 0 0 5px var(--highlight);
  transition: background-color 0.3s ease 1s, box-shadow 0.3s ease 1s;
  /* ↑ 1s 延迟，让高亮缓慢消退 */
}

/* 悬停引用 → 侧注高亮 */
.footnote-ref:hover + .marginnote {
  --highlight: var(--highlight-weak);
  transition-delay: 0s;  /* 立即响应 */
}

/* 悬停侧注 → 引用高亮 (CSS :has() 伪类) */
.footnote-ref:has(+ .marginnote:hover) {
  --highlight: var(--highlight-strong);
  transition-delay: 0s;
}
```

*技术亮点*：
- 使用 CSS 自定义属性 `--highlight` 作为灵活的高亮色变量
- `.footnote-ref:hover + .marginnote` — 相邻兄弟选择器（悬停引用 → 侧注）
- `.footnote-ref:has(+ .marginnote:hover)` — `:has()` 伪类（悬停侧注 → 引用，实现"前向选择"）
- `transition-delay: 1s` → 高亮缓慢消退，`0s` → 悬停立即响应

=== 7.5 深色模式处理

数学公式在 Typst HTML 导出中渲染为 SVG（白底黑字），在深色模式下需要反色：

```css
@media (prefers-color-scheme: dark) {
  [role="math"] {
    filter: invert(1) hue-rotate(180deg);
  }
}
```

*原理*：

```text
原始公式 SVG (白底黑字)
  ┌─────────────────┐
  │  f(x) = x²      │  ← 白色背景 + 黑色文字
  └─────────────────┘
         │
         ▼  filter: invert(1)
  ┌─────────────────┐
  │  f(x) = x²      │  ← 黑色背景 + 白色文字 (色相偏移)
  └─────────────────┘
         │
         ▼  hue-rotate(180deg)
  ┌─────────────────┐
  │  f(x) = x²      │  ← 深色背景 + 正常颜色文字
  └─────────────────┘
```

- `invert(1)` 将 RGB 全部反转 → 黑白互换，彩色倒置
- `hue-rotate(180deg)` 将色相旋转回原位 → 彩色恢复正常
- 组合效果：深色背景上的公式保持正常文字颜色

=== 7.6 页面层级继承

跨越晨昏 采用文件系统层级作为页面继承结构：

```text
config.typ  (根配置)
    │
    ├── content/index.typ  →  #import "../config.typ"
    │       │
    │       ├── content/blog/index.typ  →  #import "../index.typ"
    │       │       │
    │       │       └── content/blog/.../index.typ  →  #import "../index.typ"
    │       │
    │       ├── content/cv/index.typ  →  #import "../index.typ"
    │       │
    │       └── content/docs/index.typ  →  #import "../index.typ"
    │               │
    │               ├── content/docs/01-quick-start/index.typ
    │               ├── content/docs/02-configuration/index.typ
    │               ├── content/docs/03-styling/index.typ
    │               ├── content/docs/04-deploy/index.typ
    │               └── content/docs/embedding-markdown/index.typ
```

*继承规则*：
- 根页面 `content/index.typ` 从 `../config.typ` 导入 `template`
- 子页面从父级的 `../index.typ` 导入
- 任何层级可以通过 `template.with()` 覆盖参数
- 下级页面自动继承上级的参数覆盖

== 8. 数据流与渲染管道

```text
                    用户内容 (.typ 文件)
                           │
                           ▼
                  ┌─────────────────┐
                  │  #show: template │  ← config.typ 中的预设模板
                  └────────┬────────┘
                           │
                           ▼
                  ┌─────────────────┐
                  │  kych-web()   │  ← src/kych.typ
                  │  ┌─────────────┐│
                  │  │ show 规则    ││
                  │  │ ├─ math     ││  ← src/math.typ
                  │  │ ├─ refs     ││  ← src/refs.typ
                  │  │ ├─ notes    ││  ← src/notes.typ
                  │  │ └─ figures  ││  ← src/figures.typ
                  │  ├─────────────┤│
                  │  │ set text    ││
                  │  ├─────────────┤│
                  │  │ html.html   ││
                  │  │ ├─ head     ││  ← title, meta, css links
                  │  │ └─ body     ││
                  │  │    ├─ nav   ││  ← make-header()
                  │  │    └─ article││
                  │  │       └─ section│
                  │  └─────────────┘│
                  └────────┬────────┘
                           │
                           ▼
               Typst HTML 导出编译器
                           │
                           ▼
                  ┌─────────────────┐
                  │   .html 文件    │  ← _site/
                  │   + CSS 样式    │  ← _site/assets/
                  └─────────────────┘
```

*渲染顺序*：
+ 用户内容传递给 `kych-web()` 函数
+ 4 个 show 规则依次应用，重写特定元素
+ `set text(lang: lang)` 设置文档语言
+ `html.html()` 构建完整的 HTML DOM 结构
+ Typst 编译器将 Typst DOM 序列化为 HTML 字符串
+ 浏览器加载 HTML + CSS，Tufte CSS 完成最终布局

== 9. 关键设计决策与权衡

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  table.header(
    [*决策*], [*优势*], [*代价/限制*],
  ),
  [*Typst HTML 导出*], [零 JavaScript、语义化 HTML、类型安全], [实验性功能、功能受限],
  [*Tufte CSS via CDN*], [成熟稳定、社区维护、开箱即用], [依赖外部 CDN（离线不可用）],
  [*Makefile 构建系统*], [零额外依赖、跨平台], [不如现代打包工具灵活],
  [*脚注→侧注转换*], [Tufte 风格完整性], [侧注过长时可能溢出边距],
  [*SVG 公式渲染*], [高质量矢量、可缩放], [深色模式需要 hack（CSS filter）],
  [*文件系统层级继承*], [直观、无需配置], [深层嵌套时路径复杂],
  [*symbolic link 开发模式*], [即时生效、无需发布], [需要手动运行 `make link`],
)

== 10. 扩展开发指南

=== 添加新的 Show 规则

```typst
// 在 src/ 下创建新模块，例如 src/code.typ
#let template-code(content) = {
  show raw.where(lang: "python"): it => {
    if target() == "html" {
      html.pre(html.code(class: "language-python", it.text))
    }
  }
  content
}

// 在 src/kych.typ 中导入并应用
#import "code.typ": template-code
show: template-code
```

=== 添加自定义 CSS 变量

```css
/* template/assets/custom.css */
:root {
  --my-accent: #e74c3c;
  --my-font-mono: "JetBrains Mono", monospace;
}
```

=== 添加新的内容类型页面

```text
template/content/
  └── gallery/
       └── index.typ  ← 新页面
```

```typst
// gallery/index.typ
#import "../index.typ": template, kych
#show: template

= Photo Gallery

#kych.full-width({
  // 全宽图片画廊
  image("img1.webp")
  image("img2.webp")
})
```

=== 自定义导航链接

```typst
// config.typ
#let template = kych.kych-web.with(
  header-links: (
    "/": "首页",
    "/blog/": "博客",
    "/gallery/": "画廊",
    "/about/": "关于",
  ),
  title: "我的网站",
  lang: "zh",  // 中文语言
)
```

== 文件修改统计

#table(
  columns: (auto, auto),
  align: (left, left),
  table.header(
    [*文件*], [*变更类型*],
  ),
  [`typst.toml`], [添加配置说明注释],
  [`src/kych.typ`], [添加主模板详细注释],
  [`src/layout.typ`], [添加布局函数注释],
  [`src/math.typ`], [添加公式渲染注释],
  [`src/notes.typ`], [添加脚注转换注释],
  [`src/refs.typ`], [添加交叉引用注释],
  [`src/figures.typ`], [添加图表处理注释],
  [`Makefile`], [添加构建系统注释],
  [`template/config.typ`], [添加用户配置注释],
  [`template/Makefile`], [添加网站构建注释],
  [`template/assets/kych.css`], [添加完整 CSS 注释],
  [`template/assets/custom.css`], [添加样式说明],
  [`template/content/index.typ`], [添加首页说明],
  [`template/content/blog/*.typ`], [添加博客文章注释],
  [`template/content/cv/index.typ`], [添加简历页注释],
  [`template/content/docs/*.typ`], [添加文档页注释],
)

*跨越晨昏* 精心地将 Typst 的类型安全文档编写体验与 Tufte CSS 的优雅排版风格相结合，证明了一个新的可能性：*用学术排版工具的思维来构建网页*。