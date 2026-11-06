/**
= Extended syntax
This syntax is supported when `#writing(syntax)` is `true`. It is implemented in Typst itself,
using some deep Typst wizardry, and consequently, there are some limitations to its use.
Known limitations will be mentioned in this documentation.


== Unnumbered headings
```typst
|= Level 1
|== Level 2
|=== Level 3
|==== Level 4
|===== Level 5
|====== Level 6
```
Small circles above the titles indicate their levels. To insert text on the line immediately
below the heading, you will need to insert a line break; otherwise, the text will be
interpreted as part of the heading.
**/
#let unnumbered-headings(enable: true, body) = {
  if not enable {return body}
  
  show regex("(?m)^\|=+.*$"): it => {
    set circle(
      fill: text.fill,
      radius: 1pt,
    )
    set box(
      inset: (x: 5pt),
    )
    set align(center)
    let level = it.text.find(regex("=+")).len()
    let title = it.text.replace(regex("^\|=+\s*"), "")
    
    assert.ne(level, 0, message: "min-writing failed to parse syntax")
    
    v(par.spacing)
    box(circle()) * level
    v(0.32em, weak: true)
    
    heading(
      title,
      level : level,
      numbering: none,
    )
  }
  
  body
}


/**
== Quotations
```typst
Lorem """ipsum""" dolor sit amet.

> Lorem ipsum.
> — Attribution
```
If the last line of the block quote begins with an em dash and contains no formatting,
it will be parsed as an attribution.
**/
#let quotes(enable: true, body) = {
  if not enable {return body}
  
  show regex("\"\"\".*\"\"\""): it => quote(it.text.trim("\"\"\""))
  
  show par: it => {
    import "@preview/nexus-tools:0.3.0": content2str
    
    let string = content2str(it.body)
    let attribution
    
    if string != none and string.starts-with(">") {
      attribution = string.match(regex(".*>\s*—\s(.*)$"))
      attribution = if attribution  != none{attribution.captures.at(0)} else {attribution}
      
      show regex(">\s*(?:—\s*" + attribution + ")?\s*"): ""
      
      quote(it, attribution: attribution, block: true)
    }
    else {it}
  }
  
  body
}


/**
== Paragraph and page breaks
```typst
One paragraph. \\\\ Another paragraph.
\\\\\\
Paragraph on a new page.
```
**/
#let breaks(enable: true, paged: false, body) = {
  if not enable {return body}
  
  show regex("\\\\+"): it => {
    if it.text.len() == 2 {parbreak()}
    else if it.text.len() == 3 {
      if paged {pagebreak()} else {divider()}
    }
    else {it}
  }
  
  body
}


/**
== Inline formatting
```typst
=Highlight=
​::Boxed::
​:::Underline:::
~~Strikethrough~~
[^This is a footnote]
```
These markups have very limited support for parsing other markups internally: it is possible
to have a strikethrough inside a highlighted text, for example, but nesting markups beyond that
is not possible.
**/
#let inline(enable: true, accent-color: gray, body) = context {
  if not enable {return body}
  
  let nbsp = sym.space.nobreak
  
  // Dark magick: bring elements back from string representation
  show regex("\\|\\|[^\\|\s]+\\|\\|.*?\\|\\|[^\\|\s]+\\|\\|"): it => {
    import "@preview/nexus-tools:0.3.0": content2str
    
    let body = content2str(it)
    let func = body.match(regex("\\|\\|(.*?)\\|\\|")).captures.at(0)
    let body = body.match(regex(func + "\\|\\|(.*?)\\|\\|" + func)).captures.at(0)
    let functions = (
      emph: text.with(style: "italic"),
      strong: text.with(weight: "bold"),
      raw: raw
    )
    
    func = functions.at(func)
    
    func(body + sym.zws)
  }
  
  // Strikethrough
  show regex(nbsp + nbsp + ".+?" + nbsp + nbsp): it => {
    show nbsp: ""
    
    strike(it)
  }
  
  // Marker
  show regex("=.+?="): it => {
    show "=": ""
    
    highlight(it, fill: accent-color)
  }
  
  // Box
  show regex("::.+?::"): it => {
    import "cmd.typ": boxed
    
    show ":": ""
    
    boxed(it, stroke: 1pt + accent-color)
  }
  
  // Underline
  show regex(":::.+?:::"): it => {
    show ":::": ""
    
    underline(it)
  }
  
  // Footnote
  show regex("\\[\\^.+?\\]"): it => {
    footnote({
      show regex("[\\[\\]\\^]"): ""
      
      it
    })
  }
  
  // Dark magick: Transform elements into string representation
  show selector.or(strong, emph, raw.where(block: false)): it => {
    import "@preview/nexus-tools:0.3.0": content2str
    
    let func = "||" + repr(it.func()) + "||"
    let body = content2str(it)
    
    if body == none or body.ends-with(sym.zws) {return it}
    
    func
    body
    func
  }
  
  body
}


/**
== Check lists
```typst
- [ ] Item
- [X] Item
- [/] Item
- [-] Item
- [!] Item
```
Extended checklist support provided by~#univ("cheq") package.
**/
#let check-lists(enable: true, body, stroke: black, fill: white) = {
  if not enable {return body}
  
  import "@preview/cheq:0.4.0": checklist
  
  checklist(body, fill: fill, stroke: stroke)
}


/**
== Dividers
```typst
Content

----

Content
```
**/
#let dividers(enable: true, body) = {
  if not enable {return body}
  
  show regex("^(?:[—–-][—–-]){1,}-?\s*$"): divider()
  
  body
}


/**
== Outline
```typst
Content

[TOC]

Content
```
The word _"toc"_ is case-insensitive.
**/
#let toc(enable: true, body) = {
  if not enable {return body}
  
  show regex("^(?i)\S*\\[toc\\]\s*$"): outline()
  
  body
}


/**
== Tables
```typst
| *Header* | *Header* | *Header* |
| :------: | :------- | -------: |
| Cell     | Cell     | Cell     |
| Cell     | Cell     | <        |
```
This Markdown-inspired syntax is provided by~#univ("tablem") package.
**/
#let tables(enable: true, body) = {
  if not enable {return body}
  
  show par: it => {
    import "@preview/nexus-tools:0.3.0": content2str
    
    let string = content2str(it.body)
    
    if string != none and string.contains(regex("^\s*\\|.*\\|\s*$")) {
      import "@preview/tablem:0.3.0": tablem
      
      let body = it.body.children.map(elem => if elem == [—] [---] else if elem == [–] [--] else {elem})
      
      tablem(body.join())
    }
    else {it}
  }
  
  body
}


/**
== Mermaid diagrams
````typst
```mermaid
graph TD
    A[Start] --​> B[Finish]
```
````
This feature is provided by~#univ("merman") package. To actually highlight the Mermaid syntax
instead of rendering the markup, use the `#raw` command.
**/
#let mermaid(enable: true, body) = {
  if not enable {return body}
  
  import "cmd.typ": mermaid
  
  show raw.where(lang: "mermaid"): mermaid
  
  body
}