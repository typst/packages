//
// Description: Import other modules so you only need to import the helpers
// Author     : Silvan Zahno
//
#import "boxes.typ": *
#import "constants.typ": *
#import "items.typ": *

// External Plugins
// Fancy pretty print with line numbers and stuff
#import "@preview/codelst:2.0.2": sourcecode
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *
// Glossarium for glossary
#import "@preview/glossarium:0.5.10": *
// Wordometer for word and character count
#import "@preview/wordometer:0.1.6": word-count
// add datetime support for other languages
#import "@preview/icu-datetime:0.2.2"
// List with Checkmarks
#import "@preview/cheq:0.4.0": checklist
// mermaid diagrams
#import "@preview/mmdr:0.2.2": mermaid

//-------------------------------------
// Sourcecode modifs
//
#let sourcecode = sourcecode.with(
  frame: block.with(
    fill: colors.code.bg,
    stroke: (left: 3pt + luma(80%), rest: 0.1pt + colors.code.border),
    radius: (left: 0pt, right: 4pt),
    inset: (left: 7pt, rest: 10pt),
  ),
  numbering: "1",
  numbers-style: (lno) => text(luma(210), size: 7pt, lno + h(0.3em)),
  numbers-step: 1,
  numbers-width: -1.2em,
)
// code blocks
#let init-syntaxes(doc) = {
  set raw(syntaxes: path("syntax/VHDL.sublime-syntax"))
  set raw(syntaxes: path("syntax/riscv.sublime-syntax"))
  doc
}

//-------------------------------------
// Internationalization
//

/// Get a translation in the given language
///
/// - key (string): translation key
/// - lang (string): target language id
/// - extra-i18n (dictionary, none): extra i18n languages and keys (can override default translations)
/// -> string, content
#let i18n(
  key,
  lang: "en",
  extra-i18n: none
) = {
  let langs = json("i18n-package.json")
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

/// Get the figure complement for a given object
///
/// - lang (string): target language id
/// - it (content): object of which to get the complement
/// -> content, str, auto
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

/// Get a translation for the given gender and in the given language
///
/// - gender (string): target gender id
/// - key-base (string): base translation key
/// - lang (string): target language id
/// -> content, str
#let get-gendered-label(
  gender,
  key-base,
  lang: "en",
) = {
  if gender == "feminin" {
    i18n(key-base + "-f", lang: lang)
  } else if gender == "inclusive" {
    i18n(key-base + "-i", lang: lang)
  } else {
    i18n(key-base, lang: lang)
  }
}

//-------------------------------------
// Reference helper function
//

/// Safely reference a label
///
/// Display a red question mark if the label cannot be found
///
/// - label (label): target label
/// -> content
#let myref(label) = locate(loc =>{
  if query(label,loc).len() != 0 {
    ref(label)
  } else {
    text(fill: red)[?]
  }
})

//-------------------------------------
// Sanitization helper function
//

/// Combine a dictionary with default values and check required keys
///
/// - dict (dictionary): modified values
/// - defaults (dictionary): default values
/// - required (string, array): required key(s) that must be set and not none
/// -> dictionary
#let apply-dict-defaults(
  dict,
  defaults: (:),
  required: ()
) = {
  let result = defaults + dict
  if type(required) != array {
    required = (required,)
  }
  for r in required {
    assert(
      result.at(r, default: none) != none,
      message: "Missing required field: " + r
    )
  }
  return result
}

//-------------------------------------
// Specifications
//

/// Display a full-page image
///
/// - path (path, none): image path
/// -> content
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
      rotate(
        -45deg,
        origin: center+horizon,
        text(fill: red, size: huger)[
          No page found
        ]
      )
    )
  }
}

//-------------------------------------
// Table of content
//

/// Display tables of contents, figures, tables, etc.
///
/// - tableof (dictionary): outline selection and parameters
/// - titles (dictionary): outline titles
/// - before (function, label, location, selector, none): end boundary for entries in the outlines
/// - indent (auto, length): outline indent size
/// -> content
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
      target: math.equation.where(block: true),
      indent: indent,
      depth: tableof.maxdepth,
    )
  }
}

