/*
 * mkuipers-ulusofona — internal engine
 *
 * Not part of the package's public API (see lib.typ for what's exported).
 * Based on the excellent orange-book template.
 *
 * Adapted by: Martijn Kuipers (martijn.kuipers@ulusofona.pt)
 */

#import "@preview/acrostiche:0.7.0": *

//#let normal-font = "Libertinus Serif"
#let normal-font = "New Computer Modern"
#let math-font = "New Computer Modern Math"
#let code-font = "DejaVu Sans Mono"

#show math.equation: set text(font:math-font)
#show math.equation: set text(font: math-font)
#show raw: set text(font: code-font)


#let translations = yaml("translations.yaml")

#let translation(key) = {
  let lang-dict = translations.at(key, default: key)
  // If default value was returned
  return if type(lang-dict) == str {
    lang-dict
  } else {
    context lang-dict.at(text.lang, default: lang-dict.at("en", default: key))
  }
}

#let to-roman(n, lowercase: true) = {
  // Roman numeral map as string keys
  let numerals = (
    "1000": "M", "900": "CM", "500": "D", "400": "CD",
    "100": "C", "90": "XC", "50": "L", "40": "XL",
    "10": "X", "9": "IX", "5": "V", "4": "IV", "1": "I"
  )

  // Ensure n is an integer
  let num = int(str(n.text))
  let keys = numerals.keys().map(x => int(x)).sorted().rev()
  let result = ""

  // Iterate in reverse order
  for i in range(keys.len()) {
    let key = keys.at(i)
    while num >= key {
      result += numerals.at(str(key))
      num -= key
    }
  }

  if lowercase {
    lower(result)
  } else {
    result
  }
}


// Outline
#let my-outline-row( textSize:none,
                    textWeight: "regular",
                    insetSize: 0pt,
                    textColor: blue,
                    number: "0",
                    title: none,
                    heading_page: "0",
                    location: none,
                    front-matter: false) = {
  set text(size: textSize, fill: textColor, weight: textWeight)
  box(width: 1.1cm, inset: (y: insetSize), align(left, number))
  h(0.1cm)
  
  let page_number = if front-matter {
    to-roman(heading_page)
  } else {
    heading_page
  }
  box(inset: (y: insetSize), width: 100% - 1.2cm, )[
    #set align(left)
    #link(location, title)
    #box(width: 1fr, repeat(text(weight: "regular")[. #h(4pt)])) 
    #link(location, page_number)
  ]
}

#let my-outline(front-matter-state, appendix-state, appendix-state-hide-parent, part-state, part-location,part-change,part-counter, main-color, lang, depth: 2, textSize1:none, textSize2:none, textSize3:none, textSize4:none) = {
  show outline.entry: it => {
     let front-matter-state = front-matter-state.at(it.element.location())
    let appendix-state = appendix-state.at(it.element.location())
    let appendix-state-hide-parent = appendix-state-hide-parent.at(it.element.location())
    let numberingFormat = if appendix-state != none {"A.1"} else {"1.1"}
    let counterInt = counter(heading).at(it.element.location())
    let number = none
    if counterInt.first() > 0 {
      number = numbering(numberingFormat, ..counterInt)
    }
    let title = it.element.body
    let heading_page = it.page()
    

    if it.level == 1 {
      let part-state = part-state.at(it.element.location())
      let part-location = part-location.at(it.element.location())
      let part-change = part-change.at(it.element.location())
      let part-counter = part-counter.at(it.element.location())
      if (part-change){
        v(0.7cm, weak: true)
        box(width: 1.1cm, fill: main-color.lighten(80%), inset: 5pt, align(center, text(size: textSize1, weight: "bold", fill: main-color.lighten(30%), numbering("I",part-counter.first()))))
        h(0.1cm)
        box(width: 100% - 1.2cm, fill: main-color.lighten(60%), inset: 5pt, align(center, link(part-location,text(size: textSize1, weight: "bold", part-state))))
        v(0.45cm, weak: true)
      }
      else{
        v(0.5cm, weak: true)
      }

      if (counterInt.first() == 1 and appendix-state != none and not appendix-state-hide-parent ){
        my-outline-row(insetSize: 2pt, textWeight: "bold", textSize: textSize2, textColor:main-color, number: none, title: appendix-state, heading_page: heading_page, location: it.element.location(), front-matter: front-matter-state)
        v(0.5cm, weak: true)
      }
      my-outline-row(insetSize: 5pt, textWeight: "bold", textSize: textSize2, textColor:main-color, number: number, title: title, heading_page: heading_page, location: it.element.location(), front-matter: front-matter-state)
    }
    else if it.level ==2 {
      my-outline-row(insetSize: 2pt, textWeight: "bold", textSize: textSize3, textColor:black, number: number, title: title, heading_page: heading_page, location: it.element.location(), front-matter: front-matter-state)
    } else {
       my-outline-row(textWeight: "regular", textSize: textSize4, textColor:black, number: number, title: title, heading_page: heading_page, location: it.element.location(), front-matter: front-matter-state)
    }
  }
    heading(level: 1, translation("table-of-contents"), numbering: none)
    outline(title: none, depth: depth, indent: 0em)
}

