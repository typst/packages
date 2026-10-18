#import "@preview/cuti:0.4.0": show-cn-fakebold, show-cn-fakeitalic

#import "../template/custom/parameter.typ": *
#import "function.typ": *
#import "../library/theobox.typ": *
#import "../template/custom/custom-func.typ": *
#import "../template/custom/custom-config.typ": custom-config

#let part-judge = state("part-judge", false) // 部分页判断
#let part-title = state("part-title") // 部分标题存储
#let part-count = counter("part-counter") // 部分计数器
#let global-heading = counter("global-heading") // 总章节计数器
#let chapter-title = state("chapter-title", none) // 章节名称
#let section-title = state("section-tilte", none) // 次章节名称
#let appendix-count = counter("appendix-counter") // 附录环境判断
#let heading-image = state("heading-image", none) // 头图环境
#let set-heading-image(image) = {heading-image.update(image)} // 更新头图

// ----------------------------------------------------------------------------------------
/* 封面环境 */
#let cover-environment(
  style: 1,
  title: "",
  subtitle: "",
  author: (),
  date: datetime.today(),
  cover-image: none,
) = {
  set document(title: title, author: author, date: date) // 设置PDF元数据的标题、作者以及日期
  set page(
    width: page-all.width,
    height: page-all.height,
    margin: 0mm,
    numbering: "A",
  )

  date = date.display("[year]年[month]月[day]日") // 日期显示样式

  /* 渲染封面 */
  if style == 1 {
    grid(
      rows: (65%, 4%, 11%, 6%, 14%),
      {
        set image(width: 100%)
        cover-image
      },
      [],
      [
        #show: align.with(center)
        #show: block.with(width: 80%)
        #text(font: sans-font, size: 24pt)[#title]
        #v(19pt, weak: true)
        #text(font: sans-font, size: 14pt)[#subtitle]
      ],
      [],
      grid(
        columns: (50%, 50%), 
        [],
        [
          #text(font: serif-font, size: 10.5pt, fill: black)[#h(80pt) 作者：#author]

          #text(font: serif-font, size: 10.5pt, fill: black)[#h(80pt) 日期：#date]
        ]
      )
    )
  }
}

// ----------------------------------------------------------------------------------------
/* 总体页面段落标题样式 */
#let overall(body) = {
  // --------------------------------------------
  /* 页面样式&页眉 */
  
  set page(
    width: page-all.width,
    height: page-all.height,
    margin: (
      top: page-all.mar-t,
      bottom: page-all.mar-b,
      left: page-all.mar-x,
      right: page-all.mar-x,
    ),
    header: context{
      set text(..aux-text.header-text)
      let page-num = here().page()
      let chap-page = query(heading.where(level: 1))
      if chap-page.any(it => it.location().page() == page-num) or part-judge.get() {
        return
      }

      if chapter-title.get() != none and section-title.get() != none {
        set par(leading: 1em)
        box(width: 100%, inset: (bottom: 0.5em), stroke: (bottom: 0.5pt))[
          #grid(
            columns: (1fr, 1fr),
            h(1em) + box(chapter-title.get()),
            h(1fr) + box(section-title.get()) + h(1em),
          )
        ]
      }

      counter(footnote).update(0) // 每个页面页脚重新编号
    }
  )

  // --------------------------------------------
  /* 文字段落样式 */
  set text(
    lang: lans.language,
    region: lans.region,
    ..main-text
  )
  set par(
    first-line-indent: paras.indent,
    leading: paras.wspace,
    spacing: paras.wspace,
  )

  // --------------------------------------------
  show: show-cn-fakebold // 中文字加粗插件
  show: show-cn-fakeitalic // 中文字体倾斜插件
  set underline(offset: 3pt) // 下划线样式
  show link: set text(fill: colour.link) // 链接样式
  set block(spacing: paras.bspace, breakable: true) // block样式
  set enum(
    indent: paras.lstind,
    numbering: "1.a.i.",
    number-align: center
  ) // 有序列表样式（三级）
  set list(indent: paras.lstind, marker: ([•], [-], [\~])) // 项目列表样式（三级）
  set terms(indent: 1em) // 解释列表样式

  // --------------------------------------------
  /* 引用样式 */
  set cite(style: lans.cite-sty)
  show cite: it => text(colour.cite, it)

  // --------------------------------------------
  /* 公式环境 */
  set math.equation(supplement: lans.equation)
  show math.equation: set text(font: math-font)

  // --------------------------------------------
  /* 图像表格环境 */
  show figure.where(kind: image).or(figure.where(kind: table)): set figure(gap: 1.3em)
  show figure.where(kind: image).or(figure.where(kind: table)): it => align(center)[
    #if(it.placement == top){
      it
      v(paras.ispace, weak: true)
    } else if(it.placement == bottom) {
      v(paras.ispace, weak: true)
      it
    } else {
      v(paras.ispace, weak: true)
      it
      v(paras.ispace, weak: true)
    }
  ]
  show figure.where(kind: image): set figure(supplement: lans.image)
  show figure.where(kind: table): set figure(supplement: lans.table)
  show raw: set text(font: code-font)

  // --------------------------------------------
  /* 标题样式 */
  set heading(hanging-indent: 0em)
  show heading.where(level: 1): it => {
    it
    counter("global-heading").step()
  } 

  // --------------------------------------------
  /* 定理样式 */
  show: my-show-theorion

  show: custom-config

  body
}

