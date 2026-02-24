#import "@preview/a2c-nums:0.0.1": int-to-cn-simple-num
#import "@preview/cuti:0.3.0": show-cn-fakebold
#show: show-cn-fakebold

#let 字号 = (
  初号: 42pt,
  小初: 36pt,
  一号: 26pt,
  小一: 24pt,
  二号: 22pt,
  小二: 18pt,
  三号: 16pt,
  小三: 15pt,
  四号: 14pt,
  中四: 13pt,
  小四: 12pt,
  五号: 10.5pt,
  小五: 9pt,
  六号: 7.5pt,
  小六: 6.5pt,
  七号: 5.5pt,
  小七: 5pt,
)

#let 字体 = (
  仿宋: ("Tex Gyre Termes", "FandolFang R"),
  宋体: ("Tex Gyre Termes", "FandolSong"),
  黑体: ("Tex Gyre Heros","FandolHei"),
  楷体: ("Tex Gyre Termes", "FandolKai"),
  代码: ("Cascadia Code", "FandolHei"),
)

#let lengthceil(len, unit: 字号.小四) = calc.ceil(len / unit) * unit
#let partcounter = counter("part")
#let chaptercounter = counter("chapter")
#let appendixcounter = counter("appendix")
#let footnotecounter = counter(footnote)
#let rawcounter = counter(figure.where(kind: "code"))
#let imagecounter = counter(figure.where(kind: image))
#let tablecounter = counter(figure.where(kind: table))
#let equationcounter = counter(math.equation)
#let appendix() = {
  appendixcounter.update(50)
  chaptercounter.update(0)
  counter(heading).update(0)
}
#let skippedstate = state("skipped", false)

#let chinesenumber(num, standalone: false) = if num < 11 {
  ("零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十").at(num)
} else if num < 100 {
  if calc.rem(num, 10) == 0 {
    chinesenumber(calc.floor(num / 10)) + "十"
  } else if num < 20 and standalone {
    "十" + chinesenumber(calc.rem(num, 10))
  } else {
    chinesenumber(calc.floor(num / 10)) + "十" + chinesenumber(calc.rem(num, 10))
  }
} else if num < 1000 {
  let left = chinesenumber(calc.floor(num / 100)) + "百"
  if calc.rem(num, 100) == 0 {
    left
  } else if calc.rem(num, 100) < 10 {
    left + "零" + chinesenumber(calc.rem(num, 100))
  } else {
    left + chinesenumber(calc.rem(num, 100))
  }
} else {
  let left = chinesenumber(calc.floor(num / 1000)) + "千"
  if calc.rem(num, 1000) == 0 {
    left
  } else if calc.rem(num, 1000) < 10 {
    left + "零" + chinesenumber(calc.rem(num, 1000))
  } else if calc.rem(num, 1000) < 100 {
    left + "零" + chinesenumber(calc.rem(num, 1000))
  } else {
    left + chinesenumber(calc.rem(num, 1000))
  }
}

#let chinesenumbering(..nums, location: none, brackets: false) = context {
  let actual_loc = if location == none { here() } else { location }
  if appendixcounter.at(actual_loc).first() < 50 {
    if nums.pos().len() == 1 {
      "第" + [#nums.pos().first()] + "章"
    } else {
      numbering(if brackets { "(1.1)" } else { "1.1" }, ..nums)
    }
  } else {
    if nums.pos().len() == 1 {
      "附录 " + numbering("A.1", ..nums)
    } else {
      numbering(if brackets { "(A.1)" } else { "A.1" }, ..nums)
    }
  }
}

#let chineseunderline(s, width: 300pt, bold: false) = {
  let chars = s.clusters()
  let n = chars.len()
  style(styles => {
    let i = 0
    let now = ""
    let ret = ()

    while i < n {
      let c = chars.at(i)
      let nxt = now + c

      if measure(nxt, styles).width > width or c == "\n" {
        if bold {
          ret.push(strong(now))
        } else {
          ret.push(now)
        }
        ret.push(v(-1em))
        ret.push(line(length: 100%))
        if c == "\n" {
          now = ""
        } else {
          now = c
        }
      } else {
        now = nxt
      }

      i = i + 1
    }

    if now.len() > 0 {
      if bold {
        ret.push(strong(now))
      } else {
        ret.push(now)
      }
      ret.push(v(-0.9em))
      ret.push(line(length: 100%))
    }

    ret.join()
  })
}