/// Display a mini table of contents for a specific section
///
/// - after (function, label, location, selector): start boundary for entries in the outline
/// - before (function, label, location, selector): end boundary for entries in the outline
/// - addline (bool): whether to add lines before and after the outline
/// - stroke (stroke): stroke for the lines around the outline
/// - length (ratio, length): length of the lines around the outline
/// - depth (int): outline depth
/// - title (content): outline title
/// - indent (auto, length): outline indent size
/// -> content
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
    line(length: length, stroke: stroke)
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
    line(length: length, stroke: stroke)
  }
}

/// Display an outline of TODOs
///
/// - title (content): outline title
/// -> content
#let outline-todos(title: [TODOS]) = context {
  heading(numbering: none, outlined: false, title)

  let queried-todos = query(<todo>)
  let headings = ()
  let last-heading
  for todo in queried-todos {
    let headings-before = query(
      selector(heading).before(todo.location())
    )
    let new-last-heading = headings-before.last(default: none)

    if headings.len() == 0 or last-heading != new-last-heading {
      headings.push((
        heading: new-last-heading,
        todos: (todo,)
      ))
      last-heading = new-last-heading
    } else {
      headings.last().todos.push(todo)
    }
  }

  for head in headings {
    if head.heading != none {
      let number = if head.heading.at("numbering", default: none) != none {
        numbering(
          head.heading.numbering,
          ..counter(heading).at(head.heading.location())
        )
      }
      link(head.heading.location())[
        #number
        #head.heading.body
      ]
    } else [_Ungrouped_]
    [ ]
    box(width: 1fr, repeat[.])
    if head.heading != none {
      [ ]
      [#head.heading.location().page()]
    }

    linebreak()
    pad(left: 1em, head.todos.map(todo => {
      list.item(
        link(
          todo.location(),
          todo.value.body
        )
      )
    }).join())
  }
}

//--------------------------------------
// Heading shift
//

/// Display some content with a prefix in the margin
///
/// = Example
/// ```example
/// #unshift-prefix[Prefix][Body]
/// #lorem(5)
/// ```
/// shows as:
/// ```
/// PrefixBody
///       Lorem ipsum dolor sit amet
/// ```
///
/// - prefix (content): prefix in the margin
/// - content (content): main content
/// -> content
#let unshift-prefix(prefix, content) = context {
  pad(left: -measure(prefix).width, prefix + content)
}

//-------------------------------------
// Research
//
// item, item, item and item List
//

/// Always return an array of non-none elements
///
/// Panics if `arr-or-none` is neither none nor an array
///
/// - arr-or-none (array, none): array or none
/// -> array
#let _safe-array(arr-or-none) = {
  if arr-or-none == none {
    return ()
  }
  assert(
    type(arr-or-none) == array,
    message: "Expected array, got " + repr(type(arr-or-none))
  )
  return arr-or-none.filter(i => i != none)
}

/// Format a list of authors
///
/// - items (array, none): authors metadata
/// - multiline (bool): whether to show multiple authors on separate lines
/// -> content
#let enumerating-authors(
  items: none,
  multiline: false,
) = {
  let items = _safe-array(items).filter(i => "name" in i)
  let separator = if multiline and items.len() > 2 [\ ] else [, ]

  items.map(item => {
    if "affiliation" in item [#item.name#super[#item.affiliation]]
    else [#item.name]
  }).join(separator)
}

/// Format a list of people and their affiliations
///
/// - items (array, none): list of people dictionaries
/// -> content
#let enumerating-affiliation(
  items: none,
) = {
  let items = _safe-array(items)
  for (i, item) in items.enumerate(start: 1) {
    let group = if item.research_group != none [_ #item.research_group - _]
    [_#super[#i]_ #group _ #item.name __, #item.address _ \ ]
  }
}

//-------------------------------------
// Script
//
// item, item, item and item List
//

/// Format a list of items
///
/// - items (array, none): list of items
/// - bold (bool): whether to show items in bold
/// - italic (bool): whether to show items in italic
/// -> content
#let enumerating-items(
  items: none,
  bold: false,
  italic: false,
) = {
  let items = _safe-array(items)
  items.map(
    item => {
      if bold {
        item = strong(item)
      }
      if italic {
        item = text(style: "italic", item)
      }
      item
    }
  ).join[, ]
}

/// Format a list of links
///
/// - names (array): list of link texts
/// - links (array): list of link URLs
/// -> content
#let enumerating-links(
  names: none,
  links: none,
) = {
  let names = _safe-array(names)
  let links = _safe-array(links)
  links.zip(names, exact: true).map(
    ((l, n)) => link(l, n)
  ).join[, ]
}
#let listing-links(
  names: none,
  links: none,
) = {
  let names = _safe-array(names)
  let links = _safe-array(links)
  links.zip(names, exact: true).map(
    ((l, n)) => link(l, n)
  ).join[ \ ]
}

