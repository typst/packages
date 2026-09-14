// Minimal Manuals
// TODO: Implement web manual when HTML become stable

#import "comments.typ": parse as from-comments
#import "markdown.typ": parse as from-markdown
#import "@preview/nexus-tools:0.1.0": comp.url, comp.pkg, comp.callout

/** #v(1fr) #outline() #v(1.2fr) #pagebreak() #import "utils.typ": syntax
= Quick Start
```typ
#import "@preview/min-manual:0.3.0": manual
#show: manual.with(
  title: "Package Name",
  manifest: toml("typst.toml"),
)
```

= Description

Create modern and elegant manuals with a clean visual style and a focus on
maintaining attention on the document's content. This package seeks a balance
between new visual trends and the traditional simplicity of older manuals:
there are no abstract designs, colorful sections, diverse themes, or anything
that steals the focus; however, it adopts modern fonts, pleasant spacing, text
layout inspired by web pages, as well as automation tools and practical features.

This was created with Typst in mind, but also aiming for the potential to
universally document code from other languages: all the features of _min-book_
are supported when documenting any type of program or code.

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
    /// `"@namespace/name:version"  "pkg:type/namespace/name@version"`\
    ///  Package identification (see @id section). |
  authors: none, /// <- string | array of strings <required>
    /// `"name <url>"`\ Package authors, each followed by an optional `<url>`. |
  license: none, /// <- string | content <required>
    /// Package license. |
  url: none, /// <- string | content
    /// Package URL. |
  logo: none, /// <- image | content
    /// Manual logo. |
  manifest: none, /// <- toml | dictionary
    /// Retrieve essential data from _typst.toml_ package manifest. |
  typst-defaults: false, /// <- boolean
    /// Use Typst defaults instead of min-manual defaults. |
  from-comments: none, /// <- string | read
    /// Retrieve documentation from comments in source code files. |
  from-markdown: none, /// <- string | read
    /// Retrieve documentation from markdown files (experimental). |
  comment-delim: auto, /// <- array of strings
    /// #raw(repr(syntax.doc-comment))\ Set documentation comment delimiters. |
    /// <comment-delim>
  body,
) = context {
  import "@preview/nexus-tools:0.1.0": storage, default, get
  import "comments.typ"
  import "markdown.typ"
  import "utils.typ"
  
  let comment-delim = get.auto-val(comment-delim, utils.comment-delim)
  let description = description
  let package = package
  let authors = authors
  let license = license
  let url = url
  
  // Retrieve data from typst.toml manifest
  if manifest != none {
    assert.eq(
      type(manifest), dictionary,
      message: "#manual(manifest) must be dictionary"
    )
    description = manifest.package.at("description", default: description)
    package = manifest.package.name + ":" + manifest.package.version
    authors = manifest.package.at("authors", default: authors)
    license = manifest.package.at("license", default: license)
    url = manifest.package.at("repository", default: url)
  }
  
  // Check required arguments
  assert.ne(package, none)
  assert.ne(title, none)
  assert.ne(authors, none)
  assert.ne(license, none)
  
  storage.add("typst-defaults", typst-defaults, namespace: "min-manual")
  storage.add("comment-delim", comment-delim, namespace: "min-manual")
  
  set text(
    ..default(when: text.size == 11pt, value: (size: 13pt), typst-defaults)
  )
  
  context {
    /** #pagebreak()
    == Package Identification <id>
    ```
    @namespace/name:version
    ```
    ```
    pkg:type/namespace/name@version
    ```
    The package identification can be done through an Typst import or a #url(
    "https://github.com/package-url/purl-spec/blob/main/README.rst#purl")[
    package URL]; both are ways to reliably identify and locate packages, but
    the latter works in a mostly universal and uniform way across dofferent
    programming languages, package managers, packaging conventions, tools, APIs
    and databases.
    
    The Typst import consists of the following components:
    
    @namespace/ <- nothing
      Typst namespace; can be omitted if it's `@preview/`.
      
    name: <- nothing <required>
      Typst package name.
      
    version <- nothing
      Typst package version.
    
    The package URL used is a custom implementation that consists of the
    following components:
    
    pkg: -> nothing <required>
      Package URL scheme
    
    type/ <- nothing
      Package protocol, platform, manager, etc.
    
    namespace/ <- nothing
      Additional prefix to the name, generally used for desambiguity.
    
    name@ <- nothing <required>
      Package name.
    
    version <- nothing
      Package version.
    **/
    let data = utils.purl(package)
    let authors = authors
    let by = by
    let font = (font: ("tex gyre heros", "arial"))
    
    assert.ne(data, none, message: "Invalid #manual(package): " + package)
    
    if type(authors) == str {authors = (authors,)}
    if by == none {by = authors.at(0).replace(regex("\s*<.*>\s*"), "")}
    
    set document(
      title: (title, description).join(" - "),
      author: by,
    )
    set text(
      ..default(
        when: text.font == "libertinus serif",
        value: font,
        typst-defaults
      ),
      ..default(
        when: text.size == 11pt,
        value: (size: 13pt),
        typst-defaults
      ),
      hyphenate: true,
    )
    set page(
      ..default(
        when: page.margin == auto,
        value: (margin: (top: 3cm, bottom: 2cm, x: 2cm)),
        typst-defaults
      ),
      
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
    set par(
      ..default(
        when: par.justify == false,
        value: (justify: true),
        typst-defaults
      )
    )
    set terms(
      separator: [: ],
      tight: true,
      hanging-indent: 1em,
    )
    set table(
      stroke: gray.lighten(60%),
      inset: 10pt,
      align: (_,y) => if y == 0 { center } else { left },
      fill: (_,y) => if y == 0 {gray.lighten(85%)} else {none},
    )
    set rect(
      inset: 0pt,
      outset: 5pt,
      stroke: 1pt + gray.lighten(60%),
    )
    
    show heading: it => {
      set text(
        ..default(
          when: text.font == "libertinus serif",
          value: (title: font),
          typst-defaults
        ),
        hyphenate: false
      )
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
    show selector.or(
      raw.where(lang: "eg"),
      raw.where(lang: "example"),
    ): it => {
      import "lib.typ": example
      
      pad(left: -1em, example(it.text, block: true))
    }
    /** = Syntax
    == Terminal Simulation
    ````markdown
    ```terminal
    prompt$ command
    output
    ```
    ````
    Generates a generic terminal simulation, with syntax highlight for prompt,
    command, and output. It is implemented as `#raw(lang: "terminal")`, and also
    available under the shorter `"term"` name. The syntax detects key characters
    (yellow) and sets everything at its left as prompt (green) and at its right
    as command (red); lines without key characters are considered output (white).
    ```terminal
    usr@host ~ % command (zsh)
    usr@host:~$ command (bash)
    usr@host:~# command (root)
    C:\> command (windows)
    output
    ```
    **/
    show selector.or(
      raw.where(lang: "term"),
      raw.where(lang: "terminal"),
    ): set raw(
      syntaxes: "assets/term.sublime-syntax",
      theme: "assets/term.tmTheme"
    )
    show selector.or(
      raw.where(lang: "term", block: true),
      raw.where(lang: "terminal", block: true),
    ): it => {
      set text(fill: rgb("#CFCFCF"))
      
      pad(
        right: 1em,
        block(
          width: 100%,
          fill: rgb("#1D2433"),
          inset: 8pt,
          radius: 2pt,
          it
        )
      )
    }
    show <min-manual:example-cmd>: it => {
      if type(it) == content and it.func() == raw {it = pad(left: -1em, it)}
      it
    }
    show raw.where(block: true): it => pad(left: 1em, it)
    show raw: set text(size: text.size)
    show footnote.entry: set text(size: text.size - 2pt)
    show selector.or(
      terms, enum, table, figure, list,
      quote.where(block: true),
      raw.where(block: true),
    ): set block(
      above: par.spacing + 0.3em,
      below: par.spacing + 0.3em
    )
    show ref: it => {
      if it.citation.supplement == none {link(locate(here()), it.element.body)}
      else {it}
    }
    show outline: it => align(center, block(width: 80%, align(left, it)))
    
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
      data = data.map(item => {if item != none {h(1fr) + item + h(1fr)}})
      
      block(width: 90%, data.join())
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


/// = Commands


/**
== Arguments
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
  assert.eq(type(title), str, message: "#arg(title) must be string")
  assert.ne(body, [], message: "#arg(body) should not be empty: " + title)
  
  let required = title.match(regex("<([^<]+?)>\s*$"))
  let output = false
  let display = ""
  let types = ()
  let title = title
  let body = body
  let ignored = (none, "", "nothing")
  let parts
  let name
  
  if title.contains("<-") {display = "i"}
  if title.contains("->") {display = display + "o"}
  
  title = title.replace(regex("<([^<]+)>\s*$"), "")  // removes any <required>
  parts = title.split(regex("<-|->"))
  name = parts.at(0).trim() + " "
  
  if name == "" {panic("Argument name required: " + title)}
  
  // Split input and output types
  for part in parts.slice(1) {
    part = part.replace(regex("\s*\|\s*"), "|").trim()
    part = if part == "nothing" {(none,)} else {part.split("|")}
    
    types.push(part)
  }
  
  if types.len() > 2 {panic(title + " has multiple '->' or '<-' arrows")}

  // Show name as raw
  if name.contains(regex("`.*`")) {name = eval(name, mode: "markup")}
  else if type(name) == str {name = raw(name)}
  
  title = ()
  title.push(strong(name) + " ")
  
  // Manages input types
  if display.contains("i") {
    let input = ()
    
    for type in types.at(0) {
      if not ignored.contains(type) {
        input.push(
          box(
            fill: luma(225),
            inset: (x: 3pt, y: 0pt),
            outset: (y: 3pt),
            type
          ) + " "
        )
      }
    }
    title.push(input.join())
  }
  
  // Manages output types
  if display.contains("o") {
    let output = ()
    let n = if display.contains("i") {1} else {0}
    
    // Insert output arrow
    if not ignored.contains(types.at(n).at(0)) { title.push(sym.arrow.r + " ") }
    
    for type in types.at(n) {
      if not ignored.contains(type) {
        output.push(
          box(
            fill: luma(230),
            inset: (x: 3pt, y: 0pt),
            outset: (y: 3pt),
            type
          ) + " "
        )
      }
    }
    title.push(output.join())
  }
  
  // Grid for name and types
  title = ( grid(columns: title.len(), ..title) ,)
  
  // Add required to current title
  if required != none {
    required = emph("(" + required.captures.at(0) + ")")
    
    title.push(align(right, required))
  }
  
  // Grid for current title and required
  title = grid(columns: (1fr, auto), align: left, ..title)
  
  // Left-padded body
  if body != [] {body = pad(left: 1em, body)}
  
  body = [
    #{
      set par(justify: false)
      title
    }
    #context v(-par.leading * 0.5)
    #body
  ]
  
  block(
    breakable: false,
    fill: luma(245),
    width: 100%,
    outset: 5pt,
    body
  )
}


/**
== Extract
:extract:
Extract code from another file or location (see `/tests/commands/extract/`).
**/
#let extract(
  name, /// <- string
    /// Name of the code structure to retrieve (uses last match). |
  from: auto, /// <- string | read <required>
    /// File from where the code will be retrieved (required in the first use). |
  display: auto, /// <- string
    /** `"show.with"  "show"  "call"  "set"  "str"  "src"  "arg"  "let"`\
        How to render the code retrieved: as one of the predefined Typst cases
        above, or an arbitrary template that interpolates `<name>`, `<capt>`,
        and `<text>` as the name, last capture, and last retrieved text, respectively. |**/
  lang: "typ", /// <- string
    /// Programming language of the code. |
  model: auto, /// <- string
    /** `"func"  "arg"  "let"  "var"  "call"`\
        Regex pattern to retrieve code: one of the predefined names above, or
        a custom pattern (spaces before code normalizes indentation). |**/
) = context {
  import "@preview/nexus-tools:0.1.0": storage
  import "utils.typ"
  
  let from = from
  let model = model
  let display = display
  let lang = lang
  let std-models = (
    "func": "(?s)\s*#?let\s+<name>(\(<matching>\))\s*=",
    "call": "(?s)\s*#?<name>(?:\.with)?\((<matching>)\)",
    "let": "(?s)\s*#?let\s+<name>\s*=\s*(\(<matching>\)|.*?\n)",
    "var": "(?s)\s*#?\s+<name>\s*=\s*(\((?:\(<matching>\)|.)*?\)|.*?\n)",
    "arg": "(?s)\s*<name>\s*:\s*(\((?:\(<matching>\)|.)*?\)|.*?)(?:,.*)?(?:\n|$)",
  )
  let std-cases = (
    "show.with": "#show: <name>.with(<capt>)",
    "show": "#show: <doc> => <name>(<capt>)",
    "call": "#<name>(<capt>)",
    "set": "#set <name>(<capt>)",
    "str": "<capt>",
    "src": "<text>",
    "arg": "<name>: <capt>",
    "let": "#let <name> = <capt>",
  )
  let comments = storage.get("comment-delim", namespace: "min-manual")
  let capt-delim = true
  let matching = ()
  let matches
  let capt
  let indent
  
  // Retrieve #extract(from) when not given
  if from == auto {from = storage.get("extract-from", namespace: "min-manual")}
  else {storage.add("extract-from", from, namespace: "min-manual")}
  
  assert.ne(from, none, message: "#extract(from) required")
  
  if display == auto {
    if not lang.contains("typ") {panic("#extract(display) required for " + lang)}
    
    // Set default #extract(display) based on #extract(model) used
    display = if ("arg", "let").contains(model) {model} else {"call"}
  }
  
  if model == auto {
    if not lang.contains("typ") {panic("#extract(model) required for " + lang)}
    
    // Set default #extract(model) based on #extract(display) used
    model = if ("arg", "let").contains(display) {display} else {"func"}
  }
  
  // Adjust code highlight for #extract(display: "arg")
  if lang == "typ" and display == "arg" {lang = "typc"}
  
  if model == "func" {capt-delim = false}
  
  // Use default Typst cases and extraction models.
  if std-cases.keys().contains(display) {display = std-cases.at(display)}
  if std-models.keys().contains(model) {model = std-models.at(model)}
  
  // Set matching characters
  if model.contains("<matching>") {
    matching = model
      .match(regex("\\\\?.<matching>\\\\?.")).text
      .replace("\\", "")
      .split("<matching>")
    model = model.replace("<matching>", ".*")
  }
  
  model = model.replace("<name>", name)
  matches = from.matches(regex(model))
  
  assert(
    matches != () and matches.last().captures != (),
    message: "Could not extract '" + name + "' using model '" + model + "'"
  )
  
  // Get additional indentation (if any) from capture begin
  indent = matches.last().text
    .trim("\n")
    .match(regex("^[ \t]*")).text
    .len()
  
  capt = matches.last().captures.at(0)
    .replace(regex("(?m)^[ \t]{" + str(indent) + "}"), "")
  
  // Get matching characters
  if matching != () and capt.contains(matching.at(0)) {
    let clusters = capt.clusters()
    let count = 0
    let end = 0
    
    for (i, char) in clusters.enumerate() {
      if char == matching.at(0) {
        // Opening character
        count += 1
      }
      else if char == matching.at(1) {
        // Closing character
        count -= 1
        if count == 0 {
          end = i + 1
          break
        }
      }
    }
    
    assert.ne(end, 0)
    
    capt = clusters.slice(0, end).join()
  }
  
  // Remove documentation comments
  if comments != none {
    import "comments.typ": esc
    
    comments = comments.map(item => {esc(item)})
    comments = comments.at(0) + ".*|(?s)" + comments.slice(1, 3).join(".*?")
    
    capt = capt.replace(regex(comments), "")
    display = display.replace(regex(comments), "")
  }
  
  if not capt-delim {capt = capt.trim(regex("[()]"))}
  
  display = display
    .replace("<name>", name)
    .replace("<capt>", capt)
    .replace("<text>", matches.last().text)
  
  // Normalize captured code
  display = display
    .replace(regex("^\s*\n+"), "\n") // trim and start with just one \n
    .replace(regex("\n\s*\n"), "\n") // remove blank lines
    .replace(regex("\n+\s*$"), "\n") // trim and end with one \n
  
  
  if display.starts-with(regex("\s*#?show:")) {
    let pos = capt.split(",").filter(it => it.contains(regex("^\s*[^\s:]+\s*$")))
    
    assert.ne(
      pos, (),
      message: "Could not find positional arguments in '" + name + "'"
    )
    
    if display.contains(".with(") {
      display = display.replace(regex("\s*" + pos.last().trim() + ",?.*?"), "")
    }
    else {
      display = display.replace("<doc>", pos.last().trim())
    }
  }
  else if display.starts-with(regex("#?set")) {
    let pos = capt.split(",").filter(it => it.contains(regex("^\s*[^\s:]+$")))
    let re = "\s*(?:" + pos.map(it => it.trim()).join("|") + "),?.*?"
    
    display = display.replace(regex(re), "")
  }
  
  // Show final output
  raw(display, lang: lang, block: true)
}


/**
== Code Example
:example:
Generates a code example that showcases its result. If only a Typst code is
passed, the result is automatically generated. Can also be used as
`#raw(lang: "example")` syntax for Typst codes; a shorter `"eg"` is also available.
**/
#let example(
  scope: auto, /// <- dictionary | yaml | toml
    /// Additional scope available when generating Typst results. |
  output-align: auto, /// <- top | bottom | left | right | false
    /// Position of result block. |
  ..data /// <- raw | string
    /// `(code, result)`\
    /// Positional arguments for code and optional result. |
) = {
  import "@preview/nexus-tools:0.1.0": storage, get
  import "lib.typ"
  
  // #layout allows to calc 50% of content width
  layout(page-size => {
    let data = data.pos()
    let code = data.at(0, default: none)
    let out = data.at(1, default: none)
    let output-align = output-align
    let scope = dictionary(lib) + get.auto-val(scope, (:))
    let cols = (auto,)
    let lang
    let first
    let last
    
    if type(code) == str {code = raw(code, block: true)}
    if type(code) != content {panic("#example(code) must be #raw or string")}
    
    assert(data.len() <= 2, message: "#example expects only 2 arguments")
    assert(code.func() == raw, message: "#example(code) must be #raw or string")
    
    lang = code.at("lang", default: "typ")
    
    set raw(lang: lang)
    set grid.cell(inset: 1em)
    
    if not lang.contains("typ") and out == none {
      panic("Provide both #example(code, output) options, or Typst code")
    }
    
    // Evaluate output from Typst code
    if output-align != false and out == none {
      out = eval(code.text, mode: "markup", scope: scope)
    }
  
    if output-align == auto {
      let code-width = measure(code).width
      let page-width = page-size.width * 50%
      
      output-align = if code-width >= page-width {bottom} else {right}
    }
    
    code = [#code <min-manual:example-cmd>]
    out = [#out <min-manual:example-cmd>]
    code = grid.cell(code)
    out = grid.cell(out, stroke: gray.lighten(60%))
    
    // Set grid data
    if (left, top).contains(output-align) {
      first = out
      last = code
    }
    else if (right, bottom).contains(output-align) {
      first = code
      last = out
    }
    else {
      panic("Invalid #example(alignment: " + str(alignment) + ")")
    }
    
    // Set grid column number and width
    if output-align == right {cols.push(1fr)}
    else if output-align == left {cols.insert(0, 1fr)}
    else {cols = (1fr,)}
    
    set grid(stroke: if cols.len() == 1 {gray.lighten(80%)} else {none})
    
    block(grid(columns: cols, first, last))
  })
}


/**
== Paper-friendly URL
```typ
#url(target, id, text)
```
Creates a paper-friendly link, attached to a footnote containing the URL itself
to ensure readability in paper.

target <- string | label <required>
  URL used as link and footnote, or  or label referencing a previous `#url` command.

id <- label
  Optional label for further reference.
  
text <- string | content
  Text shown as link (fallback to the URL).

== Callout
```typ
#callout(
  icon: "information-circle",
  title: none,
  text: (:),
  background: (:),
  body,
)
```
Create a simple yet highly customizable callout box, used to highlight a text or
showcase important content.

icon: <- string
  Icon name, as set by #url("https://heroicons.com/")[Heroicons].

title: <- string | content | none
  Set title, if any.

text: <- color | dictionary
  Text (`#text`) options; the special `text.title` set title options.

background: <- color | dictionary
  Background style (`#block`) options.

== Package URLs
```typ
#pkg(url)
#univ(name)
#pip(name)
#crate(name)
#npm(name)
#gh(slug)
```
Generates paper-friendly links to packages from different sources/platforms
requiring only essential data. Supports generic packages, Typst Universe, Python
Pypi, Rust crates, Node.js npm, GitHub repositories.

url <- string
  `"https://repo.com/{name}/download"  "https://repo.com/name"`\
  Package URL. Extracts the package name between `{}` or as the last `/slug`.

name <- string
  Package name as it appears in the package source/platform.

slug <- string
  The `user/repo` slug of the GitHub repository URL.
**/


// Typst packages (Typst Universe)
#let univ(name, ..args) = {
  if type(name) == str {name = "https://typst.app/universe/package/" + name}
  pkg(name, ..args)
}

// Python packages (PyPi/Pip)
#let pip(name, ..args) = {
  if type(name) == str {name = "https://pypi.org/project/" + name}
  pkg(name, ..args)
}

// Rust packages (crates.io)
#let crate(name, ..args) = {
  if type(name) == str {name = "https://crates.io/crates/" +name}
  pkg(name, ..args)
}

// Node.js packages (npm)
#let npm(name, args) = {
  if type(name) == str {name = "https://www.npmjs.com/package/" + name}
  pkg(name, ..args)
}

// GitHub repositories
#let gh(slug, ..args) = {
  if type(slug) == str {slug = "https://github.com/" + slug}
  pkg(slug, ..args)
}

/**
= Alternative Sources
**/