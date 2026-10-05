# 地狱之下模板 · UnderHell Template

用于架空世界内容创作的 [Typst](https://typst.app) 模板——冒险模组、世界设定文档、角色卡片。
A [Typst](https://typst.app) template for worldbuilding — adventure modules, setting documents, character sheets.

**`@preview/underhell:0.6.1`** · Typst 0.15+ · MIT · [GitHub](https://github.com/kych-net/UnderHell) · [GitCode](https://gitcode.com/CrossDark/UnderHell)

---

> **关于本仓库 / About this repo**
>
> 本仓库是 [地狱之下 (UnderHell)](https://github.com/kych-net/UnderHell) 项目的文档模板子模块,在此同步维护并按需调整。
> This is the documentation-template submodule of the [UnderHell](https://github.com/kych-net/UnderHell) worldbuilding project.
>
> **出处与版权 / Origin & license**
>
> 本模板源自 [coljac/typst-dnd5e](https://github.com/coljac/typst-dnd5e)(即 Typst Universe 中的 `dragonling` 包),作者 Colin Jacobs,基于 MIT 协议发布。感谢原作者的工作。
> Derived from [coljac/typst-dnd5e](https://github.com/coljac/typst-dnd5e) (the `dragonling` package on Typst Universe) by Colin Jacobs, MIT. Thanks to the original author.

## 安装 · Installation

已发布至 Typst Universe,直接 import 即可。
Published on Typst Universe — just import it:

```typst
#import "@preview/underhell:0.6.1": *
```

_地狱之下_ 项目自身经 `配置.typ` 再导出(`#import "…/配置.typ": *`),不直接引模板。
The _UnderHell_ project itself re-exports the template through `配置.typ` instead of importing it directly.

本包兼容 Typst 0.15。
This package targets Typst 0.15+.

## 用模板起项目 · Start from the template

本包同时是模板(见 `typst.toml` 的 `[template]`)。`typst init` 会生成一个可直接编译的示例项目:根下 `配置.typ`(站点配置)、`Makefile` 与 `README.md`,`内容/` 下是分章的正文,`附件/` 下是元素系统数据,`脚本/` 下是单页入口与网页后处理。`内容/关于.typ` 用 `cmarker`(配 `mitex` 渲染公式)把 `README.md` 渲染进正文,演示导入 Markdown——图片经 `scope` 变成带题注的图表。`make web` 出多页站点:各页共用一份 `/assets/underhell.css`,定义在别页的元素自动连成跳转链接。
This package doubles as a template: `typst init` scaffolds a ready-to-build project — `配置.typ`, `Makefile` and `README.md` at the root, chapters under `内容/`, element-system data under `附件/`, and a single-page entry plus web post-processing under `脚本/`. `内容/关于.typ` renders `README.md` via `cmarker` (with `mitex` for math), demonstrating Markdown import — images go through `scope` into captioned figures. `make web` builds a multi-page site: every page shares one `/assets/underhell.css`, and elements defined on another page become links.

```sh
typst init @preview/underhell:0.6.1 我的设定集
cd 我的设定集
make pdf     # 内容/ 下每个 .typ → 一份 PDF(dist/) ; make web → HTML(内容/ 里已有的 .html 原样保留) ; make watch → 监听自动重编
```

直接调 typst 时须带 `--root .`——`内容/` 下的正文以 `../配置.typ` 引用根目录的配置。
When calling typst directly, pass `--root .` — chapters under `内容/` import the root config via `../配置.typ`:

```sh
typst compile --root . 内容/index.typ out.pdf
```

Universe 页面上的 “Create project in app” 按钮等价于同一操作。
The “Create project in app” button on the Universe page does the same.

## 快速开始 · Quick start

```typst
#import "@preview/underhell:0.6.1": *

#show: 地狱之下模板.with(
  title: "我的设定集",
  subtitle: "一个崭新的世界",
  author: "你的名字",
)

= 星球

#设定元素(level: 2)[天堂]

星球拥有一颗名为*天堂*的卫星,它是一颗生物卫星。
```

## 基本用法 · Basic usage

`地狱之下模板` 会为你初始化整篇文档。常用参数:
The `地狱之下模板` template initializes the document for you. Common options:

- `title` —— 文档标题,以文字形式渲染;封面图已含标题时可省略。

  Document title rendered as text. Omit if your cover image already shows the title.

- `subtitle` —— 封面底部的副标题/标语。

  Subtitle or tagline at the bottom of the cover.

- `author` —— 你的名字。

  Your name.

- `cover` —— 用于封面的 `image`。

  An `image` used for the cover.

- `fancy-author` —— 把作者名放进红色火焰装饰中。

  Puts the author name inside a red flame flourish.

- `logo` —— 提供 `image`,在首页放置 logo。

  An `image` to place a logo on the first page.

- `font-size` —— 默认 `12pt`。

  Default `12pt`.

- `paper` —— 默认(合理地)为 `a4`;美国用户可改用 `us-letter`。

  Defaults (sensibly) to `a4`; US users may want `us-letter`.

- `add-title` —— 是否在首页打印标题。若自制了封面图,可设为 `false`。

  Whether to print the title on the first page. Set `false` if you made your own cover image.

- `bg` —— 内容页背景:`"default"` 为羊皮纸(默认),`none` 为适合打印的白色背景,或传 `image(...)` 自定义。

  Content-page background: `"default"` (parchment), `none` for print-friendly white, or an `image(...)`.

- `lang` —— 用于 `属性框`、`人物框` 中本地化标签(Armor Class、Description 等)的双字母语言代码,默认 `"en"`。内置 `"it"`;可参照 `languages/en.toml` 新增 `languages/<code>.toml`。语言文件的 `[fonts]` 段配置字体:`body`(正文)、`header`(标题)、`italic`(斜体)。

  Two-letter language code for localized labels in `属性框` / `人物框`, default `"en"`. Ships with `"it"`; add your own as `languages/<code>.toml`. The `[fonts]` section configures `body`, `header`, `italic`.

- `元素系统` —— 元素系统名称(见下文)。默认取编译时 `--input 元素系统=xxx`,缺省 `"普通"`;显式传入可覆盖。

  Element-system name (see below). Defaults to the build-time `--input 元素系统=xxx`, falling back to `"普通"`.

- `元素系统数据` —— 元素系统数据文件的 `csv()` 读取结果(见下文)。

  The `csv()` result of the element-system data file (see below).

以下参数用于站点定制。其中 `品牌名` 与 `主题` 的 `标题色`/`强调色` 同时影响 PDF;默认值即 _地狱之下_ 项目自身的值,第三方使用时覆盖即可。
These options customize the site. `品牌名` and the theme's `标题色`/`强调色` also affect the PDF. Defaults are the _UnderHell_ project's own values — overwrite them for your site.

- `品牌名` —— `品牌` 函数打印的名字,默认 `"地狱之下"`。

  Name printed by the `品牌` helper. Default `"地狱之下"`.

- `页脚链接` —— 网页右上角导航链接数组,每项 `(标签: "PDF", 网址: "...", 提示: "...")`;`提示` 省略则用标签。

  Nav links for the web page: `(标签:, 网址:, 提示:)`; `提示` falls back to `标签`.

- `备案号` / `备案链接` —— 网页底部备案号与链接;`备案号` 设为 `""` 则不渲染页脚。

  ICP filing number and link at the page bottom; set `备案号` to `""` to omit the footer.

- `主题` —— 调色字典,可含 `标题色`、`强调色`(PDF 与网页共用)与 `纸色`、`墨色`(仅网页)。值为 Typst 颜色或 CSS 颜色字符串。

  Theme dict with `标题色`, `强调色` (PDF + web) and `纸色`, `墨色` (web only). Values are Typst colors or CSS color strings.

- `阅读器` —— 网页阅读器面板配置,见下文「网页输出」。

  Web reader-panel config, see “Web output” below.

```typst
#show: 地狱之下模板.with(
  title: "我的设定集",
  品牌名: "某大陆",
  页脚链接: ((标签: "主页", 网址: "https://example.com", 提示: "回到主页"),),
  备案号: "",
  主题: (标题色: rgb("#2b4a6f"), 强调色: rgb("#c8a24a"), 纸色: "#f6f4ef"),
  阅读器: (默认字号: 1, 字号: (("小", 0.9), ("中", 1), ("大", 1.15))),
)
```

## 便捷函数 · Helpers

之后几乎所有需求都可用基础 Typst 标记完成。模板另提供以下函数:
Almost everything else is plain Typst. The template also provides:

### 元素 · Elements

`元素(id, font: none)` —— 返回当前元素系统下的名词文本,**渲染为深红色**,默认使用标题字体(段宁毛笔小楷),可用 `font:` 覆盖。正文中不可用 `[` `]` 包裹。若该元素在文档中已有定义标题,自动变为指向该标题的链接;未定义时 PDF 编译给出 warning,HTML 输出(`--features html --input html=true`)渲染悬停"未定义"弹窗。

Returns the term for `id` under the current element system, **in dark red**, using the heading font by default (overridable via `font:`). Must not be wrapped in `[` `]` in running text. Links to the element's heading when one exists; otherwise warns in PDF and shows a hover "undefined" tooltip in HTML.

`设定元素(id, font: none, level: none)` —— 普通模式返回深红文本(同 `元素`,但不生成链接)。**传入 `level` 时进入"标题+锚点"模式**,生成带 `<名>` 标签的编号标题,可用 `@名` 交叉引用。文档中的章节标题即用此形式。

In normal mode returns dark-red text (like `元素`, but no link). **Passing `level` switches to “heading + anchor” mode**, producing a numbered heading labeled `<名>` and referenceable via `@名`. Section titles use this form.

`评论(body)` —— 以标题字体、**灰色**显示注释(默认无删除线);编译时传 `--input 隐藏评论=true` 可整体隐藏。

Shows a comment in the heading font, **in gray**. Pass `--input 隐藏评论=true` to hide all.

`品牌` —— 以小型大写字母打印品牌名(取自 `品牌名` 参数)。

Prints the brand name (from `品牌名`) in small caps.

### 版面 · Layout

`表格(name, columns: (1fr, 4fr), breakable: false, ..contents)` —— 常规格式表格。默认 2 列、比例 1:4;`breakable` 为 `true` 时可跨页拆分。

A regular formatted table. Defaults to 2 columns at 1:4; set `breakable` to `true` to split across pages.

`提示框(title, contents)` —— 带彩色背景的方框,可选标题以小型大写显示。

A colored-background box, with an optional small-caps title.

`属性框(stats)` —— 接受如下字典。`skillblock` 与 `traits` 可含任意键。traits 之后,若存在 `Actions`、`Reactions`、`Limited Usage`、`Equipment` 或 `Legendary Actions`,将依次显示。

Takes a dictionary in the format below. `skillblock` and `traits` may hold arbitrary keys. After traits, `Actions` / `Reactions` / `Limited Usage` / `Equipment` / `Legendary Actions` are shown in turn when present.

```typst
#属性框((
  name: "Creature name",
  description: [Size creature, alignment],
  ac: [20 (natural armor)],
  hp: [29 (1d10 + 33)],
  speed: [10ft, climb 10ft.],
  stats: (STR: 13, DEX: 14, CON: 18, INT: 5, WIS: 4, CHA: 7),  // 修正值自动计算
  skillblock: (
    Skills: [Perception +6, Stealth +5],
    Senses: [passive Perception 13],
    Languages: [Gnomish],
    Challenge: [5 (1800 XP)],
  ),
  traits: (
    ("Trait name", [Trait description]),
  ),
  actions: (
    ("Multiattack", [While the monster remains alive, it is a thorn in the party's side.]),
    ("Saliva", [If a character is eaten by the monster, it takes 1d10 saliva damage per round.]),
  ),
))
```

`人物框(npc)` —— 非玩家角色卡片。除 `name` 外所有字段可选,省略即跳过对应部分;属性使用与 `属性框` 相同的自动修正值表。

A non-player-character card. All fields except `name` are optional; stats use the same auto-calculated modifiers as `属性框`.

```typst
#人物框((
  name: "Old Maggie of the Marsh",
  race: [Human],
  class: [Hedge witch],
  alignment: [Chaotic Good],
  stats: (STR: 9, DEX: 11, CON: 10, INT: 15, WIS: 17, CHA: 13),
  description: [A wizened crone with bright, knowing eyes...],
  background: [Born and raised in the marsh village...],
  roleplay: [
    - Speaks in proverbs and riddles.
    - Always offers tea.
  ],
))
```

`法术` —— 接受如下字典,所有属性均可选。

Takes a dictionary; all fields are optional:

```typst
#法术((
  name: "",
  spell-type: [2nd level ...],
  properties: (
    ("Casting time", []),
    ("Range", []),
    ("Duration", []),
    ("Components", []),
  ),
  description: [Spell effects description],
))
```

### 页面元素 · Page elements

`顶部图` / `底部图` —— 把图片插入页面顶部/底部,横跨两栏,并抑制该页页脚。

`顶部图` / `底部图` place an image at the top/bottom of the page, spanning both columns, and suppress the page footer.

```typst
#底部图(image("swordtorn.png", width: 140%))
```

`附录(title: "附录", numbering-fmt: "A.1.", ..body)` —— 在文末生成附录章节,自动把标题编号切换为字母格式(附录 A,子标题 A.1、A.1.1……)并重置计数器,避免与正文编号冲突。

Generates an appendix at the end, switching heading numbering to letters (Appendix A, A.1, A.1.1 …) and resetting counters to avoid clashing with the body.

```typst
#附录[
  == 附录子标题
  附录正文内容...
]

// 也可 include 独立的附录文件 / or include a separate appendix file
#附录[
  #include "附录文件.typ"
]
```

`导入(路径, 偏移: 1)` —— 用 `#include` 引入另一个 `.typ` 文件,并整体增加其标题层级(默认 +1)。被引入文件自行 `#import` 所需函数,本函数不注入作用域、不解析文件文本。

Includes another `.typ` file via `#include` and deepens its heading levels with `set heading(offset:)` (default +1). The file does its own `#import`; this helper injects no scope and parses no text.

- `路径` —— 被引入文件的路径。模板版本以仓库根(`--root`)为基准,如 `"文档/内容/怪动植物.typ"`。

  Path of the file to include, relative to the repo root (`--root`).

- `偏移` —— 标题层级增量(必须非负,即只加深),默认 `1`。因此被引入文件应写得比最终层级浅一档(目标为 `===` 则源文件写 `==`)。

  Heading-level increment (non-negative), default `1`. Include files should be written one level shallower than the target.

```typst
#导入("文档/内容/怪动植物.typ")            // 全部标题层级 +1

#导入("文档/内容/附录.typ", 偏移: 2)       // 指定其他偏移量
```

> **注意** / Note
>
> `set heading(offset:)` 只取非负值,无法把标题变浅;需调整层级时改被引入文件的源码。
> `set heading(offset:)` only takes non-negative values; edit the source file to change levels.

## 标题样式 · Heading styles

模板对六级标题均有差异化样式。
All six heading levels are styled differently:

| 级别 Level | 样式 Style |
|------|------|
| `=` 一级 L1 | 小型大写、深红、1.5em · small caps, dark red, 1.5em |
| `==` 二级 L2 | 小型大写、深红、黄色下划线 · small caps, dark red, yellow underline |
| `===` 三级 L3 | 小型大写、深红、1.3em · small caps, dark red, 1.3em |
| `====` 四级 L4 | 深红、1.15em、黄色左色条 · dark red, 1.15em, yellow left bar |
| `=====` 五级 L5 | 左侧圆点(垂直居中)+ 深红斜体 · left dot (vertically centered) + dark-red italic |
| `======` 六级 L6 | 深红、0.95em、前置 `—` 符号 · dark red, 0.95em, preceding `—` |

打印模式下所有彩色装饰(下划线、色条、圆点)自动去除。
All colored decorations (underlines, bars, dots) are removed in print mode automatically.

## 元素系统 · Element system

元素系统让同一核心概念(如"黑白怪物")在不同设定版本中拥有不同叫法,便于同一份文档输出多种"世界观名词"。
The element system lets one core concept carry different terms under different settings, so a single document can output several sets of worldbuilding vocabulary.

**核心概念用"元素"标识**——即普通元素系统的名称(如 `怪动植物` 代表黑白怪物)。**普通元素系统直接读取 ID 的值本身**,因此它不是 CSV 的列。**所有元素系统集中存放在同一个 CSV 文件**(宽表:首行为各元素系统名,首列为元素 id,单元格为该元素在对应系统下的名词,无名词则留空),由文档在模板初始化时通过 `元素系统数据` 传入。**并非每个系统都涵盖所有元素**,当前系统缺失某元素时自动回退到普通名词(即 ID)。别名通过名为 `别名` 的元素系统提供。

Core concepts are identified by "elements" — the names of the ordinary system. **The ordinary system reads the ID itself**, so it is not a CSV column. **All element systems live in one CSV file** (a wide table: first row = system names, first column = IDs, cells = the term, blank when absent), passed in via `元素系统数据`. **Not every system covers every element**; missing ones fall back to the ID. Aliases come from a system named `别名`.

示例 `元素系统.csv`:
Example `元素系统.csv`:

```csv
id,别名,academic
怪物,,
怪动物,白色怪物,
怪植物,黑色怪物,
怪动植物,黑白怪物,
超级系统,,生物能量超级系统
嗜血仙子,黑白仙女,
水仙子,水仙女,
蝶仙子,蝶仙女,
花仙子,花仙女,
```

在文档中使用:
In a document:

```typst
#import "../模板/lib.typ": *

#show: 地狱之下模板.with(
  // ...
  元素系统数据: csv("元素系统.csv"),   // 全部系统集中在同一 CSV
)
```

文中用 `#元素[怪动植物]` 取词:
In text, use `#元素[怪动植物]`:

```typst
#元素[怪动植物]   // 普通系统下返回"怪动植物"(即 ID 本身)
#设置元素系统("别名")
#元素[怪动植物]   // 别名系统下渲染"黑白怪物"
```

标题用 `#设定元素(level: n)[名]`(标题+锚点模式),自动带 `<名>` 标签可被引用:
For headings use `#设定元素(level: n)[名]`, auto-labeled and referenceable:

```typst
#设定元素(level: 2)[伪神]   // 生成二级标题,`@伪神` 可交叉引用
```

> **注意** / Note
>
> 正文中直接写 `#元素(...)`,不要用 `[` `]` 包裹,否则会渲染字面方括号;函数参数位置(如 `#表格(...)`、`name: ...`)则可以用 `[...]` 包裹成 content。
> In running text write `#元素(...)` directly — wrapping in `[` `]` renders literal brackets. In function-argument positions you may wrap with `[...]`.

```typst
#提示框([#元素[天堂卫星]的能力], [...])
#表格([#元素[热量循环系统]], [...])
#属性框((name: [#元素[怪动植物]]))
```

编译时选择元素系统(缺省为"普通"):
Choose the element system at build time (default `"普通"`):

```sh
typst compile --input 元素系统=academic main.typ out.pdf
# 或 / or
make 元素系统 元素系统名=academic
```

文档内也可动态切换:`#设置元素系统("academic")`。未传入 `元素系统数据` 时,`#元素(...)` 直接返回传入的名称本身。
You can also switch at runtime: `#设置元素系统("academic")`. When `元素系统数据` is absent, `#元素(...)` returns the name verbatim.

**元素化范围**:仅核心概念(地名、生物类别、专有系统名)用 `#元素(...)`;描述性文本如"怪物侧"、"仙子侧"、"怪物分类"保持普通文本。`怪物` 与 `怪物系统` 是两个不同的元素。

**Element scope**: only core concepts (place names, creature categories, proper system names) use `#元素(...)`; descriptive text stays plain. `怪物` and `怪物系统` are two distinct elements.

## 网页输出 · Web output

用 `--features html --input web=true --format html` 导出单栏 HTML,样式由包内的 `web.css` 提供(lib.typ 在 web 模式下直接读取它,并把字体、主题色、阅读器档位按配置填进样式表的锚点注释)。网页自带右上角导航、浮动目录与可调字号字体的"阅读器"面板,全部由 CSS 实现,不需要额外脚本或后处理。

Export single-column HTML with `--features html --input web=true --format html`. Styling comes from the bundled `web.css`, which lib.typ reads in web mode and fills its anchor comments with your font/theme/reader settings. The page ships a top-right nav, a floating table of contents, and a reader panel — all pure CSS, no scripts or post-processing.

只在网页出现的内容用 `#if is_web() [ … ]` 包住,PDF 编译时整段跳过(如站内导航链接)。`is_web()` 与 `is-web-target()` 由模板导出,依据编译参数 `--input web=true` 判定。

Wrap web-only content in `#if is_web() [ … ]` and it is skipped in PDF builds. `is_web()` / `is-web-target()` are exported by the template and read `--input web=true`.

字体与 `@font-face` 由语言文件的 `[web]` 段配置(不配则回退到 `[fonts]` 的系统字体):

```toml
[web]
body-family = "uh-lxgw-mono"      # 自托管族名,插到 [fonts].body 列表首位
header-family = "duan-kaixiao"
comment-family = "zhaoji-shoujin"
bold-family = "uh-zhenkai"

[[web.fonts]]                      # 逐条生成 @font-face;file 相对 HTML 输出目录
family = "uh-lxgw-mono"
file = "webfonts/lxgw-wenkai-mono.woff2"
```

`阅读器` 参数控制面板档位(默认 小/中/大/特大 与 楷体/宋体/黑体):

```typst
阅读器: (
  默认字号: 1,                                      // 默认选中第几档(0 起)
  默认字体: 0,
  字号: (("小", 0.88), ("中", 1), ("大", 1.15)),      // (档名, 字号倍率)
  字体: (("楷体", none), ("宋体", "\"Songti SC\", serif")),  // (档名, CSS 字体栈;none=沿用正文字体)
)
```

## AI 技能 · AI skill

仓库内置 AI 助手技能,描述模板开发规范(中文化函数、元素系统、字体、网页输出、Typst Universe 发布流程与已知坑)。

Ships an AI-assistant skill describing template conventions (localized functions, element system, fonts, web output, the Typst Universe release workflow, and known pitfalls).

- `.skills/SKILL.md`

## 致谢与贡献 · Credits

灵感来自 [typst-dnd5e](https://github.com/coljac/typst-dnd5e) 及 [DND LaTeX module](https://github.com/rpgtex/DND-5e-LaTeX-Template)。
Inspired by [typst-dnd5e](https://github.com/coljac/typst-dnd5e) and the [DND LaTeX module](https://github.com/rpgtex/DND-5e-LaTeX-Template).

贡献者 / Contributors:

- [@neuromancer89](https://github.com/neuromancer89) —— `bg` 参数及本地化系统(`lang` 参数、`languages/*.toml`)。
  The `bg` parameter and the localization system.

## 许可 · License

MIT。
MIT.