// NAME: Translator

#import "utils.typ": show-db

/**
 * = Quick Start
 *
 * ```typ
 * #import "@preview/transl:0.1.0": transl
 * #transl(data: yaml("lang.yaml"))
 * 
 * // Get "I love you" in Spanish:
 * #set text(lang: "es")
 * #transl("I love you")
 * 
 * // Translate every "love" to Italian:
 * #set text(lang: "it")
 * #show: doc => transl("love", doc)
 * ```
 * 
 * = Description
 * 
 * Get comprehensive and contextual translations, with support for regular
 * expressions and #url("https://projectfluent.org/", "Fluent") localization.
 * This package have one main command, `#transl`, that receives one or more
 * expression strings, searches for each of them in its database and then
 * returns the translation for each one.
 * 
 * The expressions are the text to be translated, they can be simple words or
 * longer text excerpts, or can be used as identifiers to obtain longer text
 * blocks at once. Regular expressions are supported as string patterns — not
 * `#regex` elements.
 * 
 * All the conceptual structure of _transl_ and its idea is heavily inspired by
 * the great #univ("linguify") package.
 * 
 * #pagebreak()
 * 
 * = Options
 * 
 * These are all the options and its defaults used:
 * 
 * :transl:
**/
#let transl(
  from: auto,
  /** <- string
   * Initial origin language.**/
  to: auto,
  /** <- string | auto
   * Final target language — fallback to `#text.lang` when not set. **/
  data: none,
  /** <- yaml | dictionary
   * Translation file — see the `docs/assets/example.yaml` file.**/
  mode: context(),
  /** <- type
   * Type of value returned: an opaque `context()` or a contextualized `str`
   * — used as `#context transl(mode: str)`. **/
  args: (:),
  /** <- dictionary
    * Arguments passed to Fluent, used to customize the translation output. **/
  ..expr
  /** <- strings
   * Expressions to be translated. **/
) = {
  import "utils.typ"
  
  if expr.named() != (:) {panic("unexpected argument: " + repr(expr.named()))}
  
  let expr = expr.pos()
  let l10n = "std"
  let showing = if expr != () and type(expr.last()) == content {true} else {false}
  let body = if showing {expr.pop()} else {none}
  
  if data != none {
    if to != auto {mode = str}
    
    // Manage output of #fluent()
    l10n = data.at("l10n", default: "std")
    data = data.at("files", default: data)
    
    if not showing and mode != str {
      // Insert data into the translation database
      if data != (:) {utils.db(add: l10n, data)}
      if mode != str {utils.db(add: "l10n", l10n)}
    }
    
    // Allows context-free use
    let curr-data = data
    data = (:)
    data.insert(l10n, curr-data)
  }
  
  // Exits if given no expression
  if expr == () and not showing {return}
  
  
  // Get translations
  let get-data() = {
    let data = if data == none {utils.db().get()} else {data}
    let l10n = data.at("l10n", default: l10n)
    let default = data.at(l10n).at("default", default: "en")
    let to = if to == auto {text.lang} else {to}
    let result = ()
    let expr = expr
    
    // If target language is available in database
    if data.at(l10n).keys().contains(to) {
      // Resolve localization mechanism (feeds result array)
      if l10n == "std" {
        let available = data.at(l10n).at(to)
        
        // Translate all entries available when no expression given in show rule
        if showing and expr.len() == 0 { expr = data.at(l10n).at(to).keys() }
        
        for i in range(expr.len()) {
          // if expr.at(i).starts-with("regex!") {
          //   expr.at(0) = available.keys().find(key => key.contains(re))
          // }
          
          // Try to use expression as string, then try to use it as regex pattern
          let res = available.at(
            expr.at(i),
            default: {
              let re = regex("(?i)" + expr.at(i))
              let key = available.keys().find(key => key.contains(re))
    
              if key != none {available.at(key)} else {key}
            }
          )
          if res == none {panic("Translation not found: " + repr(expr.at(i)))}
          
          result.push(res)
        }
      }
      else if l10n == "ftl" {
        for i in range(expr.len()) {
          let res = utils.fluent-data(
            get: expr.at(i),
            lang: to,
            data: data.at(l10n),
            args: args
          )
          
          if res == none {panic("Translation not found: " + repr(expr.at(i)))}
          if l10n == "ftl" and from != auto and showing {
            expr.at(i) = data
              .at("std")
              .at(from)
              .at(expr.at(i), default: expr.at(i))
          }
          
          result.push(res)
        }
      }
    }
    // If origin and target languages are the same
    else if from == to {result = expr}
    else {panic("Target language not found: " + repr(to))}
    
    return (expr, result)
  }
  
  // When using #show: transl or else #transl
  if showing {
    context {
      let (expr, translated) = get-data()
      let body = body
      
      for i in range(translated.len()) {
        let re = regex("(?i)" + expr.at(i))
        
        body = {
          // Substitute the expression every time across the content
          show re: it => {
            let result = translated.at(i)
            
            if it.text.first() != upper(it.text.first()) {result}
            else if it.text != result {upper(result.first()) + result.slice(1)}
            else if it != upper(it) {upper(result)}
          }
          body
        }
      }
      body
    }
  }
  else {
    // The context type
    let contxt = [#context()]
    
    if mode == str {get-data().at(1).join(" ")}
    else if mode.func() == contxt.func() {context get-data().at(1).join(" ")}
    else {panic("Invalid mode: " + repr(mode))}
  }
}


// UTIL: Resolve Fluent data for translation database. Used inside #eval
/**
 * = Fluent Data
 * 
 * :fluent:
 * 
 * Fluent is a localization solution (L10n) developed by Mozilla that can easily
 * solve those wild language-specific variations that are tricky to fix in code,
 * like gramatical case, gender, number, tense, aspect, or mood. When used to
 * set `#transl(data)`, this function signalizes _transl_ to use its embed
 * Fluent plugin instead of the standard mechanism (YAML). It may need to
 * be wrapped in an `#eval` to work properly.
**/
#let fluent(
  ..data,
  /** <- string
    * Path to where the `ftl` files are stored in the project (requires `#eval`)
    * or `"file!"` followed by the Fluent code itself (does not require `#eval`). **/
  lang: (),
  /** <- array | string
    * The languages used — each corresponds to _lang.ftl_ inside the given path. **/
) = {
  // Normalizes lang as array
  if type(lang) != array {lang = (lang,)}
  if type(lang) == () {panic("Missing #transl(lang) argument")}
  
  data = data.pos().at(0, default: "")
  if data == "" {return (l10n: "ftl", files: (:))}
  
  let scope = (
    DATA: repr(data),
    LANGS: repr(lang),
    IS-FILE: repr(data.starts-with("file!"))
  )
  
  // Code to be evaluated
  let code = ```typst
    let result = (
      l10n: "ftl",
      files: (:),
    )
    
    if not IS-FILE {
      for lang in LANGS {
        result.files.insert(lang, str(read(DATA + "/" + lang + ".ftl")))
      }
    }
    else {
      result.files.insert(LANGS.at(0), str(DATA).slice(5))
    }
    
    result
  ```.text
  
  // Replace the PLACEHOLDERs by their respective values
  code = code.replace(
    regex("\b(" + scope.keys().join("|") + ")\b"),
    m => scope.at(m.text)
  )
  
  // Eval if data is "file!" string, or return code to be evaluated
  if data.starts-with("file!") {eval(code)} else {code}
}

/**
 * = Standard Data
 * 
 * After setting Fluent as localization mechanism, _transl_ will use it from now
 * on. To go back to the default localization mechanism the `#std()` command
 * must be used:
 * 
 * :std:
**/
#let std(
  data: (:)
) = {
  (
    l10n: "std",
    files: (:),
  )
}

/// The `#std` command does not need to be wrapped in an `#eval`.