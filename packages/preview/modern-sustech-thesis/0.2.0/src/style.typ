#import "@preview/hydra:0.6.2": hydra
#import "@preview/numbly:0.1.0": numbly
#import "@preview/equate:0.3.2": equate

#import "util.typ": *
#import "font.typ"

/// Default leading.
#let leading = 20pt - font.csort.s4

// Section title as header. {{{
#let header-with-chapter = text(
  size: font.csort.S5,
  context {
    set align(center)
    box(
      width: 100%,
      inset: 0.65em,
      stroke: (bottom: gray),
      hydra(
        1,
        skip-starting: false,
        display: (ctx, cand) => {
          if cand.numbering != none {
            numbering(cand.numbering, ..counter(heading).at(cand.location()))
            h(0.5em)
          }
          spreadl(3em, cand.body)
        },
      ),
    )
  },
)
// }}}

// Generic and begining. {{{

/// 论文大体样式，在开头施加于所有内容。
///
/// = 示例
/// ```example
/// #show: generic-style
/// // ...
/// ```
///
/// - conf (dictionary): 配置，大概不用动这个
/// - trans (dictionary): 翻译，大概不用动这个
/// - body (content): 要施加样式的内容
/// -> content
#let generic(
  conf: none,
  trans: none,
  body,
) = {
  let (
    lang,
    region,
    print-date,
    bibliography-style,
    description,
    print,
    degree,
    bachelor,
    binding-guide,
  ) = conf

  doc-class.update(degree)

  set document(
    title: trans.at(lang).title,
    author: trans.at(lang).candidate,
    keywords: trans.at(lang).keywords,
    date: print-date,
    description: description,
  )

  set page(
    paper: "a4",
    margin: if bachelor {
      if print {
        (
          top: 2.5cm,
          bottom: 2cm,
          inside: 3cm,
          outside: 2.5cm,
        )
      } else {
        (
          top: 2.5cm,
          bottom: 2cm,
          rest: 2.5cm,
        )
      }
    } else {
      3cm
    },
    ..(
      if not bachelor {
        (
          header-ascent: 0.8cm, // 3 - 2.2 = 0.8
          footer-descent: 0.8cm,
        )
      }
    ),
  )

  set page(
    background: context {
      let i = calc.rem(here().page(), 2)
      place(
        (right, left).at(i),
        dx: 0.5cm * (-1, 1).at(i),
        line(
          angle: 90deg,
          length: 100%,
          stroke: black.transparentize(80%) + 0.5pt,
        ),
      )
    },
  ) if print and bachelor and binding-guide

  set text(
    font: font.group.song,
    size: font.csort.s4,
    lang: lang,
    region: region,
  )

  // NOTE Assuming the font (Times New Roman) is OpenType
  // and implements proportional width correctly.
  // show smartquote: set text(features: ("pwid",))
  // which (my) Times New Roman does not.
  show smartquote: set text(font: "Times New Roman")

  set par(
    first-line-indent: (amount: 2em, all: true),
    leading: if bachelor {
      1em
    } else {
      leading
    },
  )

  set figure(
    numbering: figure-numbering-with-chapter.with(
      numbering: "1",
    ),
  )

  show figure: it => {
    set figure.caption(
      position: top,
    ) if it.kind == table

    // NOTE Automatic "cont." with caption a/o hline-d header is unachievable in Typst 0.14, requiring seperation by user.
    set block(breakable: false)

    it
  }

  show figure.caption: it => {
    set text(
      size: 11pt,
    )
    // NOTE `figure` itself covers block spacing, so no extra spacing setting.

    it
  }

  set table(
    stroke: none,
  )

  show table: it => {
    set text(
      size: 11pt,
    )
    set par(
      spacing: 3pt,
    )

    it
  }

  show heading: it => {
    set text(
      font: if it.level < 4 {
        font.group.hei
      } else {
        font.group.song
      },
      size: if it.level == 1 {
        font.csort.S3
      } else if it.level == 2 {
        font.csort.S4
      } else if it.level == 3 and not bachelor {
        13pt
      } else {
        font.csort.s4
      },
      weight: if bachelor {
        "bold"
      } else if it.level < 4 {
        "bold"
      } else {
        "regular"
      },
    )

    set block(
      above: if it.level >= 2 { 24pt } else { 12pt },
      below: if it.level >= 1 { 18pt } else { 6pt },
    )

    set heading(supplement: none) if not bachelor and it.level == 1

    it
  }

  show heading.where(level: 1): it => {
    counter(math.equation).update(0)

    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)

    set align(center) if not bachelor
    show regex(`^\p{Han}{2}$`.text): it => if bachelor {
      it
    } else {
      spreadl(3em, it)
    }

    // if not bachelor {
    pagebreak(weak: true)
    // }

    it
  }

  show title: it => {
    set text(
      font: font.group.hei,
      size: font.csort.S2,
    )

    set par(
      leading: leading * 1.25,
    )

    it
  }

  show math.equation: set text(
    font: font.group.song-math,
  )

  show math.equation.where(block: false): set math.frac(style: "horizontal")

  show: equate

  set math.equation(
    numbering: equation-numbering-with-chapter,
  )

  // HACK Fixing equations' contextual numbering not following original heading count.
  // Source: equate 0.3.2, edited.
  show ref: it => {
    if it.element == none { return it }
    if it.element.func() != figure { return it }
    if it.element.kind != math.equation { return it }
    if it.element.body == none { return it }
    if it.element.body.func() != metadata { return it }

    let sub-numbering-state = state("equate/sub-numbering", false)

    let nums = if sub-numbering-state.at(it.element.location()) {
      it.element.body.value
    } else {
      (it.element.body.value.first() + it.element.body.value.slice(1).sum(default: 1) - 1,)
    }

    let num = numbering(
      if type(it.element.numbering) == function {
        it.element.numbering.with(loc: it.element.location())
      } else { it.element.numbering },
      ..nums,
    )

    let supplement = if it.supplement == auto {
      it.element.supplement
    } else if type(it.supplement) == function {
      (it.supplement)(it.element)
    } else {
      it.supplement
    }

    link(it.element.location(), if supplement not in ([], none) [#supplement~#num] else [#num])
  }

  set bibliography(
    title: none,
    style: bibliography-style,
  )

  // HACK Fixing supplement.
  // Source: <https://forum.typst.app/t/how-to-cite-with-a-page-number-in-gb-t-7714-2015-style/1501/4>, edited.
  show cite.where(style: auto): it => {
    if it.supplement != none {
      let (key, ..args) = it.fields()
      cite(it.key, ..args, style: "./gb-t-7714-2015-numeric.cite.csl")
    } else {
      it
    }
  }

  // HACK Fixing zh-en mixed bibliography.
  // Source: modern-nju-thesis 0.4.0, edited.
  show bibliography: it => {
    align(
      center,
      heading(
        level: 1,
        if lang == "zh" [参考文献] else [REFERENCES],
      ),
    )


    // Please fill in the remaining mapping table here
    let mapping = (
      //"等": "et al",
      "卷": "Vol.",
      "册": "Bk.",
      // "译": ", tran",
      // "等译": "et al. tran",
      // 注: 请见下方译者数量判断部分。
    )

    let allow-comma-in-name = false

    let extra-comma-before-et-al-trans = false

    let to-string(content) = {
      if content.has("text") {
        content.text
      } else if content.has("children") {
        content.children.map(to-string).join("")
      } else if content.has("child") {
        to-string(content.child)
      } else if content.has("body") {
        to-string(content.body)
      } else if content == [ ] {
        " "
      }
    }

    show grid.cell.where(x: 1): it => {
      // 后续的操作是对 string 进行的。
      let ittext = to-string(it)
      // 判断是否为中文文献：去除特定词组后，仍有至少两个连续汉字。
      let pureittext = ittext.replace(regex("[等卷册和版本章期页篇译间者(不详)]"), "")
      if pureittext.find(regex("\p{sc=Hani}{2,}")) != none {
        ittext
      } else {
        // 若不是中文文献，进行替换
        // 第xxx卷、第xxx册的情况：变为 Vol. XXX 或 Bk. XXX。
        let reptext = ittext
        reptext = reptext.replace(
          regex("(第\s?)?\d+\s?[卷册]"),
          itt => {
            if itt.text.contains("卷") {
              "Vol. "
            } else {
              "Bk. "
            }
            itt.text.find(regex("\d+"))
          },
        )

        // 第xxx版/第xxx本的情况：变为 1st ed 格式。
        reptext = reptext.replace(
          regex("(第\s?)?\d+\s?[版本]"),
          itt => {
            let num = itt.text.find(regex("\d+"))
            num
            if num.clusters().len() == 2 and num.clusters().first() == "1" {
              "th"
            } else {
              (
                "1": "st",
                "2": "nd",
                "3": "rd",
              ).at(num.clusters().last(), default: "th")
            }
            " ed"
          },
        )

        // 译者数量判断：单数时需要用 trans，复数时需要用 tran 。
        /*
        注:
            1. 目前判断译者数量的方法非常草率：有逗号就是多个作者。但是在部分 GB/T 7714-2015 方言中，姓名中可以含有逗号。如果使用的 CSL 是姓名中含有逗号的版本，请将 bilingual-bibliography 的 allow-comma-in-name 参数设为 true。
            2. 在 GB/T 7714-2015 原文中有 `等译`（P15 10.1.3 小节 示例 1-[1] 等），但未给出相应的英文缩写翻译。CSL 社区库内的 GB/T 7714-2015 会使用 `等, 译` 和 `et al., tran` 的写法。为使中英文与标准原文写法一致，本小工具会译作 `et al. tran`。若需要添加逗号，请将 bilingual-bibliography 的 extra-comma-before-et-al-trans 参数设为 true。
            3. GB/T 7714-2015 P8 7.2 小节规定：“译”前需加逗号。因此单个作者的情形，“译” 会被替换为 ", trans"。与“等”并用时的情况请见上一条注。
            如果工作不正常，可以考虑换为简单关键词替换，即注释这段情况，取消 13 行 mapping 内 `译` 条目的注释。
        */
        reptext = reptext.replace(regex("\].+?译"), itt => {
          // 我想让上面这一行匹配变成非贪婪的，但加问号后没啥效果？
          let comma-in-itt = itt.text.replace(regex(",?\s?译"), "").matches(",")
          if (
            type(comma-in-itt) == array
              and comma-in-itt.len()
                >= (
                  if allow-comma-in-name { 2 } else { 1 }
                )
          ) {
            if extra-comma-before-et-al-trans {
              itt.text.replace(regex(",?\s?译"), ", tran")
            } else {
              itt.text.replace(regex(",?\s?译"), " tran")
            }
          } else {
            itt.text.replace(regex(",?\s?译"), ", trans")
          }
        })

        // `等` 特殊处理：`等`后方接内容也需要译作 `et al.`，如 `等译` 需要翻译为 `et al. trans`
        reptext = reptext.replace(
          regex("等."),
          itt => {
            "et al."
            // 如果原文就是 `等.`，则仅需简单替换，不需要额外处理
            // 如果原文 `等` 后没有跟随英文标点，则需要补充一个空格
            if not (
              itt.text.last() in (".", ",", ";", ":", "[", "]", "/", "\\", "<", ">", "?", "(", ")", " ", "\"", "'")
            ) {
              " "
            }
            // 原文有英文句号时不需要重复句号，否则需要将匹配到的最后一个字符吐回来
            if not itt.text.last() == "." {
              itt.text.last()
            }
          },
        )

        // 其他情况：直接替换
        reptext = reptext.replace(
          regex("\p{sc=Hani}+"),
          itt => {
            mapping.at(itt.text, default: itt.text)
            // 注意：若替换功能工作良好，应该不会出现 `default` 情形
          },
        )
        reptext
      }
    }

    it
  }

  body
}
// }}}

// Begining of paginated content. {{{

/// 论文前言有页码的样式，在前言有页码时施加于所有内容。本科论文中无效。
///
/// = 示例
/// ```example
/// // ...
/// #show: front-matter-paginated-style
/// #abstract[
///   #include "abstract-zh.typ"
/// ]
/// // ...
/// ```
///
/// - conf (dictionary): 配置，大概不用动这个
/// - trans (dictionary): 翻译，大概不用动这个
/// - body (content): 要施加样式的内容
/// -> content
#let front-matter-paginated(
  conf: none,
  body,
) = {
  let (bachelor,) = conf

  if bachelor {
    return body
  }

  set page(
    numbering: "I",
  )

  set par(
    justify: true,
  )

  counter(page).update(1)

  body
}
// }}}

