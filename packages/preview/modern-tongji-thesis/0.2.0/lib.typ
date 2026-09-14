#import "utils/fonts.typ": *
#import "utils/tables.typ": *
#import "utils/theorion.typ": *
#import "utils/helpers.typ": *
#import "utils/word-count.typ": *
#import "utils/lists.typ": *
#import "utils/continued-table.typ": *
#import "utils/figurex.typ": *
#import "layouts/cover.typ": *
#import "layouts/info-page.typ": *
#import "layouts/abstract.typ": *
#import "layouts/outline.typ": *
#import "layouts/header-footer.typ": *
#import "layouts/references.typ": *
#import "layouts/appendix.typ": *
#import "@preview/gb7714-bilingual:0.2.3": init-gb7714-impl, gb7714-bibliography, multicite
#import "@preview/algo:0.3.6": algo, i, d, comment, code
#import "@preview/wordometer:0.1.5": word-count-of
#import "@preview/cuti:0.4.0": show-cn-fakebold
#import "@preview/equate:0.3.3": equate
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": codly-languages

#let thesis(
  school: "某学院", major: "某专业", id: "0000000", student: "某某某", advisor: "某某某", title: "某标题", subtitle: "某副标题", title-english: "Some Title", subtitle-english: "Some Subtitle", date: datetime.today(), abstract: "慧枫尚萍氢，驳展妙棚端梦称委竞励。绘象臂淬人壳闭营风混仓、问抬兽村蜡胡锹挤污艰烃伏惧派宝既抓章住蓟棒褶均谭穿谴属；羟贮银…钓郭曾牙记氢硝巍仰蒲邀趟。革旅剑撞压单施宵饼狼将售烷贸问术粮洞魔。却烟陕倍且隘框糟秩板商，宙刚疮顿表羽楞景哺驯邮戒歌溜著聪峻忙劈左绩卖卫萨讯完读百釉好仔帜纽龟玉炒脂衍蛴瓦副冯查索桐梁；轴派？蝗丸朝保岂搅搞燕挫品休礼倾玻黑李宽列邮苦仔汛鳙物己弱寸栓孝哄俭牙敬厄搬吨楞干捧原趋息…善！", keywords: ("关键词1", "关键词2", "关键词3"), abstract-english: lorem(300), keywords-english: ("Keyword1", "keyword2", "keyword3"), doc,
  field: "science",
  fontset: "fandol",
  // Info page
  infotype: "thesis", infoabstract: "", infodrawings: "", infowordcount: "", infothesiswords: "", infomaterials: (),
  // Abstract titles (defaults to thesis title)
  abstract-title: none, abstract-subtitle: none, abstract-title-english: none, abstract-subtitle-english: none,
  // Bibliography
  bib-content: none,
  // Twoside
  twoside: false,
  // Punctuation — "circle" keeps U+3002, "dot" replaces with U+FF0E
  fullwidthstop: "circle",
) = {
  let is-humanities = (field == "humanities")
  let cover-text = if is-humanities { "毕业论文（设计）" } else { "毕业设计（论文）" }
  let header-text = cover-text

  // Apply fontset
  let p = font-presets.at(fontset)
  let ff = (
    song: p.song,
    hei: p.hei,
    kai: p.kai,
    fang: p.fang,
    xiaobiaosong: p.song,
    xihei: p.hei,
    code: ("DejaVu Sans Mono", "Fira Code"),
    math: ("New Computer Modern Math",),
  )
  set document(author: id + " " + student, title: title)
  let page-margin = if twoside {
    (top: 4.0cm, bottom: 2.7cm, inside: 3.3cm, outside: 1.8cm)
  } else {
    (top: 4.0cm, bottom: 2.7cm, left: 3.3cm, right: 1.8cm)
  }
  set page(
    paper: "a4", margin: page-margin, binding: left,
  )
  set text(TJFONT_BODY, font: ff.song, lang: "zh", region: "cn")

  make-cover(
    (
      "课题名称", title, "副标题", subtitle, "学院", school, "专业", major, "学生姓名", student, "学号", id, "指导教师", advisor, "日期", date.display("[year]年[month]月[day]日"),
    ),
    cover-text: cover-text,
    fonts: ff,
  )
  newpage(twoside: twoside)

  make-info-page(
    title: title, subtitle: subtitle, school: school, major: major,
    infotype: infotype, infoabstract: infoabstract, infodrawings: infodrawings,
    infowordcount: infowordcount, infothesiswords: infothesiswords,
    infomaterials: infomaterials, header-text: header-text, fonts: ff,
  )
  newpage(twoside: twoside)

  set par(justify: true, first-line-indent: (amount: 2em, all: true), leading: 1.2em, spacing: 1.2em)
  set par(justification-limits: (tracking: (min: -0.01em, max: 0.02em)), linebreaks: "optimized")
  show: show-cn-fakebold
  show strong: it => text(font: ff.hei, it.body)
  show emph: it => text(font: ff.kai, style: "italic", it.body)
  show raw: set text(font: ff.code)
  show math.equation: set text(font: ff.math)
  // Display math spacing: 0pt above/below (official spec)
  show math.equation.where(block: true): it => v(0pt) + it + v(0pt)
  show: equate.with(breakable: true, sub-numbering: false)
  set underline(offset: 3pt, stroke: 0.6pt)
  // Circled number footnotes
  set footnote(numbering: n => circled-number(n))
  // Lists: decoupled-marker layout avoids CJK-Latin baseline offset in items
  set enum(
    numbering: (..nums) => {
      let pos = nums.pos()
      if pos.len() == 1 {
        "（" + str(pos.first()) + "）"
      } else if pos.len() == 2 {
        circled-number(pos.last())
      } else {
        // Deeper nesting — use circled numbers
        circled-number(pos.last())
      }
    },
    indent: 2em,
    spacing: 1.2em,
  )
  set list(indent: 2em, spacing: 1.2em)
  if fullwidthstop == "dot" {
    show "。": "．"
  }

  // Cross-reference formatting — "第 X 章" / "第 X 节" pattern
  show ref: it => {
    if it.element != none and it.element.func() == heading {
      let h = it.element
      if h.numbering != none {
        let n = numbering(h.numbering, ..counter(heading).at(h.location()))
        let lv = h.level
        let prefix = if lv == 1 { "第" + n + "章" } else if lv == 2 { "第" + n + "节" } else if lv == 3 { "第" + n + "小节" } else { none }
        if prefix != none { link(h.location(), prefix) } else { it }
      } else { it }
    } else {
      it
    }
  }

  set heading(numbering: (..nums) =>
    if is-humanities {
      let pos = nums.pos()
      if pos.len() == 1 {
        chinese-numeral(pos.at(0)) + "、"
      } else if pos.len() == 2 {
        "（" + chinese-numeral(pos.at(1)) + "）"
      } else if pos.len() == 3 {
        str(pos.at(2)) + "."
      } else if pos.len() == 4 {
        "（" + str(pos.at(3)) + "）"
      } else if pos.len() == 5 {
        circled-number(pos.at(4))
      } else {
        pos.map(str).join(".")
      }
    } else {
      if nums.pos().len() <= 3 {
        nums.pos().map(str).join(".")
      } else if nums.pos().len() == 4 {
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ".at(nums.pos().at(-1) - 1) + "."
      } else if nums.pos().len() == 5 {
        "abcdefghijklmnopqrstuvwxyz".at(nums.pos().at(-1) - 1) + "."
      }
    }
  )

  show heading: it => context {
    set par(first-line-indent: 0pt)
    if it.level == 1 {
      set align(center)
      let heading-size = if it.numbering != none { TJFONT_CHAPTER } else { TJFONT_HEADING }
      set text(font: ff.hei, size: heading-size, weight: "regular")
      v(16pt)
      if it.numbering != none {
        numbering(it.numbering, ..counter(heading).get())
        h(0.6em)
        it.body
      } else {
        it.body
      }
      v(0.6em)
    } else if it.level == 2 {
      set text(font: ff.hei, size: TJFONT_BODY, weight: "regular")
      v(0.6em)
      if it.numbering != none {
        numbering(it.numbering, ..counter(heading).get())
        h(0.6em)
        it.body
      } else {
        it.body
      }
      v(0.6em)
    } else if it.level == 3 {
      set text(font: ff.hei, size: TJFONT_BODY, weight: "regular")
      v(0.6em)
      if it.numbering != none {
        h(2em)
        numbering(it.numbering, ..counter(heading).get())
        h(0.6em)
        it.body
      } else {
        h(2em)
        it.body
      }
      v(0.6em)
    } else if it.level == 4 {
      set text(font: ff.hei, size: TJFONT_BODY, weight: "regular")
      v(0.6em)
      if it.numbering != none {
        h(2em)
        numbering(it.numbering, ..counter(heading).get())
        h(0.6em)
        it.body
      } else {
        h(2em)
        it.body
      }
      v(0.6em)
    } else if it.level == 5 {
      set text(font: ff.hei, size: TJFONT_BODY, weight: "regular")
      v(0.6em)
      if it.numbering != none {
        h(2em)
        numbering(it.numbering, ..counter(heading).get())
        h(0.6em)
        it.body
      } else {
        h(2em)
        it.body
      }
      v(0.6em)
    } else {
      it
    }
  }

  // Theorem environments — matching LaTeX's independent per-type counters
  set-inherited-levels(1)
  set-theorion-numbering("1.1")
  set-qed-symbol[#sym.wj]

  show: show-thm
  show: show-cor
  show: show-lem
  show: show-prop
  show: show-conj
  show: show-assume
  show: show-dfn
  show: show-exmp
  show: show-rem
  show: show-pf

  // Figure auto-center + float spacing matching official spec
  // Skip theorem-kind figures (handled by theorion)
  show figure: it => {
    let thm-kinds = ("theorem", "lemma", "corollary", "proposition", "conjecture", "assumption", "definition", "example", "remark", "proof")
    if it.kind in thm-kinds { it }
    else if it.kind == "subfigure" { it }
    else { set align(center); v(1.2em) + it + v(1.2em) }
  }
  show figure: set block(breakable: true)
  show table: it => it
  show math.equation.where(block: true): it => it

  // Code blocks: syntax highlighting with line numbers
  show: codly-init.with()
  codly(languages: codly-languages)

  // Captions: 五号(10.5pt) 宋体, no indent
  show figure.caption: it => {
    set text(font: ff.song, size: TJFONT_CAPTION)
    set par(first-line-indent: 0pt)
    it
  }

  // Table text: 小五号(9pt)
  show figure.where(kind: table): it => {
    set text(size: TJFONT_TABLE)
    it
  }

  show heading: it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(figure.where(kind: "algo")).update(0)
    counter(figure.where(kind: "subfigure")).update(0)
    it
  }
  set figure(numbering: n => context {
    let ch = counter(heading).get().first()
    str(ch) + "." + str(n)
  })
  show math.equation.where(block: true): set math.equation(numbering: n => context {
    let ch = counter(heading).get().first()
    numbering("(1.1)", ch, n)
  })
  show figure.where(kind: table): set figure.caption(position: top)

  set page(
    margin: page-margin, binding: left,
    numbering: "I", header: make-page-header(ff, twoside, header-text), header-ascent: 20%, footer: context {
      set align(center)
      set text(font: ff.song, size: TJFONT_BODY)
      numbering("I", counter(page).get().first())
    },
  )
  counter(page).update(1)

  let cn-title = if abstract-title != none { abstract-title } else { title }
  let cn-subtitle = if abstract-subtitle != none { abstract-subtitle } else { subtitle }
  let en-title = if abstract-title-english != none { abstract-title-english } else { title-english }
  let en-subtitle = if abstract-subtitle-english != none { abstract-subtitle-english } else { subtitle-english }
  let cn-heading = if infotype == "engineering" { "设计总说明" } else { "摘" + h(0.5em) + "要" }

  make-abstract(
    title: cn-title, subtitle: cn-subtitle, abstract: abstract, keywords: keywords,
    prompt: (cn-heading, "关键词："), heading-override: cn-heading, fonts: ff,
  )
  pagebreak()

  make-abstract(
    title: en-title, subtitle: en-subtitle, abstract: abstract-english, keywords: keywords-english,
    prompt: ("ABSTRACT", "Key words: "), is-english: true, fonts: ff,
  )
  pagebreak()

  make-outline()
  newpage(twoside: twoside)

  set page(margin: page-margin, binding: left, numbering: "1", header: make-page-header(ff, twoside, header-text), header-ascent: 20%, footer: context {
    line(stroke: 1.8pt, length: 100%)
    set text(font: ff.song, size: TJFONT_BODY)
    v(-0.6em)
    let is-odd = calc.rem(counter(page).get().first(), 2) != 0
    let swap = twoside and not is-odd
    if swap {
      set align(left)
      [
        第#h(1em)
        #counter(page).display()
        #h(1em)页#h(1em)
        共#h(1em)
        #counter(page).final().at(0)#h(1em)
        页
      ]
    } else {
      set align(right)
      [
        共#h(1em)
        #counter(page).final().at(0)#h(1em)
        页#h(1em)
        第#h(1em)
        #counter(page).display()
        #h(1em)页
      ]
    }
  })
  counter(page).update(1)

  // Initialize bibliography if bib-content provided
  let body-with-bib = if bib-content != none {
    init-gb7714-impl(bib-content, style: "numeric", version: "2015", doc)
  } else {
    doc
  }

  // Word count tracking (CJK characters + words, excluding headings/tables/code)
  let word-count-tracked(content) = {
    let stats = word-count-of(
      content,
      exclude: (heading, table, raw, figure.caption),
      counter: s => {
        let cleaned = s.replace(regex("\s+"), "")
        (
          words-cjk: cleaned.clusters().len(),
        )
      },
    )
    state("total-words-cjk").update(prev => prev + stats.words-cjk)
    content
  }

  let body = word-count-tracked(body-with-bib)
  let final = apply-list-rules(body)

  final
}
