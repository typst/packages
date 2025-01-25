#import "../lib.typ": *
#import "./otr/utils.typ": *

#set page(margin: 2cm)
#set par(justify: true)

#show raw.where(block: false): set text(font: "Fira Code")

#show heading.where(level: 1): it => {pagebreak(weak: true); it}
#show heading.where(level: 2): it => {line(length: 100%); it}

= Cuti Demo & Doc

== Introduction

Cuti is a package designed for simulating fake bold / fake italic. 


== Demo

=== Part 1: `font: ("Times New Roman", "SimSun")`
#block(
  fill: rgb("dcedc8"),
  stroke: 0.5pt + luma(180),
  inset: 10pt,
  width: 100%,
)[
  #set text(font: ("Times New Roman", "SimSun"))
  #grid(
    columns: 2,
    column-gutter: 0.2em,
    row-gutter: 0.6em,
    [Regular:], [你说得对，但是《Cuti》是一个用于伪粗体和伪斜体的包。],
    [Bold(Font Only):], text(weight: "bold")[你说得对，但是《Cuti》是一个用于伪粗体和伪斜体的包。],
    [Bold(Fake Only):], fakebold[你说得对，但是《Cuti》是一个用于伪粗体和伪斜体的包。],
    [Bold(Fake+Font):], show-cn-fakebold(text(weight: "bold")[你说得对，但是《Cuti》是一个用于伪粗体和伪斜体的包。]),
    [Italic(Font Only):], text(style: "italic")[你说得对，但是《Cuti》是一个用于伪粗体和伪斜体的包。],
    [Italic(Fake Only):], fakeitalic[你说得对，但是《Cuti》是一个用于伪粗体和伪斜体的包。],
    [Italic(Fake+Font):], regex-fakeitalic(reg-exp: "[\p{script=Han} ！-･〇-〰—]", text(style: "italic")[你说得对，但是《Cuti》是一个用于伪粗体和伪斜体的包。]),
  )
]

=== Part 2: `font: "Source Han Serif SC"`
#block(
  fill: rgb("dcedc8"),
  stroke: 0.5pt + luma(180),
  inset: 10pt,
  width: 100%,
)[
  #set text(font: "Source Han Serif SC")
  #grid(
    columns: 2,
    column-gutter: 0.2em,
    row-gutter: 0.6em,
    [Regular:], [前面忘了。同时，逐步发掘「Typst」的奥妙。],
    [Bold(Font Only):], text(weight: "bold")[前面忘了。同时，逐步发掘「Typst」的奥妙。],
    [Bold(Fake Only):], fakebold[前面忘了。同时，逐步发掘「Typst」的奥妙。],
    [Bold(Fake+Font):], show-cn-fakebold(text(weight: "bold")[前面忘了。同时，逐步发掘「Typst」的奥妙。])
  )
]

= Fake Bold

Cuti simulates fake bold by utilizing the `stroke` attribute of `text`. This package is typically used on fonts that do not have a `bold` weight, such as "SimSun". This package uses 0.02857em as the parameter for stroke. In Microsoft Office software, enabling fake bold will apply a border of about 0.02857em to characters. This is where the value of 0.02857em is derived from. (In fact, the exact value may be $1/35$.)

== fakebold

`#fakebold[]` with no parmerter will apply the #fakebold[fakebold] effect to characters.

#example(
  ```typst
  - Fakebold: #fakebold[#lorem(5)]
  - Bold: #text(weight: "bold", lorem(5))
  - Bold + Fakebold: #fakebold[#text(weight: "bold", lorem(5))]
  ```
)

`#fakebold[]` can accept the same parameters as `#text`. In particular, if the `weight` parameter is specified, it can be used to outline based on a certain font weight. If `weight` is not specified, the baseline font weight will be inherited from the context. Specifying the `stroke` parameter will be ignored.

#example(
  ```typst
  - Bold + Fakebold: #fakebold(weight: "bold")[#lorem(5)]
  - Bold + Fakebold: #set text(weight: "bold"); #fakebold[#lorem(5)]
  ```
)

*Note:* The `base-weight` parameter used by `cuti:0.2.0` is still retained to ensure compatibility.

== #regex-fakebold

The `#regex-fakebold` is designed to be used in multilingual and multi-font scenarios. It allows the use of a RegExp string as the `reg-exp` parameter to match characters that will have the fake bold effect applied. It can also accept the same parameters as `#text`.

#example(
  ```typst
  + RegExp `[a-o]`: #regex-fakebold(reg-exp: "[a-o]")[#lorem(5)]
  + RegExp `\p{script=Han}`: #regex-fakebold(reg-exp: "\p{script=Han}")[衬衫的价格是9磅15便士。] 
  + RegExp `\p{script=Han}`: #set text(weight: "bold"); #regex-fakebold(reg-exp: "\p{script=Han}")[衬衫的价格是9磅15便士。]
  ```
)