// ----------------------------------------------------------------------------------------
/* 前辅文环境 */
#let front-matter(body) = {
  // --------------------------------------------
  /* 标题 */
  set heading(
    numbering: (..nums) => {
      if page-pre.index {numbering("I.1", ..nums)} else {
        if nums.pos().len() >= 2 {numbering("I.1", ..nums)}
      }
    },
    bookmarked: true,
    outlined: false
  )
  show heading.where(level: 1): set heading(supplement: lans.preface-prefix, outlined: page-pre.outline)
  show heading: it => {

    set text(size: main-text.size)

    if it.level == 1 {
      pagebreak()
      set text(..heading1-sty.text)
      set par(leading: 1em)
      set align(center)
      counter(image).update(0)
      counter(table).update(0)
      counter(raw).update(0)
      counter(math.equation).update(0)
      context{
        let img = heading-image.get()
        if heading1-sty.image and img != none {
          set image(width: page-all.width, height: page-all.height * 0.3)
          place(dx: -page-all.mar-x, dy: -page-all.mar-t, img)
          place(
            dx: -page-all.mar-x,
            dy: -page-all.mar-t,
            block(
              width: page-all.width,
              height: page-all.height * 0.3
            )[
              #align(center + bottom)[
                #v(3fr)
                #block(
                  width: 65%,
                  stroke: (0.7mm + colour.theme),
                  radius: 3.5mm,
                  inset: 0.7em,
                  fill: rgb("#FFFFFFAA"),
                  it
                )
                #v(1fr)
              ]
            ])
          v(page-all.height * 0.3 - page-all.mar-t + 2em)
        } else {
          v(heading1-sty.upspace)
          it
          v(heading1-sty.downspace, weak: true)
        }
        if page-pre.header {
          chapter-title.update(it)
          section-title.update(none)
        }
        set-heading-image(none)
      }
    } else if it.level == 2 or it.level == 3 or it.level == 4 {
      if it.level == 2 {
        if page-pre.header {section-title.update(it)}

        set text(..heading2-sty.text)
        v(heading2-sty.upspace, weak: true)
        block[
          #mark-display(
            it.numbering,
            heading2-sty.mark, 
            heading2-sty.mark-gutter,
            page-all.mar-x,
          )
          #it
        ]
        v(heading2-sty.downspace, weak: true)
      } else if it.level == 3 {
        set text(..heading3-sty.text)
        v(heading3-sty.upspace, weak: true)
        block[
          #mark-display(
            it.numbering,
            heading3-sty.mark, 
            heading3-sty.mark-gutter,
            page-all.mar-x,
          )
          #it
        ]
        v(heading3-sty.downspace, weak: true)
      } else if it.level == 4 {
        set text(..heading4-sty.text)
        v(heading4-sty.upspace, weak: true)
        block[
          #mark-display(
            it.numbering,
            heading4-sty.mark, 
            heading4-sty.mark-gutter,
            page-all.mar-x,
          )
          #it
        ]
        v(heading4-sty.downspace, weak: true)
      }
    } else {
      it
    }
  }

  // --------------------------------------------
  /* 页码 */
  set page(
    numbering: "i",
    footer: {
      set text(..aux-text.footer-text)
      context align(center, counter(page).display("- i -"))
    },
  )

  // --------------------------------------------
  /* 公式计数样式 */
  set math.equation(
    numbering: num => numbering("(I.1)", counter(heading).get().first(), num),
  )

  // --------------------------------------------
  /* 图像表格计数样式 */
  show figure.where(kind: image).or(figure.where(kind: table)): set figure(
    numbering: num => numbering("I.1", counter(heading).get().first(), num),
  )
  
  // --------------------------------------------
  /* 盒子的各种环境配置 */
  set-theorion-numbering("I.1")

  /* 重新计数页码和章节并修改公式标号 */
  counter(heading).update(0)
  counter(page).update(1)

  body
}