#let my-outline-small(partTitle, appendix-state, part-state, part-location,part-change,part-counter, main-color, textSize1:none, textSize2:none, textSize3:none, textSize4:none) = {
  show outline.entry: it => {
    let appendix-state = appendix-state.at(it.element.location())
    let numberingFormat = if appendix-state != none {"A.1"} else {"1.1"}
    let counterInt = counter(heading).at(it.element.location())
    let number = none
    if counterInt.first() >0 {
      number = numbering(numberingFormat, ..counterInt)
    }
    let title = it.element.body
    let heading_page = it.page()
    let part-state = part-state.at(it.element.location())
    if (part-state == partTitle and counterInt.first() >0 and appendix-state==none){
      if it.level == 1 {
        v(0.5cm, weak: true)
        my-outline-row(insetSize: 1pt, textWeight: "bold", textSize: textSize2, textColor:main-color, number: number, title: title, heading_page: heading_page, location: it.element.location(), front-matter: front-matter-state)
      }
      else if it.level == 2 {
        my-outline-row(textWeight: "regular", textSize: textSize4, textColor:black, number: number, title: text(fill: black, title), heading_page: text(fill: black, heading_page), location: it.element.location(), front-matter: front-matter-state)
      }
    }
    else{
      v(-0.65em, weak: true)
    }
  }
  box(width: 9.5cm, outline(depth: 2, indent: 0em, title: none))
}

#let my-outline-sec(list-of-figure-title, target, textSize) = {
heading(level: 1, list-of-figure-title, numbering: none)

  show outline.entry.where(level: 1): it => {
    let heading_page = it.page()
    [
      #set text(size: textSize)
      #box(width: 100%)[
        #box(width: 0.75cm, align(right, [#it.prefix().at("children").at(2) #h(0.2cm)]))
        #link(it.element.location(), it.element.at("caption").body)
        #box(width: 1fr, repeat(text(weight: "regular")[. #h(4pt)])) 
        #link(it.element.location(),heading_page)
      ]
    ]
  }
  outline(
    title: none,
    target: target
  )
}

// Theorems

#let thmcounters = state(
  "thm",
  (
    "counters": ("heading": ()),
    "latest": (),
  ),
) 

