//
// Description: Import other modules so you only need to import the helpers
// Use        : #import "/00-templates/helpers.typ": *
// Author     : Silvan Zahno
//
#import "boxes.typ": *
#import "constants.typ": *
#import "items.typ": *

// External Plugins
// Fancy pretty print with line numbers and stuff
#import "@preview/codelst:2.0.2": sourcecode
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
// Glossarium for glossary
#import "@preview/glossarium:0.5.9": *
// Wordometer for word and character count
#import "@preview/wordometer:0.1.5": word-count
// add datetime support for other languages
#import "@preview/icu-datetime:0.2.0"
// List with Checkmarks
#import "@preview/cheq:0.3.0": checklist
// PDF integration
#import "@preview/muchpdf:0.1.1": muchpdf

//-------------------------------------
// Sourcecode modifs
//
#let sourcecode = sourcecode.with(
  frame: block.with(
    fill: code-bg,
    stroke: (left: 3pt + luma(80%), rest: 0.1pt + code-border),
    radius: (left:0pt, right: 4pt),
    inset: (left:7pt, rest:10pt),
  ),
  numbering: "1",
  numbers-style: (lno) => text(luma(210), size:7pt, lno + h(0.3em)),
  numbers-step: 1,
  numbers-width: -1.2em,
)
// code blocks
#set raw(syntaxes:"syntax/VHDL.sublime-syntax")
#set raw(syntaxes:"syntax/riscv.sublime-syntax")

//-------------------------------------
// Internationalization
//
#let langs = json("i18n-thesis.json")
#let i18n(
  key,
  lang: "en",
  extra-i18n: none) = {
  if type(extra-i18n) == dictionary {
    for (lng, keys) in extra-i18n {
      if not lng in langs {
        langs.insert(lng, (:))
      }
      langs.at(lng) += keys
    }
  }
  if not lang in langs {
    lang = "en"
  }
  let keys = langs.at(lang)
  assert(
    key in keys,
    message: "I18n key " + str(key) + " doesn't exist"
  )
  return keys.at(key)
}

#let get-supplement(
  lang: "en",
  it
) = {
    let f = it.func()
    if (f == image) {
      i18n("figure-name", lang: lang)
    } else if (f == table) {
      i18n("table-name", lang: lang)
    } else if (f == raw) {
      i18n("listing-name", lang: lang)
      } else if (f == math.equation) {
      i18n("equation-name", lang: lang)
    } else {
      auto
    }
  }
//-------------------------------------
// Reference helper function
//
#let myref(label) = locate(loc =>{
    if query(label,loc).len() != 0 {
        ref(label)
    } else {
        text(fill: red)[?]
    }
})

//-------------------------------------
// Specifications
//
#let full-page(path) = {
  set page(margin: (
    top: 0cm,
    bottom: 0cm,
    x: 0cm,
  ))

  if path != none {
    image(path, width: 100%)
  } else {
    table(
      columns: (100%),
      rows: (100%),
      stroke: none,
      align: center+horizon,
      [
        #rotate(
          -45deg,
          origin: center+horizon,
        )[
          #text(fill: red, size: huger)[
            No page found
          ]
        ]
      ]
    )
  }
}

//-------------------------------------
// Table of content
//
#let toc(
  tableof: (
    toc: true,
    tof: false,
    tot: false,
    tol: false,
    toe: false,
    maxdepth: 3,
    lang: "en",
  ),
  titles: (
    toc: i18n("toc-title", lang: "en"),
    tof: i18n("tof-title", lang: "en"),
    tot: i18n("tot-title", lang: "en"),
    tol: i18n("tol-title", lang: "en"),
    toe: i18n("toe-title", lang: "en"),
  ),
  before: none,
  indent: auto,
) = {
  // Table of content
    if tableof.toc == true {
      if before != none {
        outline(
          title: titles.toc,
          target: selector(heading).before(before, inclusive: true),
          indent: indent,
          depth: tableof.maxdepth,
        )
      } else {
        outline(
          title: titles.toc,
          indent: indent,
          depth: tableof.maxdepth,
        )
      }
    }

  // Table of figures
  if tableof.tof == true {
    outline(
      title: titles.tof,
      target: figure.where(kind: image),
      indent: indent,
      depth: tableof.maxdepth,
    )
  }

  // Table of tables
  if tableof.tot == true {
    outline(
      title: titles.tot,
      target: figure.where(kind: table),
      indent: indent,
      depth: tableof.maxdepth,
    )
  }

  // Table of listings
  if tableof.tol == true {
    outline(
      title: titles.tol,
      target: figure.where(kind: raw),
      indent: indent,
      depth: tableof.maxdepth,
    )
  }

  // Table of equation
  if tableof.toe == true {
    outline(
      title: titles.toe,
      target: math.equation.where(block:true),
      indent: indent,
      depth: tableof.maxdepth,
    )
  }
}

