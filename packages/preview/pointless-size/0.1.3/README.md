# Typst Pointless Size——字号 zìhào

[![Typst Universe](https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fpointless-size&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=universe&labelColor=white&color=%23239DAE)](https://typst.app/universe/package/pointless-size)
[![GitHub Repo stars](https://img.shields.io/github/stars/YDX-2147483647/typst-pointless-size?style=flat&logo=github)](https://github.com/YDX-2147483647/typst-pointless-size)
[![Changelog](https://img.shields.io/badge/changelog-gray?logo=github)](https://github.com/YDX-2147483647/typst-pointless-size/blob/v0.1.3/CHANGELOG.md)

中文字号的号数制及字体度量单位。
Chinese size system (hào-system) and type-related measurements units.

```typst
#import "@preview/pointless-size:0.1.3": zh, zihao

#set text(size: zh(5)) // 五号（10.5pt）
// or
#set text(zh(5))
#show: zihao(5)

// 小号用负数或 .5 表示 Use negative numbers or .5 for small sizes 
#zh(-4)   #zh(4.5) // 小四（12pt）
#zh(1)    #zh(1.0) // 一号（26pt）
#zh(-1)   #zh(1.5) // 小一（24pt）
#zh("-0") #zh(0.5) // 小初（36pt）
#zh(0)    #zh(0.0) // 初号（42pt）

// 写汉字也可以 Han characters are also acceptable
#zh("五号") #zh("五")
#zh("小五")
```

[![转换表 Conversion table](https://ydx-2147483647.github.io/typst-pointless-size/assets/conversion-table.svg)](https://github.com/YDX-2147483647/typst-pointless-size/blob/v0.1.3/docs/conversion-table.typ)
[![倍数关系 Multiples](https://ydx-2147483647.github.io/typst-pointless-size/assets/multiples.svg)](https://github.com/YDX-2147483647/typst-pointless-size/blob/v0.1.3/docs/multiples.typ)

## 覆盖定义 Override

字号没有统一规定，本包默认与 [CTeX、MS Word、WPS、Adobe 的中文规则][docs-ref]一致。
Chinese size systems were not standardized. By default, this package is consistent with [Chinese rules of CTeX, MS Word, WPS, Adobe][docs-ref].

如想覆盖定义：If you want to override:

```typst
#import "@preview/pointless-size:0.1.3": zh as _zh

#let zh = _zh.with(overrides: ((7, 5.25pt),))

#assert.eq(_zh(7), 5.5pt)
#assert.eq(zh(7), 5.25pt)
```

[docs-ref]: https://github.com/YDX-2147483647/typst-pointless-size/blob/v0.1.3/docs/ref.md

## 参考资料 References

- [基本参考链接 Basic Reference Links][docs-ref]（中文 + English）

- 资料汇编：汉字号数与点数的映射关系 Reference Compilation: Mapping Between the Chinese Size System and the Point Unit（中文 only）

  [分章版首页 per-chapter homepage][ref-one-pdf] (~0.2 MB) / [合集版 all-in-one][ref-split-pdf] (~30 MB)

[ref-one-pdf]: https://ydx-2147483647.github.io/typst-pointless-size/ref/index.pdf
[ref-split-pdf]: https://ydx-2147483647.github.io/typst-pointless-size/ref.pdf
