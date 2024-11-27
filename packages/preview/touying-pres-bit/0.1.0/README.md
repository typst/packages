# touying-pres-ustc 中国科学技术大学touying演示模板

**www.中国科学技术大学.com**

```typ
#import "@preview/touying-pres-ustc:0.2.0": *

#let s = register(aspect-ratio: "16-9")
#let s = (s.methods.numbering)(self: s, section: "1.", "1.1")
#let s = (s.methods.info)(
  self: s,
  title: [Typst template for School of Computer Science and Technology, USTC],
  subtitle: [Continuously Improving...],
  author: [Quaternijkon],
  date: datetime.today(),
  institution: [School of Computer Science and Technology, USTC],
  logo: image("../../assets/img/USTC.svg", width: 50%),
  github: []
)

#let (init, slides) = utils.methods(s)
#let (slide, empty-slide, title-slide, outline-slide, new-section-slide, ending-slide, focus-slide,matrix-slide) = utils.slides(s)

#show: codly-init.with()
#show: init
#show: slides.with()

#outline-slide()

= Section

== Page
```

## 省流版

`content/example/main.typ`是渲染的入口

## Change log

### 0.2.0

修改文件组织结构
