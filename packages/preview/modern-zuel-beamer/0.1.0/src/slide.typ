// ============================================================================
// 页面组件 —— 封面 / 目录 / 章节分隔 / 内容 / 结束
// 每个页面都包进 Polylux 的 _engine-slide，使分步显示生效。
// ============================================================================

#import "theme.typ": color, font, size, layout
#import "setup.typ": doc-info, current-section, section-list, section-locs, section-counter
#import "overlay.typ": _engine-slide

// ---------------------------------------------------------------------------
// 局部外观参数（置顶，勿写死进函数）
// ---------------------------------------------------------------------------
#let title-underline-gap = 0.35em // 内容页标题与下划线间距
#let title-underline-len = 100% // 内容页下划线长度
#let footer-gap = 4pt // 页脚横线与文字间距
#let section-rule-len = 28% // 章节分隔页装饰线长度
#let cover-rule-len = 24% // 封面装饰线长度
#let cover-watermark-dy = 1.6em // 封面水印下沉量（贴近页底）
#let thanks-size = 40pt // 结束页「谢谢」字号
#let toc-num-width = 1.8em // 目录序号列宽
#let nav-dot-radius = 3.8pt // 页眉导航圆点半径
#let nav-dot-gap = 0.55em // 圆点间距
#let nav-below = 0.5em // 导航栏与标题间距
#let nav-dot-dim = 58% // 非当前圆点的淡化程度（主色 lighten）

// ---------------------------------------------------------------------------
// 工具：日期格式化
// ---------------------------------------------------------------------------
#let _fmt-date(d) = if type(d) == datetime {
  d.display("[year]年[month padding:none]月[day padding:none]日")
} else { d }

// ---------------------------------------------------------------------------
// 内容页标题栏
// ---------------------------------------------------------------------------
#let _frametitle(title) = block(width: 100%, below: 0.9em, {
  text(font: font.sans, size: size.frametitle, weight: "bold", fill: color.primary, title)
  v(title-underline-gap, weak: true)
  line(length: title-underline-len, stroke: layout.rule-bold + color.gold)
})

// ---------------------------------------------------------------------------
// 页脚：左作者 · 中章节 · 右页码
// ---------------------------------------------------------------------------
#let _footer() = context {
  let info = doc-info.get()
  let pg = counter(page).get().first()
  let total = counter(page).final().first()
  set text(size: size.footer, fill: color.muted, font: font.sans)
  block(width: 100%, {
    line(length: 100%, stroke: layout.rule-thin + color.gold)
    v(footer-gap, weak: true)
    grid(
      columns: (1fr, auto, 1fr),
      align: (left + horizon, center + horizon, right + horizon),
      info.at("author", default: ""),
      info.at("title", default: ""), // 中间固定显示封面标题
      [#pg / #total],
    )
  })
}

// ---------------------------------------------------------------------------
// 页眉导航：每章一个圆点，当前章高亮，点击跳转到该章节页
// ---------------------------------------------------------------------------
#let _nav() = context {
  let secs = section-list.final()
  if secs.len() > 0 {
    let locs = section-locs.final()
    let cur = section-counter.get().first() - 1
    let dots = secs.enumerate().map(((i, name)) => {
      let dot = circle(
        radius: nav-dot-radius,
        fill: if i == cur { color.gold } else { color.primary.lighten(nav-dot-dim) },
        stroke: none,
      )
      if i < locs.len() { link(locs.at(i), dot) } else { dot }
    })
    block(width: 100%, below: nav-below, align(right, stack(dir: ltr, spacing: nav-dot-gap, ..dots)))
  }
}

// ---------------------------------------------------------------------------
// 内容页：#slide(title: "...")[ 正文，可含 uncover/one-by-one ]
// ---------------------------------------------------------------------------
#let slide(title: none, body) = _engine-slide({
  _nav()
  if title != none { _frametitle(title) }
  body
  place(bottom + center, _footer())
})

// ---------------------------------------------------------------------------
// 封面
// ---------------------------------------------------------------------------
#let title-slide() = _engine-slide(context {
  let info = doc-info.get()
  // 底部水印（在内容之下）
  if info.at("watermark", default: none) != none {
    place(bottom + center, dy: cover-watermark-dy, info.watermark)
  }
  set align(center + horizon)
  block(width: 100%, {
    if info.at("logo", default: none) != none {
      info.logo
      v(0.6em)
    }
    text(font: font.sans, size: size.title, weight: "bold", fill: color.primary-dark,
      info.at("title", default: ""))
    if info.at("subtitle", default: none) != none {
      v(0.35em)
      text(font: font.sans, size: size.subtitle, fill: color.gold, info.subtitle)
    }
    v(0.7em)
    line(length: cover-rule-len, stroke: layout.rule-bold + color.gold)
    v(0.7em)
    set text(size: size.small, fill: color.text)
    // 个人信息：两列对齐表格（左列标签右对齐，右列内容左对齐）
    let pairs = (
      ("研究生", info.at("author", default: none)),
      ("学　号", info.at("student-id", default: none)),
      ("指导教师", info.at("supervisor", default: none)),
      ("专　业", info.at("major", default: none)),
      ("学　院", info.at("school", default: none)),
    ).filter(p => p.last() != none)
    let cells = pairs.map(p => (text(fill: color.muted)[#p.first()：], [#p.last()])).flatten()
    align(center, grid(
      columns: 2,
      column-gutter: 0.6em,
      row-gutter: 0.5em,
      align: (right + horizon, left + horizon),
      ..cells,
    ))
    v(0.6em)
    text(fill: color.muted, _fmt-date(info.at("date", default: none)))
  })
})

// ---------------------------------------------------------------------------
// 目录（汇总所有 section）
// ---------------------------------------------------------------------------
#let outline-slide(title: "目　录") = _engine-slide(context {
  _frametitle(title)
  v(0.4em)
  let secs = section-list.final()
  set text(size: size.frametitle)
  for (i, name) in secs.enumerate() {
    block(below: 0.85em, {
      box(width: toc-num-width, text(fill: color.gold, weight: "bold", font: font.sans, [#(i + 1).]))
      text(fill: color.primary-dark, name)
    })
  }
})

// ---------------------------------------------------------------------------
// 章节分隔页：#section("研究背景与意义")
// ---------------------------------------------------------------------------
#let section(name) = {
  section-counter.step()
  current-section.update(name)
  section-list.update(l => l + (name,))
  _engine-slide(context {
    let loc = here() // 在 context 内取位置，再存入 state（供页眉圆点跳转）
    section-locs.update(a => a + (loc,))
    let n = section-counter.get().first()
    set align(center + horizon)
    block({
      text(font: font.sans, size: size.section-num, weight: "bold", fill: color.gold-light, [#n])
      v(0.1em)
      text(font: font.sans, size: size.section, weight: "bold", fill: color.primary, name)
      v(0.5em)
      line(length: section-rule-len, stroke: layout.rule-bold + color.gold)
    })
  })
}

// ---------------------------------------------------------------------------
// 结束页
// ---------------------------------------------------------------------------
#let end-slide(message: "敬请各位老师批评指正！") = _engine-slide(context {
  let info = doc-info.get()
  set align(center + horizon)
  block({
    text(font: font.sans, size: thanks-size, weight: "bold", fill: color.primary, [谢　谢！])
    v(0.6em)
    text(size: size.frametitle, fill: color.gold, message)
    v(1.2em)
    set text(size: size.small, fill: color.muted)
    [#info.at("author", default: "")　#h(1em)　#_fmt-date(info.at("date", default: none))]
  })
})
