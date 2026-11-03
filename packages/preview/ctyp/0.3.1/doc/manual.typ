#import "@preview/tidy:0.4.3"
#import "@preview/ctyp:0.3.1": ctyp, fandol-fontset, page-grid
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *
#codly(languages: codly-languages)
#import "@preview/theorion:0.5.0": cosmos
#import cosmos.default: *
#import "@preview/marge:0.1.0": sidenote

#let appendix(body) = {
  counter(heading).update(0)
  set heading(numbering: "A.1")
  show heading.where(level: 1): set heading(supplement: [附录])
  show heading.where(level: 1): it => {
    set par(first-line-indent: 0em)
    [附录] + counter(heading).display(it.numbering) + box(width: 1em) + it.body
  }
  body
}

#show: page-grid.with(width: 48, note-right: 8)

#let (ctypset, (song, hei, kai, fang)) = ctyp(
  heading-numbering: "1."
)
#show: ctypset
#show: codly-init

#let sidenote = sidenote.with(
  side: right,
  padding: (left: 1em, right: 2em),
  format: it => block(width: 8em + 8pt, inset: (x: 4pt, y: 4pt), stroke: gray + 1pt, radius: 2pt, it.body)
)

#let note-ctyp-arg(..bodies) = sidenote[
  #let (name, ..desc) = bodies.pos()
  #stack(
    dir: ttb,
    spacing: 8pt,
    emoji.a + h(4pt) + name,
    ..desc
  )
]

#let note-ctyp-func(..bodies) = sidenote[
  #let (name, ..desc) = bodies.pos()
  #stack(
    dir: ttb,
    spacing: 8pt,
    emoji.mousetrap + h(4pt) + name,
    ..desc
  )
]

#block(width: 100%, below: 2em)[
  #set align(center)
  #text(size: 1.5em, strong[CTyp 使用手册])
  
  #emph[版本: 0.3.1]
]

CTyp 是一个用于提供 Typst 中文排版支持的包。
该包集成了一些常用的中文排版设置，用于提供快速的中文排版体验。

#warning-block[
  由于 Typst 的中文排版支持仍不完善，该包只能提供非语言级的排版支持。
  并不保证能够实现所有中文排版需求。
]

#outline(target: heading.where(level: 1).or(heading.where(level: 2)))

= 快速开始

通过以下代码快速使用 CTyp 包的设置：

```typ
#import "@preview/ctyp:0.3.1": ctyp
#let (ctypset, cjk) = ctyp()
#show: ctypset
```

#note-block[
  变量名 `ctypset` 和 `cjk` 可以自行设置，无需使用文档中的名字。
]

在 Typst Web App 环境中，可以直接使用 Noto CJK 字体系列，通过以下代码进行设置：

```typ
#import "@preview/ctyp:0.3.1": *
#let (ctypset, cjk) = ctyp(
  fontset-cjk: "noto"
)
#show: ctypset
```

= 字体设置

== 字体集合

#note-ctyp-arg[fontset][字体集合。接受一个字符串选取预定义的字体集合，或一个字典自定义字体集合。][默认值：`fandol`]
字体集合是一系列字体名称的集合，包括其变体。
字体集合通常包含以下元素：宋体、黑体、楷体、仿宋。
字体集合至少包含一个元素，但无需包含所有元素。

=== 格式说明

字体集合应当是如下结构的字典。

```typ
#let fandol-fontset = (
  family: (
    song: (name: "FandolSong", variants: ("bold",)),
    hei: (name: "FandolHei", variants: ("bold",)),
    ... // 其他字体
  ),
  map: (
    text: (cjk: "song", latin: "serif"),
    strong: (cjk: "hei", latin: "serif"),
    .. // 其他元素
  )
)
```

具体字段含义如下：

- `family`： 一个字典，列出了所用的各种字形，如 `song`, `hei`, `kai`, `fang` 等。
  - `[key]`：字形的名称，是一个字典。
    - `name`：所用的字体的名称。
    - `variants`：这个字体包含的所有变体。
- `map`：一个字典，列出各种元素所使用的 CJK 字体和西文字体对应关系。
  - `[element]`：元素的名称
    - `cjk`：CJK 字体映射，格式为 `"family":"variant"`。其中 `family` 是 `family` 中的键，`variant` 是 `variants` 中的值。若指定了不再存在的变体，认为该字体不存在，回归使用 `family` 字典中的第一个字体。
    - `latin`：西文字体映射，可选项是 `"serif"`, `"sans"`, `"mono"` 或者字体名称。
      - `serif`：使用衬线字体。
      - `sans`：使用无衬线字体。
      - `mono`：使用等宽字体。

=== 预定义的集合

CTyp 包提供了以下预定义的字体集合：`fandol`, `fangzheng`, `source`, `noto`, `windows`, `huawen`。
安装对应字体后即可使用。字体集合的详细情况参考@app:fontsets。

