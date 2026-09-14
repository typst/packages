#import "elements.typ"
#import "draw.typ"
#import draw: cetz

#let parse(content) = {
  if content == none {
    return ()
  }

  let code = content.split("\n")

  let elems = ()

  let i = 0
  while i < code.len() {
    let line = code.at(i).trim()

    if line == "" {
      i += 1
      continue
    }

    if line.starts-with("if ") {
      let (left, right) = ((), ())
      let left-branch = true
      let if-count = 0

      i += 1
      while if-count > 0 or code.at(i).trim() not in ("endif", "end if") {
        let code-line = code.at(i).trim()

        if code-line.starts-with("if") {
          if-count += 1
        } else if if-count > 0 and code-line in ("endif", "end if") {
          if-count -= 1
        }

        if code.at(i).trim() == "else" and if-count == 0 {
          left-branch = false
        } else if left-branch {
          left += (code.at(i),)
        } else {
          right += (code.at(i),)
        }

        i += 1
      }

      elems += elements.branch(
        line.slice(3).trim(),
        parse(left.join("\n")),
        parse(right.join("\n")),
        column-split: if left == () {
          25%
        } else if right == () {
          75%
        } else {
          50%
        },
      )
    } else if line.starts-with("switch ") {
      let branches = (:)
      let default = ()
      let default-branch = false
      let switch-count = 0

      i += 1
      while switch-count > 0 or code.at(i).trim() not in ("endswitch", "end switch") {
        let code-line = code.at(i).trim()

        if switch-count > 0 and code-line in ("endswitch", "end switch") {
          switch-count -= 1
        }

        if code-line.starts-with("case ") and switch-count == 0 {
          default-branch = false
          let key = code-line.slice("case ".len())
          branches.insert(key, ())
        } else if code-line.starts-with("default") and switch-count == 0 {
          default-branch = true
        } else if branches.len() > 0 or default-branch {
          if code-line.starts-with("switch") {
            switch-count += 1
          }
          if default-branch {
            default += (code.at(i),)
          } else {
            branches.at(branches.keys().at(-1)) += (code.at(i),)
          }
        }

        i += 1
      }

      for (key, value) in branches {
        branches.at(key) = parse(value.join("\n"))
      }
      branches.default = parse(default.join("\n"))

      elems += elements.switch(
        line.slice("switch ".len()).trim(),
        branches,
      )
    } else if line.starts-with("while ") {
      let children = ()
      let while-count = 0

      i += 1
      while while-count > 0 or code.at(i).trim() not in ("endwhile", "end while") {
        let code-line = code.at(i).trim()

        if code-line.starts-with("while") {
          while-count += 1
        } else if while-count > 0 and code-line in ("endwhile", "end while") {
          while-count -= 1
        }

        children += (code.at(i),)
        i += 1
      }

      elems += elements.loop(
        line.slice(6),
        parse(children.join("\n")),
      )
    } else if line.starts-with("function ") {
      let children = ()

      i += 1
      while code.at(i).trim() not in ("endfunction", "end function") {
        children += (code.at(i),)
        i += 1
      }

      elems += elements.function(
        line.slice(9),
        parse(children.join("\n")),
      )
    } else {
      if line.starts-with("|") and line.ends-with("|") {
        elems += elements.call(line.slice(1, -1).trim())
      } else if line.contains("<-") {
        let (a, b) = line.split("<-")
        elems += elements.assign(a.trim(), b.trim())
      } else {
        elems += elements.process(line)
      }
    }

    i += 1
  }

  return elems
}

#let themes = (
  default: (
    empty: rgb("#fffff3"),
    process: rgb("#fceece"),
    call: rgb("#fceece"),
    branch: rgb("#fadad0"),
    loop: rgb("#dcefe7"),
    switch: rgb("#fadad0"),
    parallel: rgb("#dcefe7"),
    function: rgb("#ffffff"),
  ),
  colorful: (
    empty: color.map.turbo.first(),
    process: color.map.turbo.at(int(color.map.turbo.len() / 4)),
    call: color.map.turbo.at(int(color.map.turbo.len() / 4)),
    branch: color.map.turbo.at(int(color.map.turbo.len() / 8)),
    loop: color.map.turbo.at(int(color.map.turbo.len() / 16)),
    switch: color.map.turbo.at(int(color.map.turbo.len() / 8)),
    parallel: color.map.turbo.at(int(color.map.turbo.len() / 16)),
    function: rgb("#ffffff"),
  ),
  nocolor: (
    empty: white,
    process: white,
    call: white,
    branch: white,
    loop: white,
    switch: white,
    parallel: white,
    function: white,
  ),
  greyscale: (
    empty: luma(100%),
    process: luma(90%),
    call: luma(90%),
    branch: luma(75%),
    loop: luma(75%),
    switch: luma(50%),
    parallel: luma(75%),
    function: luma(100%),
  ),
)