#let thmenv(identifier, base, base_level, fmt) = {

  let global_numbering = numbering

  return (
    body,
    name: none,
    numbering: "1.1",
    base: base,
    base_level: base_level,
  ) => {
    set par(first-line-indent: 0em)
    let number = none
    if not numbering == none {
      context {
        let her = here()
        thmcounters.update(thmpair => {
          let counters = thmpair.at("counters")
          // Manually update heading counter
          counters.at("heading") = counter(heading).at(her)
          if not identifier in counters.keys() {
            counters.insert(identifier, (0,))
          }

          let tc = counters.at(identifier)
          if base != none {
            let bc = counters.at(base)

            // Pad or chop the base count
            if base_level != none {
              if bc.len() < base_level {
                bc = bc + (0,) * (base_level - bc.len())
              } else if bc.len() > base_level {
                bc = bc.slice(0, base_level)
              }
            }

            // Reset counter if the base counter has updated
            if tc.slice(0, -1) == bc {
              counters.at(identifier) = (..bc, tc.last() + 1)
            } else {
              counters.at(identifier) = (..bc, 1)
            }
          } else {
            // If we have no base counter, just count one level
            counters.at(identifier) = (tc.last() + 1,)
            let latest = counters.at(identifier)
          }

          let latest = counters.at(identifier)
          return (
            "counters": counters,
            "latest": latest,
          )
        })
      }

      number = context {
        global_numbering(numbering, ..thmcounters.get().at("latest"))
      }
    }

    fmt(name, number, body)
  }
}


#let thmref(
  label,
  fmt: auto,
  makelink: true,
  ..body,
) = {
  if fmt == auto {
    fmt = (nums, body) => {
      if body.pos().len() > 0 {
        body = body.pos().join(" ")
        return [#body #numbering("1.1", ..nums)]
      }
      return numbering("1.1", ..nums)
    }
  }

  context {
    let elements = query(label)
    let locationreps = elements.map(x => repr(x.location().position())).join(", ")
    assert(
      elements.len() > 0,
      message: "label <" + str(label) + "> does not exist in the document: referenced at " + repr(here().position()),
    )
    assert(
      elements.len() == 1,
      message: "label <" + str(label) + "> occurs multiple times in the document: found at " + locationreps,
    )
    let target = elements.first().location()
    let number = thmcounters.at(target).at("latest")
    if makelink {
      return link(target, fmt(number, body))
    }
    return fmt(number, body)
  }
}


#let thmbox(
  identifier,
  fill: none,
  stroke: none,
  inset: 1.2em,
  radius: 0.3em,
  breakable: false,
  padding: (top: 0.5em, bottom: 0.5em),
  namefmt: x => [(#x)],
  titlefmt: strong,
  bodyfmt: x => x,
  separator: [#h(0.1em):#h(0.2em)],
  base: "heading",
  base_level: none,
) = {
  let boxfmt(name, number, body) = {
    if not name == none {
      name = [ #namefmt(name)]
    } else {
      name = []
    }
    let title = translation(identifier)
    if not number == none {
      title += " " + number
    }
    title = titlefmt(title)
    body = bodyfmt(body)
    block(
      fill: fill,
      stroke: stroke,
      spacing: 1.2em,
      inset: inset,
      width: 100%,
      radius: radius,
      breakable: breakable,
      [#title#name#separator#body],
    )
  }
  return thmenv(identifier, base, base_level, boxfmt)
}


#let thmplain = thmbox.with(
  padding: (top: 0em, bottom: 0em),
  breakable: true,
  inset: (top: 0em, left: 1.2em, right: 1.2em),
  namefmt: name => emph([(#name)]),
  titlefmt: emph,
)

// Index
#let classes = (main: "Main")
#let index_string = "my_index"

#let index(content) = place(hide(
figure(
    classes.main,
    caption: content,
    numbering: none,
    kind: index_string
)))

#let make-index-int(title: none, main-color-state:none) = {

    let content-text(content) = {
        let ct = ""
        if content.has("text") {
            ct = content.text
        }
        else {
            for cc in content.children {
                if cc.has("text") {
                    ct += cc.text
                }
            }
        }
        return ct
    }
    
    set par(first-line-indent: 0em)
    context{
        let main-color = main-color-state.at(here())
            let elements = query(selector(figure.where(kind: index_string)).before(here()))
        let words = (:)
        for el in elements {
            let ct = ""
            if el.caption.has("body"){
                ct = content-text(el.caption.body)
            }
            else{
                ct = content-text(el.caption)
            }

            // Have we already know that entry text? If not,
            // add it to our list of entry words
            if words.keys().contains(ct) != true {
                words.insert(ct, ())
            }

            // Add the new page entry to the list.
            let ent = (class: el.body.text, page: el.location().page())
            if not words.at(ct).contains(ent){
                words.at(ct).push(ent)
            }
        }


        let sortedkeys = words.keys().sorted()

        let register = ""
        if title != none {
            heading(level: 1, numbering: none, title)
        }
        block(columns(2,gutter: 1cm, [
            #for sk in sortedkeys [
                #let formattedPageNumbers = words.at(sk).map(en => {
                    link((page: en.page, x:0pt, y:0pt), text(fill: black, str(en.page)))
                })
                    #let firstCharacter = sk.first()
                    #if firstCharacter != register {
                        v(1em, weak:true)
                        box(width: 100%, fill: main-color.lighten(60%), inset: 5pt, align(center, text(size: 1.1em, weight: "bold", firstCharacter)))
                        register = firstCharacter
                        v(1em, weak:true)
                    }
                    #set text(size: 0.9em)
                    #if(sk.contains("!")){
                        h(2em)
                        sk.slice(sk.position("!")+1)
                    }else{
                     sk
                    }
                    #box(width: 1fr, repeat(text(weight: "regular")[. #h(4pt)])) 
                    #formattedPageNumbers.join(",")
                    #v(0.65em, weak:true)
        ]
        ]))
    }
}


