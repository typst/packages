#import "@preview/conjak:0.2.3": cjk-date-format
#import "@preview/numbly:0.1.0": numbly
#import "@preview/subpar:0.2.2"

#import "util.typ": *
#import "font.typ"

// Unnumbered heading for conclusion. {{{
#let heading-conclusion(
  conf: none,
) = {
  set heading(
    numbering: none,
  )
  if conf.lang == "zh" [
    = 结论
  ] else [
    = CONCLUSION
  ]
}
// }}}

// Recommended sizes for figure bodies. {{{

/// 研究生、博士论文中建议使用的图片尺寸，有小、中、大三种，即 `small`、`medium`、`large`。
#let fig-sizes = (
  small: (
    width: 20cm / 3,
    height: 5cm,
  ),
  medium: (
    width: 9cm,
    height: 6.75cm,
  ),
  large: (
    width: 13.5cm,
    height: 9cm,
  ),
)
// }}}

// Subfigure wrapper. {{{

/// 实现子图的帮手。
///
/// Typst 的 `figure` 还不能做子图，得用这个。
///
/// = 用法
/// 按照 subpar:0.2.2 的 `grid` 使用，减去参数 `numbering`、`numbering-sub-ref`、`grid-styles`。
///
/// 一般只用到 `columns`、`caption`、`label`。
/// - `columns` 与 `table` 的 `columns` 一样，可以是一个数字（有几列）或长度的数组（每一列有多宽）
/// - `caption` 是总图注
/// - `label` 是总图标签
///
/// = 示例
/// ```example
/// #figures(
///   caption: [母图],
///   columns: 2,
///   figure(/* ... */), <fg:child-1>,
///   figure(/* ... */),
///   label: <fg:parent>
/// )
/// ```
#let figures = subpar.grid.with(
  numbering: figure-numbering-with-chapter.with(
    numbering: "1",
  ),
  numbering-sub-ref: figure-numbering-with-chapter.with(
    numbering: "1 (a)",
  ),
  grid-styles: it => {
    set std.grid(
      gutter: 1em,
      align: bottom,
    )
    show figure.caption: set text(
      size: 11pt,
    )

    it
  },
)
// }}}

// Abstract, {{{