#let chineseoutline(title: "目　　录", depth: none, indent: false) = {
  heading(title, numbering: none, outlined: false)
  context{
    let it = here()
    let elements = query(heading.where(outlined: true).after(it))

    for el in elements {
      // Skip list of images and list of tables
      if partcounter.at(el.location()).first() < 20 and el.numbering == none { continue }

      // Skip headings that are too deep
      if depth != none and el.level > depth { continue }

      let maybe_number = if el.numbering != none {
        if el.numbering == chinesenumbering {
          chinesenumbering(..counter(heading).at(el.location()), location: el.location())
        } else {
          numbering(el.numbering, ..counter(heading).at(el.location()))
        }
        h(0.5em)
      }

      let line = {
        if indent {
          h(1em * (el.level - 1 ))
        }

        if el.level == 1 {
          v(0.5em, weak: true)
        }

        if maybe_number != none {
          //style(styles => {
          //  let width = measure(maybe_number, styles).width
            box(
              width: auto,//lengthceil(width),
              link(el.location(), if el.level == 1 {
                strong(maybe_number)
              } else {
                maybe_number
              })
            )
          //})
        }

        link(el.location(), if el.level == 1 {
          strong(el.body)
        } else {
          el.body
        })

        // Filler dots
        // if el.level == 1 {
        //   box(width: 1fr, h(10pt) + box(width: 1fr) + h(10pt))
        // } else {
           box(width: 1fr, h(10pt) + box(width: 1fr, repeat[.]) + h(10pt))
        // }

        // Page number
        let footer = query(selector(<__footer__>).after(el.location()))
        let page_number = if footer == () {
          0
        } else {
          counter(page).at(footer.first().location()).first()
        }
        
        link(el.location(), if el.level == 1 {
          strong(str(page_number))
        } else {
          str(page_number)
        })

        linebreak()
        v(-0.2em)
      }

      line
    }
  }
}

#let listoffigures(title: "插图清单", kind: image) = {
  heading(title, numbering: none, outlined: true)
  context{
    let it = here()
    let elements = query(figure.where(kind: kind).after(it))
    set par(spacing: 12pt)

    for el in elements {
      let maybe_number = {
        let el_loc = el.location()
        if kind == image{
          [图]
        } else if kind == table{
          [表]
        }
        chinesenumbering(chaptercounter.at(el_loc).first(), counter(figure.where(kind: kind)).at(el_loc).first(), location: el_loc)
        h(0.5em)
      }
      let line = {
        //style(styles => {
        //let width = measure(maybe_number, styles).width
          box(
            width: auto,//lengthceil(width),
            link(el.location(), maybe_number)
        //  )}
        )

        link(el.location(), el.caption.body)

        // Filler dots
        box(width: 1fr, h(10pt) + box(width: 1fr, repeat[.]) + h(10pt))

        // Page number
        let footers = query(selector(<__footer__>).after(el.location()))
        let page_number = if footers == () {
          0
        } else {
          counter(page).at(footers.first().location()).first()
        }
        link(el.location(), str(page_number))
        linebreak()
        v(-0.2em)
      }

      line
    }
  }
}

#let codeblock(raw, caption: none, outline: false) = {
  figure(
    if outline {
      rect(width: 100%)[
        #set align(left)
        #raw
      ]
    } else {
      set align(left)
      raw
    },
    caption: caption, kind: "code", supplement: ""
  )
}

