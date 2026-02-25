/** #v(1fr) #outline() #v(1.2fr) #pagebreak()
= Quick Start

```typ
#import "@preview/transl:0.2.0": transl
#set text(lang: "es")

#transl(data: yaml("lang.yaml"))

#transl("I love you")

#show: transl.with("love")
```

= Description

Get comprehensive and localized translations, with support for regular
expressions and #url("https://projectfluent.org/", "Fluent") files. This package
comes with only one `#transl` command used to both set the translation database
and retrieve translations. 

The expressions are the texts to be translated; they can be words, phrases, or
regular expression strings. Multiple expressions can be used in a single command,
where each one will be retrieved and concatenated (separated by space).

Although written from scratch, the package's conceptual structure is heavily
inpired by the #univ("linguify") package; the Fluent WASM plugin was also borrowed
from this great package.

= Options <options>
:transl:
**/
#let transl(
  from: auto, /// <- string
    /// Initial origin language. |
  to: auto, /// <- string
    /// Final target language; set to `#text.lang` when `auto`. |
  data: (:), /// <- string | yaml | dictionary
    /** Translation file; `string` sets Fluent database and `dictionary` sets
        standard database (see @database section). |**/
  mode: context(), /// <- context() | str
    /// How to retrieve values: as opaque context or string values. |
  ..expr /// <- arguments
    /// Expressions to be translated (pos) and localization arguments (named). |
) = {
  import "utils.typ"
  import "@preview/nexus-tools:0.1.0": storage, has, its
  
  let args = expr.named()
  let expr = expr.pos()
  let showing = if expr != () and type(expr.last()) == content {true} else {false}
  let body = if showing {expr.pop()} else {none}
  
  // Set database
  if data != (:) {
    let l10n
  
    if to != auto {mode = str}
    
    if type(data) == dictionary {
      // YAML database
      if not has.key(data, "l10n") {data.insert("l10n", "std")}
      
      l10n = data.l10n
      let _ = data.remove("l10n")
    }
    else if type(data) == str {
      // Individual Fluent file
      let lang = args.at("lang", default: to)
      let new = (:)
      
      assert.ne(lang, none, message: "Fluent requires #transl(lang|to) option")
      new.insert(lang, data)
      
      l10n = "ftl"
      data = new
    }
    else {
      panic("Invalid database type: " + repr(type(data)))
    }
    
    // Check language data types for standard and Fluent databases
    let required = if l10n == "std" {dictionary} else {str}
    for lang in data.keys() {
      if type(data.at(lang)) != required {
        let path = l10n + "." + lang
        panic("Data for '" + path + "' should be " + repr(required))
      }
    }
    
    if not showing and mode != str {
      storage.add(l10n, data, append: true, namespace: "transl")
    }
    
    // Allows context-free use
    let curr-data = data
    data = (:)
    data.insert(l10n, curr-data)
  }
  
  // Exits when no expression (except for #show rules)
  if expr == () and not showing {return}
  
  if showing {
    // Support for #show rule
    context {
      let body = body
      let data = data
      let expr = expr
      let to = to
      
      if data == (:) {data = storage.get(namespace: "transl")}
      if to == auto {to = text.lang + if text.region != none {"-" + text.region}}
      
      // Use all expressions available in database when no expression
      if expr == () {
        expr = data
          .at("std", default: (:))
          .at(to, default: (:))
          .keys()
      }
      
      for item in expr {
        let translated = utils.translate(item, from, to, data, args, showing)
        let re
        
        // Checks data.std.at(from).at(item) for pattern used in rule
        if from != auto {
          item = data
            .at("std", default: (:))
            .at(from, default: (:))
            .at(item, default: item)
        }
        re = regex("(?i)" + item)
        
        // Apply show rule to substitute each pattern for its translation
        body = {
          show re: it => utils.set-case(translated, it.text)
          body
        }
      }
      body
    }
  }
  else {
    // Manages context-dependent and no context value retrieval
    if mode == str {
      // Return context-dependent or plain strings
      if data == (:) {data = storage.get(namespace: "transl")}
      if to == auto {to = text.lang + if text.region != none {"-" + text.region}}
      if expr == () {
        expr = data
          .at("std", default: (:))
          .at(to, default: (:))
          .keys()
      }
      
      expr
        .map( item => utils.translate(item, from, to, data, args, showing) )
        .join(" ")
    }
    else if its.context-val(mode) {
      // Return opaque context() value
      context {
        let data = data
        let expr = expr
        let to = to
        
        if data == (:) {data = storage.get(namespace: "transl")}
        if to == auto {to = text.lang + if text.region != none {"-" + text.region}}
        if expr == () {
          expr = data
            .at("std", default: (:))
            .at(to, default: (:))
            .keys()
        }
        
        expr
          .map( item => utils.translate(item, from, to, data, args, showing) )
          .join(" ")
      }
    }
    else {
      panic("Invalid #transl(mode) value: " + repr(mode))
    }
  }
}