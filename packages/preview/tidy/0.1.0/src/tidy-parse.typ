


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
// #let docstring-matcher = regex(`([^\S\r\n]*///.*(?:\n[^\S\r\n]*///.*)*)\n[^\S\r\n]*#?let (\w[\w\d\-_]*)`.text)
#let docstring-matcher = regex(`(?m)^((?:[^\S\r\n]*///.*\n)+)[^\S\r\n]*#?let (\w[\w\d\-_]*)`.text)
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


// Matches an argument documentation of the form `/// - myparameter (string)`. 
#let argument-documentation-matcher = regex(`[^\S\r\n]*/{3} - ([.\w\d\-_]+) \(([\w\d\-_ ,]+)\): ?(.*)`.text)

// Matches docstring references of the form `@@otherfunc` or `@@otherfunc()`. 
#let reference-matcher = regex(`@@([\w\d\-_\)\(]+)`.text)



/// #set raw(lang: "typc")
/// Parse a Typst argument list either at
///  - call site, e.g., `f("Timbuktu", value: 23)` or at
///  - declaration, e.g. `let f(place, value: 0)`.
///
/// This function returns a tuple `(args, count-processed-chars)` where
/// `count-processed-chars` is the number of processed characters, i.e., the
/// length of the argument list and `args` is a list with an entry for each 
/// argument. 
/// 
/// The entries are lists with either one item if the argument is positional
/// or two items if the argument is named. In this case, the first item holds
/// the name, the second the value. Names as well as values are returned as 
/// strings. 
/// 
/// This function returns `none`, if the argument list is not properly closed. 
/// Note, that valid Typst code is expected. 
///
/// *Example: * Calling this function with the following string 
///
/// ```
/// "#let func(p1, p2: 3pt, p3: (), p4: (entries: ())) = {...}"
/// ```
///
/// and index `9` (which points to the opening parenthesis) yields the result 
/// ```
///   (
///     (
///       ("p1",),
///       ("p2", "3pt"),
///       ("p3", "()"),
///       ("p4", "(entries: ())"),
///       ("p5",),
///     ),
///     44,
///   )
/// ```
/// 
/// This function can deal with
///  - any number of opening and closing parenthesis
///  - string literals
/// We don't deal with:
///  - commented out code (`//` or `/**/`)
///  - raw strings with #raw("``") syntax that contain `"` or `(` or `)`
///
/// - text (string): String to parse. 
/// - index (integer): Position of the opening parenthesis of the argument list. 
/// -> array
#let parse-argument-list(text, index) = {
  if text.at(index) != "(" { return ((:), 0) }
  index += 1
  let brace-level = 1
  let literal-mode = none // Whether in ".."
  let arg-strings = ()
  let current-arg = ""
  let is-named = false // Whether current argument is a named arg
  
  let previous-char = none
  let count-processed-chars = 1

  let maybe-split-argument(arg, is-named) = {
      if is-named {
        let colon-pos = arg.position(":")
        return (arg.slice(0, colon-pos).trim(), arg.slice(colon-pos + 1).trim())
      } else {
        return (arg.trim(),)
      }
  }
  
  for c in text.slice(index) {
    let ignore-char = false
    if c == "\"" and previous-char != "\\" { 
      if literal-mode == none { literal-mode = "\"" }
      else if literal-mode == "\"" { literal-mode = none }
    }
    if literal-mode == none {
      if c == "(" { brace-level += 1 }
      else if c == ")" { brace-level -= 1 }
      else if c == "," and brace-level == 1 {
        arg-strings.push(maybe-split-argument(current-arg, is-named))
        current-arg = ""
        ignore-char = true
        is-named = false
      } else if c == ":" and brace-level == 1 {
        is-named = true
      }
    }
    count-processed-chars += 1
    if brace-level == 0 {
      if current-arg.trim().len() > 0 {
        arg-strings.push(maybe-split-argument(current-arg, is-named))
      }
      break
    }
    if not ignore-char { current-arg += c }
    previous-char = c
  }
  if brace-level > 0 { return none }
  return (arg-strings, count-processed-chars)
}

/// This is similar to @@parse-argument-list but focuses on parameter lists 
/// at the declaration site. 
///
/// If the argument list is well-formed, a dictionary is returned with 
/// an entry for each parsed 
/// argument name. The values are dictionaries that may be empty or 
/// have an entry for the key `default` containing a string with the parsed
/// default value for this argument. 
/// 
/// 
/// 
/// *Example* \  
/// Let us take the string
/// ```typc
/// "#let func(p1, p2: 3pt, p3: (), p4: (entries: ())) = {...}"
/// ```
/// Here, we would call `parse-parameter-list(source-code, 9)` and retrieve
/// #pad(x: 1em, ```typc
/// (
///   p0: (:),
///   p1: (default: "3pt"),
///   p2: (default: "()"),
///   p4: (default: "(entries: ())"),
/// ) 
/// ```)
///
/// - text (string): String to parse. 
/// - index (integer): Index where the argument list starts. This index should point to the character *next* to the function name, i.e., to the opening brace `(` of the argument list if there is one (note, that function aliases for example produced by `myfunc.where(arg1: 3)` do not have an argument list).
/// -> none, dictionary
#let parse-parameter-list(text, index) = {
  let result = parse-argument-list(text, index)
  if result == none { return none }
  let (arg-strings, count) = result
  let args = (:)
  for arg in arg-strings {
    if arg.len() == 1 {
      args.insert(arg.at(0), (:))
    } else {
      args.insert(arg.at(0), (default: arg.at(1)))
    }
  }
  return args
}