// Main



#let scr(it) = text(
  features: ("ss01",),
  box($cal(it)$),
)
#let mathcal = (it) => {
  set text(size: 1.3em, font: normal-font)
  it
  h(0.1em)
}


#let normal-text = 1em
#let large-text = 3em
#let huge-text = 16em
#let title-main-1 = 3.5em
#let title-main-2 = 1.2em
#let title-main-3 = 2.2em
#let title-main-4 = 1.5em
#let title1 = 2.2em
#let title2 = 1.5em
#let title3 = 1.3em
#let title4 = 1.2em
#let title5 = 11pt

#let outline-part = 1.5em;
#let outline-heading1 = 1.3em;
#let outline-heading2 = 1.1em;
#let outline-heading3 = 1.1em;


#let nocite(citation) = {
  place(hide[#cite(citation)])
}

#let language-state = state("language-state", none)
#let main-color-state = state("main-color-state", none)
#let appendix-state = state("appendix-state", none)
#let appendix-state-hide-parent = state("appendix-state-hide-parent", )
#let lang = state("lang", "pt")
#let cover-image = state("cover-image", none)
#let heading-image = state("heading-image", none)
#let supplement-part-state = state("supplement_part", none)
#let part-style-state = state("part-style", 0)
#let part-state = state("part-state", none)
#let part-location = state("part-location", none)
#let part-counter = counter("part-counter")
#let part-change = state("part-change", false)

#let format_authors(authors, lang) = {
  let lang_word = if lang == "en" { " and " } else { " e " }
  return authors.map(a => a.name).join(", ", last: lang_word)
}

#let format-copyright-authors(authors, lang) = {
  ", Copyright " + sym.copyright + " de " + format_authors(authors) + ", Universidade Lusófona."
}

#let part(title) = {
  pagebreak(to: "odd")
  part-change.update(x =>
    true
  )
  part-state.update(x =>
    title
  )
  part-counter.step()
  [
    #context{
      let her = here()
      part-location.update(x =>
        her
      )
    }

    #context{
      let main-color = main-color-state.at(here())
      let part-style = part-style-state.at(here())
      let supplement_part = supplement-part-state.at(here())
      if part-style == 0 [
        #set par(justify: false)
        #place(block(width:100%, height:100%, outset: (x: 3cm, bottom: 2.5cm, top: 3cm), fill: main-color.lighten(70%)))
        #place(top+right, text(fill: black, size: large-text, weight: "bold", box(width: 60%, part-state.get())))
        #place(top+left, text(fill: main-color, size: huge-text, weight: "bold", part-counter.display("I")))
      ] else if part-style == 1 [
        #set par(justify: false)
        #place(block(width:100%, height:100%, outset: (x: 3cm, bottom: 2.5cm, top: 3cm), fill: main-color.lighten(70%)))
        #place(top+left)[
          #block(text(fill: black, size: 2.5em, weight: "bold", supplement_part + " " + part-counter.display("I")))
          #v(1cm, weak: true)
          #move(dx: -4pt, block(text(fill: main-color, size: 6em, weight: "bold", part-state.get())))
        ]
      ]
      align(bottom+right, my-outline-small(title, appendix-state, part-state, part-location,part-change,part-counter, main-color, textSize1: outline-part, textSize2: outline-heading1, textSize3: outline-heading2, textSize4: outline-heading3))
    } 
  ]
}


