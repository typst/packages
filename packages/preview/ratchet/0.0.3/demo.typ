#import "@preview/ratchet:0.0.3": figure-number, ratchet

#show: ratchet.with(
  fig-outline: "1.1",
)

#align(center)[#text(size: 18pt)[Better Numbering Demo]]

本 demo 演示 `ratchet` 的核心能力：基于章节/小节前缀的图表/公式编号、跨章节引用一致性、以及“同一篇文档中分段重新配置编号样式”。

This demo showcases the core capabilities of `ratchet`: section/subsection-based figure/equation numbering, consistent cross-section references, and the ability to reconfigure numbering styles in different parts of the same document.

该包主要更改了图表和公式的编号方式，使其能够根据章节自动更新编号，并在进入新章节时重置计数器。此外，它还允许用户自定义编号的层级深度和格式。支持`image`、`table`、`raw`、`math.equation`以及自定义的`figure(kind: ...)`等元素类型。

This package primarily modifies the numbering of figures and equations to automatically update based on sections and reset counters when entering new sections. Additionally, it allows users to customize the depth and format of numbering. It supports element types such as `image`, `table`, `raw`, `math.equation`, and custom `figure(kind: ...)`.

你可以像这样引入该包并启用增强编号功能：

Import this package and enable better numbering with:
```typ
#import "@preview/ratchet:0.0.3": *
#show: ratchet
```
默认的配置如下：

the default settings are:
```typ
#show: ratchet.with(
  offset: 0,
  init: "rebase",
  reset-figure-kinds: (image, table, raw),
  fig-depth: 2,
  fig-outline: "1.1",
  fig-color: none,
  figure-groups: (),
  eq-depth: 2,
  eq-outline: "(1.1)",
  eq-color: none,
)
```

如你所见，所有的图表和公式编号都根据章节自动更新，并且在进入新章节时重置计数器。你可以自由调整展示的层级深度和编号格式，以满足你的需求。在没有对应层级的章节出现时，会以0补充编号，确保编号的一致性。

As you can see, all figure and equation numbers are automatically updated based on the sections, and counters are reset when entering new sections. You can freely adjust the depth of numbering and the numbering format to suit your needs. When certain heading levels are absent, zeros are used to fill in the numbering, ensuring consistency.

#let placeholder-img() = rect(width: 4cm, height: 2cm, radius: 4pt, stroke: 1pt)[
  #align(center + horizon)[*placeholder image*]
]

#let placeholder-table() = table(
  columns: (auto, auto, auto),
  [Item], [Qty], [Note],
  [Apples], [2], [red],
  [Oranges], [5], [sweet],
)

#grid(columns: (1fr,) * 2)[
  #figure(
    placeholder-img(),
    caption: [This is a placeholder image],
  )<fig1>

  #figure(
    placeholder-img(),
    caption: [This is a placeholder image],
    numbering: none,
  )

  #figure(
    placeholder-img(),
    caption: [This is a placeholder image],
  )<fig2>
][
  ```typst
  #figure(
    placeholder-img(),
    caption: [This is a placeholder image],
  )<fig1>

  #figure(
    placeholder-img(),
    caption: [This is a placeholder image],
    numbering: none,
  )

  #figure(
    placeholder-img(),
    caption: [This is a placeholder image],
  )<fig2>
  ```
]
= section

#figure(
  placeholder-img(),
  caption: [This is a placeholder image],
)
$
  nabla^2 = (partial^2)/(partial x^2) + (partial^2)/(partial y^2) + (partial^2)/(partial z^2)
$

== subsection

#figure(
  placeholder-img(),
  caption: [This is a placeholder image],
)

#figure(
  grid(columns: (1fr, 1fr))[
    #figure(
      placeholder-img(),
      caption: [(a) This is a placeholder image],
      numbering: none,
      outlined: false,
    )
  ][
    #figure(
      placeholder-img(),
      caption: [(b) This is a placeholder image],
      numbering: none,
      outlined: false,
    )
  ],
  caption: [ Figure with sub-figures ],
)
```typst
#figure(
  grid(columns: (1fr, 1fr))[
    #figure(
      placeholder-img(),
      caption: [(a) This is a placeholder image],
      numbering: none,
      outlined: false,
    )
  ][
    #figure(
      placeholder-img(),
      caption: [(b) This is a placeholder image],
      numbering: none,
      outlined: false,
    )
  ],
  caption: [ Figure with sub-figures ],
)
```

#figure(
  grid(columns: (1fr, 1fr))[
    #figure(
      placeholder-table(),
      caption: [This is a placeholder table],
    )<tab1>
  ][
    #figure(
      placeholder-table(),
      caption: [This is another placeholder table],
    )
  ],
  caption: [ Figure with sub-figures ],
  kind: image,
)
```typ
#figure(
  grid(columns: (1fr, 1fr))[
    #figure(
      placeholder-table(),
      caption: [This is a placeholder table],
    )<tab1>
  ][
    #figure(
      placeholder-table(),
      caption: [This is another placeholder table],
    )
  ],
  caption: [ Figure with sub-figures ],
  kind: image,
)
```

所有的编号都是合适的，在子图和表格中也是如此，你可以轻松管理和引用它们`@tab1`@tab1。

All numbering is appropriate, including in sub-figures and tables, allowing you to easily manage and reference them.

#figure(
  placeholder-table(),
  caption: [This is a placeholder table],
)

= section

#figure(
  placeholder-img(),
  caption: [This is a placeholder image],
)

#figure(
  placeholder-table(),
  caption: [This is a placeholder table],
)

`label`和`ref`功能也能正常工作，可以直接用原本的方式进行引用，例如`@ref`和`<ref>`。跨章节的引用也不会出错 `@tab1:`@tab1 ，`@fig1:`@fig1；`@fig2:`@fig2 ；`@tab2:`@tab2；`@eq1:`@eq1 。