In Example \#3, `9` and `15` are the real bold characters from the font file, while the other characters are simulated as "fake bold" based on the `regular` weight.

If the `fill` parameter of `#text` is set to a specific color or gradient, , the fake bold outline will also change to the corresponding color.

#example(
  ```typst
  - Blue + Fakebold: #fakebold(fill: blue)[花生瓜子八宝粥，啤酒饮料矿泉水。#lorem(5)]
  - Gradient + Fakebold: #set text(fill: gradient.conic(..color.map.rainbow)); #fakebold[花生瓜子八宝粥，啤酒饮料矿泉水。#lorem(5)]
  ```
)

== show-fakebold

In multilingual and multi-font scenarios, different languages often utilize their own fonts, but not all fonts contain the `bold` weight. It can be inconvenient to use `#fakebold` or `#regex-fakebold` each time we require `strong` or `bold` effects. Therefore, the `#show-fakebold` function is introduced for `show` rule.

The `show-fakebold` function shares the same parameters as `regex-fakebold`. By default, `show-fakebold` will apply the RegExp `"."`, which means all characters with the `strong` or `weight: "bold"` property will be fakebolded if the corresponding show rule has been set.

#example(
  ```typst
  #show: show-fakebold
  - Regular: #lorem(10)
  - Bold: #text(weight: "bold")[#lorem(10)]
  ```
)

Typically, the combination of bold + fakebold is not the desired effect. It is usually necessary to specify the RegExp to indicate which characters should utilize the fakebold effect.

#example(
  ```typst
  #show: show-fakebold.with(reg-exp: "\p{script=Han}")
  - Regular: 我正在使用 Typst 排版。 
  - Strong: *我正在使用 Typst 排版。*
  ```
)

It can also accept the same parameters as `#text`.

== cn-fakebold & show-cn-fakebold

`cn-fakebold(`#typebox[content]`)`

`show-cn-fakebold(`#typebox[content]`)`

`cn-fakebold` and `show-cn-fakebold` are encapsulations of the above `regex-fakebold` and `show-fakebold`, pre-configured for use with Chinese text. Please refer to the Chinese documentation for detailed usage instructions.

= Fake Italic

The `skew` function used in cuti is from typst issue #2749 (https://github.com/typst/typst/issues/2749) by Enivex.

Cuti simulates fake italic by utilizing `rotate` and `scale`. This package uses $-0.32175$ as the default angle. In Microsoft Office software, enabling fake italic will apply a $arctan(1/3)$ skew effect to characters. Please note that due to different English fonts having varying skew angles, you may need to find a suitable angle on your own. If using Times New Roman alongside SimSun, the default angle is relatively appropriate.

== fakeitalic

`fakeitalic(` \
#h(2em) `ang:` #typebox[angle] default: `-0.32175,` \
#h(2em) #typebox[content] \
`)`

`#fakeitalic[]` will apply the #fakeitalic[fakeitalic]#h(1pt) effect to characters.

#example(
  ```typst
  - Regular: #lorem(5)
  - Italic: #text(style: "italic", lorem(5))
  - Fakeitalic: #fakeitalic[#lorem(5)]
  - Fakeitalic + Fakebold: #fakeitalic[#fakebold[#lorem(5)]]
  ```
)

The angle of skew can be adjusted through the `ang` parameter.

#example(
  ```typst
  - -10deg: #fakeitalic(ang: -10deg)[#lorem(5)]
  - -20deg: #fakeitalic(ang: -20deg)[#lorem(5)]
  - +20deg: #fakeitalic(ang:  20deg)[#lorem(5)]
  ```
)

== #regex-fakeitalic

`regex-fakeitalic(` \
#h(2em) `reg-exp:` #typebox[str] default: `"[^ ]",` \
#h(2em) `ang:` #typebox[angle] `,` \
#h(2em) `spacing:` #typebox[relative] #typebox[none] default: #typebox[none] `,` \
#h(2em) #typebox[content] \
`)`

The `#regex-fakeitalic` is designed to be used in multilingual and multi-font scenarios. It allows the use of a RegExp string as the `reg-exp` parameter to match characters that will have the fake bold effect applied. It also accepts the `ang` parameter.

#example(
  ```typst
  + RegExp `[a-o]`: #regex-fakeitalic(reg-exp: "[a-o]")[#lorem(5)]
  + RegExp `\p{script=Han}`: #regex-fakeitalic(reg-exp: "\p{script=Han}")[衬衫的价格是9磅15便士。] 
  + RegExp `\p{script=Han}`: #set text(style: "italic"); #regex-fakeitalic(reg-exp: "\p{script=Han}", ang: -10deg)[衬衫的价格是9磅15便士。]
  ```
)

In Example \#3, `9` and `15` are the real italic characters from the font file, while the other characters are simulated as "fake italic".

== Issues at hand

The current implementation of faux italics disrupts spacing, particularly the spacing between symbols and characters. This is especially evident in the demo.