#let booktab(columns: (), aligns: (), width: auto, caption: none, ..cells) = {
  let headers = cells.pos().slice(0, columns.len())
  let contents = cells.pos().slice(columns.len(), cells.pos().len())
  set align(center)

  if aligns == () {
    for i in range(0, columns.len()) {
      aligns.push(center)
    }
  }

  let content_aligns = ()
  for i in range(0, contents.len()) {
    content_aligns.push(aligns.at(calc.rem(i, aligns.len())))
  }

  /*return*/ figure(
    block(
      width: width,
      grid(
        columns: (auto),
        row-gutter: 1em,
        line(length: 100%),
        [
          #set align(center)
          #box(
            width: 100% - 1em,
            grid(
              columns: columns,
              ..headers.zip(aligns).map(it => [
                #set align(it.last())
                #strong(it.first())
              ])
            )
          )
        ],
        line(length: 100%),
        [
          #set align(center)
          #box(
            width: 100% - 1em,
            grid(
              columns: columns,
              row-gutter: 1em,
              ..contents.zip(content_aligns).map(it => [
                #set align(it.last())
                #it.first()
              ])
            )
          )
        ],
        line(length: 100%),
      ),
    ),
    caption: caption,
    kind: table
  )
}





#let conf(
  文章类型: "Theis", //"Thesis"或"Dissertation"

作者名: "某某某",

作者_英: "Some Guy",

论文题目:[
  清华大学研究生学位论文
  
  Typst模板
],

论文题目_书脊:"清华大学研究生学位论文 Typst 模板", //仅用于书脊页，内容同上，但去除换行，中西文之间添加空格，括号用半角

论文题目_英: "Tsinghua Thesis Typst Template",

副标题: "申请清华大学医学博士学位论文",

院系: "基础医学系",

英文学位名: "Doctor of Medicine",

专业: "基础医学",

专业_英: "Basic Medical Sciences",

导师: "某某某 教授",

导师_英: "Professor Some Prof",

副导师: "某某某 教授", //前往template.typ搜索变量名以调整

副导师_英: "Professor Some Prof",

日期: datetime.today(), //默认为当前日期

关键词: ("Typst", "模板"),

关键词_英: ("Typst", "Template", [_Italic Text_]),

指导小组名单: /*三个为一组，姓名-职称-单位*/
("某某某", "教授", "清华大学",
"某    某", "副教授", "清华大学",
"某某某", "助理教授", "清华大学"),

公开评阅人名单:
("某某某", "教授", "清华大学",
"某某某", "副教授", "XXXX大学",
"某某某", "研究员", "中国XXXX科学院XXXXXX研究所"),

答辩委员会名单:/*注意，所有委员只有第一个需要写明，其余留空字符串*/
("主席", "某某某", "教授", "清华大学",
"委员", "某某某", "教授", "清华大学",
"", "某某某", "研究员", "中国XXXX科学院\nXXXXXX研究所",
"", "某某某", "教授", "XXXX大学",
"", "某某某", "副教授", "XXXX大学",
"秘书", "某某某", "助理研究员", "清华大学"),

参考文献格式: "cell", // https://typst.app/docs/reference/model/bibliography/#parameters-style

文献库: "文献库.bib",

目录深度: 3,

盲审版本: false, // 尚未调整

插图清单: true,

附表清单: true,

代码清单: false, // 尚未调整

右页起章: false, // 目前有bug

字体: (
  仿宋: ("Tex Gyre Termes", "FandolFang R"),
  宋体: ("Tex Gyre Termes", "FandolSong"),
  黑体: ("Tex Gyre Heros","FandolHei"),
  楷体: ("Tex Gyre Termes", "FandolKai"),
  代码: ("Cascadia Code", "FandolHei"),
),

others: none,