// ----------------------------------------------------------------------------------------
/* 正文环境 */
#let main-matter(body) = {
  // --------------------------------------------
  /* 标题 */
  set heading(numbering: "1.1", outlined: true)
  show heading.where(level: 1): set heading(numbering: lans.chapter-sty, supplement: lans.chapter-prefix)
  show heading: it => {
    set text(size: main-text.size)
    if it.level == 1 {
      pagebreak()
      set text(..heading1-sty.text)
      set par(leading: 1em)
      set align(center)
      counter(image).update(0)
      counter(table).update(0)
      counter(raw).update(0)
      counter(math.equation).update(0)
      context{
        let img = heading-image.get()
        if heading1-sty.image and img != none {
          set image(width: page-all.width, height: page-all.height * 0.3)
          place(dx: -page-all.mar-x, dy: -page-all.mar-t, img)
          place(
            dx: -page-all.mar-x,
            dy: -page-all.mar-t,
            block(
              width: page-all.width,
              height: page-all.height * 0.3
            )[
              #align(center + bottom)[
                #v(3fr)
                #block(
                  width: 65%,
                  stroke: (0.7mm + colour.theme),
                  radius: 3.5mm,
                  inset: 0.7em,
                  fill: rgb("#FFFFFFAA"),
                  it
                )
                #v(1fr)
              ]
            ])
          v(page-all.height * 0.3 - page-all.mar-t + 2em)
        } else {
          v(heading1-sty.upspace)
          it
          v(heading1-sty.downspace, weak: true)
        }
        chapter-title.update(it)
        section-title.update(none)
        part-judge.update(false)
        set-heading-image(none)
      }
    } else if it.level == 2 or it.level == 3 or it.level == 4 {
      if it.level == 2 {
        section-title.update(it)

        set text(..heading2-sty.text)
        v(heading2-sty.upspace, weak: true)
        block[
          #mark-display(
            it.numbering,
            heading2-sty.mark, 
            heading2-sty.mark-gutter,
            page-all.mar-x,
          )
          #it
        ]
        v(heading2-sty.downspace, weak: true)
      } else if it.level == 3 {
        set text(..heading3-sty.text)
        v(heading3-sty.upspace, weak: true)
        block[
          #mark-display(
            it.numbering,
            heading3-sty.mark, 
            heading3-sty.mark-gutter,
            page-all.mar-x,
          )
          #it
        ]
        v(heading3-sty.downspace, weak: true)
      } else if it.level == 4 {
        set text(..heading4-sty.text)
        v(heading4-sty.upspace, weak: true)
        block[
          #mark-display(
            it.numbering,
            heading4-sty.mark, 
            heading4-sty.mark-gutter,
            page-all.mar-x,
          )
          #it
        ]
        v(heading4-sty.downspace, weak: true)
      } 
    } else {
      it
    }
  }

  // --------------------------------------------
  /* 页码 */
  set page(
    numbering: "1",
    footer: {
      set text(..aux-text.footer-text)
      context if not part-judge.get() {
        context align(center, counter(page).display("- 1 -"))
      }
    },
  )

  // --------------------------------------------
  /* 重新计数页码和章节 */
  counter(heading).update(0)
  counter(page).update(1)

  /* 全局公式图表序号表示 */
  let heading-index
  if not heading1-sty.index {
    heading-index = heading
  } else {
    heading-index = "global-heading"
  }

  // --------------------------------------------
  /* 公式计数样式 */
  set math.equation(
    numbering: num => numbering("(1.1)", counter(heading-index).get().first(), num),
  )

  // --------------------------------------------
  /* 图像表格计数样式 */
  show figure.where(kind: image).or(figure.where(kind: table)): set figure(
    numbering: num => numbering("1.1", counter(heading-index).get().first(), num),
  )

  // --------------------------------------------
  /* 盒子的各种环境配置 */
  set-theorion-numbering("1.1")

  body

}

