// NAME: Minimal Manuals
// TODO: Implement web manual (HTML) when stable

#import "comments.typ": parse as from-comments
#import "markdown.typ": parse as from-markdown


/**
#v(1fr)
#outline()
#v(1.2fr)
#pagebreak()

= Quick Start

```typm
#import "@preview/min-manual:0.2.1": manual
#show: manual.with(
  title: "Package Name",
  description: "Short description, no longer than two lines.",
  package: "pkg-name:0.4.2",
  authors: "Author <mailto:author@email.com>",
  license: "MIT",
  logo: image("assets/logo.png")
)
```

= Description

Generate modern manuals without losing the simplicity of old manpages. This
package draws inspiration from old manuals while adopting the facilities of
modern tools, like Markdown and documentation embedded in comments. The design
aims to be sober: a minimal informative header, technical text in comfortable
fonts and well-formatted code examples.

The package was created with Typst in mind, but also targeting the potential
to universally document code from other languages: all _min-book_ features are
supported when documenting any type of program or code.

= Options
:show.with manual:
**/
#let manual(
  title: none, /// <- string | content <required>
    /// Descriptive name of the package (what is being documented). |
  description: none, /// <- string | content
    /// Short package description, generally two lines long or less. |
  by: none, /// <- string | content
    /// Manual author (fallback to `authors.at(0)` if not set). |
  package: none, /// <- string <required>
    /** `"pkg:type/namespace/name@version"` \ 
    Package identification,#footnote[Inspired by
    _#link("https://github.com/package-url/purl-spec/blob/main/README.rst#purl",
    "https://github.com/package-url/purl-spec/")_] where `pkg:type/namespace/` is
    optional (fallback to `pkg:typst/`) and `name@version` can also be written
    `name:version`. |**/
  authors: none, /// <- string | array of strings <required>
    /** `"name <url>"` \
    Package author or authors, each followed by an optional `<url>`. |**/
  license: none, /// <- string | content <required>
    /// Package license. |
  url: none, /// <- string | content
    /// Package URL. |
  logo: none, /// <- image | content
    /// Manual logo. |
  use-defaults: false, /// <- boolean
    /// Use Typst defaults instead of min-manual defaults. |
  from-comments: none, /// <- string | read
    /// Retrieve documentation from comments in source files. |
  from-markdown: none, /// <- string | read
    /// Retrieve documentation from markdown files (experimental). |
  comment-delim: auto, /// <- array of strings
    /** #raw(`("///", "/.**", "**./")`.text.replace(".", "")) \
    Set documentation comment delimiters. |**/
  body,
) = context {
  // Check required arguments
  assert.ne(package, none)
  assert.ne(package, "")
  assert.ne(title, none)
  assert.ne(authors, none)
  assert.ne(license, none)
  
  import "utils.typ"
  import "comments.typ"
  import "markdown.typ"
  
  let comment-delim = utils.defs.at("comment-delim")
  
  utils.storage(add: "use-defaults", use-defaults)
  utils.storage(add: "comment-delim", comment-delim)
  utils.storage(add: "raw-padding", true)
  
  set text(..utils.def(text.size == 11pt, "size", use-defaults))
  
  context {
    let data = utils.purl(package)
    let authors = authors
    let by = by
    
    if type(authors) == str {authors = (authors,)}
    if by == none {by = authors.at(0).replace(regex("\s*<.*>\s*"), "")}
    
    set document(
      title: (title, description).join(" - "),
      author: by,
    )
    set text(
      ..utils.def(text.font == "libertinus serif", "font"),
      ..utils.def(text.size == 11pt, "size"),
      hyphenate: true,
    )
    set page(
      ..utils.def(page.margin == auto, "margin"),
      
      header: context if locate(here()).page() > 1 {
        text(size: text.size - 2pt, align(right, data.at(1)))
      },
      
      footer: context if locate(here()).page() > 1 {
        set text(size: text.size - 2pt)
        
        let final-page = locate(here()).page() == counter(page).final().at(0)
        let left = []
        let middle = counter(page).display("1/1", both: true)
        let right = []
        
        if final-page {left = [Created with _min-manual_]}
        if final-page {right = [Written by #by]}
        
        grid(
          columns: (1.2fr, 1fr, 1.2fr),
          align: center,
          left, middle, right,
        )
      }
    )
    set par(..utils.def(par.justify == false, "justify"))
    set terms(
      separator: [: ],
      tight: true,
      hanging-indent: 1em,
    )
    set table(
      stroke: gray.lighten(60%),
      inset: 10pt,
      align: (_,y) => (
        if y == 0 { center }
        else { left }
      ),
    )
    set rect(
      inset: 0pt,
      outset: 5pt,
      stroke: 1pt + gray.lighten(60%),
    )
    
    show heading: it => {
      let test = ("libertinus serif", utils.defs.font).contains(text.font)
      
      set text(..utils.def(test, "font.title"), hyphenate: false)
      set block(above: 1.5em, below: par.leading)
      
      it
    }
    show heading.where(level: 1): set text(size: text.size * 2)
    show heading.where(level: 2): set text(size: text.size * 1.6)
    show heading.where(level: 3): set text(size: text.size * 1.4)
    show heading.where(level: 4): set text(size: text.size * 1.3)
    show heading.where(level: 5): set text(size: text.size * 1.2)
    show heading.where(level: 6): set text(size: text.size * 1.1)
    show table: set align(center)
    show quote.where(block: true): it => pad(x: 1em, it)
    show raw.where(block: true): it => context {
      if utils.storage(get: "raw-padding", false) {pad(left: 1em, it)} else {it}
    }
    show raw: it => {
      set text(
        ..utils.def(text.lang == "dejavu sans mono", "font.raw"),
        size: text.size + 1pt
      )
      utils.enable-example(it)
    }
    show footnote.entry: set text(size: text.size - 2pt)
    show selector.or(
      terms, enum, table, figure, list,
      quote.where(block: true), raw.where(block: true),
    ): set block(above: par.spacing + 0.3em, below: par.spacing + 0.3em)
    show ref: it => {
      if it.citation.supplement == none {link(locate(here()), it.element.body)}
      else {it}
    }
    show outline: it => align(center, block(width: 80%, align(left, it)))
    show: utils.enable-term
    
    // Main header:
    align(center, {
      if logo != none {block(logo, height: 4em)}
      
      v(-2.5em)
      heading(title, level: 1, outlined: false)
      
      text(size: text.size * 1.5)[Manual]
      linebreak()
      
      set text(size: text.size + 2pt)
      
      v(0pt)
      if description != none {description}
      line(length: 90%)
      v(0pt)
      
      set footnote(numbering: "*")
      
      if url != none {data.at(1) = link(url)[#data.at(1)#footnote(url)]}
      
      data.push(license)
      
      block(width: 90%, data.map(item => {
        if item != none {
          h(1fr)
          item
          h(1fr)
        }
      }).join())
      v(1em)
      
      for author in authors {
        let name = author.find(regex("^[^<]*"))
        let url = author.find(regex("<(.*)>"))
        let content = ()
        
        if name != none {
          name = name.trim()
          
          // Insert author URL
          if url != none {
            url = url.trim(regex("[<> ]"))
            
            // Insert GitHub URL when <@user> is used
            if url.starts-with("@") {url = "https://github.com/" + url.slice(1)}
            
            content.push(link(url, name))
            content.push(footnote(link(url)))
          }
          else {content.push(name)}
          
          content.join() + "\n"
        }
        else {panic("Could not find author name in '" + authors + "'")}
      }
      v(3em, weak: true)
    })
    
    counter(footnote).update(0)
    
    comments.parse(from-comments, comment-delim)
    markdown.parse(from-markdown)
    
    body
  }
}


/** #pagebreak()
= Command Arguments
:arg:
Defines and explains possible arguments/parameters (see `/tests/commands/arg/`).
**/
#let arg(
  title, /// <- string <required>
    /** `"name <- type | type -> type <required>"` \
    Title data: A mandatory name identifier, followed by optional ASCII arrows
    indicating input/output types, and a final `<required>` to define required
    arguments. |**/
  body
) = context {
  assert.ne(body, [], message: "#arg(body) should not be empty: " + title)
  
  // TODO: Allow other "required" texts — useful for other languages
  let required = title.contains("<required>")
  let output = false
  let display = ""
  let types = ()
  let title = title
  let body = body
  let ignored = (none, "", "nothing")
  let parts
  let name
  let width
  
  // Remove any <required> from title, if any
  title = title.replace("<required>", "")
  
  if title.contains("<-") {display = "i"}
  if title.contains("->") {display = display + "o"}
  
  parts = title.split(regex("<-|->"))
  name = parts.at(0).trim() + " "
  width = if display == "o" {" " + sym.arrow.r + " "} else {""}
  width = measure(name + width).width + 2pt
  
  if name == "" {panic("Argument name required: " + title)}
  
  //Set types, if any
  for part in parts.slice(1) {
    part = part.replace(regex("\s*\|\s*"), "|").trim()
    part = if part == "nothing" {(none,)} else {part.split("|")}
    
    types.push(part)
  }
  if types.len() > 2 {panic("There should be only one of each '<-' and '->' in " + title)}

  // Show name as raw
  if name.contains(regex("`.*`")) {name = eval(name, mode: "markup")}
  else if type(name) == str {name = raw(name)}
  
  title = (strong(name) + " ",)
  if display.contains("i") {
    for type in types.at(0) {
      if not ignored.contains(type) {
        title.push(
          box(
            fill: luma(225),
            inset: (x: 3pt, y: 0pt),
            outset: (y: 3pt),
            type
          ) + " "
        )
      }
    }
  }
  if display.contains("o") {
    let n = if display.contains("i") {1} else {0}
    
    if not ignored.contains(types.at(n).at(0)) {title.push(sym.arrow.r + " ")}
    
    for type in types.at(n) {
      if not ignored.contains(type) {
        title.push(
          box(
            fill: luma(230),
            inset: (x: 3pt, y: 0pt),
            outset: (y: 3pt),
            type
          ) + " "
        )
      }
    }
  }
  if required { title.push( box(width: 1fr, align(right)[(_required_)]) ) }
  
  if body != [] {body = pad(left: 1em, body)}
  
  block(
    breakable: false,
    fill: luma(245),
    width: 100%,
    outset: 5pt,
    [
      #par(hanging-indent: width, title.join())
      #context v(-par.leading * 0.5)
      #body
    ]
  )
}


/**
= Command Extract
:extract:
Extract code from another file or location (see `/tests/commands/extract/`).
**/
#let extract(
  name, /// <- string
    /// Name of the code structure to retrieve (the last match is used). |
  from: auto, /// <- string | read <required>
    /// File from where the code will be retrieved (required in the first use). |
  rule: none, /// <- "show.with" | "show" | "call" | "set" | "let" | "arg" | "str" | none
    /// Render Typst code in different ways. |
  lang: "typ", /// <- string
    /// Programming language of the code. |
  model: auto, /// <- string
    /** Custom regex pattern to retrieve code — spaces captured before the
    code are used to normalize indentation. |**/
  display: none, /// <- string
    /** Custom way to render retrieved code. Replaces `<name>` and `<capt>`
        markers by the name and retrieved code, respectively. |**/
) = context {
  import "utils.typ"
  
  let from = from
  
  
  if from == auto {from = utils.storage(get: "extract-from", none)}
  else {utils.storage(add: "extract-from", from)}
  
  // Required named arguments
  assert.ne(from, none, message: "#extract(from) required")
  
  import "utils.typ"
  
  let std-models = (
    "show.with": "(?s)\s*#?let\s+<name>\((.*?)\)\s*=",
    "show": "(?s)\s*#?let\s+<name>\((.*?)\)\s*=",
    "call": "(?s)\s*#?let\s+<name>\((.*?)\)\s*=",
    "set": "(?s)\s*#?let\s+<name>\((.*?)\)\s*=",
    "str": "(?s)\s*#?let\s+<name>\((.*?)\)\s*=",
    "arg": "(?s)\s*<name>\s*:\s*(\(.*?\n\)|.*?)(?:\n|$)",
    "let": "(?s)\s*#?let\s+<name>\s*=\s*(\((?:\(.*?\)|.)*?\)|.*?\n)",
  )
  let rule = if rule == none {"call"} else {rule}
  let model = if model == auto {std-models.at(rule)} else {model}
  let comments = utils.storage(get: "comment-delim")
  let model = model.replace("<name>", name)
  let from = from.matches(regex(model))
  let indent
  let code
  let capt
  
  if not lang.contains("typ") {rule = str}
  
  if from != () and from.last().captures != () {capt = from.last().captures.at(0)}
  else {panic("Could not extract '" + name + "' using '" + model + "'")}
  
  if comments != none {
    import "comments.typ": esc
    
    comments = comments.map(item => {esc(item)})
    comments = comments.at(0) + ".*|(?s)" + comments.slice(1, 3).join(".*?")
    capt = capt
      .replace(regex(comments), "")  // remove documentation comments
      .replace(regex("^\s*\n+"), "\n") // trim and start with just one \n
      .replace(regex("\n\s*\n"), "\n") // remove blank lines
      .replace(regex("\n+\s*$"), "\n") // trim and end with one \n
  }
  
  // Remove additional indentation
  indent = from.last().text.trim("\n").match(regex("^[ \t]*")).text.len()
  if indent > 0 {
    capt = capt.replace(regex("(?m)^[ \t]{" + str(indent) + "}"), "")
  }
  
  let end
  if rule == "show" {
    let indent = capt.trim("\n").match(regex("^[ \t]*")).text
    let nl = if capt.contains("\n") {"\n"} else {""}

    end = indent + "doc" + nl
  }
  
  /**
  When extracting Typst code, the `#extract(rule)` supply almost all use cases of
  a Typst code; otherwise, the `#extract(model, display)` options can be used to
  achieve any other desired result.
  **/
  if display != none {code = display.replace("<name>", name).replace("<capt>", capt)}
  else if rule == "show.with" {code = "#show: " + name + ".with(" + capt + ")"}
  else if rule == "show" {code = "#show: doc => " + name + "(" + capt + end + ")"}
  else if rule == "call" {code = "#" + name + "(" + capt + ")"}
  else if rule == "set" {code = "#set " + name + "(" + capt + ")"}
  else if rule == "let" {code = "#let " + name.trim() + " = " + capt}
  else if rule == "arg" {code = name + ": " + capt.trim(",")}
  else if rule == "str" {code = capt}
  else {code = capt}
  
  raw(code, lang: lang, block: true)
}


/**
= Command Code-Result Example
:example:
Generates a code-result example, consisting in a `#raw` code block and an annex
block representing the code result. If only a Typst code block is passed, the
result is automatically evaluated. Can also be used as `#raw(lang: "example")`
language to evaluate Typst codes; a shorter `"eg"` name can also be used as an
alias.
**/
#let example(
  scope: auto, /// <- dictionary | yaml | toml
    /// Define the `#eval` scope of automatic Typst results. |
  output-align: auto, /// <- top | bottom | left | right | false
    /// Set position of result block — `false` disables it. |
  ..data /// <- raw | string
    /// The code and result blocks — the optional latter can be a content block. |
) = {
  import "lib.typ"
  import "utils.typ": storage
  
  // Disable #raw 1em padding here
  storage(add: "raw-padding", false)
  
  // #layout allows to calc 50% of content width
  layout(page-size => {
    let code = data.pos().at(0, default: none)
    let code = if type(code) == str {raw(code)} else {code}
    let lang = code.at("lang", default: "typ")
    let out = data.pos().at(1, default: none)
    let output-align = output-align
    let scope = scope
    let cols = (auto,)
    let first
    let last
    
    set raw(lang: "typ")
    set grid.cell(inset: 1em)
  
    assert.ne(
      code, none,
      message: "No #raw code received: must have #example(raw)"
    )
    assert(
      not data.pos().len() > 2,
      message: "Received" + str(data.pos().len()) + "arguments (expected 2)"
    )
    
    if not lang.contains("typ") {output-align = false}
    if scope == auto {scope = (:)}
    
    // Insert min-manual in scope
    for pair in dictionary(lib).pairs() {
      scope.insert(..pair)
    }
    
    // Evaluate output from Typst code
    if output-align != false and out == none {
      out = eval("[" + code.text + "]", scope: scope)
    }
  
    if output-align == auto {
      let code-width = measure(code).width
      let page-width = page-size.width * 50%
      
      output-align = if code-width >= page-width {bottom} else {right}
    }
    
    // Check for invalid alignments
    assert(
      (top, bottom, left, right).contains(output-align),
      message: "Invalid #example(alignment): " + str(alignment)
    )
    
    // Set grid data
    if (left, top).contains(output-align) {
      first = grid.cell(out, stroke: gray.lighten(60%))
      last = grid.cell(code)
    }
    else if (right, bottom).contains(output-align) {
      first = grid.cell(code)
      last = grid.cell(out, stroke: gray.lighten(60%))
    }
    
    // Set grid column number and width
    if output-align == right {cols.push(1fr)}
    else if output-align == left {cols.insert(0, 1fr)}
    else {cols = (1fr,)}
    
    set grid(stroke: if cols.len() == 1 {gray.lighten(80%)} else {none})
    
    block(grid(columns: cols, first, last))
  })
  
  // Re-enable #raw 1em padding
  storage(add: "raw-padding", true)
}


/**
= Command URL
```typ
#url(url, id, text)
```

Creates a paper-friendly link, attached to a footnote containing the URL itself
for readability when printed.

url <- string | label <required>
  URL set to link and shown in footnote.

id <- label
  Label set to the footnote for future reference.

text <- string | content
  Text to be shown in-place as the link itself.
**/
#let url(url, ..data) = {
  h(0pt)
  
  assert(
    data.pos().len() <= 2,
    message: "Received " + str(data.pos().len() + 1) + " arguments (expected 3)"
  )
  
  let note = if type(url) == str {link(url)} else {url}
  let text = data.pos().at(-1, default: url)
  let id = data.pos().at(-2, default: [])

  link(url, emph(text))
  [#footnote(note)#id]
}


/**
== Commands for Package URLs
```typ
#pkg(url)
#univ(name)
#pip(name)
#crate(name)
#npm(name)
#gh(slug)
```
Generates paper-friendly links to packages from different sources/platforms using
only essential data like its name (see `/tests/commands/links/`).

url <- string
  Package URL (used by `#pkg`). The package name is extracted if enclosed in `{}`
  or fallback to the last `/slug` of the URL.

name <- string
  Package name as it is in the source repository/platform (used by `#pip`, 
  `#univ`, and `#crate`).

slug <- string
  A `user/name` path, as it appears in GitHub repository paths (used by `#gh`).
**/
// TODO: Enable labels in #univ, #pip, #crate, #gh
#let pkg(..data) = context {
  let data = data.pos()
  let out = ()
  let target = data.remove(0)
  let text = target
  
  // #pkg
  if data == () {
    if type(target) == label {panic("#pkg(text, label) required")}
    
    text = target.match(regex("\{.*?\}|/[^/]*?$")).text.trim(regex("[/{}]"))
    target = target.replace( regex("\{(.*?)\}"), m => {m.captures.at(0)} )
  }
  else {
    text = data.last().trim(regex(".*?/"))
    
    for m in target.matches(regex("\{.*?\}")) {
      target = target.replace(m.text, data.remove(0))
    }
  }
  
  out.push(target)
  out.push(text)
  
  //[#out]
  url(..out)
}

// Typst packages (Typst Universe)
#let univ(name) = pkg("https://typst.app/universe/package/{pkg}", name)

// Python packages (PyPi/Pip)
#let pip(name) = pkg("https://pypi.org/project/{pkg}", name)

// Rust packages (crates.io)
#let crate(name) = pkg("https://crates.io/crates/{pkg}", name)

// Node.js packages (npm)
#let npm(name) = pkg("https://www.npmjs.com/package/", name)

// GitHub repositories
#let gh(slug) = pkg("https://github.com/{path}/", slug)


/**
= Terminal Emulation
#grid(columns: (auto, 1fr),gutter: 1em,
  ````typ
    ```terminal
    ~$ command
    output
    ```
  ````,
  ```terminal
  ~$ command
  output
  ```
)
This `#raw(lang: "terminal")` language emulates a terminal window, with prompt
highlight; a shorter `"term"` name can also be used as an alias. Prompts are any
line inside the cod block that obeys a certain basic syntax (green paths are optional):
```terminal
~/path$ user command
~/path# root command
C:path> windows command
command output
```
**/