doc: none

) = {
  
  let pagebreakToRight = () => {
    if 右页起章 {
      skippedstate.update(true)
      pagebreak(to: "odd", weak: true)
      skippedstate.update(false)
    } else {
      pagebreak(weak: true)
    }
  }

set page("a4",
    header: context {
      //let currentPage = here().page()
      let nextFooterLoc = query(selector(<__footer__>).after(here())).first().location()
      let chaptersBefore = query(selector(heading.where(level:1)).before(nextFooterLoc))
      let currentChapNumber = chaptercounter.at(nextFooterLoc).first()
      if chaptersBefore != (){
        [
          #set align(center)
          #set text(字号.五号, font: 字体.宋体)
          #if currentChapNumber > 0 and chaptersBefore.last().numbering != none {chinesenumbering(currentChapNumber)+h(1em)}
          #chaptersBefore.last().body
          #v(-5pt)
          #line(length: 100%)
          #v(-18pt)
        ]
      }
    },
    // header: locate(loc => {
    //   if skippedstate.at(loc) and calc.even(loc.page()) { return }
    //   [
    //     #set text(字号.五号)
    //     #set align(center)
    //     #if partcounter.at(loc).at(0) < 10 {
    //       let headings = query(selector(heading).after(loc), loc)
    //       let next_heading = if headings == () {
    //         ()
    //       } else {
    //         headings.first().body.text
    //       }

    //       // [HARDCODED] Handle the first page of Chinese abstract specailly
    //       if next_heading == "摘　　要" and calc.odd(loc.page()) {
    //         [
    //           #next_heading
    //           #v(-1em)
    //           #line(length: 100%)
    //         ]
    //       }
    //     } else if partcounter.at(loc).at(0) <= 20 {
    //       if calc.even(loc.page()) {
    //         [
    //           #align(center, cheader)
    //           #v(-1em)
    //           #line(length: 100%)
    //         ]
    //       } else {
    //         let footers = query(selector(<__footer__>).after(loc), loc)
    //         if footers != () {
    //           let elems = query(
    //             heading.where(level: 1).before(footers.first().location()), footers.first().location()
    //           )

    //           // [HARDCODED] Handle the last page of Chinese abstract specailly
    //           let el = if elems.last().body.text == "摘　　要" or not skippedstate.at(footers.first().location()) {
    //             elems.last()
    //           } else {
    //             elems.at(-2)
    //           }
    //           [
    //             #let numbering = if el.numbering == chinesenumbering {
    //               chinesenumbering(..counter(heading).at(el.location()), location: el.location())
    //             } else if el.numbering != none {
    //               numbering(el.numbering, ..counter(heading).at(el.location()))
    //             }
    //             #if numbering != none {
    //               numbering
    //               h(0.5em)
    //             }
    //             #el.body
    //             #v(-1em)
    //             #line(length: 100%)
    //           ]
    //         }
    //       }
    //   }]}),
    footer: 
    //   context { 
    //   let loc = here()
    //   if skippedstate.at(loc) and calc.even(loc.page()) { return }
    //   [
    //     #set text(字号.五号)
    //     #set align(center)
    //     #if query(selector(heading).before(loc)).len() < 2 or query(selector(heading).after(loc)).len() == 0 {
    //       // Skip cover, copyright and origin pages
    //     } else {
    //       let headers = query(selector(heading).before(loc))
    //       let part = partcounter.at(headers.last().location()).first()
    //       [
    //         #if part < 20 {
    //           numbering("I", counter(page).at(loc).first())
    //         } else {
    //           str(counter(page).at(loc).first())
    //         }
    //       ]
    //     }
    //     #label("__footer__")
    //   ]
    // },
    context [
      #set align(center)
      #set text(字号.五号, font: 字体.宋体)
      #if query(selector(heading).before(here())) != () [
        #move(dy:-12pt,counter(page).display())
      ]#label("__footer__")
    ]
  )

  set text(字号.一号, font: 字体.宋体, lang: "zh")
  set align(center + horizon)
  set heading(numbering: chinesenumbering)
  set figure(
    numbering: (..nums) => context { let loc = here()
      if appendixcounter.at(loc).first() < 10 {
        numbering("1.1", chaptercounter.at(loc).first(), ..nums)
      } else {
        numbering("A.1", chaptercounter.at(loc).first(), ..nums)
      }
    }
  )
  set math.equation(
    numbering: (..nums) => context { let loc = here()
      set text(font: 字体.宋体)
      if appendixcounter.at(loc).first() < 10 {
        numbering("(1.1)", chaptercounter.at(loc).first(), ..nums)
      } else {
        numbering("(A.1)", chaptercounter.at(loc).first(), ..nums)
      }
    }
  )
  set list(indent: 2em)
  set enum(indent: 2em)

  //show strong: it => text(font: 字体.黑体, weight: "semibold", it.body)
  show emph: it => text(font: 字体.楷体, style: "italic", it.body)
  set par(first-line-indent: (amount: 2em, all: true))
  show raw: set text(font: 字体.代码)

  show heading: it => {
    set text(font: 字体.黑体, weight: "medium")
    set par(first-line-indent: 0em)
    let showHeading(it, size, above: 0em, below: 0em, hard_above: 0em, hard_below: 0em) = {
    set text(size)
      block(
        above: above, below: below,
        {
          v(hard_above)
          if it.numbering != none {
            counter(heading).display()
            h(1em)
          }
          it.body
          v(hard_below)
        }
      )
    }
    
    if it.level == 1 {
      
      // if not it.body.text in ("Abstract", "学位论文使用授权说明", "版权声明","摘　　要")  {
      if it.numbering != none{
        pagebreakToRight()
      } else{
        pagebreak()
      }
      
      //locate(loc => {
        context { let loc = here()
          if it.body.text == "摘　　要" {
            partcounter.update(10)
            //counter(page).update(1)
          } else if it.numbering != none and partcounter.at(loc).first() < 20 {
            partcounter.update(20)
            //counter(page).update(1)
          } 
        }
      
      if it.numbering != none {
        chaptercounter.step()
      }
      

      
      footnotecounter.update(())
      imagecounter.update(())
      tablecounter.update(())
      rawcounter.update(())
      equationcounter.update(())

      set align(center)

      // 设置heading样式
      showHeading(it, 字号.三号, hard_above: 27pt, below: 29pt)
    } else {
      
      if it.level == 2 {
        showHeading(it, 字号.四号, above: 32pt, below: 16pt)
      } else if it.level == 3 {
        showHeading(it, 字号.中四, above: 21pt, below: 16pt)
      } else {
        showHeading(it, 字号.小四, above: 21pt, below: 16pt)
      }
      
    }
  }
  
  show figure: it => [
    #set align(center)
    #if not it.has("kind") {
      it
    } else if it.kind == image {
      it.body
      [
        #set text(11pt)
        #v(-2pt)
        #it.caption
        #v(11pt)
      ]
    } else if it.kind == table {
      [
        #set text(11pt)
        //#it.caption
      ]
      it.body
    } else if it.kind == "code" {
      [
        #set text(11pt)
        代码#it.caption
      ]
      it.body
    }
  ]

  show ref: it => {
    if it.element == none {
      // Keep citations as is
      it
    } else {
      // Remove prefix spacing
      h(0em, weak: true)

      let el = it.element
      let el_loc = el.location()
      if el.func() == math.equation {
        // Handle equations
        link(el_loc, [
          式
          #chinesenumbering(chaptercounter.at(el_loc).first(), equationcounter.at(el_loc).first(), location: el_loc, brackets: true)
        ])
      } else if el.func() == figure {
        // Handle figures
        if el.kind == image {
          link(el_loc, [
            图
            #chinesenumbering(chaptercounter.at(el_loc).first(), imagecounter.at(el_loc).first(), location: el_loc)
          ])
        } else if el.kind == table {
          link(el_loc, [
            表
            #chinesenumbering(chaptercounter.at(el_loc).first(), tablecounter.at(el_loc).first(), location: el_loc)
          ])
        } else if el.kind == "code" {
          link(el_loc, [
            代码
            #chinesenumbering(chaptercounter.at(el_loc).first(), rawcounter.at(el_loc).first(), location: el_loc)
          ])
        }
      } else if el.func() == heading {
        // Handle headings
        if el.level == 1 {
          link(el_loc, chinesenumbering(..counter(heading).at(el_loc), location: el_loc))
        } else {
          link(el_loc, [
            节
            #chinesenumbering(..counter(heading).at(el_loc), location: el_loc)
          ])
        }
      }

      // Remove suffix spacing
      h(0em, weak: true)
    }
  }

  let scatterChars(str, width: none) = {
    set align(left)
    if width == none{
      str
    } else {
      box(
      width: width,
      stack(
        dir: ltr,
        ..str.clusters().map(x => [#x]).intersperse(1fr),
      ),
    )
    }
  }


  // let fieldvalue(value) = [
  //   #set align(left)
  //   #grid(
  //     rows: (auto, auto),
  //     row-gutter: 0.2em,
  //     value,
  //   )
  // ]



  
// 封面

if 盲审版本 {
  [盲审封面，尚未完成]
} else {
  // box(
  //   grid(
  //     columns: (auto, auto),
  //     gutter: 0.4em,
  //     image("pkulogo.svg", height: 2.4em, fit: "contain"),
  //     image("pkuword.svg", height: 1.6em, fit: "contain")
  //   )
  // )
  // linebreak()
  // strong(副标题)

  set page(margin: (x: 4cm, y: 6cm))
  set align(top)
  set par(spacing: 1em)
  // place(rect( width: 100%,height: 100%,)) //显示页边距
  v(5pt)
  text(字号.一号, font: 字体.黑体)[#论文题目]

  v(7pt)
  text(字号.小二, font: 字体.宋体, tracking: 1pt)[（#副标题）]
  
  set text(字号.三号, font: 字体.仿宋)


  set align(bottom)
  let coverInfoKeyWidth = 5em
  grid(
    rows: 12pt,
    columns: (5em,2em, auto),
    row-gutter: 1.2em,
    scatterChars("培养单位", width: coverInfoKeyWidth),h(0.5em)+"：",
    scatterChars(院系),
    
    scatterChars("学科", width: coverInfoKeyWidth),h(0.5em)+"：",
    scatterChars(专业),
    
    scatterChars("研究生", width: coverInfoKeyWidth),h(0.5em)+"：",
    scatterChars(作者名, width: 4em),
    
    scatterChars("指导教师", width: coverInfoKeyWidth),h(0.5em)+"：",
    scatterChars(导师, width: 8em),

    if 副导师 != none{
      grid(
        rows: 12pt,
        columns: (5em,2em, auto),
        row-gutter: 1.2em,
        scatterChars("副指导教师", width: coverInfoKeyWidth),h(0.5em)+"：",
        scatterChars(副导师, width: 8em), 
      )
   }
  )
  
  
  v(55pt)
   text(字号.三号, font: 字体.宋体)[
    #str(int-to-cn-simple-num(日期.year())+"年"+int-to-cn-simple-num(日期.month())+"月")
  ]
  v(15pt)
}




// 书脊
pagebreak()
set align(top + left)
set text(字号.小四, font: 字体.宋体)
[
  #set page(margin: (x: 1cm, y: 5.5cm))
  //#place(rect( width: 100%,height: 100%,)) //显示页边距
  #set text(字号.小三, font: 字体.仿宋)
  #set align(top + left)
  
  #let r(c) = if (c.contains(regex("[[:ascii:]]"))) {
    c
  } else {
    rotate(-90deg,c)
  }
  
  #move(dx: 18.45cm,dy: -0.7em,
  rotate(90deg, origin: (left+bottom))[
    #set align(left)
    #stack(
      dir:ltr,
      ..论文题目_书脊.clusters().map(
          c => r(c)
      )
    )
  ])
  #set align(bottom + right)
  #move(dx: -0.5cm,dy: 0em,
  rotate(90deg, origin: (right+bottom))[
    #set align(left)
    #box(width: 5em,
    stack(
      dir:ltr,
      ..作者名.clusters().map(
          c => r(c)
      ).intersperse(1fr),
    ))
  ])
]



