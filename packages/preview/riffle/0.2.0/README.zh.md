# riffle

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![手册](https://img.shields.io/badge/manual-Chinese%20%7C%20English-purple)](https://github.com/sses7757/typst-riffle/blob/v0.2.0/doc/manual-zh.pdf)

在页面中途把内容重排到新的页边距。

使用非对称页边距的文档（例如书籍版式中较宽的外侧留白，用于旁注、图片等）有时需要某一段内容采用不同的版式——例如让习题跨对称宽度排成两栏，或在这类内容块之后让正文回到书籍的宽外侧页边距。`riffle` 会在内容*出现的位置*直接重排，**不强制换页**，并让其后的页面沿用新的页边距。

“在页面中途重排内容”的想法来自 [meander.typ](https://github.com/Vanille-N/meander.typ)。本包聚焦于“非对称 ⇄ 对称”方向的重排，尤其是以往可能[不收敛](https://github.com/Vanille-N/meander.typ/issues/1#issuecomment-3306100761)的多页非对称重排，并支持中英文混排。

名字沿用这一河流隐喻：*riffle* 是河流中水流性质改变的那一小段浅滩急流，这里指页面中途改变版式走向的一小段。

## 安装

本包已发布在 Typst Universe：

```typ
#import "@preview/riffle:0.2.0": margin-reflow
```

## 快速开始

```typ
#import "@preview/riffle:0.2.0": margin-reflow

#set page(margin: (inside: 1.75cm, outside: 6.45cm))
#set par(first-line-indent: (amount: 2em, all: true), justify: true)

// ……当前非对称页面上的正文……

#margin-reflow(
  columns: (count: 2, gutter: 14pt),
  margin: "symmetric",
  footnote-style: (size: 9pt),
)[
  第一段内容。#footnote[第一条脚注。]

  第二段内容。
]
```

该调用会在内容出现的位置把内容重排为横跨对称内容宽度的两栏，其后各页使用对称页边距。

## `margin-reflow`

所有方向都由同一个函数完成：

```typ
#margin-reflow(
  content,
  columns: (count: 1, gutter: 4%),
  margin: auto,
  footnote-style: none,
  set-page-margin: true,
)
```

- `content` *（content）*：要重排的内容。会识别段落分隔。
- `columns` *（dictionary，默认 `(count: 1, gutter: 4%)`）*：转发给分栏排版。只有 `count`（int，默认 `1`）和 `gutter`（length，默认为重排宽度的 `4%`）有意义。
- `margin` *（auto、length、dictionary 或 `"symmetric"`，默认 `auto`）*：要切换到的水平页边距——页边距字典（如 `(inside: 1cm, outside: 3cm)`）、单个长度（左右相等）、`"symmetric"`（把当前页面的 `min(inside, outside)` 用于两侧）或 `auto`（沿用当前页边距）。当前页面的上下页边距保持不变。
- `footnote-style` *（none、dictionary 或 function）*：手动排版脚注条目的样式。`none` 沿用继承的默认样式；dictionary 对条目正文施加 `set text(...)`（可用键是 `text` 的参数，如 `size`、`fill`）；function 直接施加到条目正文。条目间距（`gap`、`indent`、`clearance`、`separator`）取自环境中的 `footnote.entry` 设置。
- `set-page-margin` *（bool，默认 `true`）*：`true` 时用 `set page(...)` 切换*其后*页面的页边距，只有当前页由本包手工分栏（速度快、推荐，对任意 `count` 都适用）；`false` 时完全不使用 `set page(...)`，每页都由本包手工分栏、用内边距模拟页边距变化（速度较慢，但不改动文档的页面设置）。手工分页路径要求 `count: 1`：手工分页的页面无法在页面中途切换到多栏版式，其他 `count` 会触发断言。

本函数会：

- 从当前位置开始，不在重排内容之前插入换页；
- 让重排内容与可用高度齐平；
- 把脚注从正文流中取出，在重排块底部手动排版，保留编号与引用；
- 让其后的页面切换到新的页边距；
- 是 `context` 函数，会自行测量当前页面。

若需要首行缩进，请设置 `par.first-line-indent`。

## 限制

- **不能嵌套使用。** 本函数会测量并重写传入的内容，并根据自身所在位置的页面状态决定版式，因此重排内容内部再出现的 `margin-reflow` 调用无法被处理：内层调用测量到的页面版式已被外层替换。请顺序调用。
- **重排内容中不能使用状态更新。** 为确定能放下多少内容，本包会多次排版同一段内容（在 `set-page-margin: false` 时每页一次），因此重排内容里更新的 `state` 会执行多次，不能依赖。请把状态处理放在外面，把结果传进来，或改用 metadata 等实现方式。由 Typst 在排版之后解析的 `counter`（包括作为普通文档内容书写的 `counter(...).update(...)` 或 `.step()`）*不受*影响。
- **脚注由本包排版。** Typst 自己的 `footnote.entry` 规则对重排内的脚注不生效；条目正文请用 `footnote-style`，条目间距请用 `#set footnote.entry(...)`。
- **页面设置。** 页面宽高必须是具体长度；`set-page-margin: false` 要求 `count: 1`。`margin: auto` 沿用当前页边距，在非对称页面上会让栏使用非对称宽度；两栏重排请传 `margin: "symmetric"`。

## 兼容性与中文 / CJK

- **处理内容的包**应在把内容传入*之前*先应用到内容上，因为本函数会拆分并重建内容。例如与 `cjk-unbreak` 连用：

  ```typ
  #import "@preview/cjk-unbreak:0.2.3": remove-cjk-break-space

  #margin-reflow(
    columns: (count: 2, gutter: 10pt),
    margin: "symmetric",
  )[
    #remove-cjk-break-space[
      中文与英文混排内容……
    ]
  ]
  ```

- **中文与混排**：拆分器能识别汉字、中文标点与空格，因此支持中文、日文、韩文文本，以及中英文混排的重排。建议设置支持中文的字体，并开启两端对齐与首行缩进：

  ```typ
  #set text(font: ("New Computer Modern", "SimSun"), lang: "zh")
  #set par(first-line-indent: (amount: 2em, all: true), justify: true)
  ```

  *源文件*中两个汉字之间的换行会被渲染成一个空格；当两侧都是纯文本时 `cjk-unbreak` 可以去掉它，但如果其中一侧是 `strong`、脚注等样式元素则无能为力。

- **版式相关的包**尚未测试。本函数会自行构建固定高度的 `grid`/`block` 结构并修改 `page.margin`，因此与同样控制分页、分栏或页面几何的包可能冲突。仅对内容做装饰的包通常可以使用。

- **旁注包**（例如常见的 `marginalia` 组合）：由于重排函数接管了页面并在页面中途修改 `page.margin`，*不要*把本函数的输出包在 `marginalia.wideblock` 中，*也不要*用 `marginalia.wideblock`/`marginalia.header` 来排版页眉页脚；应直接依据 `page.margin` 对齐页眉页脚，使其跟随本包设置的页边距（手册中有最简示例）。仍可用一个*空的* `marginalia.wideblock` 来避免旁注溢出到正文。

## 文档

- [手册（中文）](https://github.com/sses7757/typst-riffle/blob/v0.2.0/doc/manual-zh.pdf)
- [Manual (English)](https://github.com/sses7757/typst-riffle/blob/v0.2.0/doc/manual.pdf)
- [README (English)](README.md)

手册中的示例以小页面渲染，并带有边界辅助线：*蓝色*虚线标记对称内容边界，*橙色*虚线标记非对称内容边界。

## 开发

- 注册 Git 仓库以便在本地更新本包。
  ```sh
  git init
  git remote add origin git@github.com:sses7757/typst-riffle.git
  ```
- 运行测试。
  ```sh
  powershell -NoProfile -File tests\run.ps1
  ```
- 重新渲染手册插图。
  ```sh
  powershell -NoProfile -File scripts\render-doc-images.ps1
  ```

## 许可证

采用 [MIT 许可证](LICENSE)。
