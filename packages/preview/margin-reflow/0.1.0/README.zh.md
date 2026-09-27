# margin-reflow

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![手册](https://img.shields.io/badge/manual-Chinese%20%7C%20English-purple)](doc/manual-zh.pdf)

在页面中途把内容重排到新的页边距。

使用非对称页边距的文档（例如书籍版式中较宽的外侧留白，用于旁注、图片等）有时需要
某一段内容采用不同的版式——例如让习题跨对称宽度排成两栏，或在这类内容块之后让正文
回到书籍的宽外侧页边距。`margin-reflow` 会在内容*出现的位置*直接重排，**不强制
换页**，并让其后的页面沿用新的页边距。

“在页面中途重排内容”的想法来自
[meander.typ](https://github.com/Vanille-N/meander.typ)。本包聚焦于“非对称 ⇄ 对称”
方向的重排，尤其是以往可能
[不收敛](https://github.com/Vanille-N/meander.typ/issues/1#issuecomment-3306100761)
的多页非对称重排，并支持中英文混排。

## 安装

本包已发布在 Typst Universe：

```typ
#import "@preview/margin-reflow:0.1.0": column-flow, single-flow, asymmetric-flow
```

## 快速开始

```typ
#import "@preview/margin-reflow:0.1.0": column-flow

#set page(margin: (inside: 1.75cm, outside: 6.45cm))
#set par(first-line-indent: (amount: 2em, all: true), justify: true)

// ……当前非对称页面上的正文……

#v(1em)

#column-flow(
  [
    第一段内容。#footnote[第一条脚注。]

    第二段内容。
  ],
  gutter: 14pt,
  footnote-entry: (indent: 0em, size: 9pt),
)
```

该调用会在内容出现的位置把内容重排为横跨对称内容宽度的两栏，其后各页使用对称页边距。

## 函数

| 函数 | 起始页边距 | 产生版式 |
| --- | --- | --- |
| `column-flow` | 非对称 | 横跨对称宽度的两栏 |
| `single-flow` | 非对称 | 横跨对称宽度的单栏 |
| `asymmetric-flow` | 对称 | 横跨指定非对称宽度的单栏 |

三者都会：

- 从当前位置开始，不在重排内容之前插入换页；
- 让重排内容与可用高度齐平；
- 把脚注从正文流中取出，在重排块底部手动排版，保留编号与引用；
- 让其后的页面切换到新的页边距；
- 是 `context` 函数，会自行测量当前页面。

若需要首行缩进，请设置 `par.first-line-indent`。

### `column-flow`

```typ
#column-flow(content, gutter: 4%, count: 2, footnote-entry: none)
```

- `content` *（content）*：要重排的内容。会识别段落分隔。
- `gutter` *（length，默认 `4%`，相对重排宽度）*：栏间距。
- `count` *（int，默认 `2`）*：栏数。
- `footnote-entry` *（none、dictionary 或 function）*：手动排版脚注条目的样式。
  `none` 使用 Typst 默认值；dictionary 作为 `footnote.entry` 配置（如 `indent`、
  `size`、`leading`、`clearance`、`gap`、`separator`、`style`）；function 等价于
  `(style: function)`。

### `single-flow`

```typ
#single-flow(content, footnote-entry: none)
```

- `content` *（content）*：要重排的内容。
- `footnote-entry` *（none、dictionary 或 function）*：同 `column-flow`。

### `asymmetric-flow`

```typ
#asymmetric-flow(content, margin, footnote-entry: none)
```

- `content` *（content）*：要重排的内容。
- `margin` *（auto、length 或 dictionary）*：要切换到的非对称水平页边距，例如
  `(inside: 1cm, outside: 3cm)` 或 `(left: 1cm, right: 3cm)`。`inside`/`outside`
  会像 `page.margin` 一样依据当前页面的奇偶解析。只取 `margin` 的水平页边距；当前
  页面的上下页边距会被保留。
- `footnote-entry` *（none、dictionary 或 function）*：同 `column-flow`。

## 兼容性与中文 / CJK

- **处理内容的包**应在把内容传入*之前*先应用到内容上，因为本包会拆分并重建内容。
  例如与 `cjk-unbreak` 连用：

  ```typ
  #import "@preview/cjk-unbreak:0.2.3": remove-cjk-break-space

  #column-flow(remove-cjk-break-space[
    中文与英文混排内容……
  ])
  ```

- **中文与混排**：拆分器能识别汉字、中文标点与空格，因此支持中文、日文、韩文文本，
  以及中英文混排的重排。建议设置支持中文的字体，并开启两端对齐与首行缩进：

  ```typ
  #set text(font: ("New Computer Modern", "SimSun"), lang: "zh")
  #set par(first-line-indent: (amount: 2em, all: true), justify: true)
  ```

- **版式相关的包**尚未测试。本包会自行构建固定高度的 `grid`/`block` 结构并修改
  `page.margin`，因此与同样控制分页、分栏或页面几何的包可能冲突。仅对内容做装饰的
  包通常可以使用。脚注是手动排版的，如果某个包重设了 `footnote.entry`，请改用
  `footnote-entry` 参数。

## 文档

- [手册（中文）](doc/manual-zh.pdf)
- [Manual (English)](doc/manual.pdf)
- [README (English)](README.md)

手册中的示例以小页面渲染，并带有边界辅助线：*蓝色*虚线标记对称内容边界，*橙色*虚线
标记非对称内容边界。

## 许可证

采用 [MIT 许可证](LICENSE)。