// Body matter. {{{

/// 论文正文的样式，在正文前施加于所有内容。
///
/// = 示例
/// ```example
/// // ...
/// #show: body-matter-style
/// #include "chapter-1.typ"
/// // ...
/// ```
///
/// - conf (dictionary): 配置，大概不用动这个
/// - trans (dictionary): 翻译，大概不用动这个
/// - body (content): 要施加样式的内容
/// -> content
#let body-matter(
  conf: none,
  trans: none,
  body,
) = {
  let (
    print,
    bachelor,
  ) = conf

  if print and not bachelor {
    pagebreak(to: "even")
  }

  set page(
    numbering: "1",
    header: if bachelor {
      none
    } else {
      header-with-chapter
    },
  )

  set heading(
    numbering: if bachelor {
      // NOTE Choosing the simplest out of the four.
      "1."
    } else {
      numbly(
        n => context if text.lang == "zh" [第#n;章] else [CHAPTER #n],
        "{1}.{2}",
        "{1}.{2}.{3}",
        (..ns) => context if text.lang == "zh" [
          // #h(-0.6em, weak: true)（#ns.at(3)）#h(-0.6em)
          （#ns.at(3)）#h(-0.3em)
        ] else [
          (#ns.at(3))
        ],
        "{5:①}",
        "{6:a.}",
      )
    },
  )

  counter(page).update(1)
  counter(heading).update(0)

  body
}
// }}}

// Appendix. {{{

/// 论文附录的样式，在附录前施加于所有内容。
///
/// = 示例
/// ```example
/// // ...
/// #show: appendix-style
/// #include "appendix.typ"
/// // ...
/// ```
///
/// - conf (dictionary): 配置，大概不用动这个
/// - body (content): 要施加样式的内容
/// -> content
#let appendix(
  conf: none,
  body,
) = {
  let (bachelor,) = conf

  doc-state.update("appendix")

  counter(heading).update(0)

  set heading(
    numbering: if bachelor {
      // Drop first number since they want appendix to be one chapter.
      (..ns) => numbering("A1.1", ..ns.pos().slice(1))
    } else {
      "A.1."
    },
    supplement: context if text.lang == "zh" [附录] else [APPENDIX],
  )

  // Make it truly none, hence no gap between a non-none numbering that returns none.
  show heading.where(level: 1): set heading(
    numbering: none,
  ) if bachelor

  show heading.where(level: 1): set align(center)

  let offset = if bachelor { 1 } else { 0 }

  show heading.where(level: 1 + offset): set heading(
    numbering: (..ns) => {
      let ns = ns.pos()
      if bachelor and ns.len() == 1 {
        return none
      }
      let num = numbering("A", ns.at(offset))
      context if text.lang == "zh" [附录#num] else [APPENDIX #num]
    },
    supplement: none,
  )

  body
}
// }}}

// Attachments (résumé, list of works). {{{

/// 论文附录后的样式，在附录后施加于所有内容。
///
/// = 示例
/// ```example
/// // ...
/// #show: attachment-style
/// #include "acknowledgement.typ"
/// // ...
/// ```
///
/// - body (content): 要施加样式的内容
/// -> content
#let post-appendix(
  body,
) = {
  set heading(
    numbering: none,
    supplement: none,
  )

  show heading.where(level: 2): set align(center)

  // Override appendix show with inner show.
  show heading.where(level: 1): set heading(
    numbering: none,
    supplement: auto,
  )
  show heading.where(level: 2): set heading(
    numbering: none,
    supplement: auto,
  )

  body
}
// }}}