The `label` and `ref` functionalities also work correctly, allowing you to reference them in the usual way, such as `@ref` and `<ref>`.Cross-section references also work correctly.

你可以直接重新引用以改变编号样式，例如创建一个*附录*：

You can directly re-apply to change the numbering style, for example, to create an *appendix*:

如果你希望自定义 figure kind 使用独立的编号深度和样式，可以像下面通过 `figure-groups` 配置：

Use `figure-groups` when custom figure kinds need an independent numbering depth and style:

每个分组包含四个字段：`kinds` 指定这一组的 figure kind；`depth` 指定编号深度；`outline` 指定编号格式；`color` 指定引用和目录中的编号颜色。同一个 kind 同时出现在多个分组时，最后一个分组优先。

Each group has four fields: `kinds` selects its figure kinds, `depth` controls heading-aware resets, `outline` sets the numbering pattern, and `color` styles numbers in references and outlines. If a kind occurs in multiple groups, the last group wins.

#show: ratchet.with(
  offset: 0,
  reset-figure-kinds: (image, table, raw),
  fig-depth: 3,
  fig-outline: "I.1.1",
  fig-color: blue,
  figure-groups: (
    (kinds: ("custom-kind",), depth: 2, outline: "A.1", color: purple),
  ),
  eq-depth: 3,
  eq-outline: "(I.1.1)",
  eq-color: red,
)
```typ
#show: ratchet.with(
  offset: 0,
  reset-figure-kinds: (image, table, raw),
  fig-depth: 3,
  fig-outline: "I.1.1",
  fig-color: blue,
  figure-groups: (
    (kinds: ("custom-kind",), depth: 2, outline: "A.1", color: purple),
  ),
  eq-depth: 3,
  eq-outline: "(I.1.1)",
  eq-color: red,
)
```

#figure(
  placeholder-img(),
  caption: [This is a placeholder image],
)

= Appendix

== subsection

$
  a^2 + b^2 = c^2
$

$
  E = m c^2
$<eq1>

== subsection

#figure(
  placeholder-table(),
  caption: [This is a placeholder table],
)<tab2>

你会发现编号风格已经改变，现在支持三级编号格式，例如`1.1.1`。

You will notice that the numbering style has changed, now supporting three-level numbering formats, such as `1.1.1`.

在这里你甚至可以引用之前的图表和公式，它们的编号也不会改变；而新的图表和公式会采用新的编号格式  `@fig1:`@fig1 ，`@tab1:`@tab1，`@fig2:`@fig2 ，`@tab2:`@tab2，`@eq1:`@eq1 。

Previous figures and equations can still be referenced without changing their numbering; new figures and equations will adopt the new numbering format.

可以直接生成图表目录：

You can directly generate a list of figures:
```typst
#outline(
  title: [List of Figures],
  target: figure.where(kind: image, outlined: true,),
)
```
#outline(
  title: [List of Figures],
  target: figure.where(
    kind: image,
    outlined: true,
  ),
)

会排除掉`outlined: false`的图表，但会包含`numbering: none`但`outlined: true(default)`的图表。

Figures with `outlined: false` will be excluded, but those with `numbering: none` but `outlined: true (default)` will be included.

此外，我们也可以为自定义的`figure(kind: ...)`类型启用编号功能：

Additionally, we can also enable numbering for custom `figure(kind: ...)` types:

`figure-number` 可以把 Ratchet 管理的编号放进自定义渲染内容中。下面的 `custom-card` 没有使用标准 caption，而是在块标题中直接读取 `custom-kind` 的编号：

`figure-number` places a Ratchet-managed number inside a custom renderer. The following `custom-card` does not use a standard caption; it reads the `custom-kind` number directly in the block title:

#let custom-card(lab: none, body) = {
  let elem = figure(
    block(
      fill: purple.lighten(80%),
      stroke: (left: 4pt + purple),
      inset: 8pt,
      width: 100%,
    )[
      *Custom card #figure-number("custom-kind")*
      #linebreak()
      #body
    ],
    kind: "custom-kind",
    supplement: [CUSTOM CARD],
    caption: none,
    outlined: false,
  )
  [#elem #if lab != none { label(lab) }]
}

#custom-card(lab: "custom-card")[This number is rendered inside the card body.]

```typst
#let custom-card(lab: none, body) = {
  let elem = figure(
    block(stroke: (left: 4pt + purple), inset: 8pt, width: 100%)[
      *Custom card #figure-number("custom-kind")*
      #linebreak()
      #body
    ],
    kind: "custom-kind",
    supplement: [CUSTOM CARD],
    caption: none,
    outlined: false,
  )
  [#elem #if lab != none { label(lab) }]
}

#custom-card(lab: "custom-card")[This number is rendered inside the card body.]
```

自定义渲染的块也可以正常引用：`@custom-card:` @custom-card。

The custom-rendered block can be referenced normally: `@custom-card:` @custom-card.

= next section

#figure(
  placeholder-img(),
  caption: [This is a placeholder image],
  kind: "custom-kind",
  supplement: [CUSTOM KIND],
)<custom-fig>

```typst
#figure(
  placeholder-img(),
  caption: [This is a placeholder image],
  kind: "custom-kind",
  supplement: [CUSTOM KIND],
)<custom-fig>
```

同样也可以引用它：`@custom-fig:`@custom-fig 。

It can also be referenced: `@custom-fig:`@custom-fig .

刚才自定义渲染的块也可以正常引用：`@custom-card:` @custom-card。

The previously custom-rendered block can also be referenced normally: `@custom-card:` @custom-card.
