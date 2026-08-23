// ============================================================
// lib/utils.typ: 工具函数与字号常量
// ============================================================

// ---- 中文字号常量（Word 标准） ----
#let chuhao = 42pt      // 初号
#let xiaochu = 36pt     // 小初
#let yihao = 26pt       // 一号
#let xiaoyi = 24pt      // 小一
#let erhao = 22pt       // 二号
#let xiaoer = 18pt      // 小二
#let sanhao = 16pt      // 三号
#let xiaosan = 15pt     // 小三
#let sihao = 14pt       // 四号
#let xiaosi = 12pt      // 小四（正文默认）
#let wuhao = 10.5pt     // 五号
#let xiaowu = 9pt       // 小五

// ---- 行距常量 ----
#let line-spacing-15 = 18pt
#let line-spacing-20 = 24pt
#let line-spacing-25 = 30pt

// ---- 工具函数 ----

// 生成带章节前缀的编号（如 "第 1 章"）
#let ch-numbering(..nums) = {
  let arr = nums.pos()
  if arr.len() == 1 {
    "第 " + str(arr.first()) + " 章"
  } else {
    arr.map(str).join(".")
  }
}

// ---- 伪粗体（fake bold） ----
// 中文字体（如 SimHei）通常没有独立的 Bold 字重，Typst 默认不会自动模拟加粗。
// 使用 text stroke 来模拟粗体效果，与 LaTeX 的 AutoFakeBold 类似。
// 参考 cuti 包实现。
#let fakebold(s, weight: "regular", ..params) = {
  set text(weight: weight) if type(weight) in (str, int)
  set text(weight: "regular") if weight == none
  set text(..params) if params != ()
  context {
    set text(stroke: 0.02857em + text.fill)
    s
  }
}

// 对内容块中所有匹配正则的文本应用 fakebold
#let regex-fakebold(reg-exp: "[\\p{script=Han}！-･〇-〰—]+", s, ..params) = {
  show regex(reg-exp): it => fakebold(it, weight: "regular", ..params)
  s
}

// ---- 附录状态（用于引用编号） ----
#let appendix-active = state("appendix-active", false)
#let appendix-letter = state("appendix-letter", "")

// ---- 续表状态（跨页表头续表标注起始页号） ----
#let _tltable-start-page = state("_tltable-start-page", 0)

// ---- 表头辅助：名称与单位分行显示 ----
// 用法 1（自动拆分）：hcell("辐照时间/s")  =>  辐照时间 在上，/s 在下
// 用法 2（手动传入）：hcell([功率密度], [/$W dot "cm"^(-2)$])
// 用法 3（普通文本）：hcell([试验编号])   =>  不拆分，原样居中
#let hcell(..args) = {
  let pos = args.pos()
  if pos.len() == 1 {
    let s = pos.first()
    if type(s) == str {
      let parts = s.split("/")
      if parts.len() > 1 {
        let name = parts.at(0)
        let unit = "/" + parts.slice(1).join("/")
        align(center, stack(dir: ttb, spacing: 18pt, name, unit))
      } else {
        align(center, s)
      }
    } else {
      align(center, s)
    }
  } else if pos.len() == 2 {
    align(center, stack(dir: ttb, spacing: 18pt, pos.at(0), pos.at(1)))
  } else {
    align(center, pos.join())
  }
}

// ---- 三线表辅助函数 ----
// 自动添加三线表格式（顶粗线、头细线、底粗线），并支持跨页续表标注。
// 跨页时自动在续页表头右上方显示"续表X-X"（正文）或"续表AX"（附录）。
// 使用示例：
//   #three-line-table(
//     columns: 3,
//     header: ([列1], [列2], [列3]),
//     [数据1], [数据2], [数据3],
//   )
//   #three-line-table(
//     columns: 3,
//     continued: false,  // 小型表格，不跨页重复
//     header: ([列1], [列2], [列3]),
//     [数据1], [数据2], [数据3],
//   )
#let three-line-table(
  columns: auto,
  rows: auto,
  table-align: center + horizon,
  inset: 6pt,
  continued: true,
  header: (),
  ..body
) = {
  let col-count = if type(columns) == int {
    columns
  } else if type(columns) == array {
    columns.len()
  } else {
    if header.len() > 0 { header.len() } else { 1 }
  }

  if header == () {
    table(
      columns: columns,
      rows: rows,
      align: table-align,
      inset: inset,
      stroke: none,
      table.hline(stroke: 1.5pt),
      ..body,
      table.hline(stroke: 1.5pt),
    )
  } else if continued {
    context {
      _tltable-start-page.update(here().page())
    }
    table(
      columns: columns,
      rows: rows,
      align: table-align,
      inset: inset,
      stroke: none,
      table.header(
        repeat: true,
        table.cell(
          colspan: col-count,
          inset: (x: 6pt, top: 0pt, bottom: 0pt),
          align(right, context {
            let sp = _tltable-start-page.at(here())
            let cp = here().page()
            if cp > sp {
              let is-app = appendix-active.at(here())
              if is-app {
                let letter = appendix-letter.at(here())
                let nums = counter(figure.where(kind: table)).at(here())
                text(size: 10pt, "续表" + str(letter) + str(nums.last()))
              } else {
                let ch = counter(heading.where(level: 1)).at(here()).first()
                let nums = counter(figure.where(kind: table)).at(here())
                text(size: 10pt, "续表" + str(ch) + "-" + str(nums.last()))
              }
              v(3pt)
            }
          }),
        ),
        table.hline(stroke: 1.5pt),
        ..header,
        table.hline(stroke: 0.75pt),
      ),
      ..body,
      table.hline(stroke: 1.5pt),
    )
  } else {
    table(
      columns: columns,
      rows: rows,
      align: table-align,
      inset: inset,
      stroke: none,
      table.hline(stroke: 1.5pt),
      table.header(
        repeat: false,
        ..header,
        table.hline(stroke: 0.75pt),
      ),
      ..body,
      table.hline(stroke: 1.5pt),
    )
  }
}