// Take the result of `parse-argument-list()` and retrieve a list of positional and named
// arguments, respectively. The values are `eval()`ed. 
#let parse-arg-strings(args) = {
  let positional-args = ()
  let named-args = (:)
  for arg in args {
    if arg.len() == 1 {
      positional-args.push(eval(arg.at(0)))
    } else {
      named-args.insert(arg.at(0), eval(arg.at(1)))
    }
  }
  return (positional-args, named-args)
}


/// Take a documentation string (for example a function or parameter description) 
/// and process docstring cross-references (starting with `@@`), turning 
/// them into links. 
/// - text (string): Source code.
/// - parse-info (dictionary): 
#let process-function-references(text, parse-info) = {
  return text.replace(reference-matcher, info => {
    let target = info.captures.at(0).trim(")").trim("(")
    return "#link(label(\"" + parse-info.label-prefix + target + "()\"))[`" + target + "()`]"
  })
}


#let example(code) = {
  set text(size: .9em)
  grid(
    columns: 1,
    gutter: 1em,
    block(radius: 3pt, inset: 5pt, stroke: .5pt + luma(180), code, width: 100%),
    block(
      width: 100%,
      fill: luma(230), radius: 3pt,
      inset: 5pt,
      rect(
        width: 100%,
        fill: white,
        eval(code.text)
      )
    )
  )
}
#let eval-docstring(docstring, parse-info) = {
  let scope = parse-info.scope
  let content = process-function-references(docstring.trim(), parse-info)
  eval(content, mode: "markup", scope: scope)
}

/// Parse a function docstring that has been located in the source code with given match. 
///
/// The return value is a dictionary with the keys
/// - `name` (string): the function name.
/// - `description` (content): the function description.
/// - `args`: A dictionary containing the argument list. 
/// - `return-types` (array(string)): A list of possible return types. 
///
/// The entries of the argument list dictionary are
/// - `default` (string): the default value for the argument.
/// - `description` (content): the argument description.
/// - `types` (array(string)): A list of possible argument types. 
/// Every entry is optional and the dictionary also contains any non-documented arguments. 
///
///
///
/// - source-code (string): The source code containing some documented Typst code. 
/// - match (match): A regex match that matches a documentation string. The first capture
///   group should hold the entire, raw docstring and the second capture the function name 
///   (excluding the opening parenthesis of the argument list if present). 
/// - parse-info (dictionary): 
/// -> dictionary
#let parse-function-docstring(source-code, match, parse-info) = {
  let docstring = match.captures.at(0)
  let fn-name = match.captures.at(1)
  
  let fn-desc = ""
  let started-args = false
  let documented-args = ()
  let return-types = none
  for line in docstring.split("\n") {
    let arg-match = line.match(argument-documentation-matcher)
    if arg-match == none {
      let trimmed-line = line.trim().trim("/")
      if not started-args { fn-desc += trimmed-line + "\n"}
      else { // Return type:
        if trimmed-line.trim().starts-with("->") {
          return-types = trimmed-line.trim().slice(2).split(",").map(x => x.trim())
        } else {
          documented-args.last().desc += "\n" + trimmed-line 
        }
      }
    } else {
      started-args = true
      let param-name = arg-match.captures.at(0)
      let param-types = arg-match.captures.at(1).split(",").map(x => x.trim())
      let param-desc = arg-match.captures.at(2)
      documented-args.push((name: param-name, types: param-types, desc: param-desc))
    }
  }
  let args = parse-parameter-list(source-code, match.end)
  for arg in documented-args {
    if arg.name in args {
      args.at(arg.name).description = eval-docstring(arg.desc, parse-info)
      args.at(arg.name).types = arg.types
    } else {
      assert(false, message: "The parameter \"" + arg.name + "\" does not appear in the argument list of the function \"" + fn-name + "\"")
    }
  }
  if parse-info.require-all-parameters {
    for arg in args {
      assert(documented-args.find(x => x.name == arg.at(0)) != none, message: "The parameter \"" + arg.at(0) + "\" of the function \"" + fn-name + "\" is not documented. ")
    }
  }
  return (
    name: fn-name, 
    description: eval-docstring(fn-desc, parse-info), 
    args: args, 
    return-types: return-types
  )
}

