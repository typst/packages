
// Matches docstring references of the form `@@otherfunc` or `@@otherfunc()`. 
#let reference-matcher = regex(`@@([\w\d\-_\)\(]+)`.text)


/// Take a documentation string (for example a function or parameter 
/// description) and process docstring cross-references (starting with `@@`), 
/// turning them into links. 
///
/// - text (string): Source code.
/// - info (dictionary): 
#let process-references(text, info) = {
  return text.replace(reference-matcher, match => {
    let target = match.captures.at(0)
    return "#(tidy.show-reference)(label(\"" + info.label-prefix + target + "\"), \"" + target + "\")"
  })
}



/// Evaluate a docstring description (i.e., a function or parameter description)
/// while processing cross-references (@@...) and providing the scope to the 
/// evaluation context. 
///
/// - docstring (string): Docstring to evaluate. 
/// - info (dictionary): Object holding information for cross-reference 
///        processing and evaluation scope. 
#let eval-docstring(docstring, info) = {
  let scope = info.scope
  let content = process-references(docstring.trim(), info)
  eval(content, mode: "markup", scope: scope)
}


#let get-style-functions(style) = {
  // Default implementations for some style functions
  let show-reference(label, name, style-args) = link(label, raw(name))

  import "styles.typ"
  let show-example = styles.default.show-example
  let show-variable = styles.default.show-variable
  
  let style-functions = style 
  if type(style) == "module" {
    import style: *
    style-functions = (
      show-outline: show-outline,
      show-type: show-type,
      show-function: show-function,
      show-parameter-list: show-parameter-list,
      show-parameter-block: show-parameter-block,
      show-reference: show-reference,
      show-example: show-example,
      show-variable: show-variable,
    )
  }
  return style-functions
}