# Typst Pointless Size——字号 zìhào

<a href="https://typst.app/universe/package/pointless-size">
    <img src="https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fpointless-size&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE" />
</a>

中文字号的号数制及字体度量单位。
Chinese size system (hào-system) and type-related measurements units.

```typst
#import "@preview/pointless-size:0.1.1": zh, zihao

#set text(size: zh(5)) // 五号（10.5pt）
// or
#set text(zh(5))
#show: zihao(5)

// 小号用负数表示 use negative numbers for small sizes 
#zh(-4) // 小四（12pt）
#zh(1) // 一号（26pt）
#zh(-1) // 小一（24pt）
#zh("-0") // 小初（36pt）
#zh(0) // 初号（42pt）

// 写汉字也可以 Han characters are also acceptable
#zh("五号")
#zh("五")
#zh("小五")
```

[![转换表 Conversion table](https://github.com/user-attachments/assets/1cbdcedd-9ab0-4f62-9e67-4d4ef222972e)](https://github.com/YDX-2147483647/typst-pointless-size/blob/main/docs/conversion-table.typ)
[![倍数关系 Multiples](https://github.com/user-attachments/assets/d045ca93-7995-410e-bc35-782f976d4466)](https://github.com/YDX-2147483647/typst-pointless-size/blob/main/docs/multiples.typ)

## 覆盖定义 Override

字号没有统一规定，本包默认与 [CTeX、MS Word、WPS、Adobe 的中文规则][docs-ref]一致。
Chinese size systems were not standardized. By default, this package is consistent with [Chinese rules of CTeX, MS Word, WPS, Adobe][docs-ref].

如想覆盖定义：If you want to override:

```typst
#import "@preview/pointless-size:0.1.1": zh as _zh

#let zh = _zh.with(overrides: ((7, 5.25pt),))

#assert.eq(_zh(7), 5.5pt)
#assert.eq(zh(7), 5.25pt)
```

[docs-ref]: https://github.com/YDX-2147483647/typst-pointless-size/blob/main/docs/ref.md
