/**
= Comment Documentation

```typ
/// = Feature
/// The `#feature` command does something.
#feature(title)
```

The documentation can be embedded into the source code itself through special
comments, sometimes called _doc-comments_. These comments contains Typst code
retrieved by _min-mannual_ to generate a complete manual, while at the same time
they are useful as in-code documentation.

By default, documentation comments are a extension of Typst comments, both
one-line and block comments:

#table(
  columns: 2,
  align: center,
  fill: (_,y) => if y == 0 {gray.lighten(85%)} else {none},
  table.header[*Normal*][*Documentation*],
  `//`, `///`,
  raw("/.* *./".replace(".", "")),
  raw("/.** **./".replace(".", "")),
)

Custom comment delimiters can be set in manual initialization with an array of
strings containing the one-line and opening/closing block comments used:

#raw(lang: "typ", block: true, ```
#manual(
  comment-delim: ("///", "/.**", "**./")
)
```.text.replace(".", ""))

In addition to Typst code, documentation comments also support all _min-book_
features both as commands and through special syntax:

#raw(lang: "typ", block: true, ```
// #extract (from documentation files itself)
.:rule name: lang "model" => display

// #arg (optional arrows)
name <.- type | type -.> type <required>
  body |
```.text.replace(".", ""))

The _min-manual_ itself is documented through comments in source code, check it
out to see how it looks like in practice.
**/

// FEAT: comment.esc() escapes all non alphanumerical characters and apply regex
#let esc(text) = {
  let pattern = ""
  
  for letter in text {
    if letter.contains(regex("^[0-9A-Za-z]$")) {pattern = pattern + letter}
    else {pattern = pattern + "\\" + letter}
  }
  
  pattern
}

// FEAT: comment.arg-handle() enables option/arg documentation
#let handle-args(doc, delims) = {
  let delim = delims.slice(0,2).join("|")
  
  doc.replace(regex("(.*?),?\s*(" + delim + ")\s*<-(.*)"), m => {
    let name = m.captures.at(0).trim(regex("[\s,;]"))
    let mark = m.captures.at(1)
    let types = m.captures.at(2)
    
    name = name.replace(regex(" *?( ?=|:).*"), m => m.captures.at(0))
    
    mark + name + "<-" + types
  })
}


// FEAT: comment.get() retrieves documentation from the text content
#let clean(doc, delims) = {
  let all = delims.at(0) + ".*|(?s)" + delims.slice(1, 3).join(".*?")
  let opening = delims.at(0) + "|" + delims.slice(1).join("|")
  
  doc.matches(regex(all)).map(
    m => m.text
      .trim(regex(opening))
      //.replace(regex("(?m)^(?: *\*+ ?)?"), "")  // removes *
      .replace(regex("\|$"), "\n")
      .replace(regex("\n\n+"), "\n\n")
  )
}


// FEAT: comment.extract() retrieves code from this or any other document
#let get-extract(doc, doc-orig) = {
  // USAGE: :title: lang "model" => display
  let re = "(?s):([^\n]+?):(?:<s>(\w+)<s>)?(?:<s>\"(.*?)\")?(?:<s>=>\s*(.*?))?"
  let s = " *\n? *"
  let pattern = re.replace("<s>", s)
  
  doc.replace(regex("(?m)^ *" + pattern + " *(?:\n|$)"), m => {
    let title = m.captures.at(0).split(" ")
    let rule = title.slice(0, -1).join(" ")
    let name = title.last()
    let lang = m.captures.at(1)
    let model = m.captures.at(2)
    let display = m.captures.at(3)
    let args = ()
    
    if name == "" {panic("Invalid name in " + m.text.trim())}
    if rule != none {rule = rule.trim()}
    
    args.push(repr(name) + ", ")
    //args.push("from: " + repr(doc-orig) + ", ")
    
    if rule != none {args.push("rule: " + repr(rule) + ", ")}
    if lang != none {args.push("lang: " + repr(lang) + ", ")}
    if model != none {args.push("model: " + repr(model) + ", ")}
    if display != none {args.push("display: " + repr(display) + ", ")}

    "\n\n#extract(" + args.join() + ")\n\n"
  })
}


// FEAT: comment.args() parses argument notation syntax
#let get-arg(doc) = {
  doc.replace(regex("\s*(.*\s*(?:<-|->)\s*.*)\n?(?s)(.*?)(?:\n\n|$)"), m => {
    let title = m.captures.at(0)
    let body = m.captures.at(1)
    
    // Insert raw in title, if not already
    if not title.starts-with(regex("`.*`")) {
      title = title.replace(regex("\s*(.*?)\s*(<-|->)"), m => {
        "`" + m.captures.at(0) + "`" + m.captures.at(1)
      })
    }
    
    // Create an #arg command with the data retrieved
    "\n\n#arg(" + repr(title) + ")[" + body + "]\n\n"
  })
}


// MAIN: comment.parse() handles doc-comments inside content
#let parse(doc, delims) = {
  if doc == none {return}
  
  delims = delims.map(item => {esc(item)})

  let doc-orig = doc
  
  doc = handle-args(doc, delims)
  doc = clean(doc, delims)
  
  doc.insert(0, "#import \"lib.typ\": *\n\n")
  doc.insert(1, "#state(\"min-manual-configuration-storage\").update(curr => {
    curr.insert(\"extract-from\", doc)
    curr
  })\n")
  
  doc = doc.join("\n")
  doc = get-arg(doc)
  doc = get-extract(doc, doc-orig)
  
  eval( doc, mode: "markup", scope: (doc: doc-orig) )
}
