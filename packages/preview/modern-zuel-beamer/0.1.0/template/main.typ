// ============================================================================
// 开题答辩演示文稿 —— 由 modern-zuel-beamer 模板生成
// 编译： typst compile main.typ
// 改下面文档信息与各页内容即可。完整用法见包内 README 与 example/。
// ============================================================================

#import "@preview/modern-zuel-beamer:0.1.0": *
#import "@preview/cetz:0.4.0" as cetz

#show: zuel-beamer.with(
  title: "你的论文题目",
  subtitle: "硕士学位论文开题报告",
  author: "你的姓名",
  student-id: "学号",
  supervisor: "导师 教授",
  major: "专业",
  school: "学院",
  date: datetime.today(),
  // handout: true,   // 讲义模式：去掉分步动画
)

#title-slide()
#outline-slide()

// ─────────────────────────────────────────────
#section("研究背景与意义")

#slide(title: "选题背景")[
  研究背景第一点……

  - 现有方法的问题一
  #uncover("2-")[- 问题二（第 2 步出现）]

  #uncover("2-")[
    #definition-block(title: "研究问题")[在此提出你的核心研究问题。]
  ]
]

// ─────────────────────────────────────────────
#section("研究方法与技术路线")

#slide(title: "技术路线")[
  #align(center, cetz.canvas(length: 1cm, {
    import cetz.draw: *
    let stages = ("① 数据采集", "② 方法设计", "③ 实证分析", "④ 结论建议")
    let (bw, bh, gap) = (6.4, 1.2, 0.5)
    for (i, s) in stages.enumerate() {
      let top = -i * (bh + gap)
      rect((-bw / 2, top - bh), (bw / 2, top),
        fill: color.primary.lighten(86%), stroke: 1pt + color.primary, radius: 0.12)
      content((0, top - bh / 2), text(fill: color.primary-dark, weight: "bold", s))
      if i > 0 {
        line((0, -(i - 1) * (bh + gap) - bh), (0, top),
          mark: (end: ">", fill: color.gold), stroke: 1.4pt + color.gold)
      }
    }
  }))
]

#slide(title: "进度安排")[
  #set text(size: size.small)
  #table(
    columns: (auto, auto, 1fr),
    inset: (x: 0.8em, y: 0.6em),
    stroke: 0.5pt + color.gray-light,
    table.header(..("阶段", "时间", "任务").map(h =>
      table.cell(fill: color.primary, text(fill: white, weight: "bold", h)))),
    [第一阶段], [2026.07 – 2026.09], [文献调研与数据采集],
    [第二阶段], [2026.10 – 2026.12], [方法实现与实验],
  )
]

#end-slide()