//英文封面

pagebreak()
set text(top-edge: "ascender")
[
  #set page(margin: (top: 5.5cm, bottom:5cm, x: 3.6cm))
  //#place(rect( width: 100%,height: 100%,)) //显示页边距
  #set align(top + center)
  #[
    #v(5pt)
    #set par(spacing: 0.7em)
    #set text(20pt, font: 字体.黑体)
    #strong[#论文题目_英]
  ]

  #set align(bottom)
  #set text(字号.三号, font: 字体.宋体)
  #set par(spacing: 1.02em)
  
  #文章类型 submitted to
  
  *Tsinghua University*
  
  in partial fulfillment of the requirement
  
  for the degree of
  
  #text(font: 字体.黑体)[*#英文学位名*] 
  
  in
  
  #text(font: 字体.黑体)[*#专业_英*]
  
  \
  
  #text(font: 字体.黑体)[by]

  #text(font: 字体.黑体)[*#作者_英*]
  
  \
  
  #text(字号.小三)[
    #grid(
      columns: (12em,1em,20em),
      align: (right,left,left),
      [#文章类型 Supervisor],":  ",导师_英
    )
    
    #if 副导师_英 != none{
      grid(
        columns: (12em,1em,20em),
        align: (right,left,left),
        [Associate Supervisor],":  ",副导师_英
      )
    }
  ]
  #v(25pt)
  #text(font: 字体.黑体)[*#日期.display("[month repr:long], [year]")*]
  #v(4pt)
]

