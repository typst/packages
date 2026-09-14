
#let split-once(string, delimiter) ={
  let pos = string.position(delimiter)
  if pos == none { return string }
  (string.slice(0, pos), string.slice(pos + 1))
}

#let parse-argument-list(text) = {
  let brace-level = 1
  let literal-mode = none // Whether in ".."
  
  let args = ()
  
  let arg = ""
  let is-named = false // Whether current argument is a named arg
  
  let previous-char = none // lookbehind of 1
  let count-processed-chars = 1

  let maybe-split-argument(arg, is-named) = {
      if is-named {
        return split-once(arg, ":").map(str.trim)
      } else {
        return (arg.trim(),)
      }
  }
  let skip-line = false

  for c in text {
    let ignore-char = false
    
    if c == "\"" and previous-char != "\\" { 
      if literal-mode == none { literal-mode = "\"" }
      else if literal-mode == "\"" { literal-mode = none }
    } else if literal-mode == none {
      if c == "(" { brace-level += 1 }
      else if c == ")" { brace-level -= 1 }
      else if c == "," and brace-level == 1 {
        if is-named {
          let (name, value) = split-once(arg, ":").map(str.trim)
          args.push((name, value))
        } else {
          arg = arg.trim()
          args.push((arg,))
        }
        arg = ""
        ignore-char = true
        is-named = false
      } else if c == ":" and brace-level == 1 {
        is-named = true
      } else if c == "/" and previous-char == "/" {
        skip-line = true
        arg = arg.slice(0, -1)
      } else if c == "\n" {
        skip-line = false
      }
    }
    count-processed-chars += 1
    if brace-level == 0 {
      if arg.trim().len() > 0 {
        if is-named {
          let (name, value) = split-once(arg, ":").map(str.trim)
          args.push((name, value))
        } else {
          arg = arg.trim()
          args.push((arg,))
        }
      }
      break
    }
    if not (ignore-char or skip-line) { arg += c }
    previous-char = c
  }
  return (
    args: args,
    brace-level: brace-level - 1,
    processed-chars: count-processed-chars - 1
  )
}

// #assert.eq(
//   parse-argument-list("text)"), 
//   (args: (("text",),), brace-level: -1, processed-chars: 5)
// )
// #assert.eq(
//   parse-argument-list("pos,"), 
//   (args: (("pos",),), brace-level: 0, processed-chars: 4)
// )
// #assert.eq(
//   parse-argument-list("12, 13, a)"), 
//   (args: (("12",), ("13",), ("a",)), brace-level: -1, processed-chars: 10)
// )
// #assert.eq(
//   parse-argument-list("a: 2, b: 3)"), 
//   (args: (("a", "2"), ("b", "3")), brace-level: -1, processed-chars: 11)
// )
// #assert.eq(
//   parse-argument-list("a: 2 // 2\n)"), 
//   (args: (("a", "2"),), brace-level: -1, processed-chars: 11)
// )
// #assert.eq(
//   parse-argument-list("a: 2, // 2\nb)"), 
//   (args: (("a", "2"),("b",)), brace-level: -1, processed-chars: 13)
// )


#let eval-doc-comment-test((line-number, line), label-prefix: "") = {
    if line.starts-with(" >>> ") {
      return " #test(`" + line.slice(8) + "`, source-location: (module: \"" + parse-info.label-prefix + "\", line: " + str(line-number) + "))"
    }
    line
}


#let parse-description-and-types(lines, label-prefix: "", first-line-number: 0) = {

  let description = lines
    // .enumerate(start: first-line-number)
    // .map(eval-doc-comment-test.with(label-prefix: label-prefix))
    .join("\n")
    
  if description == none { description = "" }
    
  let types = none
  if description.contains("->") {
    let parts = description.split("->")
    types = parts.last().split("|").map(str.trim)
    description = parts.slice(0, -1).join("->")
  }
  
  return (
    description: description.trim(), 
    types: types
  )
}

#assert.eq(
  parse-description-and-types(("asd",)),
  (description: "asd", types: none)
)
#assert.eq(
  parse-description-and-types(("->int",)),
  (description: "", types: ("int",))
)
#assert.eq(
  parse-description-and-types((" -> int",)),
  (description: "", types: ("int",))
)
#assert.eq(
  parse-description-and-types(("abcdefg -> int",)),
  (description: "abcdefg", types: ("int",))
)
#assert.eq(
  parse-description-and-types(("abcdefg", "-> int",)),
  (description: "abcdefg", types: ("int",))
)



#let trim-trailing-comments(line) = {
  let pos = line.position("//")
  if pos == none { return line }
  return line.slice(0, pos).trim()
}

#assert.eq(trim-trailing-comments("1+2+3+4 // 23"), "1+2+3+4")
#assert.eq(trim-trailing-comments("1+2+3+4 // 23 // 3"), "1+2+3+4")




#let definition-name-regex = regex(`#?let (\w[\w\d\-_]*)\s*(\(?)`.text)


#let process-parameters(parameters) = {
  let processed-params = (:)
  
  for param in parameters {
    let param-parts = param.name
    let (description, types) = parse-description-and-types(param.desc-lines, label-prefix: "")
    let param-info = (
      // name: param-parts.first(),
      description: description,
    )
    if param-parts.len() == 2 {
      param-info.default = param-parts.last()
    } 
    if types != none {
      param-info.types = types
    }
    processed-params.insert(param-parts.first(), param-info)
  }
  processed-params
}



