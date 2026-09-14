/**
== Documentation from Markdown
````md
# Feature
```typst
#show: feature.with(title)
```
The `#feature` command does something.
````

The documentation can be written in Markdown and _min-manual_ will manage to
generate a manual from it. The conversion between Markdown and Typst code is done
using the #univ("cmarker") package; therefore some _cmarker_ features are
supported, like the _raw-typst_ and _typst-exclude_ special comments:

#raw(lang: "md", block: true, ```
<!--raw-typst
This code appears only in Typst
--.>

<!--typst-begin-exclude--.>
This code appears only in Markdown
<!--typst-end-exclude--.>
```.text.replace(".", ""))

There is also a special syntax structure for `#arg` using Markdown/HTML5 (see
the `tests/markdown/assets/file.md` file).

#callout(title: "Experimental", icon: "exclamation-triangle")[
  As it is a recent implementation, the Markdown documentation is still
  experimental and may or may not present errors, bugs, or unexpected behaviors.
  Used it with caution for now.]
**/


// Parses special <dl> tags for #arg
#let get-arg(attrs, body, lib) = {
  import "@preview/nexus-tools:0.1.0": its
  let args = ()
  
  for elem in body.children {
    // Handle <dt> tags inside <dl>
    if elem.at("text", default: "").starts-with("dt:") {
      // Get code language from <code data-lang> attribute
      let lang = elem.text.match(regex("<code\s+data-lang=\"(.*?)\""))
      
      if attrs.at("data-arg", default: none) != none {
        lang = if lang == none {""} else {lang.captures.at(0)}
        
        // Parse <dt> content into #arg(title) option
        elem = elem.text
          .slice(3)
          .replace("\n", "")
          .replace(regex("<code.*?>"), "```" + lang + " ")
          .replace("</code>", "```")
          .replace(regex("<type>(.*?)</type>"), m => m.captures.at(0) + " |")
          .replace(regex("<.*?>"), "")
          .replace("[required]", "<required>")
          .replace("&larr;", "<-")
          .replace("&zwj;", "<-")
          .replace("&rarr;", "->")
      }
      else {elem = elem.text.slice(3)}
      
      args.push(elem)
    }
    else if type(elem) == content and its.sequence(elem) {
      // Handle <dd> tags inside <dl>
      if repr(elem.children.at(0)) == "[dd:]" {
        elem = elem.children.slice(1).join()
        
        args.push(elem)
      }
    }
  }
  
  let i = 0
  
  while i != args.len() {
    if attrs.at("data-arg", default: none) != none {
      // Renders an #arg command
      lib.arg(args.at(i), args.at(i + 1))
    }
    else {
      // Fallback to a #terms list
      terms.item(args.at(i), args.at(i + 1))
    }
    
    i += 2
  }
}


// Parses <code> tags
#let set-code(attrs, body) = {
  let lang = attrs.at("data-lang", default: "")
  
  set raw(lang: lang)
  
  eval("```" + lang + " " + body + "```")
}


// Parses Markdown into Typst code using cmarker
#let parse(doc, cmarker-html: (:), ..cmarker-args) = {
  if doc == none {return}
  
  import "lib.typ"
  import "@preview/cmarker:0.1.6"
  
  cmarker.render(
    doc,
    smart-punctuation: true,
    math: none,
    h1-level: 1,
    raw-typst: true,
    html: (
      dd: ("normal", (attrs, body) => "dd:" + body),
      dt: ("raw-text", (attrs, body) => "dt:" + body),
      dl: ("normal", (attrs, body) => get-arg(attrs, body, lib)),
      code: ("raw-text", (attrs, body) => set-code(attrs, body)),
      ..cmarker-html,
    ),
    label-prefix: "",
    prefix-label-uses: true,
    scope: dictionary(lib),
    show-source: false,
    ..cmarker-args
  )
}