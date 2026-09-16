# monet-touying-cdu

## 简介 Introduction
这是一个由本校学生自行维护的，以校徽为主题色，莫奈取色为灵感的 Touying 模板。

This is a Touying template maintained by students of this school, featuring the school emblem as its theme color and inspired by Monet's colors.

## 演示样例 Example

```typ
#import "@preview/monet-touying-cdu:1.0.0": *

#show: cdu-theme.with(
  config-info(
    title: [标题],
    subtitle: [子标题],
    author: [作者],
    institution: [计算机学院],
    date: datetime.today(),
  ),
)

#title-slide()

#outline-slide(title: "目录")

= 一级标题（no focus）

== 二级标题
#lorem(200)

= 一级标题（focus and repeat)
#focus-slide()

= 一级标题（focus but no repeat)
#focus-slide(title: "一级标题")

== 二级标题
#lorem(200)

#end-slide(content: "Thanks for listening!")
```