/// Format a list of email addresses
///
/// - names (array): list of email display texts
/// - emails (array): list of email addresses
/// -> content
#let enumerating-emails(
  names:  none,
  emails: none,
) = {
  let names = _safe-array(names)
  let emails = _safe-array(emails)
  enumerating-links(
    names: names,
    links: emails.map(email => "mailto:" + email)
  )
}
#let listing-emails(
  names:  none,
  emails: none,
) = {
  let names = _safe-array(names)
  let emails = _safe-array(emails)
  listing-links(
    names: names,
    links: emails.map(email => "mailto:" + email)
  )
}

//-------------------------------------
// safe-link
//

/// Safely display a link with optionally missing data
///
/// - name (content, none): display text
/// - url (string, none): url
/// -> content, none
#let safe-link(
  name: none,
  url: none,
) = {
  if url == none {
    name
  } else {
    link(
      url,
      if name == none {url}
      else {name}
    )
  }
}

//-------------------------------------
// Chapter
//

/// Display a chapter with the given heading offset and optionally prepend a mini table of contents
///
/// - heading-offset (int): heading numbering offset
/// - after (function, label, location, selector): start boundary for entries in the outline
/// - before (function, label, location, selector): end boundary for entries in the outline
/// - pb (bool): whether to add a page break between the outline and the heading
/// - minitoc-title (content): title of the outline
/// - body (content): the chapter's body
/// -> content
#let add-chapter(
  heading-offset: 0,
  after: none,
  before: none,
  pb: false,
  minitoc-title: i18n("toc-title", lang: "en"),
  body
) = {
  if (after != none and before != none) {
    minitoc(title: minitoc-title, after: after, before: before, indent: auto)
    if pb {
      pagebreak()
    }
  }
  set heading(offset: heading-offset)

  body

  set heading(offset: 0)
}

//-------------------------------------
// Sustainable development goals
//

/// Display a sustainable development goal icon
///
/// - goal (int, str): goal id (between 1 and 17 incl.)
/// - size (length): icon size
/// -> content
#let sdg(
  goal,
  size: 5cm,
) = {
  if goal != none {
    let num = int(goal)
    assert(
      num >= 1 and num <= 17,
      message: "SDG goal must be between 1 and 17, but got " + str(goal)
    )
    let goal-str = if num < 10 { "0" + str(num) } else { str(num) }

    context {
      let path-prefix = i18n("sdg-path", lang: text.lang)
      image(path-prefix + goal-str + ".svg", width: size, height: size)
    }
  }
}

/// Merge two or more dictionaries (recursively for nested dictionaries)
///
/// - base (dictionary): base dictionary
/// - extras (dictionary): additional dictionaries to recursively merge on top of `base`
/// -> dictionary
#let merge-dicts(base, ..extras) = {
  assert(type(base) == dictionary)
  let merged = base
  for extra in extras.pos() {
    assert(type(extra) == dictionary)
    for (key, value) in extra {
      if key in merged and type(merged.at(key)) == dictionary and type(value) == dictionary {
        value = merge-dicts(merged.at(key), value)
      }
      merged.insert(key, value)
    }
  }
  return merged
}
