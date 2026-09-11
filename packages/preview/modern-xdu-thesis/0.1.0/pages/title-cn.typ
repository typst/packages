// 西安电子科技大学硕士学位论文 Typst 模板 — 中文题名页
//
// 依据：docs/前置部分规格.md §2
// - 无页眉、无页脚、无页码
// - 顶部信息栏：10.5pt 宋体；行距固定 17pt；值**居中于该行虚线填空**
// - 校名区：黑体 26pt「西安电子科技大学」 + 宋体 24pt「硕士学位论文」
// - 题目：宋体 22pt，居中，固定 30pt 行距
// - 字段区：14pt 宋体，左对齐 x=75mm，固定 32pt 行距
// - 学硕 vs 专硕差异：见 §2.4
//
// 官方实测：顶部信息栏的值不是左对齐在固定列，而是居中于虚线
//   学校代码 10701 → 虚线 48.52~74.45（中心 61.49），值中心 61.42
//   学号 1101110071 → 虚线 154.82~183.71（中心 169.27），值中心 169.26

#import "../layouts/doc.typ": 基线偏移, 到内容区, 页面坐标
#import "../utils/style.typ": 字体 as 字体集

// 行盒与 Δ
#let 信息Δ = 基线偏移(17pt, 10.5pt)
#let 标题Δ = 基线偏移(30pt, 22pt)
#let 校名26Δ = 基线偏移(30pt, 26pt)
#let 校名24Δ = 基线偏移(30pt, 24pt)
#let 字段Δ = 基线偏移(32pt, 14pt)

#let title-cn(
  degree: "academic",
  blind: false,
  fonts: (:),
  info: (:),
) = {
  let 字体集 = 字体集 + fonts
  set page(header: none, footer: none, numbering: none)

  // 顶部信息栏两栏：左 30mm 起（学校代码 / 分类号），右 140mm 起（学号 / 密级）
  let 左栏 = (("学校代码", info.school-code), ("分类号", info.clc))
  let 右栏 = (("学　　号", info.student-id), ("密　　级", info.secret-level))

  // 学硕 / 专硕字段表（唯一差异）
  let 学硕 = (
    ("作者姓名：", info.author),
    ("一级学科：", info.discipline),
    ("二级学科（研究方向）：", info.subdiscipline),
    ("学位类别：", info.degree-name),
    ("指导教师姓名、职称：",
      if info.supervisor == none { "" } else { info.supervisor.join(" ") }),
    ("学　　院：", info.department),
    ("提交日期：",
      str(info.submit-date.year) + " 年 " + str(info.submit-date.month) + " 月"),
  )
  let 专硕 = (
    ("作者姓名：", info.author),
    ("领　　域：", info.domain),
    ("学位类别：", info.degree-name),
    ("学校导师姓名、职称：",
      if info.supervisor == none { "" } else { info.supervisor.join(" ") }),
    ("企业导师姓名、职称：",
      if info.enterprise-supervisor == none or info.enterprise-supervisor.at(0) == none {
        ""
      } else { info.enterprise-supervisor.join(" ") }),
    ("学　　院：", info.department),
    ("提交日期：",
      str(info.submit-date.year) + " 年 " + str(info.submit-date.month) + " 月"),
  )
  let 字段列表 = if degree == "professional" { 专硕 } else { 学硕 }
  // 盲审（格式规格 §2.6）：隐去作者姓名与导师姓名
  if blind {
    字段列表 = 字段列表.map(((标签, 值)) => {
      (标签, if 标签.contains("姓名") { "" } else { 值 })
    })
  }
  let 题目列表 = if type(info.title) == str { (info.title,) } else { info.title }

  // 整页用页面绝对坐标（见 doc.typ 的 页面坐标）
  页面坐标({
    // ---- 顶部信息栏 ----
    for (栏, 标签x, 虚线x, 虚线宽) in (
      (左栏, 30mm, 48.52mm, 25.93mm),
      (右栏, 140mm, 154.82mm, 28.89mm),
    ) {
      for (i, (标签, 值)) in 栏.enumerate() {
        let y = 到内容区(38.36mm) + 17pt * i
        place(top + left, dx: 标签x, dy: y - 信息Δ, box({
          // 值里可能有中文（如「公开」），必须走宋体链，不能用纯 TNR
          set text(font: 字体集.宋体, size: 10.5pt,
            top-edge: 信息Δ, bottom-edge: "baseline")
          标签
        }))
        place(top + left, dx: 虚线x, dy: y + 1.06mm,
          line(length: 虚线宽,
            stroke: 0.4pt))   // 实线：官方与已过检参考论文的填空线都是实线
        // 值居中于虚线
        place(top + left, dx: 虚线x, dy: y - 信息Δ,
          box(width: 虚线宽, align(center, {
            set text(font: 字体集.宋体, size: 10.5pt,
              top-edge: 信息Δ, bottom-edge: "baseline")
            值
          })))
      }
    }

    // ---- 校名区 ----
    place(top + left, dx: 30mm, dy: 到内容区(80.02mm) - 校名26Δ,
      box(width: 155mm, align(center, {
        set text(font: 字体集.黑体, size: 26pt,
          top-edge: 校名26Δ, bottom-edge: "baseline")
        "西安电子科技大学"
      })))
    place(top + left, dx: 30mm, dy: 到内容区(111.13mm) - 校名24Δ,
      box(width: 155mm, align(center, {
        set text(font: 字体集.宋体, size: 24pt,
          top-edge: 校名24Δ, bottom-edge: "baseline")
        "硕士学位论文"
      })))

    // ---- 题目 ----
    for (i, 行) in 题目列表.enumerate() {
      place(top + left, dx: 30mm, dy: 到内容区(150.20mm) + 30pt * i - 标题Δ,
        box(width: 155mm, align(center, {
          set text(font: 字体集.宋体, size: 22pt,
            top-edge: 标题Δ, bottom-edge: "baseline")
          行
        })))
    }

    // ---- 字段区 ----
    for (i, (标签, 值)) in 字段列表.enumerate() {
      place(top + left, dx: 75mm, dy: 到内容区(200.69mm) + 32pt * i - 字段Δ,
        box(width: 110mm, {
          set text(font: 字体集.宋体, size: 14pt,
            top-edge: 字段Δ, bottom-edge: "baseline")
          text(标签) + h(2mm) + text(值)
        }))
    }
  })
}
