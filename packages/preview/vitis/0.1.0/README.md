# vitis

An automatic organizer for beautiful line breaking in scripts without whitespace word separators.

This package provides phrase segmentation for Japanese, Simplified Chinese, Traditional Chinese, and Thai based on [BudouX](https://github.com/google/budoux).

## Usage

```typst
// Pretrained models
#import "@preview/vitis:0.1.0": (
  japanese-parser, simplified-chinese-parser, thai-parser,
  traditional-chinese-parser,
)

// Japanese
#assert.eq(
  (japanese-parser.parse)(
    "Google の使命は、世界中の情報を整理し、世界中の人がアクセスできて使えるようにすることです。",
  ),
  (
    "Google の",
    "使命は、",
    "世界中の",
    "情報を",
    "整理し、",
    "世界中の",
    "人が",
    "アクセスできて",
    "使えるように",
    "する",
    "ことです。",
  ),
)

// Simplified Chinese
#assert.eq(
  (simplified-chinese-parser.parse)(
    "我们的使命是整合全球信息，供大众使用，让人人受益。",
  ),
  (
    "我们",
    "的",
    "使命",
    "是",
    "整合",
    "全球",
    "信息，",
    "供",
    "大众",
    "使用，",
    "让",
    "人",
    "人",
    "受益。",
  ),
)

// Traditional Chinese
#assert.eq(
  (traditional-chinese-parser.parse)(
    "我們的使命是匯整全球資訊，供大眾使用，使人人受惠。",
  ),
  (
    "我們",
    "的",
    "使命",
    "是",
    "匯整",
    "全球",
    "資訊，",
    "供",
    "大眾",
    "使用，",
    "使",
    "人",
    "人",
    "受惠。",
  ),
)

// Thai
#assert.eq((thai-parser.parse)("วันนี้อากาศดี"), (
  "วัน",
  "นี้",
  "อากาศ",
  "ดี",
))

// Custom model
#import "@preview/vitis:0.1.0": create-parser

#let test-sentence = "abcdeabcd"

#let p-a = create-parser(("UW4": ("a": 10000)))
#assert.eq((p-a.parse)(test-sentence), ("abcde", "abcd"))

#let p-b = create-parser(("UW4": ("b": 10000)))
#assert.eq((p-b.parse)(test-sentence), ("a", "bcdea", "bcd"))

#assert.eq((create-parser((:)).parse)(""), ())

#assert.eq((p-a.separate)("abcdeabcd", separator: "|"), "abcde|abcd")
```

## Example

```typst
#import "@preview/vitis:0.1.0": japanese-parser

#let segmented-paragraph(text, parser) = {
  let segments = (parser.parse)(text)
  for i in range(segments.len()) {
    box((segments.at(i)), stroke: red)
  }
}

#let ihatovo = "あのイーハトーヴォのすきとおった風、夏でも底に冷たさをもつ青いそら、うつくしい森で飾られたモリーオ市、郊外のぎらぎらひかる草の波。"

#set text(font: "Noto Sans CJK JP", size: 46pt)

== With BudouX

#segmented-paragraph(ihatovo, japanese-parser)

#pagebreak()

== Without BudouX

#ihatovo
```

<table>
  <tr>
    <td>
      <img src="https://raw.githubusercontent.com/3w36zj6/typst-vitis/refs/tags/v0.1.0/examples/segmented-paragraph1.svg" alt="With BudouX example" width="720" />
    </td>
    <td>
      <img src="https://raw.githubusercontent.com/3w36zj6/typst-vitis/refs/tags/v0.1.0/examples/segmented-paragraph2.svg" alt="Without BudouX example" width="720" />
    </td>
  </tr>
</table>

## License

This package is based on [BudouX](https://github.com/google/budoux) and is licensed under the Apache License 2.0.