== 修改字体映射

#note-ctyp-arg[font-cjk-map][字体映射表。修改字符集合定义的映射表。][默认值：`(:)`]
在字体集合提供默认字体映射的基础上，可以为特定元素修改其所使用的字体。
设置方法是通过 `ctyp()` 函数中的参数 `font-cjk-map` 来修改，格式参考字体集合字典中的 `map` 字段。
需要保证修改后的字体映射仍然能够找到对应的字体。

#note-ctyp-arg[font-latin][西文字体映射。定义每种西文字形所对应的字体。][默认值：`(:)`]
除了能够设置元素的中文字体，还可以通过 `font-latin` 参数设置西文字体映射。
西文字体的字形为 `fontset.map.[element].latin` 中所用到的值，一般情况下是 `serif`, `sans`, `mono` 三种。
该参数需要为这些字形指定具体的字体。

#tip-block(title: [修改字体映射])[
  将 `strong` 元素从使用#strong[黑体]改为使用宋体

  ```typ
  #let (ctypset, cjk) = ctyp(
    font-cjk-map: (
      strong: (cjk: "song:bold", latin: "sans"),
    ),
    font-latin: (
      sans: "Arial"
    )
  )
  #show: _ctypset
  #strong[加粗的宋体内容]
  ```

  #let (_ctypset, _cjk) = ctyp(
    font-cjk-map: (
      strong: (cjk: "song:bold", latin: "sans"),
    ),
    font-latin: (
      sans: "Arial"
    )
  )
  #show: _ctypset
  *加粗的宋体内容，西文使用 Sans 字体*
]

从上面的例子可以看到，*默认情况下 `strong` 元素使用常规黑体*，而非#hei(weight: "bold")[加粗的黑体]，
也就是和 ```typ #hei(weight: "regular")[]``` 的#hei(weight: "regular")[效果]相同。
如果使用#hei(weight: "bold")[加粗的黑体]，则可能过粗。
这通常也是 LaTeX 中的默认行为。
如果偏好 Microsoft Word 的行为，即使用黑体的情况下加粗，那么可以在 `font-cjk-map` 中将对应元素的 `cjk` 字段增加一个 `:bold` 后缀。

#important-block(title: [注意])[
  为了实现这一效果，`strong` 元素的 `delta` 被设置为 `0`，并全局生效。如果这导致了异常的行为，可以在 `ctyp()` 函数中设置 `reset-strong-delta` 参数为 `300`，则恢复默认行为。
  该值是 Typst 文档中标注的默认值。如果希望使用其他值，可以自行设置。
]

== 使用 CJK 字体

函数 `ctyp()` 的返回值中的第二个元素 `cjk` 是一个字典。字典的键都来自于字体集合中 `family` 字段的键，也就是字形的名称；值是一个函数，直接使用可以修改内容的字体。
这些函数提供一个参数 `weight` 用于设置字体粗细。

#tip-block(title: [直接使用 CJK 字体])[
```typ
#let (ctypset, cjk) = ctyp()
#let (song, hei, kai, fang) = cjk
- #song[这是宋体内容]
- #hei(weight: "bold")[这是黑体加粗内容]
- #kai[这是楷体内容]
- #fang[这是仿宋内容]
```

#let (ctypset_, cjk_) = ctyp()
#let (song, hei, kai, fang) = cjk_
- #song[这是宋体内容]
- #hei(weight: "bold")[这是黑体加粗内容]
- #kai[这是楷体内容]
- #fang[这是仿宋内容]
]

这些函数中的西文字体默认使用 `ctyp()` 函数参数 `font-latin` 中的 `serif` 字体。
若要修改西文字体，可以通过这些修改这些函数中的 `latin` 参数来实现，该参数接受 `font-latin` 中的键，或具体的字体名称。

#tip-block(title: [使用CJK字体并设置西文字体])[
  ```typ
  #fang(latin: "mono")[使用仿宋体和 monospace 西文字体。]
  ```
  
  #fang(latin: "mono")[使用仿宋体和 monospace 西文字体。]
]

== 智能引号（Smartquote）

#note-ctyp-arg[fix-smartquote][设置是否开启智能引号修复。][默认值：`true`]
当中文与英文混杂时，如果通过 ```typ set text(lang: "zh")``` 设置了，Typst 在英文中也会使用中文的智能引号。
为了修复这一问题，该包参考了#link("https://typst-doc-cn.github.io/guide/FAQ/smartquote-font.html")[“Typst 中文社区”]中提供的解决方案，将智能引号的字体设置为 Latin 字体。
考虑到中文书写时，往往不会使用智能引号，而是依赖输入法进行输入；而使用英文时，却往往需要智能引号，尤其是在纯文本编辑器中。
因此，该包默认开启了智能引号的字体设置。

