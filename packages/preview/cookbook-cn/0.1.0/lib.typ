#let colors = (
  text: rgb("#333333"),
  muted: rgb("#757575"),
  accent: rgb("#D9534F"), // Warm red
  bg-ing: rgb("#F9F9F9"), // Very light gray for ingredients
  line: rgb("#EEEEEE"),
)
#let fonts = (
  body: ("Zhuque Fangsong (technical preview)", "Times New Roman" ),
  header: ("LXGW WenKai",  "Arial" ),
  mono: ( "Courier New", "LXGW WenKai Mono", "Maple Mono NF CN"),
  sans: ("Sarasa Mono SC"),
)

#let icons = (
  time: box(height: 0.8em, baseline: 0.1em, image(bytes("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><circle cx='12' cy='12' r='10'/><polyline points='12 6 12 12 16 14'/></svg>"), format: "svg")),
  yield: box(height: 0.8em, baseline: 0.1em, image(bytes("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2'></path><circle cx='9' cy='7' r='4'></circle><path d='M23 21v-2a4 4 0 0 0-3-3.87'></path><path d='M16 3.13a4 4 0 0 1 0 7.75'></path></svg>"), format: "svg")),
  fire: box(height: 0.8em, baseline: 0.1em, image(bytes("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.1.243-2.143.5-3.143.51.758 1.573 1.7 1.5 3.143z'/></svg>"), format: "svg")),
)

// --- Components ---

#let checkbox = {
  box(
    height: 0.8em, 
    width: 0.8em, 
    stroke: 1pt + colors.muted.lighten(40%), 
    radius: 2pt, 
    baseline: 20%
  )
}

// --- Main Template ---