/// 生成摘要，包括对应语言的标题和关键词列表。
///
/// = 用法
/// 直接填入摘要内容。若摘要的语言不是论文语言，则额外填入语言，甚至地区。
///
/// - lang (auto, str): 语言，默认为论文的语言
/// - region (auto, str): 地区，默认为 `lang` 最常对应的地区，或若 `lang` 是论文语言，默认为论文的地区
/// - conf (dictionary): 配置；大概不用动这个
/// - trans (dictionary): 翻译；大概不用动这个
/// - body (content): 摘要内容，不含标题或关键词
/// -> content
#let abstract(
  lang: auto,
  region: auto,
  conf: none,
  trans: none,
  body,
) = {
  let lang = firstconcrete(lang, conf.lang)
  let (region,) = args-lang(
    lang,
    firstconcrete(
      region,
      default: if lang == conf.lang { conf.region } else { auto },
    ),
  ).named()
  let (
    print,
    bachelor,
  ) = conf

  set text(
    lang: lang,
    region: region,
  )

  set text(
    size: font.csort.S4,
  ) if bachelor

  set par(
    first-line-indent: 2em,
  ) if bachelor

  // Override heading show rule that sets Latin with Hei.
  let phfunc(body) = text(
    font: font.group.hei-latin-song,
    if bachelor {
      text(
        size: font.csort.S3,
        weight: "bold",
        [[#body] ],
      )
    } else {
      body
    },
  )

  let hfunc(body) = if bachelor {
    // Still using heading so outline generates properly.
    // The template ignores it however, so we instead exclude it at outline (toc)
    show heading: it => phfunc(it.body)

    [
      // NOTE The spec and template do use half-width for zh...
      = #body
    ]
  } else [
    = #body
  ]

  let hstr = if lang == "zh" [摘要] else [ABSTRACT]

  hfunc(hstr)

  body

  set par(
    first-line-indent: 0cm,
  )

  if bachelor {
    v(1fr)
  } else {
    linebreak()
  }

  phfunc(
    if bachelor {
      if lang == "zh" [关键词] else [Keywords]
    } else {
      if lang == "zh" [关键词：] else [*Keywords: *]
    },
  )
  trans.at(lang).keywords.join(if lang == "zh" [；] else [; ])

  if bachelor {
    v(1fr)
  }

  pagebreak(
    weak: true,
  )
}
// }}}

// Cover. {{{
#let cover(
  conf: none,
  trans: none,
) = {
  let (
    lang,
    degree,
    bachelor,
    clc,
    udc,
    thesis-number,
    confidentiality,
    print-date,
    print,
  ) = conf
  let (
    zh,
    en,
  ) = trans
  let lt = trans.at(lang)

  let class = {
    set align(center)

    if bachelor {
      set grid(
        align: (x, _) => if x == 0 { right } else { left },
      )

      let clctext = if lang == "zh" [分类号] else [CLC]
      let notext = if lang == "zh" [编号] else [Number]
      let cfdentry = if lang == "zh" {
        (
          spreadl(3em)[密级],
          confidentiality,
        )
      } else {
        let eb = box(stroke: black, width: 8pt, height: 8pt)
        let cb = box(stroke: black, width: 8pt, height: 8pt, fill: black)
        (
          [Available for reference],
          if confidentiality == "公开" [#cb Yes #eb No] else [#eb Yes #cb No],
        )
      }

      stack(
        dir: ltr,
        spacing: 1fr,
        grid(
          columns: 2,
          inset: (x: 0.3em, y: 0.65em),
          clctext, clc,
          context spreads(measure(clctext).width, "UDC"), udc,
        ),
        grid(
          columns: 2,
          inset: (x: 0.3em, y: 0.65em),
          spreadl(3em, notext), thesis-number,
          ..cfdentry,
        ),
      )

      image(
        "assets/" + lang + ".sustech-logo.svg",
        alt: if lang == "zh" {
          "南方科技大学的标志"
        } else {
          "A logo of the Southern University of Science and Technology"
        },
      )
    } else {
      text(
        size: font.csort.s1,
        weight: "bold",
        zh.cover.at(degree) + zh.thesis,
      )
    }
  }

  let title = if bachelor {
    align(
      center,
      text(
        size: font.csort.s0,
        weight: "bold",
        if lang == "zh" [本科生毕业设计（论文）] else [Undergraduate Thesis],
      ),
    )
  } else {
    set align(center)

    set text(
      font: font.group.hei,
      size: font.csort.S2,
      weight: "bold",
    )
    set par(
      // HACK Approximation.
      leading: font.csort.S2 * 0.75,
    )

    zh.display-title

    parbreak()

    set text(
      size: font.csort.s2,
    )
    set par(
      // HACK Approximation.
      leading: font.csort.s2 * 0.75,
    )

    en.display-title
  }

  let credits = {
    let entries = if bachelor {
      (
        (
          lt.cover.title,
          {
            // Mixed alignment makes it a par.
            set par(
              first-line-indent: 0cm,
            )
            lt.display-title
            if lt.display-subtitle != none {
              align(right)[------#lt.display-subtitle]
            }
          },
        ),
        (
          lt.cover.name,
          spreadl(3em, lt.candidate),
        ),
        (
          lt.cover.student-number,
          conf.student-number,
        ),
        (
          lt.cover.department,
          lt.department,
        ),
        (
          lt.cover.program,
          lt.discipline,
        ),
        (
          lt.cover.advisor,
          lt.supervisor,
        ),
      )
        .map(p => (
          spreadl(4em, p.at(0)) + if lang == "zh" [：] else [: ],
          p.at(1),
        ))
        .flatten()
    } else {
      (
        spreadl(5em)[研究生] + [：],
        trans.zh.candidate,
        spreadl(5em)[指导教师] + [：],
        trans.zh.supervisor,
        ..(
          if trans.zh.associate-supervisor.len() > 0 {
            (spreadl(5em)[副指导教师] + [：], trans.zh.associate-supervisor)
          }
        ),
      )
    }

    set text(
      size: if bachelor {
        font.csort.S3
      } else {
        font.csort.s2
      },
      weight: if bachelor {
        "bold"
      } else {
        "regular"
      },
    )
    set align(center)
    set grid(
      align: (x, _) => if x == 0 {
        right
      } else {
        // if bachelor {
        //   center
        // } else {
        left
        // }
      },
    )

    grid(
      columns: if bachelor {
        (1fr, 2fr)
      } else {
        (1fr, 1fr)
      },
      inset: (x: 0.3em, y: 0.65em),
      ..entries
    )
  }

  let place-n-date = if bachelor {
    align(
      center,
      text(
        size: font.csort.S3,
        conf.print-date.display(
          if lang == "zh" {
            "[year]年[month]月[day]日"
          } else {
            "[month repr:long] [day]" + ord-en(conf.print-date.day()) + ", [year]"
          },
        ),
      ),
    )
  } else {
    set text(
      size: font.csort.s2,
    )
    set align(center)

    trans.zh.institute
    linebreak()
    cjk-date-format(print-date)
  }

  stack(
    dir: ttb,
    spacing: 1fr,
    class,
    title,
    credits,
    place-n-date,
  )

  if print and not bachelor {
    pagebreak(to: "odd")
  }
}
// }}}

// Title page. {{{

/// 生成题名页。
///
/// = 用法
/// 直接调用。若题名页的语言不是论文语言，则额外填入语言，甚至地区。
///
/// - lang (auto, str): 语言，默认为论文的语言
/// - region (auto, str): 地区，默认为 `lang` 最常对应的地区，或若 `lang` 是论文语言，默认为论文的地区
/// - conf (dictionary): 配置；大概不用动这个
/// - trans (dictionary): 翻译；大概不用动这个
/// -> content
#let title-page(
  lang: auto,
  region: auto,
  conf: none,
  trans: none,
) = {
  let lang = firstconcrete(lang, conf.lang)
  let (region,) = args-lang(
    lang,
    firstconcrete(
      region,
      default: if lang == conf.lang { conf.region } else { auto },
    ),
  ).named()
  let (
    degree,
    bachelor,
    defence-date,
    clc,
    udc,
    cuc,
    confidentiality,
    print,
    professional,
  ) = conf
  let lt = trans.at(lang)

  set text(
    lang: lang,
    region: region,
  )

  if bachelor {
    // Bachelor's {{{
    let title = {
      set text(
        font: font.group.hei-latin-song,
      )

      align(
        center,
        text(
          size: font.csort.S2,
          lt.display-title,
        ),
      )

      if lt.display-subtitle != none {
        parbreak()
        align(
          right,
          text(
            size: font.csort.s2,
            [------#lt.display-subtitle],
          ),
        )
      }
    }

    let participants = {
      set align(center)

      spreadl(
        3em,
        text(
          size: font.csort.S4,
          lt.candidate,
        ),
      )
      parbreak()
      text(
        font: font.group.kai,
        size: font.csort.s4,
        if lang == "zh" [
          （#lt.department，指导教师：#lt.supervisor）
        ] else [
          (#lt.department, Supervisor: #lt.supervisor)
        ],
      )
    }

    let dfunc = if print and not bachelor {
      stack.with(
        dir: ttb,
        spacing: 1fr,
      )
    } else {
      (..args) => {
        block(
          width: 100%,
          args.pos().join(),
        )
        v(1fr)
      }
    }

    dfunc(
      title,
      participants,
    )

    // }}}
  } else {
    if lang == "zh" {
      // Master's & doctor's zh {{{
      let classifications = {
        set grid(
          align: (x, _) => if x == 0 { right } else { left },
        )

        stack(
          dir: ltr,
          spacing: 1fr,
          grid(
            columns: 2,
            inset: (x: 0.3em, y: 0.65em),
            [国内图书分类号：], clc,
            [国际图书分类号：], udc,
          ),
          grid(
            columns: 2,
            inset: (x: 0.3em, y: 0.65em),
            [学校代码：], cuc,
            [密级：], confidentiality,
          ),
        )
      }

      let discipline-n-title = {
        set align(center)

        text(
          font: font.group.song,
          size: font.csort.s2,
          weight: "bold",
          if professional {
            lt.domain
          } else {
            lt.discipline
          }
            + lt.at(degree)
            + if professional { "专业" }
            + lt.thesis,
        )
        parbreak()
        set text(
          font: font.group.hei,
          size: font.csort.S2,
          weight: "bold",
        )
        lt.title
        if lt.display-subtitle != none {
          parbreak()
          lt.display-subtitle
        }
      }

      let participants = {
        set align(center)
        set text(
          size: font.csort.S4,
        )
        set grid(
          align: (x, _) => if x == 0 { right } else { left },
        )

        show grid.cell.where(x: 0): set text(
          font: font.group.hei,
        )

        grid(
          columns: (1fr, 1fr),
          inset: (x: 0.3em, y: 0.65em),
          ..(
            [学位申请人],
            lt.candidate,
            [指导教师],
            lt.supervisor,
            ..(
              if lt.associate-supervisor != none {
                ([副指导教师], lt.associate-supervisor)
              }
            ),
            ..(
              if professional {
                ([专业类别], lt.domain)
              } else {
                ([学科名称], lt.discipline)
              }
            ),
            [答辩日期],
            defence-date.display("[year]年[month]月"),
            [培养单位],
            lt.department,
            [学位授予单位],
            lt.institute,
          )
            .chunks(2, exact: true)
            .map(p => (spreadl(6em, p.at(0)) + [：], p.at(1)))
            .flatten(),
        )
      }

      stack(
        dir: ttb,
        spacing: 1fr,
        classifications,
        discipline-n-title,
        participants,
      )
      // }}}
    } else {
      // Master's & doctor's en {{{
      let title = {
        set text(
          size: font.csort.S2,
          weight: "bold",
        )
        set align(center)

        lt.display-title
        if lt.display-subtitle != none {
          parbreak()
          lt.display-subtitle
        }
      }

      let institute-n-degree = {
        let degree-text = lt.at(degree)
        degree-text = upper(degree-text.at(0)) + degree-text.slice(1)

        set align(center)
        set text(
          size: font.csort.s3,
        )

        [
          A dissertation submitted to \
          #lt.institute \
          in partial fulfillment of the requirement \
          for the #(if professional [professional]) degree of \
          #degree-text of #lt.domain \
          #if not professional [
            in \
            #lt.discipline
          ]
        ]
      }

      let participants = {
        set align(center)
        set text(
          size: font.csort.s3,
        )

        [
          by \
          #lt.candidate

          Supervisor: #lt.supervisor
          #if lt.associate-supervisor != none [
            \
            Associate supervisor: #lt.associate-supervisor
          ]
        ]
      }

      let date = {
        set align(center)
        set text(
          size: font.csort.s3,
        )

        defence-date.display("[month repr:long] [year]")
      }

      stack(
        dir: ttb,
        spacing: 1fr,
        title,
        institute-n-degree,
        participants,
        date,
      )
      // }}}
    }
  }

  if print and not bachelor {
    pagebreak(to: "odd")
  }
}
// }}}

// List of reviewers and committee members (Chinese). {{{
#let reviewers-n-committee(
  conf: none,
  trans: none,
) = {
  let (
    reviewers,
    committee,
    print,
    bachelor,
  ) = conf

  let committee = committee.map(i => if type(i) == array {
    (position: i.at(0), name: i.at(1), title: i.at(2), institute: i.at(3))
  } else { i })

  let chair = committee.filter(i => i.position == "主席").map(i => (i.name, i.title, i.institute))

  let members = committee.filter(i => i.position == "委员").map(i => (i.name, i.title, i.institute))

  let secretary = committee.filter(i => i.position == "秘书").map(i => (i.name, i.title, i.institute))

  set align(center)

  set par(
    leading: .65em,
    justify: false,
  )

  set heading(
    outlined: false,
  )

  set table(
    stroke: none,
  )

  [
    = 学位论文公开评阅人和答辩委员会名单

    == 公开评阅人名单
    #if reviewers.len() == 0 [
      无（全隐名评阅）
    ] else {
      table(
        columns: (1fr, 1fr, 3fr),
        ..reviewers
          .map(i => if type(i) == dictionary {
            (i.name, i.title, i.institute)
          } else { i })
          .flatten(),
      )
    }

    == 答辩委员会名单
    #table(
      columns: (1fr, 1fr, 2fr, 2fr),
      ..(
        if chair.len() > 0 {
          ("主席", ..chair.intersperse(none))
        },
      ).flatten(),
      ..(
        if members.len() > 0 {
          ("委员", ..members.intersperse(none))
        },
      ).flatten(),
      ..(
        if secretary.len() > 0 {
          ("秘书", ..secretary.intersperse(none))
        },
      ).flatten(),
    )
  ]

  if print and not bachelor {
    pagebreak(to: "odd")
  }
}
// }}}

