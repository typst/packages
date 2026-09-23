// ============================================================
// show.typ — 跨元素 show 规则
// 被 setup.typ 的 page-setup 通过 #show figure / #show ref 等引用
// 职责：图/表/代码块的展示布局、交叉引用链接生成
// ============================================================

#import "../utils/number.typ": chinesenumbering
#import "../utils/counter.typ": chaptercounter, equationcounter, imagecounter, tablecounter, rawcounter, theorem-kinds

/// 图、表、代码块的 show 规则
/// 图片：caption 在下方；表格：caption 在上方；代码块：caption 在上方
/// supplements: 引用记号字典，用于生成"图 1.1"等标签
#let figure-show-rule(it, supplements, style: none) = {
  set align(center)
  if it.kind == image {
    counter(figure.where(kind: "subfigure")).update(0)
    it.body
    [
      #set text(size: style.图序图名.size)
      #it.caption
    ]
  } else if it.kind == table {
    [
      #set text(size: style.表序表名.size)
      #it.caption
    ]
    it.body
  } else if it.kind == "equation" {
    set align(center)
    block(width: 100%, {
      grid(
        columns: (1fr, auto),
        it.body,
        context { it.counter.display(it.numbering) },
      )
    })
  } else if it.kind == "code" {
    [
      #set text(size: style.代码块标题.size)
      #context { supplements.代码 + it.counter.display(it.numbering) + "   " }
      #it.caption.body
    ]
    it.body
  } else if it.kind == "subfigure" {
    it.body
    [
      #set text(size: style.图序图名.size)
      #context {
        numbering(style.子图编号格式, counter(figure.where(kind: "subfigure")).at(here()).first())
      }
      #h(0.5em)
      #it.caption.body
    ]
  } else if it.kind in theorem-kinds {
    set align(left)
    it.body
  } else {
    it.body
    [
      #set text(size: style.图序图名.size)
      #context { supplements.图表 + it.counter.display(it.numbering) + "   " }
      #it.caption.body
    ]
  }
}

/// 生成 "图 1.1" / "式 (1.1)" 这类"章号 + 子计数器"编号
/// kind-counter: 对应元素类型的计数器（如 imagecounter）
/// el-loc: 引用目标位置
/// brackets: 公式编号是否加括号
#let _kind-numbering(kind-counter, el-loc, brackets: false) = chinesenumbering(
  chaptercounter.at(el-loc).first(),
  kind-counter.at(el-loc).first(),
  location: el-loc,
  brackets: brackets,
)

/// 交叉引用 @ 标签的 show 规则
/// 根据引用目标类型（equation / figure / heading）生成中文编号链接
/// supplements: 引用记号字典，控制"图/表/式/节"等前缀
#let ref-show-rule(it, supplements) = {
  if it.element == none { it }
  else {
    h(0em, weak: true)
    let el = it.element
    let el_loc = el.location()
    if el.func() == math.equation {
      link(el_loc, [#supplements.公式 #_kind-numbering(counter(math.equation), el_loc, brackets: true)])
      h(0.25em, weak: true)
    } else if el.func() == figure {
      if el.kind == image {
        link(el_loc, [#supplements.图 #_kind-numbering(imagecounter, el_loc)])
      } else if el.kind == "subfigure" {
        // 子图引用：主图编号（imagecounter 已含当前主图序号）+ 子图字母，如 "图 1.1(a)"
        link(el_loc, text(
          str(supplements.图) + " "
          + _kind-numbering(imagecounter, el_loc)
          + str(numbering("(a)", counter(figure.where(kind: "subfigure")).at(el_loc).first())),
        ))
      } else if el.kind == table {
        link(el_loc, [#supplements.表 #_kind-numbering(tablecounter, el_loc)])
      } else if el.kind == "code" {
        link(el_loc, [#supplements.代码 #_kind-numbering(rawcounter, el_loc)])
      } else if el.kind == "equation" {
        link(el_loc, [#supplements.公式 #_kind-numbering(equationcounter, el_loc, brackets: true)])
      } else if el.kind in theorem-kinds {
        link(el_loc, [#el.supplement #_kind-numbering(counter(figure.where(kind: el.kind)), el_loc)])
      } else {
        // 未知 figure kind 的 fallback：前缀用 supplements.图表，编号取该 kind 的
        // 子计数器（未随章节重置而跨章累计，与 _figure-show-rule 的图题编号一致）
        link(el_loc, [#supplements.图表 #_kind-numbering(counter(figure.where(kind: el.kind)), el_loc)])
      }
    } else if el.func() == heading {
      if el.level == 1 {
        link(el_loc, chinesenumbering(..counter(heading).at(el_loc), location: el_loc))
      } else {
        link(el_loc, [#supplements.节 #chinesenumbering(..counter(heading).at(el_loc), location: el_loc)])
      }
    } else { it }
    h(0em, weak: true)
  }
}