#let cookbook(
  title: "Recipe Collection",
  subtitle: none,
  author: "Chef",
  date: datetime.today(),
  paper: "a4",
  accent-color: colors.accent,
  cover-image: none,
  cover-line-1: none,
  cover-line-2: none,
  back-notice: none,
  version: "年月日",
  menu_header: none,
  chapter_header: none,
  TOCType: "simple",
  // TOCSkipPage: 4,
  body
) = {
  set document(title: title, author: author)
  set page(
    paper: paper,
    margin: (x: 2cm, top: 2.5cm, bottom: 2.5cm),
    // numbering: "- 1 -",
    // number-align: center + bottom,
    header: context {
      let p = counter(page).get().first()
      if p > 1 {
        set text(font: fonts.header, size: 9pt, fill: colors.muted)
        grid(
          columns: (1fr, auto, 1fr),
          align(left, title),
          align(center)[        ],
          align(right, author)
        )
        v(-0.8em)
        line(length: 100%, stroke: 0.5pt + colors.line)
      }
    },
    footer: context {
      // 检查是否在目录部分
      let in-toc-state = state("in-toc")
      let in-toc-result = in-toc-state.get()
      let in-toc = if in-toc-result != none { in-toc-result } else { false }

      // 获取当前页面计数器
      let page-value = counter(page).get().first()

      if page-value >= 1 {
        set text(font: fonts.header, size: 9pt, fill: colors.muted)
        grid(
          columns: (1fr, auto, 1fr),
          align(left)[    ],
          align(center)[
            #{
              let page-num = if in-toc {
                // 目录部分：罗马数字格式
                "— " + counter(page).display("i") + " —"
              } else {
                // 正文部分：阿拉伯数字格式
                "— " + str(page-value) + " —"
              }
              text(page-num)
            }
          ],
          align(right)[    ]
        )
        // v(-0.8em)
        // line(length: 100%, stroke: 0.5pt + colors.line)
      }
    }
  )
  
  set text(
    font: fonts.body, 
    size: 11pt, 
    fill: colors.text, 
    lang: "cn",
    features: (onum: 1)
  )

  // Headings
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set align(center + horizon)
    block(width: 100%)[
        // #text(font: fonts.header, weight: "bold", size: 0.9em, tracking: 2pt, fill: colors.accent, upper("Chapter"))
        #text(font: fonts.header, weight: "bold", size: 0.9em, tracking: 2pt, fill: colors.accent, upper(chapter_header))
        #v(0.5em)
        #text(font: fonts.header, weight: "black", size: 3.5em, fill: colors.text, it.body)
    ]
  }
  
  show heading.where(level: 2): it => {
    pagebreak(weak: true)
    v(1em)
    text(font: fonts.header, weight: "bold", size: 2.2em, fill: colors.text, it.body)
    v(0.5em)
  }

  // Cover
  if title != none {
    page(margin: 0pt, header: none)[
    #if cover-line-1!=none {
      align(left+top)[
      #v(10%)
      #h(10%)
      #text(font: fonts.sans, weight: "regular", size: 1.5em, fill: colors.text, cover-line-1)
      ]
    }
    #if cover-line-2!=none {
      align(left+top)[
      #h(10%)
            #text(font: fonts.sans, weight: "regular", size: 1.5em, fill: colors.text, cover-line-2)
      ]
    }
      // Optional Background Image
      #if cover-image != none {
        place(top, image(cover-image, width: 100%, height: 60%, fit: "cover"))
      }
      
      #place(center + horizon)[
        #block(
           width: 75%, 
           stroke: (
             top: 4pt + accent-color, 
             bottom: if cover-image == none { 4pt + accent-color } else { none }
           ), 
           inset: (y: 3em),
           fill: if cover-image != none { colors.bg-ing.lighten(10%) } else { none },
           outset: if cover-image != none { 1cm } else { 0cm }
        )[
          #par(leading: 0.35em)[
            #text(font: fonts.header, weight: "regular", size: 4.5em, fill: colors.text, title)
            // #text(font: fonts.header, weight: "black", size: 4.5em, fill: colors.text, title)
          ]
          #v(0.5em)
          #par(leading: 0.35em)[
            #text(font: fonts.header, weight: "light", size: 2em, fill: colors.text, subtitle)
          ]
          #v(0.8em)
          #text(font: fonts.body, style: "italic", size: 1.5em, fill: colors.muted, " " + author)
        ]
      ]
      
      #place(bottom + center)[
         #pad(bottom: 3cm, text(font: fonts.header, size: 0.8em, tracking: 3pt, fill: colors.muted, upper(date.display("[year]年[month]月"))))
      ]
    ]
  }

  // TOC
  if TOCType == "numbly" {
    state("in-toc").update(true)
    counter(page).update(1)
    page(
    header: none,
    // footer: auto,
    // numbering: "- i -",
    // number-align: center + bottom,
    )[
    #set text(font: fonts.header, size: 9pt, fill: colors.muted)
    #v(3cm)
    #align(center)[
       // #text(font: fonts.header, weight: "bold", size: 1.2em, tracking: 2pt, fill: colors.accent, upper("Contents"))

       #text(font: fonts.header, weight: "bold", size: 1.2em, tracking: 2pt, fill: colors.accent, upper(menu_header))
       #v(1em)
       #line(length: 3cm, stroke: 0.5pt + colors.muted)
    ]
    #v(1.5cm)

    // 定义目录编号计数器
    #let h1-counter = counter("h1")
    #let h2-counter = counter("h2")
    // 定义目录主体的计数器
    #let entry-counter = counter("my-outline-entry")

    #h1-counter.update(1)
    #h2-counter.update(1)
    #entry-counter.update(1)
    #show outline.entry: it => {
      entry-counter.step()

      let is-first = if entry-counter.display("一") == "一" { true } else { false }
      // init TOCSkipPage 
      let TOCSkipPage = state("TOCSkipPage", 0)
      if is-first {
        TOCSkipPage.update(old => old + it.element.location().page())
      }
      if it.level == 1 {
        // 一级标题：使用中文数字编号（一、二、三...）
        h1-counter.step()
        // 重置二级标题计数器（如果需要每个章节重新编号，但用户要求统一大排序，所以不重置）
        // h2-counter.update(1)
        v(1.5em)
        box(width: 100%)[
          #text(font: fonts.header, weight: "black", size: 1.3em, fill: colors.text,
            h1-counter.display("一") + "、" + upper(it.element.body))
          // 章节标题不显示页码
        ]
      } else {
        // 二级标题：使用阿拉伯数字编号（1. 2. 3...），统一大排序
        h2-counter.step()
        v(0.5em)
        box(width: 100%)[
          #text(font: fonts.body, size: 1.1em, fill: colors.text,
            h2-counter.display() + ". " + it.element.body)
          #box(width: 1fr, repeat[ #h(0.3em) #text(fill: colors.line.darken(20%), size: 0.6em)[.] #h(0.3em) ])
          #text(font: fonts.header, weight: "bold", fill: colors.muted, context it.element.location().page() - TOCSkipPage.get())
        ]
        }
      }

      #outline(title: none, indent: 0pt, depth: 2)
    ]
    } else if TOCType == "simple" {
    state("in-toc").update(true)
    counter(page).update(1)
  page(
    header: none,
    // footer: auto,
    // numbering: "- i -",
    // number-align: center + bottom,
  )[
    #v(3cm)
    #align(center)[
       // #text(font: fonts.header, weight: "bold", size: 1.2em, tracking: 2pt, fill: colors.accent, upper("Contents"))

       #text(font: fonts.header, weight: "bold", size: 1.2em, tracking: 2pt, fill: colors.accent, upper(menu_header))
       #v(1em)
       #line(length: 3cm, stroke: 0.5pt + colors.muted)
    ]
    #v(1.5cm)

    #let toc-offset = 1
    #show outline.entry: it => {
      if it.level == 1 {
        // Section / Chapter Header
        v(1.5em)
        text(font: fonts.header, weight: "black", size: 1.3em, fill: colors.text, upper(it.element.body))
        h(1fr)
        // No page number for chapters, looks cleaner
      } else {
        // Recipe Entry
        v(0.5em)
        box(width: 100%)[
          #text(font: fonts.body, size: 1.1em, fill: colors.text, it.element.body)
          #box(width: 1fr, repeat[ #h(0.3em) #text(fill: colors.line.darken(20%), size: 0.6em)[.] #h(0.3em) ])
          #text(font: fonts.header, weight: "bold", fill: colors.muted, context it.element.location().page() - toc-offset)
        ]
        }
      }

      #outline(title: none, indent: 0pt, depth: 2)
    ]
    }


  // 重置目录状态
  state("in-toc").update(false)
  counter(page).update(1)
  // set page(numbering: "i")
  body