#let chapter(title, l: none) = {
  if l != none [
    #heading(level: 1, title) #label(l)
  ] else [
    #heading(level: 1, title) 
  ]
}

#let update-heading-image(image:none) = {
  heading-image.update(x =>
    image
  )
}

#let make-index(title: none) = {
  make-index-int(title:title, main-color-state: main-color-state)
}

// Set below hid-parent to false to add a Appendix entry in the outline
#let appendices(title, doc, hide-parent: true) = {
  counter(heading).update(0)
  appendix-state.update(x =>
    title
  )
  appendix-state-hide-parent.update(x =>
    hide-parent
  )
  set heading( numbering: (..nums) => {
      let vals = nums.pos()
      return str(numbering("A.1", ..vals)) + "."
    },
  )
  doc
}

#let my-bibliography(file, image:none) = {
  counter(heading).update(0)
  heading-image.update(x =>
    image
  )
  file
}

#let theorem(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("theorem",
    stroke: 0.5pt + main-color,
    radius: 0em,
    inset: 0.65em,
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", fill: main-color, x), 
    fill: black.lighten(95%), 
    base_level: 1)(name:name, body)
  }
}

#let definition(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("definition",
    stroke: (left: 4pt + main-color),
    radius: 0em,
    inset: (x: 0.65em),
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", x), 
    base_level: 1)(name:name, body)
  }
}

#let corollary(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("corollary",
    stroke: (left: 4pt + gray),
    radius: 0em,
    inset: 0.65em,
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", x),
    fill: black.lighten(95%), 
    base_level: 1)(name:name, body)
  }
}


#let proposition(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("proposition",
    radius: 0em,
    inset: 0em,
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", fill: main-color, x),
    base_level: 1)(name:name, body)
  }
}


#let notation(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("notation",
    stroke: none,
    radius: 0em,
    inset: 0em,
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", x), 
    base_level: 1)(name:name, body)
  }
}

#let exercise(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("exercise",
    stroke: (left: 4pt + main-color),
    radius: 0em,
    inset: 0.65em,
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(fill: main-color, weight: "bold", x),
    fill: main-color.lighten(90%), 
    base_level: 1)(name:name, body)
  }
}

#let example(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("example",
    stroke: none,
    radius: 0em,
    inset: 0em,
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", x), 
    base_level: 1)(name:name, body)
  }
}

#let problem(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("problem",
    stroke: none,
    radius: 0em,
    inset: 0em,
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(fill: main-color, weight: "bold", x), 
    base_level: 1)(name:name, body)
  }
}

#let vocabulary(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("vocabulary",
    stroke: none,
    radius: 0em,
    inset: 0em,
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => [■ #text(weight: "bold", x)], 
    base_level: 1)(name:name, body)
  }
}

#let remark(body) = {
   context{
    let main-color = main-color-state.at(here())
    set par(first-line-indent: 0em)
    grid(
    columns: (1.2cm, 1fr),
    align: (center, left),
    rows: (auto),
    circle(radius: 0.3cm, fill: main-color.lighten(70%), stroke: main-color.lighten(30%))[
      #set align(center + horizon)
      #set text(fill: main-color, weight: "bold")
      R
    ],
    body)
  }
}