#let process-definition(definition) = {
  let (description, types) = parse-description-and-types(definition.description, label-prefix: "")

  if definition.args == none {
    definition.remove("args")
    if types != none {
      definition.type = types.first()
    }
  } else {
    definition.return-types = types
    definition.args = process-parameters(definition.args)
  }
  definition.description = description
  definition
}

#let curry-matcher = regex(" *= *([.\w\d\-_]+)\.with\(")

#let parameter-parser(state, line) = {
  if line.starts-with("///") {
    state.unmatched-description.push(line.slice(3))
  } else {
    state.unfinished-param += line + "\n"

    let (args, brace-level, processed-chars) = parse-argument-list(state.unfinished-param)
    if brace-level == -1 { // parentheses are already closed on this line
      state.state = "finished"
      // let curry = state.unfinished-param.slice(processed-chars).match(curry-matcher)
      // if curry != none {
      //   state.curry = (name: curry.captures.first(), rest: state.unfinished-param.slice(processed-chars + curry.end))
      // }
    }
    if args.len() > 0 and (state.unfinished-param.trim("\n").ends-with(",") or state.state == "finished") {
      state.params.push((name: args.first(), desc-lines: state.unmatched-description))
      state.unmatched-description = ()
      state.params += args.slice(1).map(arg => (name: arg, desc-lines: ()))
      state.unfinished-param = ""
    }
  }
  return state
}

#let process-curry-info(info) = {
  let pos = info.args
    .filter(x => x.name.len() == 1)
    .map(x => x.name.at(0))
  let named = info.args
    .filter(x => x.name.len() == 2)
    .map(x => x.name).to-dict()

  (
    name: info.name,
    pos: pos,
    named: named
  )
}


#let parse(src) = {
  let lines = (src.split("\n") + ("",)).map(line => {
    // return line.trim()
    // trim only doc-comment lines
    let l = line.trim(at: start)
    if l.starts-with("///") { l }
    else { line.trim(at: end) }
  })

  let module-description = none
  let definitions = ()
  

  // Parser state
  let name = none
  let found-code = false // are we still looking for a potential module description?
  let args = ()
  let desc-lines = ()
  let curry-info = none

  
  let param-parser-default = (
    state: "idle", 
    params: (), 
    unmatched-description: (),
    unfinished-param: ""
  )
  let param-parser = param-parser-default
  let finished-definition = false
  
  for line in lines {
    if param-parser.state == "finished" {
      let curry = param-parser.at("curry", default: none)
      
      if curry-info != none {
        finished-definition = true
        curry-info.args = param-parser.params
        param-parser = param-parser-default
        args = ()
      } else {
        args = param-parser.params
        if "curry" in param-parser {
          // let curry = param-parser.curry
          // curry-info = (name: curry.name)
          // param-parser = param-parser-default
          // param-parser.state = "running"
          // param-parser = parameter-parser(param-parser, curry.rest)
          // if param-parser.state == "finished" { 
          //   finished-definition = true
          //   param-parser = param-parser-default
          // }
        } else {
          finished-definition = true
          param-parser = param-parser-default
        }
      }
    }
    if param-parser.state == "running" {
      param-parser = parameter-parser(param-parser, line)
      if param-parser.state == "running" { continue }
    } 

    if finished-definition {
      if name != none {
        definitions.push((name: name, description: desc-lines, args: args))
        if curry-info != none {
          definitions.at(-1).parent = process-curry-info(curry-info)
          curry-info = none
        }
      }
      desc-lines = ()
      name = none
      finished-definition = false
    }

    
    if line.starts-with("///") { // is a doc-comment line
      desc-lines.push(line.slice(3))
    } else if desc-lines != () { 
      // look for something to attach the doc-comment to 
      // (a parameter or a definition)
      
      line = line.trim("#", at: start)
      if line.starts-with("let ") and name == none {
        
        found-code = true
        let match = line.match(definition-name-regex)
        if match != none {
          name = match.captures.first()
          if match.captures.at(1) != "" { // it's a function
            param-parser.state = "running"
            param-parser = parameter-parser(param-parser, line.slice(match.end))
          } else { // it's a variable or a function alias
            args = none
            finished-definition = true
            let p = line.slice(match.end)
                  
            let curry = line.slice(match.end).match(curry-matcher)
            if curry != none {
              curry-info = (name: curry.captures.first())
              param-parser = parameter-parser(param-parser, line.slice(match.end + curry.end))
              // param-parser.curry = (name: curry.captures.first(), rest: state.unfinished-param.slice(processed-chars + curry.end))
            }
          }
        }
        
      } else { // neither /// nor (#)let
        if not found-code {
          found-code = true
          module-description = desc-lines.join("\n")
        }
        if name == none {
          desc-lines = ()
        }
        
      }
    }
  }

  definitions = definitions.map(process-definition)
  (
    description: module-description,
    functions: definitions.filter(x => "args" in x),
    variables: definitions.filter(x => "args" not in x),
  )
}

