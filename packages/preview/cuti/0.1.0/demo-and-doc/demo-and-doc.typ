#import "../lib.typ": *
#import "@preview/sourcerer:0.2.1": code

#set par(justify: true)

= Cuti Demo & Doc

== Introduction

Cuti is a package that simulates fake bold weight for fonts by utilizing the `stroke` attribute of `text`. This package is typically used on fonts that do not have a `bold` weight, such as "SimSun".

This package uses 0.02857em as the parameter for stroke. In Microsoft Office software, enabling fake bold will apply a border of about 0.02857em to characters. This is where the value of 0.02857em is derived from. (In fact, the exact value may be $1/35$.)

#line(length: 100%)

== fakebold

`#fakebold[]` with no parmerter will apply the #fakebold[fakebold] effect to characters.

#code(
  numbering: true,
  radius: 0pt,
  text-style: (font: ("Courier New", "SimHei")),
  ```typst
  Fakebold: #fakebold[#lorem(5)] \
  Bold: #text(weight: "bold", lorem(5)) \ 
  Bold + Fakebold: #fakebold[#text(weight: "bold", lorem(5))]
  ```
)

#block(
  stroke: (paint: blue, thickness: 1pt, dash: "dashed"),
  inset: 10pt,
)[
  Fakebold: #fakebold[#lorem(5)] \
  Bold: #text(weight: "bold", lorem(5)) \
  Bold + Fakebold: #fakebold[#text(weight: "bold", lorem(5))]
]

`#fakebold[]` has a `base-weight` parameter that can be used to specify a certain weight as the base weight for fake bold. By default, or when `base-weight` is `none`, the base weight will be inherited from the above context.

#code(
  numbering: true,
  radius: 0pt,
  text-style: (font: ("Courier New", "SimHei")),
  ```typst
  Bold + Fakebold: #fakebold(base-weight: "bold")[#lorem(5)] \
  #set text(weight: "bold")
  Bold + Fakebold: #fakebold[#lorem(5)]
  ```
)

#block(
  stroke: (paint: blue, thickness: 1pt, dash: "dashed"),
  inset: 10pt,
)[
  Bold + Fakebold: #fakebold(base-weight: "bold")[#lorem(5)] \
  #set text(weight: "bold")
  Bold + Fakebold: #fakebold[#lorem(5)]
]

#line(length: 100%)

== #regex-fakebold

The `#regex-fakebold` is designed to be used in multilingual and multi-font scenarios. It allows the use of a RegExp string as the `reg-exp` parameter to match characters that will have the fake bold effect applied. It also accepts the `base-weight` parameter.

#code(
  numbering: true,
  radius: 0pt,
  text-style: (font: ("Courier New", "SimHei")),
  ```typst
  + RegExp `[a-o]`: #regex-fakebold(reg-exp: "[a-o]")[#lorem(5)]
  + RegExp `\p{script=Han}`: #regex-fakebold(reg-exp: "\p{script=Han}")[衬衫的价格是9磅15便士。] \
  #set text(weight: "bold")
  + RegExp `\p{script=Han}`: #regex-fakebold(reg-exp: "\p{script=Han}")[衬衫的价格是9磅15便士。]
  ```
)

#block(
  stroke: (paint: blue, thickness: 1pt, dash: "dashed"),
  inset: 10pt,
)[
  + RegExp `[a-o]`: #regex-fakebold(reg-exp: "[a-o]")[#lorem(5)] \
  + RegExp `\p{script=Han}`: #regex-fakebold(reg-exp: "\p{script=Han}")[衬衫的价格是9磅15便士。] \
  #set text(weight: "bold")
  + RegExp `\p{script=Han}`: #regex-fakebold(reg-exp: "\p{script=Han}")[衬衫的价格是9磅15便士。] 
]

In Example \#3, `9` and `15` are the real bold characters from the font file, while the other characters are simulated as "fake bold" based on the `regular` weight.

#line(length: 100%)

== show-fakebold

In multilingual and multi-font scenarios, different languages often utilize their own fonts, but not all fonts contain the `bold` weight. It can be inconvenient to use `#fakebold` or `#regex-fakebold` each time we require `strong` or `bold` effects. Therefore, the `#show-fakebold` function is introduced for `show` rule.

The `show-fakebold` function shares the same parameters as `regex-fakebold`. By default, `show-fakebold` will apply the RegExp `"."`, which means all characters with the `strong` or `weight: "bold"` property will be fakebolded if the corresponding show rule has been set.

`show text` rule and `show strong` rule should be set sperately.

#code(
  numbering: true,
  radius: 0pt,
  text-style: (font: ("Courier New", "SimHei")),
  ```typst
  #show text: show-fakebold
  Regular: #lorem(10) \
  #text(weight: "bold")[Bold: #lorem(10)]
  ```
)

#block(
  stroke: (paint: blue, thickness: 1pt, dash: "dashed"),
  inset: 10pt,
)[
  #show text: show-fakebold
  Regular: #lorem(10) \
  #text(weight: "bold")[Bold: #lorem(10)]
]

Typically, the combination of bold + fakebold is not the desired effect. It is usually necessary to specify the RegExp to indicate which characters should utilize the fakebold effect.

#code(
  numbering: true,
  radius: 0pt,
  text-style: (font: ("Courier New", "SimHei")),
  ```typst
  #show strong: it => show-fakebold(reg-exp: "\p{script=Han}", it)
  Regular: 我正在使用 Typst 排版。 \
  Strong: *我正在使用 Typst 排版。*
  ```
)

#block(
  stroke: (paint: blue, thickness: 1pt, dash: "dashed"),
  inset: 10pt,
)[
  #show strong: it => show-fakebold(reg-exp: "\p{script=Han}", it)
  Regular: 我正在使用 Typst 排版。 \
  Strong: *我正在使用 Typst 排版。*
]

It also accepts the `base-weight` parameter.


#line(length: 100%)

== cn-fakebold & show-cn-fakebold

`cn-fakebold` and `show-cn-fakebold` are encapsulations of the above `regex-fakebold` and `show-fakebold`, pre-configured for use with Chinese text. Please refer to the Chinese documentation for usage instructions.