#warning-block[
  该功能启用时，无论是中文还是英文，智能引号都会使用西文字体。反之，手动引号（使用 `sym.quote.l` 和 `sym.quote.r` 或与之相应的字符）都会使用中文字体。也就是说：
  - 中文应当使用“手动引号”，使用"智能引号"则会使用西文字体。
  - Users should use "smartquote" in Latin text; otherwise, “manual quotes” will result in CJK characters.
]

如果不喜欢该功能，可以将 `ctyp()` 函数的参数 `fix-smartquote` 设置为 `false`，则不修复智能引号字体。

= 列表

== 列表布局优化

#note-ctyp-arg[fix-list-enum][设置是否修复列表样式。][默认值：`true`]
不论是编号列表还是符号列表，在使用中文时，很容易产生列表项目符号与内容基线不平的问题。
该包重新设置了列表的样式，使得列表项目符号与内容基线对齐。
该功能默认开启。

#note-block(title: [修复后的列表])[
+ 项目1
+ 项目2
  - 项目2.1
  - 项目2.2
  - 项目2.3
    - 项目2.3.1
    - 项目2.3.2
    - 项目2.3.3
      + 项目2.3.3.1
      + 项目2.3.3.2
        + 项目2.3.3.2.1
]

如果不喜欢该功能，可以将 `ctyp()` 函数的参数 `fix-list-enum` 设置为 `false`，则不修复列表样式。

#tip-block(title: [不修复列表])[
```typ
#let (theme, _) = ctyp(
  fix-list-enum: false,
)
#show: theme
```
]

== 列表布局设置

#note-ctyp-arg[fix-list-args][列表样式设置。设置列表的样式。][默认值：`(:)`]
如果要修改默认的列表布局，可以通过 `ctyp()` 函数的参数 `fix-list-args` 和 `fix-enum-args` 来设置。
这两个参数都是一个字典，包含了列表的样式设置，已尽可能兼容 Typst 提供的 `list` 和 `enum` 两个函数的参数。
具体参数说明如下：

