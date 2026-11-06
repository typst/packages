# ShuXueJuan

ShuXueJuan (数学卷 in Chinese, meaning math exam) is a simple math exam Typst template.

## Setup

```Typst
#import "@preview/shuxuejuan:0.1.3": *
#show: shuxuejuan.with(
  font: ("SimSun",),                // 正文字体
  font-bold: ("LXGW WenKai Mono",), // 用于粗体的字体
  qst-number-level2: auto,          // 二级标题编号是否连续
)
```

## Showcase & Feature

```Typst
// 大标题
#set document(title: "第一、二章复习卷")
#title()
// 个人信息
#si[班级][姓名][学号]
// 小标题
#title-small[第一章复习题]

// 标题即问题
= 解答题
== 第一大题
=== 第一小题
=== 第二小题<test1>

// 选择题与选项
== 这道题请选择#br[]选项。#op[$1+1$][$1+2$][$2+1$][$2+2$]

// 填空题与单位
== 飞机的速度是#bl[]#un[m/s]。

// 引用自动编号
== 第二大题
=== 第一小题；<test2>
=== 利用 @test1 得到的知识，说明$1+1=2$；
=== 利用 @test2 得到的知识，说明$1+2=3$；

// 题组
== 计算题
#qg(
  gutter: 6em,
  $sum_(i=1)^(+infinity)1 / (i(i+1))$,
  $1 - 1 / 2 + 1 / 3 - 1 / 4 + dots.c$,
  $integral sech x space mono(d)x$,
  $ln mono(e)^pi$,
)
= 判断题
#qg(
  preprocessor: sxj-qg-pcs-tf,
  [啊对的，对的],
  [啊不对，不对],
  [啊对，不对],
  [对的，对的],
)
#qg(
  preprocessor: sxj-qg-pcs-tf,
  level: 2,
  col: 3,
  [这题是对的],
  [啊不对],
  [对对对的],
)

// 其他细节
== 默认采用B5版面，句号自动输出为句点。
```

See [example.typ](./examples/example.typ) for a more concrete example.

In case you want to know, some key functions are documented in the source code.