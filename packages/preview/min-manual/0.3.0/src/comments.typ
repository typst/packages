/**
== Documentation from Comments
```typ
/// = Feature
/// :show.with feature:
/// The `#feature` command does something.
#let feature(title) = { }
```

The documentation can be embedded into the source code itself through special
comments, sometimes called _doc-comments_. These comments contain Typst code
that is retrieved by _min-manual_ to generate the manual document — while also
serving as documentation within the source code, like standard comments.

To use it with languages that have a different syntax for comments, check the
#link(<comment-delim>, `comment-delim`) option.

#heading([Special syntax for argument command], outlined: false, level: 3)
#example(
  raw(syntax.arg, block: true, lang: ""),
  raw("#arg(\"" + syntax.arg.replace("\n  ", "\", ") + ")", block: true, lang: "typ")
)
Each argument must be between empty lines, or end with a `|` to separate them.

#heading([Special syntax for extract command], outlined: false, level: 3)
#example(
  raw(syntax.extract, block: true, lang: ""),
  ```typ
  #extract(
    name,
    display: display, lang: lang, model: model,
  )
  ```
)
**/


// Escapes all non-alphanumerical characters
#let esc(text) = {
  let pattern = ""
  
  for letter in text {
    if letter.contains(regex("^[0-9A-Za-z]$")) {pattern = pattern + letter}
    else {pattern = pattern + "\\" + letter}
  }
  
  pattern
}


// Insert prior option/key into the special #arg syntax
#let handle-args(doc, delims) = {
  delims = delims.at(0) + if delims.len() == 3 {"|" + delims.at(1)}
  
  doc.replace(regex("(.*?),?\s*(" + delims + ")\s*<-(.*)"), m => {
    let name = m.captures.at(0).trim(regex("[\s,;]"))
    let mark = m.captures.at(1)
    let types = m.captures.at(2)
    
    name = name.replace(regex(" *?( ?=|:).*"), m => m.captures.at(0))
    
    mark + name + "<-" + types
  })
}


// Retrieve comment documentation in the midst of source code
#let clean(doc, delims) = {
  let all = delims.at(0) + ".*"
  let opening = delims.at(0)
  
  if delims.len() == 3 {
    all += "|(?s)" + delims.slice(1, 3).join(".*?")
    opening += "|" + delims.slice(1).join("|")
  }
  
  doc.matches(regex(all)).map(
    m => m.text
      .trim(regex(opening))
      .replace(regex("\|$"), "\n")
      .replace(regex("\n\n+"), "\n\n")
  )
}


// Parses special syntax for #extract
#let get-extract(doc, doc-orig) = {
  // :display name: lang "model" => display
  let re = "(?s):([^\n]+?):(?:<s>(\w+)<s>)?(?:<s>\"(.*?)\")?(?:<s>=>\s*(.*?))?"
  let s = " *\n? *"
  let pattern = re.replace("<s>", s)
  
  doc.replace(regex("(?m)^ *" + pattern + " *(?:\n|$)"), m => {
    let title = m.captures.at(0).split(" ")
    let usage = title.slice(0, -1).join(" ")
    let name = title.last()
    let lang = m.captures.at(1)
    let model = m.captures.at(2)
    let display = m.captures.at(3)
    let args = ()
    
    if name == "" {panic("Invalid name in " + m.text.trim())}
    if usage != none {display = usage.trim()}
    
    args.push(repr(name) + ", ")
    //args.push("from: " + repr(doc-orig) + ", ")
    
    //if rule != none {args.push("rule: " + repr(rule) + ", ")}
    if lang != none {args.push("lang: " + repr(lang) + ", ")}
    if model != none {args.push("model: " + repr(model) + ", ")}
    if display != none {args.push("display: " + repr(display) + ", ")}

    "\n\n#extract(" + args.join() + ")\n\n"
  })
}


// Parses special syntax for #arg
#let get-arg(doc) = {
  doc.replace(regex("\s*(.*\s*(?:<-|->)\s*.*)\n?(?s)(.*?)(?:\n[ \t]*\n|$)"), m => {
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



// Parses comment documentation (exported as #from-comment)
#let parse(doc, delims) = {
  if doc == none {return}
  if type(delims) == str {delims = (delims,)}
  
  assert(
    delims.len() in (1, 3),
    message: "#manual(comment-delim) must have 1 or 3 items"
  )
  
  delims = delims.map(item => {esc(item)})

  let doc-orig = doc
  
  doc = handle-args(doc, delims)
  doc = clean(doc, delims)
  
  // Insert data at the beginning
  doc.insert(0,
    ```
    #import "lib.typ": *
    #import "@preview/nexus-tools:0.1.0": storage
    #storage.add("extract-from", doc, namespace: "min-manual")
    ```.text
  )
  
  doc = doc.join("\n")
  doc = get-arg(doc)
  doc = get-extract(doc, doc-orig)
  
  // #doc exposes the original file content to the comment documentation
  eval( doc, mode: "markup", scope: (doc: doc-orig) )
}