set page(margin:3cm)



// 学位论文指导小组、公开评阅人和答辩委员会名单

pagebreak()
[
  //#place(rect(width: 100%,height: 100%,)) //显示页边距
  #set align(top+center)
  #set text(字号.小四, font: 字体.宋体)
  #show strong: it => text(字号.四号, font: 字体.黑体, it.body)
  #v(26pt)
  #[#set text(字号.三号, font: 字体.黑体)
    学位论文指导小组、公开评阅人和答辩委员会名单
  ]
  #v(33pt)
  
  *指导小组名单*
  #v(-4pt)
  #grid(
    inset: (y: 2pt),
    columns: (20%, 20%, 60%), row-gutter: 0.6em, align: (center + horizon), ..指导小组名单
  )
  #v(16pt)

  *公开评阅人名单*
  #v(-4pt)
  #grid(
    inset: (y: 2pt),
    columns: (20%, 20%, 60%), row-gutter: 0.6em, align: (center + horizon), ..公开评阅人名单
  )
  #v(16pt)


  *答辩委员会名单*
  #v(-4pt)
  #grid(
    inset: (y: 2pt),
    columns: (20%, 20%, 20%, 40%), rows: auto, row-gutter: 0.6em, align: (center + horizon), ..答辩委员会名单
    )
]



