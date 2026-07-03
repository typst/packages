// ============================================================================
// 组件速查 —— 演示模板提供的各类组件用法
// 编译： typst compile --root . example/组件速查.typ out.pdf
// ============================================================================

#import "../lib.typ": *

#show: zuel-beamer.with(
  title: "Modern ZUEL Beamer 组件速查",
  subtitle: "色块 · 分步 · 多栏 · 题注 · 金句 · 定理",
  author: "模板使用者",
  date: datetime.today(),
)

#title-slide()
#outline-slide()

// ---------------------------------------------------------------------------
#section("内容块与分步")

#slide(title: "六种莫兰迪色块")[
  #cols[
    #note-block(title: "说明")[note-block]
    #definition-block(title: "定义")[definition-block]
    #alert-block(title: "注意")[alert-block]
  ][
    #example-block(title: "示例")[example-block]
    #theorem-block(title: "定理")[theorem-block（非编号）]
    #highlight-block(title: "重点")[highlight-block]
  ]
]

#slide(title: "分步显示")[
  逐条出现：
  #item-by-item[
    + 第一条（第 1 步）
    + 第二条（第 2 步）
    + 第三条（第 3 步）
  ]
  #uncover("3-")[#alert-block(title: "提示")[第 3 步才出现的整块内容。]]
]

// ---------------------------------------------------------------------------
#section("布局与图文")

#slide(title: "多栏 + 金句 + 题注")[
  #cols(widths: (1.1fr, 1fr))[
    左右分栏常用于「文字 + 图」对照。

    #quote-block(by: "Altman, 1968")[财务比率对企业破产具有显著预测力。]
  ][
    #fig(image("../asset/ZUELlogo.png", width: 55%), caption: [校徽示意])
  ]
]

// ---------------------------------------------------------------------------
#section("编号定理环境")

#slide(title: "定理 / 引理 / 推论（各类独立编号）")[
  #cols[
    #theorem(title: "融合可分性")[在温和假设下，多源特征融合表示线性可分。]
    #lemma[引理自动编号为 1。]
  ][
    #theorem[第二个定理自动编号为 2。]
    #corollary[推论自动编号为 1。]
  ]
]

#end-slide(message: "组件用法见 README")
