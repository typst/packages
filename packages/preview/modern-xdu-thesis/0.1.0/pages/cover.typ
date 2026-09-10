// 西安电子科技大学硕士学位论文 Typst 模板 — 封面
//
// 依据：docs/前置部分规格.md §1
// - 无页眉、无页脚、无页码
// - 题目：宋体 22pt，居中（正文区中心 107.5mm），固定 30pt 行距
// - 字段标签：黑体 14pt，左对齐 x=60mm（页面绝对坐标）
// - 字段值：宋体 14pt，**居中于该行的填空线**
// - 每字段基线 y：239.34 / 249.88 / 260.42 / 270.96 → 固定 30pt
// - 填空横线：0.4pt **实线**，y = 基线 + 1.06mm，从标签之后起、右端到 149.87mm
// - 学硕 vs 专硕差异：见 §1 字段表
//
// 官方实测依据：值并非落在固定列，而是居中于填空线
//   作者姓名 → 线 81.73~148.88，值中心 115.40 ≈ 线中心 115.30
//   指导教师 → 线 107.40~149.87，值中心 128.39 ≈ 线中心 128.64
//   申请学位类别 → 线 91.60~149.87，值中心 120.63 ≈ 线中心 120.74
// 线型：官方 templet.pdf 与已过检的参考论文**都是实线**（线段首尾相接、无间隙）

#import "../layouts/doc.typ": 行距, 基线偏移, 到内容区, 页面坐标
#import "../utils/style.typ": 字号, 字体

#let 标题行距 = 30pt
#let 标题Δ = 基线偏移(标题行距, 22pt)
#let 标题隙 = 标题行距 - 标题Δ

#let 字段行距 = 30pt
#let 字段Δ = 基线偏移(字段行距, 14pt)

#let 题目首行基线 = 172.37mm
#let 字段首行基线 = 239.34mm
#let 字段标签x = 60mm
#let 填空线右端 = 149.87mm
#let 标签后间隙 = 1mm

// 标签墨迹宽度：汉字每字 1em
#let 标签宽(文字) = 14pt * 文字.clusters().len()

#let cover(
  degree: "academic",     // "academic" | "professional"
  blind: false,
  fonts: (:),
  info: (:),
  twoside: false,         // 兼容旧签名（P2 不做空白页）
) = {
  let 字体集 = 字体 + fonts

  // 封面无页眉页脚页码
  set page(header: none, footer: none, numbering: none)

  let 题目列表 = if type(info.title) == str { (info.title,) } else { info.title }

  // 学硕 / 专硕字段表（唯一差异）
  let 学硕字段 = (
    ("作者姓名", info.author),
    ("指导教师姓名、职称",
      if info.supervisor == none { "" } else { info.supervisor.join(" ") }),
    ("申请学位类别", info.degree-name),
  )
  let 专硕字段 = (
    ("作者姓名", info.author),
    ("学校导师姓名、职称",
      if info.supervisor == none { "" } else { info.supervisor.join(" ") }),
    ("企业导师姓名、职称",
      if info.enterprise-supervisor == none or info.enterprise-supervisor.at(0) == none {
        ""
      } else { info.enterprise-supervisor.join(" ") }),
    ("申请学位类别", info.degree-name),
  )
  let 字段列表 = if degree == "professional" { 专硕字段 } else { 学硕字段 }
  // 盲审（格式规格 §2.6）：隐去作者姓名与指导教师姓名
  if blind {
    字段列表 = 字段列表.map(((标签, 值)) => {
      (标签, if 标签.contains("姓名") { "" } else { 值 })
    })
  }

  // 整页内容用页面绝对坐标排版（见 doc.typ 的 页面坐标）
  页面坐标({
    // ---- 题目：逐行显式定位，行距固定 30pt ----
    for (i, 行) in 题目列表.enumerate() {
      place(top + left, dx: 30mm, dy: 到内容区(题目首行基线) + 标题行距 * i - 标题Δ,
        box(width: 155mm, align(center, {
          set text(font: 字体集.宋体, size: 22pt, lang: "zh",
            top-edge: 标题Δ, bottom-edge: "baseline")
          行
        })))
    }

    // ---- 字段区 ----
    for (i, (标签文字, 值文字)) in 字段列表.enumerate() {
      let 行基线 = 字段首行基线 + 字段行距 * i
      let y行顶 = 到内容区(行基线) - 字段Δ
      let 填空线左 = 字段标签x + 标签宽(标签文字) + 标签后间隙
      let 填空线宽 = 填空线右端 - 填空线左

      // 标签：黑体 14pt，不加固定宽度（否则长标签会折行）
      place(top + left, dx: 字段标签x, dy: y行顶, box({
        set text(font: 字体集.黑体, size: 14pt,
          top-edge: 字段Δ, bottom-edge: "baseline")
        标签文字
      }))

      // 填空横线：标签之后 → 149.87mm，**实线**
      //
      // 注意：早先用的是点线 `dash: ("dot", 1pt, 1.5pt)`，是**错的**：官方
      // `templet.pdf` 与已过检的参考论文实测都是实线（把线段按 0.99mm 一段切开后，
      // 相邻段首尾相接、最大间隙 0.0mm，即连续的实线，只是 PDF 生成器把它切成了多段）。
      // 当时把它记成「官方为虚线，由 ~68 段小线段构成」属于推断错误，导致封面看起来
      // 是一排小点，与官方观感明显不同。
      place(top + left, dx: 填空线左, dy: 到内容区(行基线) + 1.06mm,
        line(length: 填空线宽, stroke: 0.4pt))

      // 值：宋体 14pt，居中于该行填空线
      if 值文字 != "" {
        place(top + left, dx: 填空线左, dy: y行顶,
          box(width: 填空线宽, align(center, {
            set text(font: 字体集.宋体, size: 14pt,
              top-edge: 字段Δ, bottom-edge: "baseline")
            值文字
          })))
      }
    }
  })
}
