# 地狱之下模板 · UnderHell Template

> **本项目说明 / About this repo**:本仓库是 [地狱之下 (UnderHell)](https://github.com/CrossDark/UnderHell) 项目的文档模板子模块,在此同步维护并按需调整。
> This repo is the documentation-template submodule of the [UnderHell](https://github.com/CrossDark/UnderHell) worldbuilding project, maintained here and adjusted as needed.
>
> **出处与版权 / Origin & license**:本模板源自 [coljac/typst-dnd5e](https://github.com/coljac/typst-dnd5e)(即 Typst Universe 中的 `dragonling` 包),作者 Colin Jacobs,基于 MIT 协议发布。感谢原作者的工作。
> This template derives from [coljac/typst-dnd5e](https://github.com/coljac/typst-dnd5e) (the `dragonling` package on Typst Universe) by Colin Jacobs, released under the MIT license. Thanks to the original author.

这是一个用于架空世界内容创作的 [Typst](https://typst.app) 模板,适用于冒险模组、世界设定文档、角色卡片等场景。
A [Typst](https://typst.app) template for worldbuilding content: adventure modules, setting documents, character sheets, and more.

模板名为 `underhell`,已发布至 Typst Universe,可通过 `#import "@preview/underhell:0.2.0": *` 导入。本仓库内_地狱之下_项目自身则通过相对路径引用:`#import "../模板/lib.typ": *`。
The template is named `underhell` and published to Typst Universe, imported via `#import "@preview/underhell:0.2.0": *`. Inside this repo the _UnderHell_ project itself references it by relative path: `#import "../模板/lib.typ": *`.

**注意**:本包已更新以兼容最新版本的 Typst (0.13),可提交至 Typst Universe.
**Note**: This package is updated to work with the latest Typst (0.13) and is ready for Typst Universe.

## 基本用法 · Basic usage

`地狱之下模板` 模板会为你初始化文档。你可能需要预先指定的参数如下:
The `地狱之下模板` template initializes the document for you. Parameters you may want to set:

- `title`:文档标题,将以文字形式渲染。若封面图已含标题则可省略。
  Document title rendered as text. Omit if your cover image already shows the title.
- `subtitle`:封面底部的副标题/标语。
  Subtitle or tagline at the bottom of the cover.
- `author`:你的名字。
  Your name.
- `cover`:用于封面的 `image`。
  An `image` used for the cover.
- `fancy-author`:将作者名放在红色火焰装饰中。
  Puts the author name inside a red flame flourish.
- `logo`:提供 `image` 以在首页放置 logo。
  An `image` to place a logo on the first page.
- `font-size`:默认 `12pt`。
  Default `12pt`.
- `paper`:默认(合理地)为 `a4`(美国用户可改用 `us-letter`)。
  Defaults (sensibly) to `a4` (US users may want `us-letter`).
- `add-title`:(布尔)是否在首页打印标题。例如若你自制了封面图,可设为 false。
  (Boolean) whether to print the title on the first page. Set `false` if you made your own cover image.
- `bg`:内容页背景。`"default"`(羊皮纸,默认),`none` 为适合打印的白色背景,或传入 `image(...)` 使用自定义背景。
  Content-page background. `"default"` (parchment, default), `none` for a print-friendly white background, or pass an `image(...)` for a custom one.
- `lang`:用于 `属性框` 和 `人物框` 中本地化标签(Armor Class、Description 等)的双字母语言代码。默认为 `"en"`。仓库内置 `"it"`;可参照 `languages/en.toml` 在 `languages/<code>.toml` 添加自己的语言。语言文件的 `[fonts]` 段可配置字体:`body`(正文)、`header`(标题)、`italic`(斜体)。
  Two-letter language code for localized labels (Armor Class, Description, etc.) in `属性框` and `人物框`. Defaults to `"en"`. Ships with `"it"`; add your own as `languages/<code>.toml` following `languages/en.toml`. The `[fonts]` section configures fonts: `body`, `header`, `italic`.
- `元素系统`:元素系统名称(详见下文"元素系统")。默认为编译时 `--input 元素系统=xxx` 的值,缺省为 `"普通"`。文档可显式传入覆盖。
  The element-system name (see "元素系统" below). Defaults to the build-time `--input 元素系统=xxx` value, falling back to `"普通"`. An explicit value overrides.
- `元素系统数据`:元素系统数据文件的 `csv()` 读取结果(详见下文"元素系统")。
  The `csv()` result of the element-system data file (see "元素系统" below).

之后,几乎所有需求都可用基础 Typst 标记完成。模板还提供以下便捷函数:
Almost everything else is plain Typst. The template also provides these helpers:

`元素(id, font: none)`:返回当前元素系统下的名词文本,**渲染为深红色**,默认使用标题字体(段宁毛笔小楷),可通过 `font:` 参数覆盖。不可在正文中用 `[` `]` 包裹。若该元素在文档中已有定义标题,将自动变为指向该标题的链接;未定义时在 PDF 编译给出 warning,在 HTML 输出(`--features html --input html=true`)渲染悬停"未定义"弹窗。
Returns the term for `id` under the current element system, **rendered in dark red**, using the heading font by default (overridable via `font:`). Must not be wrapped in `[` `]` in running text. If the element has a defined heading in the document it becomes a link to it; otherwise PDF build emits a warning, and HTML output renders a hover "未定义" (undefined) tooltip.

`设定元素(id, font: none, level: none)`:普通模式返回深红文本(同 `#元素(id)`,但不生成链接)。**传入 `level`(`#设定元素(level: n)[名]`)时进入"标题+锚点"模式**,生成带 `<名>` 标签的编号标题,可用 `@名` 交叉引用(样式由 `show heading` 规则统一应用)。文档中的章节标题即用此形式。
In normal mode returns dark-red text (like `#元素(id)`, but no link). **Passing `level` (`#设定元素(level: n)[名]`) switches to "heading + anchor" mode**: it produces a numbered heading with a `<名>` label, cross-referenced via `@名` (styled by the `show heading` rule). Section titles in documents use this form.

`评论(body)`:以标题字体、**灰色**显示注释(默认无删除线);编译时传 `--input 隐藏评论=true` 可整体隐藏。
Shows a comment in the heading font, **in gray** (no strikethrough by default). Pass `--input 隐藏评论=true` to hide all.

`品牌`:以小型大写字母打印品牌名 "地狱之下"。
Prints the brand name "地狱之下" in small caps.

## 标题样式 · Heading styles

模板对六级标题均有差异化样式:
All six heading levels are styled differently:

| 级别 Level | 样式 Style |
|------|------|
| `=` 一级 L1 | 小型大写、深红、1.5em · small caps, dark red, 1.5em |
| `==` 二级 L2 | 小型大写、深红、黄色下划线 · small caps, dark red, yellow underline |
| `===` 三级 L3 | 小型大写、深红、1.3em · small caps, dark red, 1.3em |
| `====` 四级 L4 | 深红、1.15em、黄色左色条 · dark red, 1.15em, yellow left bar |
| `=====` 五级 L5 | 左侧圆点(垂直居中)+深红斜体 · left dot (vertically centered) + dark-red italic |
| `======` 六级 L6 | 深红、0.95em、前置 `—` 符号 · dark red, 0.95em, preceding `—` |

打印模式下所有彩色装饰(下划线、色条、圆点)自动去除。
All colored decorations (underlines, bars, dots) are removed in print mode automatically.

## 元素系统 · Element system

元素系统让同一核心概念(如"黑白怪物")在不同设定版本中拥有不同叫法,便于同一份文档输出多种"世界观名词"。
The element system lets the same core concept (e.g. "黑白怪物") carry different terms under different settings, so one document can output several sets of worldbuilding vocabulary.

**核心概念用"元素"标识**:即普通元素系统的名称(如 `怪动植物` 代表黑白怪物)。**普通元素系统直接读取 ID 的值本身**,因此它不是 CSV 的列。**所有元素系统集中存放在同一个 CSV 文件**(**宽表**:首行为各元素系统名,首列为元素 id,单元格为该元素在对应系统下的名词,无名词则留空),由文档在模板初始化时通过 `元素系统数据` 传入。**并非每个系统都涵盖所有元素**,当前系统缺失某元素时自动回退到普通名词(即 ID)。别名通过名为 `别名` 的元素系统提供。
Core concepts are identified by "elements" — the names of the ordinary system (e.g. `怪动植物` represents the black-and-white monsters). **The ordinary system reads the ID value itself**, so it is not a CSV column. **All element systems live in one CSV file** (a wide table: first row = system names, first column = element IDs, cells = the term under that system, blank when absent), passed in via `元素系统数据` at template init. **Not every system covers every element**; missing elements fall back to the ordinary term (the ID). Aliases are provided through a system named `别名`.

示例 `元素系统.csv` / Example `元素系统.csv`:

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

在文档中使用 / In a document:

```typst
#import "../模板/lib.typ": *

#show: 地狱之下模板.with(
  // ...
  元素系统数据: csv("元素系统.csv"),   // 全部系统集中在同一 CSV
)
```

文中用 `#元素[怪动植物]` 取词 / In text use `#元素[怪动植物]`:

```typst
#元素[怪动植物]   // 普通系统下返回"怪动植物"(即 ID 本身)
#设置元素系统("别名")
#元素[怪动植物]   // 别名系统下渲染"黑白怪物"
```

标题用 `#设定元素(level: n)[名]`(标题+锚点模式),自动带 `<名>` 标签可被引用 / For headings use `#设定元素(level: n)[名]` (heading + anchor mode), auto-labeled `<名>` and referenceable:

```typst
#设定元素(level: 2)[伪神]   // 生成二级标题,`@伪神` 可交叉引用
```

注意:正文中直接写 `#元素(...)`(不要在正文中用 `[` `]` 包裹,否则会渲染字面方括号);函数参数位置(如 `#表格(...)`、`#提示框(...)`、`name: ...`)可用 `[...]` 包裹成 content:
Note: in running text write `#元素(...)` directly (do not wrap in `[` `]`, or literal brackets render); in function-argument positions (e.g. `#表格(...)`, `#提示框(...)`, `name: ...`) you may wrap with `[...]` as content:

```typst
#提示框([#元素[天堂卫星]的能力], [...])
#表格([#元素[热量循环系统]], [...])

#属性框((name: [#元素[怪动植物]], ...))
```

编译时选择元素系统(缺省为"普通")/ Choose the element system at build time (default `"普通"`):

```sh
typst compile --input 元素系统=academic main.typ out.pdf
# 或 / or
make 元素系统 元素系统名=academic
```

文档内也可动态切换:`#设置元素系统("academic")`;`元素系统数据` 未传入时,`#元素(...)` 直接返回传入的名称本身。
You can also switch at runtime: `#设置元素系统("academic")`. When `元素系统数据` is not passed, `#元素(...)` returns the name you pass verbatim.

**元素化范围**:仅核心概念(地名、生物类别、专有系统名)用 `#元素(...)`;描述性文本如"怪物侧"、"仙子侧"、"怪物分类"保持普通文本。`怪物` 与 `怪物系统` 是两个不同的元素。
**Element scope**: only core concepts (place names, creature categories, proper system names) use `#元素(...)`; descriptive text like "怪物侧" stays plain. `怪物` and `怪物系统` are two distinct elements.

`表格(name, columns: (1fr, 4fr), breakable: false, ..contents)`:常规格式的表格。默认 2 列、比例 1:4;若 `breakable` 为 `true`,可跨页拆分。
A regular formatted table. Defaults to 2 columns at 1:4; set `breakable` to `true` to split across pages.

`提示框(title, contents)`:插入带彩色背景的方框,可选标题以小型大写显示。
Inserts a colored-background box, with an optional title shown in small caps.

`属性框(stats)`:接受如下格式的字典。`skillblock` 和 `traits` 可含任意键。traits 之后,若存在 "Actions"、"Reactions"、"Limited Usage"、"Equipment" 或 "Legendary Actions",将依次显示。
Takes a dictionary in the following format. `skillblock` and `traits` may hold arbitrary keys. After traits, "Actions", "Reactions", "Limited Usage", "Equipment", and "Legendary Actions" are shown in turn when present.

```
#属性框((
  name: "Creature name",
  description: [Size creature, alignment],
  ac: [20 (natural armor)],
  hp: [29 (1d10 + 33)],
  speed: [10ft, climb 10ft.],
  stats: (STR: 13, DEX: 14, CON: 18, INT: 5, WIS: 4, CHA: 7),  // 修正值将自动计算
  skillblock: (
      Skills: [Perception +6, Stealth +5],
      Senses: [passive Perception 13],
      Languages: [Gnomish],
      Challenge: [5 (1800 XP)]
  ),
  traits: (
    ("Trait name", [Trait desription]),
    // ..
    ("Trait name", [Trait desription])
),
  actions: (
    ("Multiattack", [While the monster remains alive, it is a thorn in the party's side.]),
    ("Saliva", [If a character is eaten by the monster, it takes 1d10 saliva damage per round.]),
    ("Tentacle squeeze", [If the monster has captured an enemy, it can squeeze them for 1d12 crushing damage.])
  )
))
```

`人物框(npc)`:非玩家角色卡片。除 `name` 外所有字段均可选 —— 省略即跳过对应部分。属性使用与 `属性框` 相同的自动修正值表。
A non-player-character card. All fields except `name` are optional — omit to skip that section. Stats use the same auto-calculated modifiers as `属性框`.

```
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

`法术`:接受如下字典;所有属性均可选:
Takes a dictionary; all fields are optional:

```
#法术((
  name: "",
  spell-type: [2nd level ...],
  properties: (
    ("Casting time", []),
    ("Range", []),
    ("Duration", []),
    ("Components", []),
  ),
  description: [Spell effects description]
  )
)
```

## 跨页图片与表格 · Cross-page images & tables

模板内置两个辅助函数 `顶部图` 和 `底部图`。以下代码:
Two helpers, `顶部图` and `底部图`. For example:

```typst
#底部图(image("swordtorn.png", width=140%))
```

会将图片插入页面底部,横跨两栏,并抑制该页页脚。
Places the image at the bottom of the page, spanning both columns, and suppresses the page footer.

## 附录 · Appendix

`附录` 函数用于在文末生成附录章节,自动将标题编号切换为字母格式(附录 A,子标题 A.1, A.1.1 ...)并重置计数器,避免与正文章节编号冲突。
The `附录` function generates an appendix section at the end, switching heading numbering to letters (Appendix A, subsections A.1, A.1.1 ...) and resetting counters to avoid clashing with the body's numbering.

- `title`:附录总标题,默认 `"附录"`。· The appendix title, default `"附录"`.
- `numbering-fmt`:附录标题编号格式,默认 `"A.1."`。· The appendix numbering format, default `"A.1."`.
- `..body`:附录正文内容。· The appendix body.

```typst
#附录[
  == 附录子标题
  附录正文内容...
]

// 也可通过 include 引入独立的附录文件 / or include a separate appendix file
#附录[
  #include "附录文件.typ"
]
```

## 导入子文件 · Including sub-files

`导入` 函数用 `#include` 引入另一个 `.typ` 文件,并通过 `set heading(offset:)` 整体增加其标题层级(默认 +1)。`路径` 以仓库根(`--root`)为基准,如 `"文档/内容/怪动植物.typ"`。被导入文件自行 `#import` 所需的模板函数,函数不注入作用域、不解析文件文本。
The `导入` function includes another `.typ` file via `#include` and deepens all its heading levels with `set heading(offset:)` (default +1). `路径` is relative to the repo root (`--root`), e.g. `"文档/内容/怪动植物.typ"`. The included file does its own `#import` etc.; the function injects no scope and parses no file text.

- `路径`:被引入文件的路径,相对仓库根(`--root`),如 `"文档/内容/怪动植物.typ"`。
  Path of the file to include, relative to the repo root (`--root`).
- `偏移`:标题层级增量(必须非负,即只加深),默认 `1`。被导入文件因此应写得比最终层级浅一档(如目标为 `===`,源文件写 `==`)。
  Heading-level increment (must be non-negative, i.e. only deepens), default `1`. Include files should thus be written one level shallower than the final result (write `==` for a target of `===`).

```typst
// 引入子文件,其全部标题层级 +1
#导入("文档/内容/怪动植物.typ")

// 指定其他偏移量 / with a custom offset
#导入("文档/内容/附录.typ", 偏移: 2)
```

注意:`set heading(offset:)` 只取非负值,无法把标题变浅;需调整层级时改被导入文件源码即可。
Note: `set heading(offset:)` only takes non-negative values and cannot shallow-out headings; edit the source file if you need to change levels.

## 致谢 · Acknowledgments

灵感来自 [typst-dnd5e](https://github.com/coljac/typst-dnd5e) 及 [DND LaTeX module](https://github.com/rpgtex/DND-5e-LaTeX-Template)。
Inspired by [typst-dnd5e](https://github.com/coljac/typst-dnd5e) and the [DND LaTeX module](https://github.com/rpgtex/DND-5e-LaTeX-Template).

## 贡献者 · Contributors

- [@neuromancer89](https://github.com/neuromancer89) —— `bg` 参数及本地化系统(`lang` 参数、`languages/*.toml`)。
  The `bg` parameter and the localization system (`lang` parameter, `languages/*.toml`).