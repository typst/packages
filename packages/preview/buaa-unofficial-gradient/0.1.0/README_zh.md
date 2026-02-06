# buaa-unofficial-gradient
[中文文档](./README_zh.md)

[English Document](./README.md)

---
一个基于[touying](https://github.com/touying-typ/touying)开发的BUAA[typst](https://github.com/typst/typst)模板.

![Example-Title](https://github.com/user-attachments/assets/677171e2-439d-4065-9c4c-b14aa1def913)

| 目录                                                                                                     | 章节                                                                                                            |
| :------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------: |
| ![Example-Outline](https://github.com/user-attachments/assets/ae07e1a7-162e-455c-a091-433d953dd23a)      | ![Example-Section](https://github.com/user-attachments/assets/02c3759d-5c76-424b-b3ff-80d74be366cc)          |

| 内容                                                                                                     | 结束                                                                                                         |
| :------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------: |
| ![Example-Slide](https://github.com/user-attachments/assets/3f7ef484-cf92-4244-892d-7e0304e82f0d)        | ![Example-End](https://github.com/user-attachments/assets/84bdfe48-40b7-4c9c-ae72-d53ed45c51f2)              |

## 简介
本项目旨在为BUAAers提供一个易用, 美观的幻灯片模板. 

## 特性
**美观与简洁:** 
- 使用渐变, 校徽, 分块等使页面内容不过分单调与扁平.
- 仅在封边, 目录, 章节切换处添加较多元素. 内容页面尽可能保持简单, 不干扰内容输出.
- 集成了一些方便排版的[小工具](#小工具).

**BUAA视觉形象:**
- 将北航校徽元素融入页面排版中.
- 本模板配色来自[北航色彩规范](https://xcb.buaa.edu.cn/info/1091/2057.htm), 具体颜色如下:
```typst
#let buaa-blue = rgb(0, 91, 172)
#let star-blue = rgb(0, 61, 166)
#let sky-blue = rgb(0, 155, 222)
#let chinese-red = rgb(195, 13, 35)
#let quality-grey = rgb(135, 135, 135)
#let pro-gold = rgb(210, 160, 95)
#let pro-silver = rgb(209, 211, 211)
```

## 快速开始
创建一个typst文件, 在文件开头使用`#import "@preview/buaa-unofficial-gradient:0.1.0": *`导入该模板. 使用`#show: buaa-theme.with()`设置基本信息与初始化幻灯片.
```typst
#import "@preview/buaa-unofficial-gradient:0.1.0": *

#show: buaa-theme.with(
  config-info(
    title: [Buaa in Touying: Customize Your Slide Title Here],
    subtitle: [Customize Your Slide Subtitle Here],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
  ),
)


#title-slide()

#outline-slide()

= Section 1

== Slide 1


#end-slide()
```

## 小工具
根据自身需求开发了一些小工具.

### 颜色文本块
基于北航配色的颜色文本块.

示例:
```typst
== Section 2.1
#lorem(20)
#tblock(title: [Title])[#lorem(20)]
#rblock(title: [Title])[#lorem(20)]

== Section 2.2
#lorem(20)
#gblock(title: [Title])[#lorem(20)]
#sblock(title: [Title])[#lorem(20)]
```
![Color-Block](https://github.com/user-attachments/assets/976b71d6-0e28-45d7-a145-6b61c14ae3d4)

### 文献信息页
基于文献汇报需求, `#article-title()`可以快速创建一个展示文献信息的页面.

示例:
```typst
== Article title

#let example-article-fig = block(
  stroke: 1pt,
  height: 100%,
  width: 50%,
  [Article Figure],
)

#article-title(
  article-fig: example-article-fig,
  journal: [Science],
  impf: [45.8],
  pub-date: [20XX-XX-XX],
  quartile: [中科院 综合性期刊1区],
  core-research: [#lorem(10)],
  authors: [#lorem(10)],
  institution: [#lorem(10)],
)
```
![Article-Title](https://github.com/user-attachments/assets/787cfe20-e906-48ac-b359-fae9f05d0645)

### 内容并排
`#horz-block()`会自动将传入的内容块 (`#horz-block()[Content 1][Content 2]`) 使用线框包裹, 并排展示在幻灯片中.

示例:
```typst
== Section 3.1
#lorem(10)
#horz-block()[
  #image("./figures/bar_chart.svg")
  #lorem(10)
][
  #image("./figures/heatmap_field.svg")
  #lorem(10)
][
  #image("./figures/line_comparison.svg")
  #lorem(10)
]

== Section 3.1
#lorem(20)
#horz-block()[
  #image("./figures/bar_chart.svg")
  #lorem(10)
][
  #image("./figures/bar_chart.svg")
  #lorem(10)
][
  #image("./figures/bar_chart.svg")
  #lorem(10)
][
  #image("./figures/bar_chart.svg")
  #lorem(10)
]
```

![Horz-Block](https://github.com/user-attachments/assets/aed200e7-5f9b-4708-8014-514b20d445e8)

## 许可证
本项代码目采用 GPL-3.0 许可证。详见 [LICENSE](./LICENSE) 文件。
本项目包含的北航校徽及相关标识，其版权及商标权归北京航空航天大学所有，不属于本项目的开源授权范围。仅限于展示与学术交流等非商业用途, 严禁用于商业用途。

## 致谢
- 本模板基于 [typst](https://github.com/typst/typst) 和 [touying](https://github.com/touying-typ/touying) 实现.
- 本模板参考 [sdu-touying-simpl](https://github.com/Dregen-Yor/sdu-touying-simpl) 和 [diatypst](https://github.com/skriptum/diatypst).