// ----------------------------------------------------------------------------------------
/* 目录环境 */
#let my-outline() = context{
  show outline.entry.where(level: 1): it => ({
    if part-judge.at(it.element.location()) {
      set text(..outline-sty.part-text)
      if outline-sty.partbox {
        v(1.5em, weak:true)
        block(inset: 0.5em, width: 100%, fill: outline-sty.partbox-color)[
          #show: align.with(center+horizon)
          #numbering(lans.part-sty, ..part-count.at(it.element.location()))
          #part-title.at(it.element.location())
        ]
        v(1.5em, weak:true)
      } else {
        block(width: 100%)[
          #show: align.with(center+horizon)
          #numbering(lans.part-sty, ..part-count.at(it.element.location()))
          #part-title.at(it.element.location())
        ]
      }
    }
    block[
      #set text(..outline-sty.level1-text)
      #grid(
        columns: (outline-sty.headbox-size, 1fr),
        column-gutter: 1mm,
        [
          #show: align.with(right)
          #it.prefix()
        ],
        [
          #text(it.body() + " ")
          #set text(..outline-sty.other-text)
          #box(width: 1fr, repeat(outline-sty.fill))
          #text(" " + link(it.element.location(), it.page()))
        ]
      )
    ]
  })
  show outline.entry.where(level: 2): it => block({
    set text(..outline-sty.level2-text)
    grid(
      columns: (outline-sty.headbox-size, 1fr),
      column-gutter: 1mm,
      [
        #show: align.with(right)
        #it.prefix()
      ],
      [
        #text(it.body() + " ")
        #set text(..outline-sty.other-text)
        #box(width: 1fr, repeat(outline-sty.fill))
        #text(" " + link(it.element.location(), it.page()))
      ]
    )
  })
  show outline.entry.where(level: 3): it => block({
    set text(..outline-sty.level3-text)
    grid(
      columns: (outline-sty.headbox-size, 1fr),
      column-gutter: 1mm,
      [],
      [
        #text(it.prefix() + " " + it.body() + " ")
        #set text(..outline-sty.other-text)
        #box(width: 1fr, repeat(outline-sty.fill))
        #text(" " + link(it.element.location(), it.page()))
      ]
    )
  })
  outline(depth: outline-sty.depth, target: heading)
}

// ----------------------------------------------------------------------------------------
/* 部分环境（注意，这里会导致增加部分标签） */
/* chapter-reindex 表示引入部分页是否初始化章节的序号 */
#let part-page(title, chapter-reindex: heading1-sty.part, img: none, body: none) = context{
  pagebreak()
  if chapter-reindex {counter(heading).update(0)} // 是否初始化章节序号
  part-count.step()
  part-judge.update(true)
  part-title.update(title)

  set image(width: 100%, height: 100%)
  set page(background: img)

  if body == none {
    v(page-all.height * 0.15)
    align(
      center,
      box(width: 80%, radius: 10pt, fill: rgb("#ffffffaa"), inset: 0.5em, stroke: 1pt)[
        #box(width: 99%, inset: 0.5em)[
          #text(..heading1-sty.text, part-count.display("第一部分") + " " + title
          )
        ]
      ]
    )
  } else {
    body
  }
}

// ----------------------------------------------------------------------------------------
/* 附录环境 */
/* in-main 表示附录页是否在正文内部，在正文内部要回复正文标题序号； */
/* count 表示一个独立的附录计数器，统一不同环境附录的计数 */
#let appendix(body, in-main: false, count: true) = context{

  let main-heading-index = counter(heading).get() // 获取正文的标题序号

  /* 标题样式 */
  set heading(numbering: "A.1", outlined: true)
  show heading.where(level: 1): set heading(numbering: lans.appendix-sty, supplement: lans.appendix-prefix)
  show heading.where(level: 1): it => {
    it
    counter("appendix-count").step()
  }

  /* 附录标题序号单独计数环境 */
  if count {
    counter(heading).update(counter("appendix-count").get())
  } else {
    counter(heading).update(0)
  }

  // --------------------------------------------
  /* 公式计数样式 */
  set math.equation(
    numbering: num => numbering("(A.1)", counter(heading).get().first(), num),
  )

  /* 图像表格计数样式 */
  show figure.where(kind: image).or(figure.where(kind: table)): set figure(
    numbering: num => numbering("A.1", counter(heading).get().first(), num),
  )

  // --------------------------------------------
  /* 盒子的各种环境配置 */
  set-theorion-numbering("A.1")

  body

  if in-main {counter(heading).update(main-heading-index)} // 恢复正文标题序号
  set-theorion-numbering("1.1") // 恢复盒子正文计数样式
}

// ----------------------------------------------------------------------------------------
/* 参考文献环境 */
#let my-bibliography(it) = {
  pagebreak(weak: true)
  set bibliography(style: lans.cite-sty)
  it
}