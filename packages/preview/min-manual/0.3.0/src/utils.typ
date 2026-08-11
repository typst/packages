// Parses package URLs (pkg:type/namespace/name@version)
#let purl(url) = {
  if url.starts-with("pkg:") {
    url = url.match(regex("^(?:pkg:)?([^/]*)/(.*?)(?:[@:](.*))?$"))
    
    if url == none {none} else {url.captures}
  }
  else {
    url = url.replace("@", "")
    url = ("typst", ..url.split(":"))
  
    if url.len() >= 3 and not url.at(2).ends-with(regex("\d+\.\d+\.\d+")) {
      panic("Typst version must be semantic (got " + url.at(-1) + ")")
    }
    else if url.len() < 3 {url.push(none)}
    
    return url
  }
}


// Default delimiters for documentation comments
#let comment-delim = ("///", "/**", "**/")


// Provide syntax-related data
#let syntax = (
  doc-comment: ("///", "/**", "**/"),
  comment: ( "//", "/* */" ),
  arg: "name <- types -> types <required>\n  body",
  extract: ":display name: lang \"model\" => display-custom",
)


// Enables a #raw(lang) to simulate terminal windows (used in #show)
#let enable-terminal(doc) = {
  show selector.or(
    raw.where(lang: "term"),
    raw.where(lang: "terminal"),
  ): set raw(
    syntaxes: "assets/term.sublime-syntax",
    theme: "assets/term.tmTheme"
  )
  
  show selector.or(
    raw.where(lang: "term"),
    raw.where(lang: "terminal"),
  ): it => {
    import "@preview/nexus-tools:0.1.0": storage
    set text(fill: rgb("#CFCFCF"))
    
    pad(
      x: 1em,
      block(
        width: 100%,
        fill: rgb("#1D2433"),
        inset: 8pt,
        radius: 2pt,
        it
      )
    )
  }
  
  doc
}


// Enables a #raw(lang) to generate source-result boards (used in #show raw)
#let enable-example(elem) = {
  import "lib.typ": example

  show raw: set text(size: text.size)
  
  if ("eg", "example").contains(elem.lang) {example(elem.text, block: true)}
  else {elem}
}