#let minitoc(
  after: none,
  before: none,
  addline: true,
  stroke: 0.5pt,
  length: 100%,
  depth: 3,
  title: i18n("toc-title", lang: "en"),
  indent: auto,
) = {
  v(2em)
  text(large, weight: "bold", title)
  if addline == true {
    line(length:length, stroke:stroke)
  }
  let h = selector(heading.where(level: 2))
      .or(heading.where(level: 3))
      .or(heading.where(level: 4))
      .or(heading.where(level: 5))
      .or(heading.where(level: 6))
      .or(heading.where(level: 7))
      .or(heading.where(level: 8))
      .or(heading.where(level: 9))
      .or(heading.where(level: 10))
  outline(
    title: none,
    target: selector(h)
      .after(after)
      .before(before, inclusive: false),
      depth: depth,
      indent: indent,
  )
  if addline == true {
    line(length:length, stroke:stroke)
  }
}

#let outline-todos(title: [TODOS]) = context {
  heading(numbering: none, outlined: false, title)

  let queried-todos = query(<todo>)
  let headings = ()
  let last-heading
  for todo in queried-todos {
    let new-last-heading = query(selector(heading).before(todo.location())).last()
    if last-heading != new-last-heading {
      headings.push((heading: new-last-heading, todos: (todo,)))
       last-heading = new-last-heading
    } else {
      headings.last().todos.push(todo)
    }
  }

  for head in headings {
    link(head.heading.location())[
      #if head.heading.at("numbering", default: none) != none {
        numbering(head.heading.numbering, ..counter(heading).at(head.heading.location()))
      }
      #head.heading.body
    ]
    [ ]
    box(width: 1fr, repeat[.])
    [ ]
    [#head.heading.location().page()]

    linebreak()
    pad(left: 1em, head.todos.map((todo) => {
      list.item(link(todo.location(), todo.body.children.at(0).body))
    }).join())
  }
}

//--------------------------------------
// Heading shift
//
// #unshift-prefix[Prefix][Body]
#let unshift-prefix(prefix, content) = context {
  pad(left: -measure(prefix).width, prefix + content)
}

//-------------------------------------
// Research
//
// item, item, item and item List
//
#let enumerating-authors(
  items: none,
  multiline: false,
) = {
  let i = 1
  if items != none {
    for item in items {
       if item != none {
        if "name" in item {
          if i > 1 {
            if multiline == true {
              if items.len() > 2 {
                [\ ]
              } else {
                [, ]
              }
            } else {
              [, ]
            }
          }
          i = i + 1
          if "institute" in item{
            [#item.name#super(repr(item.institute))]
          } else {
            [#item.name]
          }
        }
      }
    }
  }
}

#let enumerating-institutes(
  items: none,
) = {
  let i = 1
  if items != none {
    for item in items {
      if item != none {
        [_#super(repr(i))_ #if item.research_group != none { [_ #item.research_group - _]} _ #item.name __, #item.address _ \ ]
        i = i + 1
      }
    }
  }
}

//-------------------------------------
// Script
//
// item, item, item and item List
//
#let enumerating-items(
  items: none,
  bold: false,
  italic: false,
) = {
  let i = 1
  if items != none {
    for item in items {
      if item != none {
        if bold == true and italic == true {
          [#text(style: "italic")[*#item*]]
        } else if bold == true {
          [*#item*]
        } else if italic == true {
          [#text(style: "italic")[#item]]
        } else {
          [#item]
        }
        if i < items.len() {
          [, ]
        }
      }
      i = i + 1
    }
  }
}
#let enumerating-links(
  names: none,
  links: none,
) = {
  if names != none {
    let i = 0
    for name in names {
      if name != none {
        [#link(links.at(i))[#name]]
        if i+1 < names.len() {
          [, ]
        }
      }
      i = i + 1
    }
  }
}
#let listing-links(
  names: none,
  links: none,
) = {
  if names != none {
    let i = 0
    for name in names {
      if name != none {
        [#link(links.at(i))[#name]]
        if i+1 < names.len() {
          [ \ ]
        }
      }
      i = i + 1
    }
  }
}
#let enumerating-emails(
  names:  none,
  emails: none,
) = {
  if names != none {
    let i = 0
    for name in names {
      if name != none {
        [#link("mailto:"+emails.at(i))[#name]]
        if i+1 < names.len() {
        [, ]
        }
      }
      i = i + 1
    }
  }
}
#let listing-emails(
  names:  none,
  emails: none,
) = {
  if names != none {
    let i = 0
    for name in names {
      if name != none {
        [#link("mailto:"+emails.at(i))[#name]]
        if i+1 < names.len() {
        [ \ ]
        }
      }
      i = i + 1
    }
  }
}

//-------------------------------------
// safe-link
//
#let safe-link(
  name: none,
  url: none,
) = {
  if name != none {
    if url != none {
      link(url)[#name]
    } else  {
      name
    }
  } else {
    if url != none {
      link(url)[#url]
    } else {
      none
    }
  }
}

//-------------------------------------
// Chapter
//
#let add-chapter(
  file: none,
  heading-offset: 0,
  after: none,
  before: none,
  pb: false,
  minitoc-title: i18n("toc-title", lang: "en"),
  body
) = [
  #if (after != none and before != none) {
    minitoc(title: minitoc-title, after:after, before:before, indent: auto)
    if pb {
      pagebreak()
    }
  }
  #set heading(offset: heading-offset)

  #if (file != none) {
    include file
  } else {
    body
  }
  #set heading(offset: 0)
]
