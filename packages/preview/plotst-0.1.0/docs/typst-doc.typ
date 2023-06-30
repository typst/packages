// Source code for the typst-doc package

// Color to highlight function names in
#let fn-color = rgb("#4b69c6")

// Colors for Typst types
#let type-colors = (
  "content": rgb("#a6ebe6"),
  "color": rgb("#a6ebe6"),
  "string": rgb("#d1ffe2"),
  "none": rgb("#ffcbc4"),
  "auto": rgb("#ffcbc4"),
  "boolean": rgb("#ffedc1"),
  "integer": rgb("#e7d9ff"),
  "float": rgb("#e7d9ff"),
  "ratio": rgb("#e7d9ff"),
  "length": rgb("#e7d9ff"),
  "angle": rgb("#e7d9ff"),
  "relative-length": rgb("#e7d9ff"),
  "fraction": rgb("#e7d9ff"),
  "symbol": rgb("#eff0f3"),
  "array": rgb("#eff0f3"),
  "dictionary": rgb("#eff0f3"),
  "arguments": rgb("#eff0f3"),
  "selector": rgb("#eff0f3"),
  "module": rgb("#eff0f3"),
  "stroke": rgb("#eff0f3"),
  "function": rgb("#f9dfff"),
)

#let get-type-color(type) = type-colors.at(type, default: rgb("#eff0f3"))

// Create beautiful, colored type box
#let type-box(type) = { 
  let color = get-type-color(type)
  h(2pt)
  box(outset: 2pt, fill: color, radius: 2pt, raw(type))
  h(2pt)
}

// Create a parameter description block, containing name, type, description and optionally the default value. 
#let param-description-block(name, types, content, show-default: false, default: none, breakable: false) = block(
  inset: 10pt, fill: luma(98%), width: 100%,
  breakable: breakable,
  [
    #text(weight: "bold", size: 1.1em, name) 
    #h(.5cm) 
    #types.map(x => type-box(x)).join([ #text("or",size:.6em) ])
  
    #eval("[" + content + "]")
    
    #if show-default [ Default: #raw(lang: "typc", default) ]
  ]
)



/// Parse an argument list from source code at given position. 
/// This function returns `none`, if the argument list is not properly closed. 
/// Otherwise, a dictionary is returned with an entry for each parsed 
/// argument name. The values are dictionaries that may be empty or 
/// have an entry for `default` containing a string with the parsed
/// default value for this argument. 
/// 
/// 
/// 
/// *Example*
///
/// Let's take some source code:
/// ```typ
/// #let func(p1, p2: 3pt, p3: (), p4: (entries: ())) = {...}
/// ```
/// Here, we would call `parse-argument-list(source-code, 9)` and retrieve
/// #pad(x: 1em, ```typc
/// (
///   p0: (:),
///   p1: (default: "3pt"),
///   p2: (default: "()"),
///   p4: (default: "(entries: ())"),
/// ) 
/// ```)
///
/// - module-content (string): Source code.
/// - index (integer): Index where the argument list starts. This index should point to the character *next* to the function name, i.e. to the opening brace `(` of the argument list if there is one (note, that function aliases for example produced by `myfunc.where(arg1: 3)` do not have an argument list).
/// -> none, dictionary
#let parse-argument-list(module-content, index) = {
  if module-content.at(index) != "(" { return (:) }
  index += 1
  let brace-level = 1
  let arg-strings = ()
  let current-arg = ""
  for c in module-content.slice(index) {
    if c == "(" { brace-level += 1 }
    if c == ")" { brace-level -= 1 }
    if c == "," and brace-level == 1 {
      arg-strings.push(current-arg)
      current-arg = ""
      continue
    }
    if brace-level == 0 {
      arg-strings.push(current-arg)
      break
    }
    current-arg += c
  }
  if brace-level > 0 { return none }
  let args = (:)
  for arg in arg-strings {
    if arg.trim().len() == 0 { continue }
    let colon-pos = arg.position(":")
    if colon-pos == none {
      args.insert(arg.trim(), (:))
    } else {
      let name = arg.slice(0, colon-pos)
      let default-value = arg.slice(colon-pos + 1)
      args.insert(name.trim(), (default: default-value.trim()))
    }
  }
  return args
}