// Back — confidentiality notice
if back-notice != none {
pagebreak()
align(bottom+left)[
  #h(2em)#text(weight: "bold", size: 14pt)[#back-notice]
]
}
if version == "年月日" {
align(center+bottom)[
#text(weight: "bold", size: 14pt)[版本日期:] #text(weight:"bold", size: 14pt, upper(date.display("[year]年[month]月[day]日")))
]
}
}

// --- Recipe Function ---

#let recipe(
  name,
  ingredients: (),
  instructions: [],
  ingredients_header: none,
  instructions_header: none,
  worknote_header: none,
  description: none,
  image: none,
  servings: none,
  prep-time: none,
  cook-time: none,
  notes: none,
) = {
  // 1. Header Section
  heading(level: 2, name)
  
  // Description & Meta row
  grid(
    columns: (1fr, auto),
    gutter: 1em,
    align(left + horizon, {
      if description != none {
        text(font: fonts.body, style: "italic", fill: colors.muted, description)
      }
    }),
    align(right + horizon, {
      set text(font: fonts.header, size: 0.9em, fill: colors.muted)
      let meta = ()
      if servings != none { meta.push([#icons.yield #h(0.3em) #servings]) }
      // if prep-time != none { meta.push([#icons.time #h(0.3em) #prep-time]) }
      // if cook-time != none { meta.push([#icons.fire #h(0.3em) #cook-time]) }
      if meta.len() > 0 {
        meta.join(h(1.5em))
      }
    })
  )

  v(0.8em)
  line(length: 100%, stroke: 0.5pt + colors.line)
  v(2em)

  // 2. Main Layout (Sidebar + Content)
  grid(
    columns: (35%, 1fr),
    gutter: 2.5em,
    
    // -- Left Column: Ingredients --
    {
      if image != none {
        block(width: 100%, height: auto, clip: true, radius: 4pt, image)
        v(1.5em)
      }
      
      block(
        fill: colors.bg-ing,
        inset: 1.2em,
        radius: 4pt,
        width: 100%,
        stroke: 0.5pt + colors.line.darken(5%),
      )[
        #text(font: fonts.header, weight: "bold", size: 1.1em, fill: colors.text, ingredients_header)
        #v(0.8em)
        #set text(size: 0.95em)
        
        #for ing in ingredients {
          grid(
            columns: (auto, 1fr),
            gutter: 0.6em,
            checkbox,
            {
              if type(ing) == dictionary {
                [*#ing.at("amount", default: "")* #ing.at("name", default: "")]
              } else {
                ing
              }
            }
          )
          v(0.6em)
        }
      ]

      if notes != none {
        v(1.5em)
        text(font: fonts.header, size: 0.9em, weight: "bold", fill: colors.accent, worknote_header)
        v(0.3em)
        text(style: "italic", size: 0.9em, fill: colors.muted, notes)
      }
    },

    // -- Right Column: Instructions --
    {
      text(font: fonts.header, weight: "bold", size: 1.1em, fill: colors.text, instructions_header)
      v(1em)
      
      set enum(
        numbering: n => text(font: fonts.header, size: 1.2em, weight: "bold", fill: colors.accent, box(inset: (right: 0.5em), [#n]))
      )
      set par(leading: 1em, justify: true)
      
      // Just apply spacing to list items via a show rule on the item
      show enum.item: it => {
        pad(bottom: 0.8em, it)
      }
      
      instructions
    }
  )
}
