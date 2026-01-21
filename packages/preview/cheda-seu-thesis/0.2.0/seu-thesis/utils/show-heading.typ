#import "fonts.typ": 字体, 字号
#import "packages.typ": show-cn-fakebold
#import "states.typ": *
#import "to-string.typ": to-string
#import "fake-par.typ": fake-par

#let show-heading(
  heading-top-margin: (0.2cm, 0cm, 0cm),
  heading-bottom-margin: (0cm, 0cm, 0cm),
  heading-indent: (0em, 0em, 0em),
  heading-align: (center, left, left),
  heading-text: (
    (font: 字体.黑体, size: 字号.三号, weight: "bold"),
    (font: 字体.黑体, size: 字号.四号, weight: "regular"),
    (font: 字体.宋体, size: 字号.小四, weight: "regular")
  ),
  always-new-page: false, // 每次一级标题都切换到新的页面，取值为 bool 或 function ，如果 function 则会以 function 作为分页时执行的操作
  auto-h-spacing: true, // 为 true 时，二字标题会变为 A #h(2em) B
  it
) = {
  set par(first-line-indent: 0em)

  // 将章节名转换为 string
  let chapter-name-string = to-string(it.body)

  // 用于显示的章节名：如果启用 auto-h-spacing 则处理
  let chapter-name-show = {
    if auto-h-spacing and it.numbering == none and type(chapter-name-string) == str and chapter-name-string.clusters().len() == 2 and chapter-name-string.find(regex("\p{sc=Hani}{2}")) != none {
      chapter-name-string.clusters().first()
      h(2em)
      chapter-name-string.clusters().last()
    } else {
      [#chapter-name-string]
    }
  }

  // 用于显示的章节号
  let chapter-numbering-show = {
    if type(it.numbering) == str {
      numbering(
        it.numbering, 
        ..counter(heading).get()
      )
      if it.level == 1 {
        numbering(
          it.numbering, 
          ..counter(heading).get()
        )
      }
    } else if type(it.numbering) == function {
        (it.numbering)(..counter(heading).get(), location: here())
    }
  }

  chapter-name-str-state.update(chapter-name-string)
  chapter-name-show-state.update(chapter-name-show)
  chapter-numbering-show-state.update(chapter-numbering-show)
  chapter-level-state.update(it.level)

  // 一级标题有单独的 states
  if it.level == 1{
    chapter-l1-name-str-state.update(chapter-name-string)
    chapter-l1-name-show-state.update(chapter-name-show)
    chapter-l1-numbering-show-state.update(chapter-numbering-show)
    counter(math.equation).update(0)
  }

  // 处理新页面换行
  if it.level == 1 and always-new-page != false {
    if type(always-new-page) == function {
      always-new-page()
    } else {
      pagebreak(weak: true)
    }
  }
  
  v(heading-top-margin.at(
    it.level - 1, 
    default: heading-top-margin.last()
  ))

  locate(loc => {
    // 用于显示的页码
    let chapter-page-show = {
      if type(page.numbering) == str {
        numbering(page.numbering, counter(page).at(loc).first())
      } else if type(page.numbering) == function {
        (page.numbering)(counter(page).at(loc).first())
      }
    }
    chapter-true-loc-state.update(loc)
    chapter-page-number-show-state.update(to-string(chapter-page-show))
    if it.level == 1 {
      chapter-l1-true-loc-state.update(loc)
      chapter-l1-page-number-show-state.update(to-string(chapter-page-show))
    }
  })

  {
    set align(heading-align.at(
      it.level - 1,
      default: heading-text.last()
    ))

    set text(..heading-text.at(
      it.level - 1,
      default: heading-text.last()
    ))

    h(heading-indent.at(
      it.level - 1,
      default: heading-text.last()
    ))

    [
      #if chapter-numbering-show != none {
        chapter-numbering-show
        h(0.2em)
      }
      #chapter-name-show 
      <__heading__>
    ]
  }

  // if it.level == 1 {
  //   set align(center)
  //   set text(..heading-text.at(0))

    

  //   // if thesistype == "Undergraduate" and it.body.text in ("摘要", "目录", "致谢", "ABSTRACT") {
  //   //   if it.body.text == "目录" {v(5pt)} else {v(1em)}
  //   // }
    

  //   // locate(loc => {
  //   //   let itpart = partstate.at(loc)
  //   //   equationcounter.update(0)
  //   //   if itpart == "正文" { 
  //   //     chaptercounter.step()
  //   //   } else if itpart == "附录" { 
  //   //     appendixcounter.step()
  //   //   }
  //   // })
    
  // } else {
  //   set text(..heading-text.at(
  //     it.level - 1,
  //     default: heading-text.at(2)
  //   ))
  //   it
  // }

  v(heading-bottom-margin.at(
    it.level - 1, 
    default: heading-bottom-margin.at(2)
  ))

  fake-par

  heading-l1-updating-name-str-state.update(chapter-name-string)

  // text()[#v(0em, weak: true)]
  // text()[#h(0em)]
}