#align(center)[#table(
  columns: 3,
  align: (x, y) => if y == 0 or x == 0 { center + horizon} else { left + horizon },
  table.header[*参数*][*含义*][*默认值*],
  [`marker`], [符号列表的备选符号，循环使用，遇到编号列后重置。], [#(sym.circle.filled, sym.triangle.r.filled, sym.dash).join(", ")],
  [`numberer`], [编号列表的编号格式，循环使用，遇到符号列表后重置。], [#("1)", "a)", "i)").join(", ")],
  [`tight`], [是否使用紧凑布局。], [#(true)],
  [`indent`], [列表整体缩进。表现为左侧的边距。], [#(0em)],
  [`body-indent`], [列表内容缩进。], [#(0.5em)],
  [`spacing`], [列表项目之间的间隔。如果使用紧凑布局，其值采用 `par.leading`；否则采用 `par.spacing`。], [#(auto)],
  [`label-sep`], [列表符号/编号与内容之间的间隔。], [#(0em)],
  [`marker-width`], [符号的宽度。], [#(0.5em)],
  [`number-width`], [编号的宽度。], [#(1.5em)],
  [`debug`], [调试模式。], [#(false)],
  [`..block-args`], [捕获所有其他传递到 `block` 函数的参数。], []
)]

== 列表编号设置

自 v0.3.0 版本起，使用 CTyp 包提供两个函数 `item-label` 和 `enum-label` 可以实现对列表每级编号格式参数的设置。
这两个函数分别接受一个位置参数，设置符号或者编号格式。
此外，可以单独设置以下参数：

/ `width`: 列表编号的宽度。
/ `sep`: 编号与内容之间的间隔。
/ `alignment`: 编号的对齐方式。可选值为 `left`, `center`, `right`。

例如，可以通过以下代码设置编号列表的编号格式：

```typ
#let (theme, _) = ctyp(
  fix-enum-args: (
    numberer: (
      enum-label("1.", width: 1em, alignment: left),
      "a.",
      enum-label("i)", width: 1em, alignment: right),
    )
  ),
  fix-list-args: (
    marker: (
      item-label(sym.suit, width: 1em),
      sym.dash
    )
  )
)
```

= 页面设置

#note-ctyp-func[page-grid][设置页芯大小，优先保证宽度为整字符数，避免过多分散对齐问题。]
通常中文环境下，对页面的设置是基于字符数的。
该包提供了一个 `page-grid()` 函数，可以根据字符数设置页面的边距。
该函数接收 `page()` 函数的 `margin` 参数的所有合法值，但是对于 `width` 和 `height` 参数，必须是整数，表示字符的数量。

#tip-block(title: [页面设置])[
```typ
#import "@local/ctyp:0.3.1": page-grid
#show: page-grid.with(
  width: 45,
  height: 70
)
```
]

#note-block[
  由于 Typst 的限制，页面设置不能放在 `ctyp()` 函数中。
  目前采用的是提供单独的 `page-grid()` 函数来设置页面。
  这也有一些额外的好处，例如可以与其他包结合使用。
]

= 标题编号设置

#note-ctyp-arg[heading-numbering][标题编号设置。][默认值：`none`]
Typst 提供了实现任何标题编号格式的能力，但这种方法往往会比较复杂。
中文文档的标题设置通常也具有一定的规律性，可以通过配置参数来实现。
该包提供了 `ctyp()` 函数的参数 `heading-numbering` 来设置标题编号。
该参数可以接受多种类型的值：

- *单值*：用于统一设置所有级别的标题的编号格式。包括以下几种：
  - `none`：无编号。
  - 字符串：接受所有 Typst 支持的编号格式，即 `numbering()` 函数可接受的值。
  - 字典：用于设置编号格式的字典，包含以下字段：
    - `format`：表示编号格式。
      - 接受所有 Typst 支持的编号格式。
      - 接受一个函数 ```typst (..nums) => content``` 其中 `nums` 是一个数组，包含了当前标题的所有级别的编号。函数的返回值是一个内容，用于显示编号。
    - `sep`：间隔，表示编号与标题内容之间的间隔。可以是任何合法的长度值。
    - `align`：对齐方式，可以是 `left`, `center`, `right` 中的一个。默认值为 `left`。
    - `hanging-indent`：悬挂缩进。设置该值可调整标题悬挂缩进长度。默认为编号部分的宽度。
    - `first-line-indent`：首行缩进。设置该值可调整标题首行缩进长度。默认值为 `0em`。
    - `prefix`：前缀。表示编号前的内容，可以是任何内容。
    - `suffix`：后缀。表示编号后的内容，可以是任何内容。
- *数组*：数组中的每个元素都是上面可接受的单值。第 $i$ 个元素（从1开始算）用于设置第 $i$ 级标题的编号格式。如果数组长度小于标题级别，则使用数组中的最后一个元素来设置。

#context[
  #let current-heading-number = counter(heading.where(level: 1)).get()
  #counter(heading).update(0)
  #tip-block(title: [中文编号格式示例一])[
    ```typ
    #let (ctypset_, cjk_) = ctyp(
      heading-numbering: ((
        format: "一、",
        sep: 0em
      ), "1.1")
    )
    #show: ctypset_
    = 这是一级标题
    == 这是二级标题
    ```
    #set heading(outlined: false, bookmarked: false)
    #let (ctypset_, cjk_) = ctyp(
      heading-numbering: ((
        format: "一、",
        sep: 0em
      ), "1.1")
    )
    #show: ctypset_
    = 这是一级标题
    == 这是二级标题
  ]
  #counter(heading).update(current-heading-number)
]

#context[
  #let current-heading-number = counter(heading.where(level: 1)).get()
  #counter(heading).update(0)
  #tip-block(title: [中文编号格式示例二])[
    ```typ
    #let (ctypset_, cjk_) = ctyp(
      heading-numbering: ((
        format: "一",
        sep: 1em,
        align: center
      ), "1.1")
    )
    #show: ctypset_
    = 这是一级标题
    == 这是二级标题
    ```
    #set heading(outlined: false, bookmarked: false)
    #let (ctypset_, cjk_) = ctyp(
      heading-numbering: ((
        format: "一",
        sep: 1em,
        align: center
      ), "1.1")
    )
    #show: ctypset_
    = 这是一级标题
    == 这是二级标题
  ]
  #counter(heading).update(current-heading-number)
]

#show: appendix

= 参考

#{
  set heading(numbering: none)
  set par(first-line-indent: 0em)
  let refs = tidy.parse-module((
    "../src/ctyp.typ",
    "../src/utils/enumitem.typ",
    "../src/utils/page-grid.typ",
  ).map(read).join("\n\n"), name: "CTyp")
  tidy.show-module(refs, style: tidy.styles.default)
}

= 预定义的字体集合 <app:fontsets>

#align(center)[
  #table(
    columns: 4,
    align: center + horizon,
    table.header[*集合名称*][*字形*][*字体标识*][*中文名称*],
    ..yaml("fontsets.yaml").map(fs => {
      let family = fs.at("family", default: none)
      if family == none {
        (
          table.cell(rowspan: n-shapes, fs.name),
          ([], ) * 3
        ).flatten()
      } else {
        let n-shapes = fs.family.len()
        (
          table.cell(rowspan: n-shapes, fs.name),
          fs.family.map(it => (it.shape, raw(it.id), it.at("name", default: "")))
        ).flatten()
      }
    }).flatten()
  )
]
