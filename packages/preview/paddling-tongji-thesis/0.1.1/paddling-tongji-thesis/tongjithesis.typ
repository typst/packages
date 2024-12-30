#import "elements.typ": *

#set pagebreak(weak: true)

#let thesis(
  school: "某学院", major: "某专业", id: "0000000", student: "某某某", teacher: "某某某", title: "某标题", subtitle: "某副标题", title-english: "Some Title", subtitle-english: "Some Subtitle", date: datetime.today(), abstract: "慧枫尚萍氢，驳展妙棚端梦称委竞励。绘象臂淬人壳闭营风混仓、问抬兽村蜡胡锹挤污艰烃伏惧派宝既抓章住蓟棒褶均谭穿谴属；羟贮银…钓郭曾牙记氢硝巍仰蒲邀趟。革旅剑撞压单施宵饼狼将售烷贸问术粮洞魔。却烟陕倍且隘框糟秩板商，宙刚疮顿表羽楞景哺驯邮戒歌溜著聪峻忙劈左绩卖卫萨讯完读百釉好仔帜纽龟玉炒脂衍蛴瓦副冯查索桐梁；轴派？蝗丸朝保岂搅搞燕挫品休礼倾玻黑李宽列邮苦仔汛鳙物己弱寸栓孝哄俭牙敬厄搬吨楞干捧原趋息…善！", keywords: ("关键词1", "关键词2", "关键词3"), abstract-english: lorem(300), keywords-english: ("Keyword1", "keyword2", "keyword3"), doc,
) = {
  set document(author: id + " " + student, title: title)
  set page(
    paper: "a4", margin: (top: 4.2cm, bottom: 2.7cm, left: 3.3cm, right: 1.8cm), binding: left,
  )
  set text(font-size.at("5"), font: font-family.song, lang: "zh", region: "cn")

  make-cover(
    (
      "课题名称", title, "副标题", subtitle, "学院", school, "专业", major, "学生姓名", student, "学号", id, "指导老师", teacher, "日期", date.display("[year]年[month]月[day]日"),
    ),
  )
  pagebreak()

  set par(justify: true, first-line-indent: 2em, leading: 0.9em)
  show par: set block(spacing: 0.9em)
  set math.equation(numbering: none) // not implemented yet: (1.1)
  show strong: it => text(font: font-family.hei, weight: "bold", it.body)
  show emph: it => text(font: font-family.kai, style: "italic", it.body)
  show raw: set text(font: font-family.code)
  show math.equation: set text(font: font-family.math)
  show raw.where(block: true): block.with(fill: luma(250), inset: 10pt, radius: 4pt)
  set underline(offset: 3pt, stroke: 0.6pt) // to make latin and CJK characters have the same underline offset
  set list(indent: 2em, spacing: 0.9em)

  set heading(numbering: (..nums) =>
  if nums.pos().len() <= 3 {
    nums.pos().map(str).join(".")
  } else if nums.pos().len() == 4 {
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ".at(nums.pos().at(-1) - 1) + ". "
  } else if nums.pos().len() == 5 {
    "abcdefghijklmnopqrstuvwxyz".at(nums.pos().at(-1) - 1) + ". "
  })

  show heading: it => locate(
    loc => {
      if it.level == 1 {
        set align(center)
        set text(font: font-family.hei, size: font-size.at("4"), weight: "bold")
        if it.numbering != none {
          numbering(it.numbering, ..counter(heading).at(loc))
          h(1em)
          it.body
        } else {
          it
        }
        v(1.5em)
      } else if it.level == 2 {
        set text(font: font-family.hei, size: font-size.at("5"), weight: "bold")
        v(0.5em)
        if it.numbering != none {
          h(-2em)
          numbering(it.numbering, ..counter(heading).at(loc))
          h(1em)
          it.body
        } else {
          it
        }
        v(1em)
      } else if it.level == 3 {
        set text(font: font-family.hei, size: font-size.at("5"), weight: "bold")
        v(0.5em)
        if it.numbering != none {
          numbering(it.numbering, ..counter(heading).at(loc))
          h(1em)
          it.body
        } else {
          it
        }
        v(1em)
      } else if it.level == 4 {
        set text(font: font-family.hei, size: font-size.at("5"), weight: "bold")
        v(-0.5em)
        grid(columns: (2em, 1fr), [], it)
        v(0.5em)
      } else if it.level == 5 {
        set text(font: font-family.hei, size: font-size.at("5"), weight: "bold")
        v(-0.5em)
        grid(columns: (2em, 1fr), [], it)
        v(0.5em)
      } else {
        it
      }
    },
  ) + empty-par()

  show list: it => it + empty-par()
  show enum: it => it + empty-par()
  show figure: it => v(0.5em) + it + v(0.5em) + empty-par()
  show figure: set block(breakable: true)
  show table: it => it + empty-par()
  show math.equation.where(block: true): it => it + empty-par()
  show raw.where(block: true): it => it + empty-par()

  show heading: i-figured.reset-counters.with(extra-kinds: ("algo",))
  show figure: i-figured.show-figure.with(extra-prefixes: (algo: "algo:"))
  show math.equation.where(block: true): i-figured.show-equation
  show figure.where(kind: table): set figure.caption(position: top)

  set page(
    numbering: "I", header: {
      set text(font: font-family.song, font-size.at("-4"))
      grid(
        columns: (0.5em, 1fr, auto, 0.5em), [], image("figures/tongji.svg", height: 1cm), block(height: 0.7cm, [#set align(right); 毕业设计（论文）]), [],
      )
      v(-0.5em)
      line(length: 100%, stroke: 1.8pt)
      draw-binding()
    }, header-ascent: 20%, footer: locate(loc => {
      set align(center)
      set text(font: font-family.song, size: font-size.at("-4"))
      numbering("I", counter(page).at(loc).first())
    }),
  )
  counter(page).update(1)

  make-abstract(
    title: title, abstract: abstract, keywords: keywords, prompt: ("摘要", "关键词："),
  )
  pagebreak()

  make-abstract(
    title: title-english, abstract: abstract-english, keywords: keywords-english, prompt: ("ABSTRACT", "Key words: "), is-english: true,
  )
  pagebreak()

  make-outline()
  pagebreak()

  set page(footer: locate(loc => {
    line(stroke: 1.8pt, length: 100%)
    set align(right)
    set text(font: font-family.song, size: font-size.at("-4"))
    v(-0.6em)
    [
      共#h(1em)
      #counter(page).final(loc).at(0)#h(1em)
      页#h(1em)
      第#h(1em)
      #counter(page).display()
      #h(1em)页
    ]
  }))
  counter(page).update(1)

  doc
}
