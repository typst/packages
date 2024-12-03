# touying-pres-ustc 中国科学技术大学touying演示模板

**www.中国科学技术大学.com**

```typ
#import "@preview/touying-pres-ustc:0.2.0": *

#let s = register(aspect-ratio: "16-9")
#let s = (s.methods.numbering)(self: s, section: "1.", "1.1")
#let s = (s.methods.info)(
  self: s,
  title: [Typst template for University of Science and Technology of China],
  subtitle: [Continuously Improving...],
  author: [Quaternijkon],
  date: datetime.today(),
  institution: [School of Computer Science and Technology, USTC],
  logo: image("../../assets/img/USTC_logo_side.svg", width: 50%),
  head-logo: image("../../assets/img/ustc_logo_side.svg",width: 20%),
  github: ""
)
#let s = (s.methods.colors)(
  self: s, 
  primary: rgb("#004098"), 
  secondary: rgb("#004098")
)

#let (init, slides) = utils.methods(s)
#let (slide, empty-slide, title-slide, outline-slide, new-section-slide, ending-slide, focus-slide,matrix-slide) = utils.slides(s)

#show: codly-init.with()
#show: init
#show: slides.with()

#outline-slide()

= 第一章：样式

== 想分列显示？
```

## 省流版

`content/example/main.typ`是渲染的入口

## Change log

### 0.2.0 (2024-12-03)

- 修改文件组织结构
- 添加接口便于更换资源文件