// Document engine. `ulthesis` and `ulreport` (in lib.typ) are thin wrappers
// around this function that fix document-type-specific vocabulary and
// defaults. Not exported directly — see lib.typ for the public API.
#let uldocument(
  title: "",
  type: "",
  subtype: "",
  subtitle: "",
  date: "",
  authors: (),
  supervisors: (),
  supervisor-label: "Orientador",
  cosupervisor-label: "Co-orientador",
  course-unit: "",
  group: "",
  external: "",
  external-label: "Entidade Externa",
  department: "Departamento de Engenharia Informática e Sistemas de Informação",
  paper-size: "a4",
  logo: none,
  cover: image("cover_image.jpg"),
  image-index: none,
  body,
  main-color: black,
  lang: "en",
  list-of-figures: true,
  list-of-tables: true,
  list-of-acronyms: true,
  glossary-data: none,
  glossary-unused: false,
  glossary-position: "front",
  acknowledgements: none,
  abstract-en: none,
  abstract-pt: none,
  copyright-phrase: "esta dissertação",
  supplement-chapter: "Chapter",
  supplement-part: "Part",
  toc-depth: 2,
  font-size: 10pt,
  part-style: 0,
  lowercase-references: false) = {
    set document(author: format_authors(authors, lang), title: title)
    set text(size: font-size, lang: lang)
    set par(leading: 0.5em)
    set enum(numbering: "1.a.i.")
    set list(marker: ([•], [--], [◦]))

    set ref(supplement: (it)=>{lower(it.supplement)}) if lowercase-references

    if (glossary-data != none) {
      init-acronyms(glossary-data)
    }


    set math.equation(numbering: num =>
      numbering("(1.1)", counter(heading).get().first(), num)
  )

  set figure(numbering: num =>
    numbering("1.1", counter(heading).get().first(), num)
  )

  set figure(gap: 1.3em)

  show figure: it => align(center)[
    #it
    #if (it.placement == none){
      v(2.6em, weak: true)
    }
  ]

  show terms: set par(first-line-indent: 0em)

  let front-matter-state = state("front-matter", true)
  set page(
    paper: paper-size,
    margin: (x: 3cm, bottom: 2.5cm, top: 3cm),
     header: context{
      set text(size: title5)
      let page_number = here().page()//counter(page).at(here()).first()
      let odd_page = calc.odd(page_number)
      let part_change = part-change.at(here())
      // Are we on an odd page?
      // if odd_page {
      //   return text(0.95em, smallcaps(title))
      // }

      // Are we on a page that starts a chapter? (We also check
      // the previous page because some headings contain pagebreaks.)
      let all = query(heading.where(level: 1))

      if all.any(it => it.location().page() == page_number) or part_change {
        return
      }

      let appendix = appendix-state.at(here())

//      let page_number_print = counter(page).at(here()).first()
      let raw_page = counter(page).at(here()).first()
      let front = front-matter-state.at(here())
      let page_number_print = if front {
        numbering("i", raw_page)
      } else {
        str(raw_page)
      }
      if odd_page {
        let before = query(selector(heading.where(level: 1)).before(here()))
        let counterInt = counter(heading).at(here())
        if before != () and counterInt.len()> 1 {
          box(width: 100%, inset: (bottom: 5pt), stroke: (bottom: 0.5pt))[
            #text(if appendix != none {numbering("A.1", ..counterInt.slice(0,2)) + " " + before.last().body} else {numbering("1.1", ..counterInt.slice(0,2)) + " " + before.last().body})
            #h(1fr)
            #page_number_print
          ]
        }
      } else{
        let before = query(selector(heading.where(level: 1)).before(here()))
        let counterInt = counter(heading).at(here()).first()
        if before != () and counterInt > 0 {
          box(width: 100%, inset: (bottom: 5pt), stroke: (bottom: 0.5pt))[
            #page_number_print
            #h(1fr)
            #text(weight: "bold", if appendix != none {numbering("A.1", counterInt) + ". " + before.last().body} else{before.last().supplement + " " + str(counterInt) + ". " + before.last().body})
          ]
        }
      }
    },
    footer: context{
      set text(size: title5)
      let page_number = here().page()//counter(page).at(here()).first()
      let odd_page = calc.odd(page_number)
      let part_change = part-change.at(here())
      // Are we on an odd page?
      // if odd_page {
      //   return text(0.95em, smallcaps(title))
      // }

      // Are we on a page that starts a chapter? (We also check
      // the previous page because some headings contain pagebreaks.)
      let all = query(heading.where(level: 1))
     // let page_number_print = counter(page).at(here()).first()
      let raw_page = counter(page).at(here()).first()
      let front = front-matter-state.at(here())
      let page_number_print = if front {
        numbering("i", raw_page)
      } else {
        str(raw_page)
      }
      if all.any(it => it.location().page() == page_number) or part_change {
        box(width: 100%, inset: (top: 5pt), stroke: (top: 0.5pt))[
            #h(1fr)
            #page_number_print
            #h(1fr)
          ]
      }


    }
  )


  show cite: it => {
    show regex("[\w\W]"): set text(main-color)
    it
  }

  set heading(
    hanging-indent: 0pt,
    numbering: (..nums) => {
      let vals = nums.pos()
      let pattern = if vals.len() == 1 { "1." }
                    else if vals.len() <= 4 { "1.1" }
      if pattern != none { numbering(pattern, ..nums) }
    }
  )

  show heading.where(level: 1): set heading(supplement: supplement-chapter)

  show heading: it => {
    set text(size: font-size)
    if it.level == 1 {
      pagebreak(to: "odd")
      //set par(justify: false)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(math.equation).update(0)
      context{
        move(dx: 3cm, dy: -0.5cm, align(right + top, block(
            width: 100% + 3cm,
            inset: (left:0em, rest: 1.6em),
            align(left, text(size: title1, it))
          )))
        v(1.5cm, weak: true)
      }
      part-change.update(x =>
        false
      )
    }
    else if it.level == 2 or it.level == 3 or it.level == 4 {
      let size
      let space
      let color = main-color
      if it.level == 2 {
        size= title2
        space = 1em
      }
      else if it.level == 3 {
        size= title3
        space = 0.9em
      }
      else {
        size= title4
        space = 0.7em
        color = black
      }
      set text(size: size)
      let number = if it.numbering != none {
        set text(fill: main-color) if it.level < 4
        let num = counter(heading).display(it.numbering)
        let width = measure(num).width
        let gap = 7mm
        place(dx: -width - gap, num)
      }
      block(it)
      v(space, weak: true)
    }
    else {
      it
    }
  }

  set underline(offset: 3pt)

  // Title page.
  page(margin: 0cm, header: none)[
    #set text(fill: black)
    #language-state.update(x => lang)
    #main-color-state.update(x => main-color)
    #part-style-state.update(x => part-style)
    #supplement-part-state.update(x => supplement-part)
    #if cover != none {
      set image(width: 100%, height: 100%)
      place(bottom, cover)
    }
    #align(center + top, block(width: 100%, fill: none, height: 29.7cm, pad(x:2cm, y:1cm)[
      #box(height: 10cm)
      #par(leading: 0.4em)[
        #text(size: title-main-1, weight: "black", title)
      ]
      #v(0.5cm, weak: true)
      #par(leading: 0.4em)[
        #text(size: title-main-3, weight: "black", if subtitle != "" {"- " + subtitle + " -"} else {""})
      ]
      #v(1cm, weak: true)
      #text(size: title-main-2, weight: "black", type)
      #v(0.5cm, weak: true)
      #text(size: title-main-4, subtype)
      #if course-unit != "" {
        v(1cm, weak: true)
        text(size: title-main-4, weight: "bold", course-unit)
        v(1cm, weak: true)
      } else {
        v(2cm, weak: true)
      }
      #((..authors.map(author => text(size: title-main-2, author.name + ", " + author.number + ", " + author.course))).join(v(1em, weak: true)))
      #if group != "" {
        v(1cm, weak: true)
        text(size: title-main-2, weight: "bold", "Grupo: ")
        text(size: title-main-2, group)
        v(1cm, weak: true)
      } else {
        v(2cm, weak: true)
      }
      #((
        ..supervisors.enumerate().map(((i, supervisor)) => {
          let prefix = if i == 0 { supervisor-label } else { cosupervisor-label }
          text(size: title-main-2, weight: "bold",
            prefix + ": "
          )
          text(size: title-main-2,
            supervisor
          )
        })
      ).join(v(1.2em, weak: true)))
      #v(1.2em, weak: true)
      #text(size: title-main-2,weight: "bold", if external != ""  {
        external-label + ": "
      }
      )
      #text(size: title-main-2, if external != ""  {
        external
      } else { "" }
      )
      #v(5.2em, weak: true)
      #text(size: title-main-4, department)
      #v(1em, weak: true)
      #text(size: title-main-4, "Universidade Lusófona, Centro Universitário de Lisboa")
      #v(2em, weak: true)
      #text(size: title-main-4, weight: "bold", date)
    ]))
  ]
    set text(size: 10pt)
    show link: it => {
      set text(fill: main-color)
      it
    }
    set par(spacing: 2em)
    align(bottom, [
      #h(-0.3em)
      #text(size: title2, weight: "bold", "Direitos de cópia")
      #linebreak()
      #box(height: 1cm)
      #h(-0.3em)
      #text(size: normal-text, weight: "regular", title + ", Copyright " + sym.copyright + " de " + format_authors(authors, lang) + ", Universidade Lusófona")
      #linebreak()
      #box(height: 0.4cm)
      #h(-0.3em)
      #text(size: normal-text, weight: "regular", "A Escola de Comunicação, Arquitectura, Artes e Tecnologias da Informação (ECATI) e a Universidade Lusófona (UL) têm o direito, perpétuo e sem limites geográficos, de arquivar e publicar " + copyright-phrase + " através de exemplares impressos reproduzidos em papel ou de forma digital, ou por qualquer outro meio conhecido ou que venha a ser inventado, e de a divulgar através de repositórios científicos e de admitir a sua cópia e distribuição com objectivos educacionais ou de investigação, não comerciais, desde que seja dado crédito ao autor e editor.")
    ])

  if (acknowledgements != none) {
    heading(level: 1, numbering: none, outlined: true, translation("acknowledgements"))
    [#acknowledgements]
  }

  if (lang == "pt" and abstract-pt != none) {
    heading(level: 1, numbering: none, outlined: true, translation("abstract_pt"))
    [#abstract-pt]
  }

  if (abstract-en != none) {
    heading(level: 1, numbering: none, outlined: true, translation("abstract_en"))
    [#abstract-en]
  }

  if (lang == "en" and abstract-pt != none) {
    heading(level: 1, numbering: none, outlined: true, translation("abstract_pt"))
    [#abstract-pt]
  }

  my-outline(front-matter-state, appendix-state, appendix-state-hide-parent, part-state, part-location,part-change,part-counter, main-color, lang, textSize1: outline-part, textSize2: outline-heading1, textSize3: outline-heading2, textSize4: outline-heading3, depth: toc-depth)

  if (list-of-figures) {
    my-outline-sec(translation("list-figures"), figure.where(kind: image), outline-heading3)
  }
  if (list-of-tables) {
    my-outline-sec(translation("list-tables"), figure.where(kind: table), outline-heading3)
  }

  let render-glossary() = {
    print-index(title: translation("glossary"), sorted: "up", outlined: true, used-only: not(glossary-unused))
  }

  if (glossary-data != none and list-of-acronyms and glossary-position == "front") {
    render-glossary()
    pagebreak(to: "odd", weak: true)
  }
  // Main body.
  set par(
    first-line-indent: 1em,
    justify: true,
    spacing: 0.5em
  )
  set block(spacing: 1.2em)
  show link: set text(fill: main-color)

  front-matter-state.update(x => false)
  counter(page).update(1)

  body

  if (glossary-data != none and list-of-acronyms and glossary-position == "back") {
    counter(heading).update(0)
    render-glossary()
  }

}

