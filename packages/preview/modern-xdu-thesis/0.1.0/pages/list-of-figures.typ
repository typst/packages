// 西安电子科技大学硕士学位论文 Typst 模板 — 插图索引
//
// 依据：docs/索引部分规格.md §1
// - 页眉「插图索引」宋体 10.5pt 居中（基线 25.82mm）+ 双横线（27.64/28.00mm，宽 155mm）
// - 标题「插图索引」黑体 16pt 居中，基线 44.25mm
// - 条目：`图 <章-序> <题> …… <页码>`，12pt，首条基线 61.12mm，
//   行距固定 20 磅，页码右对齐到 185mm（30~185 为正文宽）
// - 数据来源：query(figure.where(kind: image))；编号为分章编号（格式规格 §2.5）
// - 每条显式绝对定位，避免流式间距污染行网格

#import "../layouts/doc.typ": 基线偏移, 到内容区, 页眉, 默认页脚, 上边距, 页眉顶, 页面大标题, 索引条目
#import "../utils/style.typ": 字体 as 字体集
#import "../utils/counters.typ": 章号, 索引中

#let 正文Δ = 基线偏移(20pt, 12pt)

#let list-of-figures(
  degree: "academic",
  blind: false,
  fonts: (:),
  info: (:),
  title: "插图索引",
) = {
  let 字体集 = 字体集 + fonts

  set page(
    numbering: "I",
    header-ascent: 上边距 - 页眉顶,
    footer-descent: 0mm,
    header: 页眉(title),
    footer: 默认页脚,
  )

  页面大标题(title)

  set text(font: 字体集.宋体, size: 12pt, lang: "zh",
    top-edge: 正文Δ, bottom-edge: "baseline")
  set par(leading: 20pt - 正文Δ, spacing: 20pt - 正文Δ)

  // 让 索引题注() 知道现在渲染的是索引（状态更新要在 context 之外，故写成块）
  索引中.update(true)
  context {
    // 注意：索引里渲染图注时必须隐藏引用（show cite => none）。
    // 否则图注里的 #cite 会在索引页（在正文之前）被渲染一次，而 Typst 的数值型
    // 参考文献按「引用首次出现的位置」编号 —— 那几条文献会被排到最前面，
    // 整份参考文献顺序错乱、正文里所有引用编号都错。
    // 隐藏后引用不参与编号，顺序回归正文。
    // （上游 issue：typst/typst#3994 → #1880，维护者认可为 bug。）
    show cite: it => none
    let 列表 = query(figure.where(kind: image))
    for (i, f) in 列表.enumerate() {
      // 注意：编号必须按**元素自身位置**求章号：写成 numbering(f.numbering, …) 时，
      //    编号函数里的 章号.get() 是在**索引页**求值（那时一章都还没有）→ 会得到「图 0.1」。
      let loc = f.location()
      // 必须写成一行：Typst 里行首的 `+` 会被解析成一元加号（或列表标记）
      let 编号 = numbering("1", 章号.at(loc).first()) + "." + numbering("1", ..f.counter.at(loc))
      place(top + left, dx: 0mm,
        dy: 到内容区(61.12mm) + 20pt * i - 正文Δ,
        box(width: 155mm, 索引条目(
          // 用 + 显式拼接，避免 markup 换行混入空格影响对齐
          text(font: 字体集.宋体, "图")
          + h(0.5em)                                     // 前缀→编号：官方 30.00→36.35
          + box(width: 10.59mm, text(font: ("Times New Roman",), 编号))  // 编号定宽列：官方 36.35→46.94
          + (if f.caption != none { f.caption.body } else { none }),
          // 注意：页号要取「页计数器在该位置的值」，不能用 location().page()：
          // 前置部分占 24 页时，正文第 1 页的物理序号是 25，但印刷页号是 1。
          // 实测 location().page() 在索引里给出 32（物理），而应为 8（印刷）。
          text(font: ("Times New Roman",), {
            // page-numbering() 在未设页码的页上返回 none，要兜底（目录页早有这层处理）
            let loc = f.location()
            let 号 = counter(page).at(loc).first()
            let 样式 = loc.page-numbering()
            if 样式 == none { str(号) } else { numbering(样式, 号) }
          }),
        )),
      )
    }
  }
  索引中.update(false)
}
