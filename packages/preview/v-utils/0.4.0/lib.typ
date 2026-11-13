#import "math.typ": *
#import "md.typ": *
#import "html.typ": *

/// Recursively extract plain text from content
#let to-string(content) = {
  if type(content) == str {
    content
  } else if content.func() == math.equation {
    "mb"
  } else if content.has("text") {
    content.text
  } else if content.has("children") {
    str(content.children.map(to-string).join(""))
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  } else {
    ""
  }
}

/// Check if content contains a math equation
#let has-math(content) = {
  if content.func() == math.equation { return true }
  if content.has("children") {
    return content.children.any(c => has-math(c))
  }
  if content.has("body") {
    return has-math(content.body)
  }
  false
}

/// Sanitize heading text into a valid label segment:
/// lowercase, spaces→`-`, strip trailing non-alnum, remove invalid label chars
#let sanitize-key(s) = {
  let s = lower(s.trim())
  let chars = s.clusters()
  while chars.len() > 0 {
    if chars.last().match(regex("^[a-z0-9]$")) != none { break }
    chars = chars.slice(0, -1)
  }
  let s = chars.join("")
  let s = s.replace(" ", "-")
  s.replace(regex("[^a-z0-9._:-]"), "")
}

/// Build hierarchical label key by querying previous headings.
/// Headings containing math get `mb1`, `mb2`, ... segments (counted among same-level siblings).
#let heading-key(it) = {
  let is-mb = has-math(it.body)
  let prev = query(selector(heading).before(here()))
  let seg = if is-mb {
    let mb-count = 0
    for h in prev.rev().slice(1) {
      if h.level < it.level { break }
      if h.level == it.level and has-math(h.body) { mb-count += 1 }
    }
    "mb" + str(mb-count + 1)
  } else {
    sanitize-key(to-string(it.body))
  }

  let prefix = ()
  let level = it.level
  for h in prev.rev().slice(1) {
    if level <= 1 { break }
    if h.level >= level { continue }
    prefix = (if has-math(h.body) { "mb" } else { sanitize-key(to-string(h.body)) },) + prefix
    level = h.level
  }
  (..prefix, seg).join(".")
}

#let prelude(doc, img: none) = [
  #show: md-parity-prelude.with(img: img)
  #show: math-notes-prelude
  #set page(margin: (y: 0.2cm)) //Q: was `0cm` before, but I'm trying to make a pagebreak not be less then literally space between line_1\n\nline_2
  #set text(fallback: false)

  // auto-gen hierarchical heading labels:
  // `= Ex I` / `== 1.` / `=== a)` becomes `@ex-i.1.a`
  #show figure.where(kind: "heading"): none
  #show heading: it => context {
    let key = heading-key(it)
    [
      #it
      #figure(kind: "heading", supplement: none, numbering: "1", caption: it.body)[] #label(key)
    ]
  }
  // name refs after their tag, unless typst renders them natively (citations, anything numbered)
  #show ref: it => {
    let el = it.element
    let native = el == none or (el.func() != figure or el.kind != "heading") and el.at("numbering", default: none) != none
    if native { it } else { link(it.target, str(it.target).replace("-", " ")) }
  }

  #doc

  // trailing blank page so zathura doesn't jump on edits at the tip.
  // Will still step forward when new page is created, but at least if I scroll below the current pos at the bottom manually, it won't jerk back on every save.
  #pagebreak()
  #hide[.]
]