// #parse-argument-list("sadsdasd (p0, p1: 3, p2: (), p4: (entries: ())) = ) asd", 9)


// Matches Typst docstring for a function declaration. Example:
// 
// // This function does something
// //
// // param1 (string): This is param1
// // param2 (content, length): This is param2.
// //           Yes, it really is. 
// #let something(param1, param2) = {
//   
// }
// 
// The entire block may be indented by any amount, the declaration can either start with `#let` or `let`. The docstring must start with `///` on every line and the function declaration needs to start exactly at the next line. 
// #let docstring-matcher = regex(`((?:[^\S\r\n]*/{3} ?.*\n)+)[^\S\r\n]*#?let (\w[\w\d\-_]+)`.text)
#let docstring-matcher = regex(`([^\S\r\n]*///.*(?:\n[^\S\r\n]*///.*)*)\n[^\S\r\n]*#?let (\w[\w\d\-_]*)`.text)
// The regex explained: 
//
// First capture group: ([^\S\r\n]*///.*(?:\n[^\S\r\n]*///.*)*)
// is for the docstring. It may start with any whitespace [^\S\r\n]* 
// and needs to have /// followed by anything. This is the first line of 
// the docstring and we treat it separately only in order to be able to 
// match the very first line in the file (which is otherwise tricky here). 
// We then match basically the same thing n times: \n[^\S\r\n]*///.*)*
//
// We then want a linebreak (should also have \r here?), arbitrary whitespace
// and the word let or #let: \n[^\S\r\n]*#?let 
//
// Second capture group: (\w[\w\d\-_]*)
// Matches the function name (any Typst identifier)


#let argument-type-matcher = regex(`[^\S\r\n]*/{3} - ([\w\d\-_]+) \(([\w\d\-_ ,]+)\): ?(.*)`.text)

#let reference-matcher = regex(`@@([\w\d\-_\)\(]+)`.text)


#let process-function-references(text, label-prefix: none) = {
  return text.replace(reference-matcher, info => {
    let target = info.captures.at(0).trim(")").trim("(")
    return "#link(label(\"" + label-prefix + target + "()\"))[`" + target + "()`]"
  })
}

/// Parse the docstrings of Typst code. This function returns a dictionary with the keys
/// - `functions`: A list of function documentations as dictionaries.
/// - `label-prefix`: The prefix for internal labels and references.
/// 
/// The function documentation dictionaries contain the keys
/// - `name`: The function name.
/// - `description`: The functions docstring description.
/// - `args`: A dictionary of info objects for each fucntion argument.
///
/// These again are dictionaries with the keys
/// - `description` (optional): The description for the argument.
/// - `types` (optional): A list of accepted argument types. 
/// - `default` (optional): Default value for this argument.
/// 
/// See @@show-module() for outputting the results of this function.
///
/// - content (string): Typst code to parse for docs. 
/// - label-prefix (none, string): Prefix for internally created labels 
///   and references. Use this to avoid name conflicts with labels. 
#let parse-code(content, label-prefix: none) = {
  let matches = content.matches(docstring-matcher)
  let function-docs = ()

  for match in matches {
    let docstring = match.captures.at(0)
    let fn-name = match.captures.at(1)

    let args = parse-argument-list(content, match.end)
    
    let fn-desc = ""
    let started-args = false
    let documented-args = ()
    let return-types = none
    for line in docstring.split("\n") {
      let match = line.match(argument-type-matcher)
      if match == none {
        let trimmed-line = line.trim().trim("/")
        if not started-args { fn-desc += trimmed-line + "\n"}
        else {
          if trimmed-line.trim().starts-with("->") {
            return-types = trimmed-line.trim().slice(2).split(",").map(x => x.trim())
          } else {
            documented-args.last().desc += "\n" + trimmed-line 
          }
        }
      } else {
        started-args = true
        let param-name = match.captures.at(0)
        let param-types = match.captures.at(1).split(",").map(x => x.trim())
        let param-desc = match.captures.at(2)
        documented-args.push((name: param-name, types: param-types, desc: param-desc))
      }
    }
    fn-desc = process-function-references(fn-desc, label-prefix: label-prefix)
    for arg in documented-args {
      if arg.name in args {
        args.at(arg.name).description = process-function-references(arg.desc, label-prefix: label-prefix)
        args.at(arg.name).types = arg.types
      }
    }
    function-docs.push((name: fn-name, description: fn-desc, args: args, return-types: return-types))
  }
  let result = (functions: function-docs, label-prefix: label-prefix)
  return result
}