#let diagram(
  width: 100%,
  font: ("Verdana", "Arial", "Geneva"),
  fontsize: 10pt,
  inset: .5em,
  theme: themes.default,
  stroke: 1pt + black,
  labels: (),
  ..cetz-args,
  elements,
) = {
  if type(elements) == content and elements.func() == raw {
    elements = elements.text
  }
  if type(elements) != array {
    elements = parse(elements)
  }

  layout(size => {
    let width = width
    if type(width) == ratio {
      width *= size.width
    }

    set text(font: font, size: fontsize)
    draw.cetz.canvas(
      ..cetz-args,
      {
        draw.diagram((0, 0), elements, width: width, inset: inset, theme: theme, stroke: stroke, labels: labels)
      },
    )
  })
}

#let shneiderman(..args) = (
  body => {
    show raw.where(block: true, lang: "nassi"): diagram.with(..args)
    body
  }
)

#let struktog(json-data, ..nassi-args) = {
  let parse-struktog(node) = {
    let strukt-def = ()

    while node != none {
      if node.type == "Placeholder" { return strukt-def }

      if node.type == "FunctionNode" {
        strukt-def.push(
          "function "
            + if node.text == "" {
              "func(" + node.parameters.join(", ") + ")"
            } else { node.text + "(" + node.parameters.join(", ") + ")" },
        )
        strukt-def += parse-struktog(node.child)
        strukt-def.push("end function")
      } else if node.type == "TaskNode" {
        strukt-def.push(node.text)
      } else if node.type == "BranchNode" {
        strukt-def.push("if " + node.text)
        strukt-def += parse-struktog(node.trueChild)
        strukt-def += ("else",)
        strukt-def += parse-struktog(node.falseChild)
        strukt-def.push("end if")
      } else if node.type == "CountLoopNode" {
        strukt-def.push("while " + node.text)
        strukt-def += parse-struktog(node.child)
        strukt-def.push("end while")
      } else if node.type == "CaseNode" {
        strukt-def.push("switch " + node.text)
        // strukt-def += parse-struktog(node.trueChild)
        // strukt-def += ("else",)
        // strukt-def += parse-struktog(node.falseChild)

        for case-node in node.cases {
          strukt-def.push("case " + case-node.text)
          strukt-def += parse-struktog(case-node.followElement)
        }

        if node.defaultOn {
          strukt-def.push("default")
          strukt-def += parse-struktog(node.defaultNode.followElement)
        }

        strukt-def.push("end switch")
      }
      node = node.followElement
    }

    return strukt-def
  }

  let struktog-parsed = parse-struktog(json-data)
  diagram(raw(struktog-parsed.join("\n")), ..nassi-args)
}

#let struktog(json-data, ..nassi-args) = {
  let parse-struktog(node) = {
    let strukt-def = ()

    while node != none {
      if node.type == "Placeholder" {
        strukt-def += elements.empty()
      } else if node.type == "FunctionNode" {
        strukt-def += elements.function(
          if node.text == "" {
            "func(" + node.parameters.sorted(key: p => p.pos).map(p => p.parName).join(", ") + ")"
          } else {
            node.text + "(" + node.parameters.sorted(key: p => p.pos).map(p => p.parName).join(", ") + ")"
          },
          parse-struktog(node.child),
        )
      } else if node.type == "TaskNode" {
        strukt-def += elements.process(node.text)
      } else if node.type == "InputNode" {
        strukt-def += elements.process("E: " + node.text)
      } else if node.type == "OutputNode" {
        strukt-def += elements.process("A: " + node.text)
      } else if node.type == "BranchNode" {
        strukt-def += elements.branch(
          node.text,
          parse-struktog(node.trueChild),
          parse-struktog(node.falseChild),
        )
      } else if node.type in ("CountLoopNode", "HeadLoopNode") {
        strukt-def += elements.loop(
          node.text,
          parse-struktog(node.child),
        )
      } else if node.type == "FootLoopNode" {
        strukt-def += elements.loop(
          node.text,
          test-last: true,
          parse-struktog(node.child),
        )
      } else if node.type == "CaseNode" {
        let cases = (:)
        for case-node in node.cases {
          let case-text = case-node.text
          let i = 0
          while case-text in cases {
            i += 1
            case-text = case-node.text + " " + str(i)
          }
          cases.insert(case-text, parse-struktog(case-node.followElement))
        }
        if node.defaultOn {
          cases.insert("default", parse-struktog(node.defaultNode.followElement))
        }

        strukt-def += elements.switch(
          node.text,
          cases,
        )
      }
      node = node.at("followElement", default: none)
    }

    return strukt-def
  }

  let struktog-parsed = parse-struktog(json-data)
  diagram(struktog-parsed, ..nassi-args)
}