// 关于学位论文使用授权的说明

pagebreak()
[
  #set align(left + top)
  //#show heading: set text(字号.二号, font: 字体.黑体)
  //#heading(numbering: none, outlined: false, [关于学位论文使用授权的说明])
  #[
    #set align(center)
    #v(39pt)
    #text(字号.二号, font: 字体.黑体)[关于学位论文使用授权的说明]
    #v(25pt)
  ]
  
  #set text(字号.四号)
  #set par(justify: true, leading: 1em, spacing: 14pt)
  
  本人完全了解清华大学有关保留、使用学位论文的规定，即：
  
  清华大学拥有在著作权法规定范围内学位论文的使用权，其中包括：（1）已获学位的研究生必须按学校规定提交学位论文，学校可以采用影印、缩印或其他复制手段保存研究生上交的学位论文；（2）为教学和科研目的，学校可以将公开的学位论文作为资料在图书馆、资料室等场所供校内师生阅读，或在校园网上供校内师生浏览部分内容；（3）根据《中华人民共和国学位条例暂行实施办法》及上级教育主管部门具体要求，向国家图书馆报送相应的学位论文。
  
  本人保证遵守上述规定。
  #v(23pt)
  #set text(字号.小四)
  #h(32pt) 作者签名：\_\_\_\_\_\_\_\_\_\_\_\_　　　　导师签名：\_\_\_\_\_\_\_\_\_\_\_\_
  #v(16pt)
  #h(32pt) 日　　期：\_\_\_\_\_\_\_\_\_\_\_\_　　　　日　　期：\_\_\_\_\_\_\_\_\_\_\_\_
]
  