/// Parse the docstrings of a typst module. This function returns a dictionary with the keys
/// - `name`: The module name as a string.
/// - `functions`: A list of function documentations as dictionaries.
/// The label prefix will automatically be the name of the module. /// 
/// See @@parse-code() for more details. 
///
/// - filename (string): Filename for the `.typ` file to analyze for docstrings.
/// - name (string, none): The name for the module. If not given, the module name will be derived form the filename. 
#let parse-module(filename, name: none) = {
  let mname = filename.replace(".typ", "")
  let result = parse-code(read(filename), label-prefix: mname)
  if name != none {
    result.insert("name", name)
  } else {
    result.insert("name", mname)
  }
  return result
}



/// Show given module in the style of the Typst online documentation. 
/// This displays all (documented) functions in the module sorted alphabetically. 
///
/// - module-doc (dictionary): Module documentation information as returned by @@parse-module. 
/// - first-heading-level (integer): Level for the module heading. Function names are created as second-level headings and the "Parameters" heading is two levels below the first heading level. 
/// - show-module-name (boolean): Whether to output the name of the module.  
/// - type-colors (dictionary): Colors to use for each type. 
///     Colors for missing types default to gray (`"#eff0f3"`).
/// - allow-breaking (boolean): Whether to allow breaking of parameter description blocks
/// - omit-empty-param-descriptions (boolean): Whether to omit description blocks for
///       Parameters with empty description. 
/// -> content
#let show-module(
  module-doc, 
  first-heading-level: 2,
  show-module-name: true,
  type-colors: type-colors,
  allow-breaking: true,
  omit-empty-param-descriptions: true,
) = {
  let label-prefix = module-doc.label-prefix
  if "name" in module-doc and show-module-name {
    let module-name = module-doc.name
    heading(module-name, level: first-heading-level)
  }
  
  for (index, fn) in module-doc.functions.enumerate() {
    [
      #heading(fn.name, level: first-heading-level + 1)
      #label(label-prefix + fn.name + "()")
    ]
    parbreak()
    eval("[" + fn.description + "]")

    block(breakable: allow-breaking,
      {
        heading("Parameters", level: first-heading-level + 2)
      
        pad(x:10pt, {
        set text(font: "Cascadia Mono", size: 0.85em, weight: 340)
        text(fn.name, fill: fn-color)
        "("
        let inline-args = fn.args.len() < 2
        if not inline-args { "\n  " }
        let items = ()
        for (arg, info) in fn.args {
          let types 
          if "types" in info {
            types = ": " + info.types.map(x => type-box(x)).join(" ")
          }
          items.push(arg + types)
        }
        items.join( if inline-args {", "} else { ",\n  "})
        if not inline-args { "\n" } + ")"
        if fn.return-types != none {
          " -> " 
          fn.return-types.map(x => type-box(x)).join(" ")
        }
      })
    })

    let blocks = ()
    for (name, info) in fn.args {
      let types = info.at("types", default: ())
      let description = info.at("description", default: "")
      if description.trim() == "" and omit-empty-param-descriptions { continue }
      param-description-block(
        name, 
        types, description, 
        show-default: "default" in info, 
        default: info.at("default", default: none),
        breakable: allow-breaking
      )
    }
    if index < module-doc.functions.len()  { v(1cm) }
  }
}