// Declarations of originality and authorization. {{{
#let declarations(
  conf: none,
  trans: none,
) = {
  let (
    lang,
    publication-delay,
    print,
    bachelor,
  ) = conf

  let author = if lang == "zh" [作者] else [Author]

  let supervisor = if lang == "zh" [指导教师] else [Supervisor]

  let signature(
    of: none,
  ) = {
    let stext = {
      if lang == "zh" {
        spreadl(3em)[#of;签名] + [：]
      } else {
        [Signature#firstof(of, ts: i => [ of #i]): ]
      }
      if bachelor {
        h(6em)
      }
    }

    let ubox = box.with(
      stroke: (bottom: gray),
      outset: (bottom: 2pt),
    )

    let dtext = {
      if lang == "zh" {
        if bachelor [
          #ubox(width: 4em)年#ubox(width: 2em)月#ubox(width: 2em)日
        ] else {
          spreadl(3em)[日期] + [：]
        }
      } else [Date: ]
      if bachelor and lang != "zh" {
        h(6em)
      }
    }

    if bachelor {
      grid(
        columns: 1fr,
        rows: 1.5cm,
        align: right + horizon,
        stext,
        dtext,
      )
    } else {
      grid(
        columns: (2fr, 1fr),
        rows: 2cm,
        align: left + horizon,
        stext, dtext,
      )
    }
  }

  show heading: set align(center)
  set heading(
    outlined: false,
  )

  set enum(
    full: true,
    numbering: numbly(
      "{1}.",
      if lang == "zh" { (..ns) => [（#ns.at(1)）#h(-0.5em)] } else { "({2})" },
    ),
  )

  if bachelor {
    set text(
      size: font.csort.S4,
    )
    if lang == "zh" [
      = #text(font.csort.S2)[诚信承诺]
      + 本人郑重承诺所呈交的毕业设计（论文），是在导师的指导下，独立进行研究工作所取得的成果，所有数据、图片资料均真实可靠。
      + 除文中已经注明引用的内容外，本论文不包含任何其他人或集体已经发表或撰写过的作品或成果。对本论文的研究作出重要贡献的个人和集体，均已在文中以明确的方式标明。
      + 本人承诺在毕业论文（设计）选题和研究内容过程中没有抄袭他人研究成果和伪造相关数据等行为。
      + 在毕业论文（设计）中对侵犯任何方面知识产权的行为，由本人承担相应的法律责任。
    ] else [
      = #text(font: font.group.song, size: font.csort.S2)[COMMITMENT OF HONESTY]
      + I solemnly promise that the paper presented comes from my independent research work under my supervisor's supervision. All statistics and images are real and reliable.
      + Except for the annotated reference, the paper contents no other published work or achievement by person or group. All people making important contributions to the study of the paper have been indicated clearly in the paper.
      + I promise that I did not plagiarize other people's research achievement or forge related data in the process of designing topic and research content.
      + If there is violation of any intellectual property right, I will take legal responsibility myself.
    ]

    v(1fr)
    signature(of: author)
  } else {
    let delay-boxes = {
      //HACK 9pt only for s4 font size
      let eb = box(stroke: black, width: 9pt, height: 9pt)
      let cb = box(stroke: black, width: 9pt, height: 9pt, fill: black)
      let bnow = eb
      let blater = bnow
      let delay-text = box(stroke: (bottom: gray), outset: (bottom: 1pt), width: 1.5em)
      if type(publication-delay) == int {
        if publication-delay == 0 { bnow = cb } else {
          blater = cb
          delay-text = box(stroke: (bottom: gray), outset: (bottom: 1pt), width: 1.5em, height: 9pt, align(
            center,
            str(publication-delay),
          ))
        }
      }
      let now = if lang == "zh" [当年] else [upon submission]
      let later = if lang == "zh" [年以后] else [ months after submission]

      [#bnow #now/ #blater #delay-text;#later]
    }

    [
      = #trans.at(lang).declarations.title

      == #trans.at(lang).declarations.title-originality
      #if lang == "zh" [
        本人郑重声明：所提交的学位论文是本人在导师指导下独立进行研究工作所取得的成果。除了特别加以标注和致谢的内容外，论文中不包含他人已发表或撰写过的研究成果。对本人的研究做出重要贡献的个人和集体，均已在文中作了明确的说明。本声明的法律结果由本人承担。
      ] else [
        I hereby declare that this thesis is my own original work under the guidance of my supervisor.
        It does not contain any research results that others have published or written.
        All sources I quoted in the thesis are indicated in references or have been indicated or acknowledged.
        I shall bear the legal liabilities of the above statement.
      ]

      #signature(of: author)

      == #trans.at(lang).declarations.title-authorization
      #if lang == "zh" [
        本人完全了解南方科技大学有关收集、保留、使用学位论文的规定，即：
        + 按学校规定提交学位论文的电子版本。
        + 学校有权保留并向国家有关部门或机构送交学位论文的电子版，允许论文被查阅。
        + 在以教学与科研服务为目的前提下，学校可以将学位论文的全部或部分内容存储在有关数据库提供检索，并可采用数字化、云存储或其他存储手段保存本学位论文。
          + 在本论文提交当年，同意在校园网内提供查询及前十六页浏览服务。
          + 在本论文提交 #delay-boxes;，同意向全社会公开论文全文的在线浏览和下载。
        + 保密的学位论文在解密后适用本授权书。
      ] else [
        I fully understand the regulations regarding the collection, retention, and use of the thesis of the Southern University of Science and Technology.

        + Submit the electronic version of the thesis as required by the University.
        + The University has the right to retain and send the electronic version to other institutions that allow the thesis to be read by the public.
        + The University may save all or part of the thesis in certain databases for retrieval and may save it with digital, cloud storage, or other methods for teaching and scientific re-search.
          I agree that the full text of the thesis can be viewed online or downloaded within the campus network.
          + I agree that once submitted, the thesis can be retrieved online and the first 16 pages can be viewed within the campus network.
          + I agree that #delay-boxes, the full text of the thesis can be viewed and downloaded by the public.
        + This authorization applies to the decrypted confidential thesis.
      ]

      #signature(of: author)
      #signature(of: supervisor)
    ]
  }

  pagebreak(
    weak: true,
    ..(
      if print and not bachelor {
        (to: "odd")
      }
    ),
  )
}
// }}}

// Outline. {{{
#let toc(
  conf: none,
) = {
  let (
    lang,
    bachelor,
  ) = conf

  set text(
    size: font.csort.S4,
  ) if bachelor

  // HACK show heading: set text(size: ...) does not seem to work.
  // It is fine since we do not outline the outline itself.
  let ohfunc(body) = if bachelor {
    text(
      size: font.csort.s2,
      body,
    )
  } else {
    body
  }

  set outline(
    indent: if bachelor {
      0cm
    } else {
      1em
    },
    depth: if bachelor {
      2
    } else {
      3
    },
    title: none,
  )

  show outline.entry: it => {
    if bachelor {
      if it.level == 1 {
        strong(it)
      } else {
        it
      }
      return
    }

    let fs = it.fields()
    let el = fs.element

    // Figured that we can do better than the template...
    // if bachelor and el in query(selector(heading).before(here())) {
    //   return
    // }

    let rule(body) = {
      set text(
        font: if bachelor {
          font.group.song
        } else {
          font.group.hei-latin-song
        },
        weight: if bachelor {
          "bold"
        } else {
          "regular"
        },
      ) if it.level == 1
      show regex(`[0-9\p{Latin}]+`.text): set text(
        weight: "bold",
      ) if not bachelor

      body
    }

    link(
      el.location(),
      grid(
        columns: (auto, auto, 1fr, auto),
        {
          h((it.level - 1) * outline.indent)
          let prefix = it.prefix()
          if prefix != none {
            show: rule
            prefix
            h(0.5em)
          }
        },
        {
          show: rule
          show regex(`^\p{Han}{2}$`.text): spreadl.with(3em)
          el.fields().body
        },
        fs.fill,
        it.page(),
      ),
    )
  }

  align(
    center,
    heading(
      level: 1,
      outlined: false,
      ohfunc(if lang == "zh" [目录] else [TABLE OF CONTENTS]),
    ),
  )

  outline()

  pagebreak(
    weak: true,
  )
}
// }}}