// 中文摘要
  
  set page(numbering: "I")
  counter(page).update(1)
  set par(leading: 10pt, spacing: 10pt)
  
  heading(numbering: none, outlined: true, "摘　　要")
  
  others.摘要
  
  set par(first-line-indent: 0em)
  linebreak()
  text(font: 字体.黑体)[关键词：]
  关键词.join("；")




  // English abstract

  heading(numbering: none, outlined: true, "Abstract")

  set par(first-line-indent: (amount: 2em,all: true))

  
  others.摘要_英

  linebreak()
  linebreak()
  set par(first-line-indent: 0em)
  [*Keywords:* ]
  关键词_英.join("; ")


  
// 目录

show outline.entry.where(level: 1):it=>{
  set par(spacing: 15pt)
  set text(字号.小四, font: 字体.黑体)
  //it.prefix()
  let loc = it.element.location()
  let actual_loc=query(selector(<__footer__>).after(loc)).first().location()
  let chap = counter("chapter").at(actual_loc).last()
  if chap > 0 and it.element.numbering != none{
    chinesenumbering(chap,location: loc)+h(1em)
  }
  
  it.body()
  set text(font: 字体.宋体)
  box(width: 1fr, it.fill)
  it.page()
  parbreak();
}
show outline.entry.where(level:2): set block(above: 0.8em)
show outline.entry.where(level:3): set block(above: 0.8em)

outline(
  title: "目　　录",
  depth: 目录深度,
  indent: 1em,
)



// 图表清单

show outline.entry.where(level: 1):it=>{
  box({
    [
      #set text(字号.小四, font: 字体.宋体)
      #it.prefix()
      #it.body()
      #set text(font: 字体.宋体)
      #box(width: 1fr, it.fill)
      #it.page()
    ]
  })
} 


if 插图清单 {
   listoffigures(title: "插图清单", kind: image)
  // outline(
  //   title: "插图清单",
  //   target: figure.where(kind: image),
  // )

}


if 附表清单 {

  listoffigures(title: "附表清单", kind: table)
}


if 代码清单 {

  listoffigures(title: "代        码", kind: "code")
}



// 符号和缩略语说明

heading(numbering: none, outlined: true, "符号和缩略语说明")
show terms.item: it=>{
  grid(
    columns: (8em, auto),
    it.term,
    it.description,
  )
}

others.符号和缩略语

pagebreak(weak: false)
  

// 正文内容
  
set align(left + top)
set par(first-line-indent: (amount: 2em, all: true))
set text(字号.小四, font: 字体.宋体)
set page(numbering: "1")
counter(page).update(1)


doc




// 附录

appendix()
pagebreak()
others.附录

// 致谢

heading(numbering: none, outlined: true, "致　　谢")
others.致谢



// 声明

heading(numbering: none, outlined: true, "声　　明")
[
  本人郑重声明：所呈交的学位论文，是本人在导师指导下，独立进行研究工作所取得的成果。尽我所知，除文中已经注明引用的内容外，本学位论文的研究成果不包含任何他人享有著作权的内容。对本论文所涉及的研究工作做出贡献的其他个人和集体，均已在文中以明确方式标明。
  #v(3em)
  #set align(right)
  签　名：\_\_\_\_\_\_\_\_\_\_\_\_　日　期：\_\_\_\_\_\_\_\_\_\_\_\_
]



// 简历、成果

heading(numbering: none, outlined: true, "个人简历、在学期间完成的相关学术成果")
{
  set heading(outlined: false)
  show heading.where(level: 2): it=>{
    
    set align(center)
    set text(字号.四号, font:字体.黑体)
    v(24pt)
    it.body
    v(6pt)
  }
  show heading.where(level: 3): it=>{
    
    set par(first-line-indent: 0em)
    set align(left)
    set text(字号.小四, font:字体.黑体)
    it.body
  }
    others.简历和成果
}



// 指导教师评语

heading(numbering: none, outlined: true, "指导教师评语")
others.指导教师评语



// 答辩委员会决议书

heading(numbering: none, outlined: true, "答辩委员会决议书")
others.答辩委员会决议书

}
