# Typst Pointless Size——字号 zìhào

中文字号的号数制及字体度量单位。
Chinese size system (hào-system) and type-related measurements units.

```typst
#import "@preview/pointless-size:0.1.0": zh, zihao

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
```

字号没有统一规定，本包默认与 CTeX、MS Word、WPS、Adobe 的中文规则一致。
Chinese size systems were not standardized. By default, this package is consistent with Chinese rules of CTeX, MS Word, WPS, Adobe.

如想覆盖定义：If you want to override:

```typst
#import "@preview/pointless-size:0.1.0": zh as _zh

#let zh = _zh.with(overrides: ((7, 5.25pt),))

#assert.eq(_zh(7), 5.5pt)
#assert.eq(zh(7), 5.25pt)
```

## 相关链接 Relevant links

> [!TIP]
>
> - ✅ = 一致 consistent
> - 👪 = 与描述的规则之一一致 consistent with one of the described rules
> - 🚸 = 不完全一致 not fully consistent

- 🚸[§2.3.5 基本版式设计的注意事项 - 中文排版需求 | W3C 编辑草稿](https://www.w3.org/International/clreq/#considerations_in_designing_type_area)（中/英）\[2024-09-13\]

  > “号”由于当年金属活字各地厂家的规范不一而不尽相同……不作为规范性规定。

  §2.3.5 Considerations when Designing the Type Area - Requirements for Chinese Text Layout | W3C Editor's Draft (Chinese & English)

  > These hào-systems were not standardized by the various foundries in the past. …It is not normative information.

- ✅表25 中文字号 - [CTeX v2.5.0 (2022-07-14) 宏集手册 | CTAN](http://mirrors.ctan.org/language/chinese/ctex/ctex.pdf)（中文）

  Table 25 Chinese text size - Documentation of the package CTeX v2.5.10 (2022-07-14) (Chinese)

  https://github.com/CTeX-org/ctex-kit/blob/0fb196c42c56287403fecca6eb6b137c00167f40/ctex/ctex.dtx#L9974-L9993

- 👪[字体度量单位 - CJK Type Blog | Adobe](https://ccjktype.fonts.adobe.com/2009/04/post_1.html)（中/英）\[2009-04-02\] ([archive.today](https://archive.today/QxXuk))

  Type-related Measurements Units (Chinese & English)

- ✅[如何转换字号、磅、px？- 技巧问答 | WPS学堂](https://www.wps.cn/learning/question/detail/id/2940)（中文）\[2020-05-07\]

  How to convert between hào, point, and pixel? - Tech Q&A | WPS learning (Chinese)

- [#135 显明解行号号珍 - 字谈字畅 | The Type](https://www.thetype.com/typechat/ep-135/)（中文，带文字说明的播客）\[2020-09-09\] ([archive.today](https://archive.today/qaG8D))

  (Chinese, podcast with show notes)

- [#543 ctexsize: 重设各级字号大小 - CTeX-org/ctex-kit | GitHub](https://github.com/CTeX-org/ctex-kit/issues/543)（中文）\[2020-10-13\]

  #543 ctextsize: Redesign the font size system (Chinese)

- ✅[GB 40070–2021 儿童青少年学习用品近视防控卫生要求 - 国家标准 | 全国标准信息公共服务平台](https://std.samr.gov.cn/gb/search/gbDetailed?id=BBE32B661B7E8FC8E05397BE0A0AB906)（中文）\[2021-02-20\]

  其中用到了号数制，例如4.3.1“小学一、二年级用字应不小于16P（3号）字”。总结下来是三号 16pt、四号 14pt、小四 12pt、五号 10.5pt、小五 9pt。

  GB 40070–2021 Hygienic requirements of study products for myopia prevention and control in children and adolescents - National standards | National public service platform for standards information (Chinese)

  The standard uses hào-system, e.g. 4.3.1 “texts for grade 1/2 of primary school should not be less than 16P (size 3)”. To summarize, size 3 = 16pt, size 4 = 14pt, size small 4 = 12pt, size 5 = 10.5pt, size small 5 = 9pt.

- 👪[字号（印刷）| 维基百科](https://zh.wikipedia.org/wiki/%E5%AD%97%E5%8F%B7_(%E5%8D%B0%E5%88%B7))（中文）

  Hào (typography) | Wikipedia (Chinese)
