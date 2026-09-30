#import "@preview/touying:0.7.4": *
#import "@preview/shuimu-touying-zen:0.1.0": *

#show: group-meeting-theme.with(
  // 主色控制横条、目录竖线、标题和强调文字；反白 SVG 背景透明。
  // primary: blue,
  font: ("Arial", "Noto Sans SC"),
  cover-logo-name: "phys-logo.svg",
  // header-logo-name: "energy-power-logo.svg",
  // cover-logo: image("assets/campus.png"),
  config-info(
    title: [组会汇报],
    subtitle: [组会报告],
    author: [姓名],
    institution: [清华大学物理系],
    date: datetime(year: 2026, month: 9, day: 7)
  ),
  outline-v-spacing: 80pt,
  show-contents: true,
)

// 控制列表默认间距
#set list(spacing: 1.2em)

#title-slide()
#outline-slide()

= 研究背景

== 研究问题

#[
#set list(spacing: 2em) // 临时设置列表间距
- 在这里概述研究对象和待解决的问题。
- #text(blue)[说明已有方法的适用条件与局限]。
- 给出本次组会需要讨论的具体问题。
]

== 理论模型

#slide(composer: (1fr, 1fr))[
  === 基本假设

  - 系统在平衡位置附近运动。
  - 暂时忽略阻尼和外界驱动。
  - 用位移 $x(t)$ 描述系统状态。
  - *加粗文字* 用清华紫显示
][
  === 简谐振子

  $ m (dif^2 x)/(dif t^2) + k x = 0 $

  $ omega_0 = sqrt(k/m) $

  $ x(t) = A cos(omega_0 t + phi) $
]

= 本周进展

== 实验与分析

#table(
  columns: (1.2fr, 2.5fr, 1fr),
  inset: 12pt,
  stroke: 0.6pt + rgb("dddddd"),
  fill: (x, y) => if y == 0 { rgb("f2edf6") },
  table.header([*工作项*], [*记录内容*], [*状态*]),
  [实验准备], [填写样品、设备和参数], [待填写],
  [数据采集], [填写测量范围与重复次数], [待填写],
  [结果分析], [填写主要现象与不确定度], [待填写],
)

#columns(2)[
  *Hello world!*
  - Hello
  #colbreak()
  - world
]

= 后续计划


== 讨论与安排

- 需要进一步验证的解释。
- 下一阶段的实验或计算安排。
- 希望获得的建议与支持。

// 如需逐步显示，在两段内容之间插入 #pause。
// 每个章节前默认插入高亮目录；section-slides: false 可关闭。
// 目录默认均匀分布；outline-v-spacing: 32pt 可统一手动指定条目间距。

#closing-slide(body: [谢谢大家，敬请批评指正!])
