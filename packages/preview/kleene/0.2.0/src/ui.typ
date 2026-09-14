#import "match.typ"
#import "analyze.typ"

// Transforms a string to show invisible characters (spaces, linebreaks, tabs).
// Returns the resulting text as a #typ.raw block.
// -> content
#let show-invisible(
  // Input text to transform.
  // -> str
  line,
  // By default, linebreaks (```typc "\n"```) are replaced by a substitute character.
  // If this option is enabled, the formatted text will still have
  // the original linebreaks in addition to the marker.
  // -> bool
  preserve-linebreaks: false,
  // Which color the special characters should be shown as.
  // -> color
  dim-color: black.lighten(70%),
  // Determines the substitution dictionary to use.
  // - ```typc "special"```: `\n` and `\t`.
  // - ```typc "unicode"```: `¤`, `»`, `␣`, `∅` denote respectively
  //   linebreak, tab, space, eof.
  // -> str
  mode: "special",
) = {
  let dicts = (
    special: (
      "\n": "\\n" + if preserve-linebreaks { "\n" } else { "" },
      "\t": "\\t",
      empty: "",
    ),
    unicode: (
      "\n": "¤" + if preserve-linebreaks { "\n" } else { "" },
      "\t": "»",
      " ": "␣",
      empty: "∅",
    ),
  )
  let dict = dicts.at(mode)
  if line.len() == 0 {
    set text(fill: gray)
    raw(dict.empty)
  }
  line.clusters().map(c => {
    if c in dict {
      set text(fill: dim-color)
      raw(dict.at(c))
    } else {
      raw(c)
    }
  }).join()
}

// Runs the unit tests attached to a grammar
// See @cmd:prelude:yy and @cmd:prelude:nn for details.
// Runs all positive and negative tests, and formats them in a table.
// -> content
#let check-unit-tests(
  // The grammar to test, as constructed by @cmd:kleene:grammar.
  // -> grammar
  grammar,
  // Left recursion analysis
  // -> dictionary
  lrec: none,
  // Closure analysis
  // -> dictionary
  closed: none,
  // Pass an array or a function to filter a subset of the tests.
  // -> auto | array | function
  select: auto,
  // Whether to display the final tally of passed/failed tests.
  // -> bool
  total: true,
) = {
  import "parse.typ": parse
  let status(ok, expect: true, validated: auto, skip: false) = {
    let color = if skip == true {
      orange
    } else if validated == auto {
      if ok == expect {
        green
      } else {
        red
      }
    } else if validated == none {
      if ok == expect {
        green
      } else {
        yellow
      }
    } else {
      red
    }
    rect(width: 5mm, height: 5mm, fill: color)
  }
  let evaluate(ruleid, tt, expect: true, validate: auto) = {
    let input-box = box(fill: gray.lighten(90%), inset: 3pt)[#text(fill: blue)[#show-invisible(tt.text, mode: "unicode", preserve-linebreaks: true)]]

    if (lrec != none and ruleid in lrec.dangerous) {
      let incr = ("skip",)
      let arr = (
        table.cell[#input-box],
        status(false, skip: true),
        [_Skipped due to null cycle_],
      )
      return (incr, arr)
    }
    if (closed != none and ruleid in closed.dangerous) {
      let incr = ("skip",)
      let arr = (
        table.cell[#input-box],
        status(false, skip: true),
        [_Skipped due to gaps in grammar_],
      )
      return (incr, arr)
    }


    let incr = ()
    let ans = parse(grammar, label(ruleid), tt.text)
    if ans.ok == expect {
      incr.push("ok")
    } else {
      incr.push("err")
    }
    let validated = if validate != auto {
      incr.push("validation-required")
      if ans.ok == expect {
        incr.push("validated")
        validate(tt.text, if ans.ok { ans.val } else { ans.msg })
      }
    }

    let rowspan = 1
    let line1 = (
      status(ans.ok, expect: expect),
      [#if ans.ok { ans.val } else { ans.msg }],
    )
    let line2 = if validated != none {
      incr.push("invalid")
      rowspan = 2
      (
        status(true, validated: validated),
        [Validation failed: #validated],
      )
    } else {
      ()
    }
    let arr = (
      table.cell(rowspan: rowspan)[#input-box],
      ..line1,
      ..line2,
    )
    (incr, arr)
  }
  let outcomes = (ok: 0, err: 0, validation-required: 0, validated: 0, invalid: 0, skip: 0)
  for (ruleid, rule) in grammar {
    if select != auto {
      if type(select) == array and ruleid not in select { continue }
      if type(select) == function and not select(ruleid) { continue }
    }
    if type(rule) != dictionary {
      panic("Rule is incorrectly constructed :" + repr(rule))
    }
    if rule.yy != () {
      table(columns: (2fr, auto, 5fr),
        table.header(
          [*#ruleid*], [],
          text(fill: green)[*examples*],
        ),
        ..for (yy, validate) in rule.yy {
          for tt in yy {
            let (incr, arr) = evaluate(ruleid, tt, expect: true, validate: validate)
            for i in incr { outcomes.at(i) += 1 }
            arr
          }
        }
      )
    }
    if rule.nn != () {
      table(columns: (2fr, auto, 5fr),
        table.header(
          [*#ruleid*], [],
          text(fill: red)[*counterexamples*],
        ),
        ..for (nn, validate) in rule.nn {
          for tt in nn {
            let (incr, arr) = evaluate(ruleid, tt, expect: false, validate: validate)
            for i in incr { outcomes.at(i) += 1 }
            arr
          }
        }
      )
    }
  }
  if total {
    box(table(columns: 4,
      [parsing], [#status(true)], [#status(false)], [#status(true, skip: true)],
      [#{outcomes.ok + outcomes.err + outcomes.skip}], [#{outcomes.ok}], [#{outcomes.err}], [#{outcomes.skip}],
    ))
    h(1cm)
    if outcomes.validated > 0 {
      box(table(columns: 4,
        [validation], [#status(true)], [#status(false, validated: none)], [#status(false)],
        [#{outcomes.validation-required}], [#{outcomes.validated - outcomes.invalid}], [#{outcomes.validation-required - outcomes.validated}], [#{outcomes.invalid}]
      ))
    }

  }
}

#let show-empty(grammar, nonempty) = {
  let tab = ((), (), ())
  for (id, _) in grammar {
    let idx = if nonempty.at(id) == none {
      1
    } else if nonempty.at(id) == true {
      0
    } else {
      2
    }
    tab.at(idx).push(id)
  }
  let titles = ([Provably nonempty], [Inconclusive], [Possibly empty])
  table(columns: 2,
    ..(
      for (title, rules) in titles.zip(tab) {
        if rules != () {
          ([*#title*], rules.map(i => raw("<" + i + ">")).join[, ])
        }
      }
    )
  )
}

#let show-leftrec(lrec) = {
  if lrec.cycles != () {
    table(
      columns: 2,
      [*Null cycle detected*], lrec.cycles.at(0).map(id => raw("<" + id + ">")).join[ $->$ ],
    )
    [_The grammar is left-recursive: #raw("<" + lrec.cycles.at(0).at(0) + ">") can loop back
    to itself without consuming any input_]
  }
}

#let show-closed(closed) = {
  if closed.undef != () {
    table(
      columns: 2,
      [*Placeholder rule found*], closed.undef.map(id => raw("<" + id + ">")).join([, ]),
    )
  }
  if closed.dangling != () {
    table(
      columns: 2,
      [*Not defined*], closed.dangling.map(id => raw("<" + id + ">")).join([, ]),
    )
  }
  if closed.undef != () or closed.dangling != () {
    [_The grammar is incomplete: some rules are undefined_]
  }
}

/// Runs the unit tests attached to a grammar and a number of sanity checks.
/// See @cmd:prelude:yy and @cmd:prelude:nn for details.
/// Runs all positive and negative tests, and formats them in a table.
/// -> content
#let test(
  /// The grammar to test, as constructed by @cmd:kleene:grammar.
  /// -> grammar
  grammar,
  /// Pass an array or a function to filter a subset of the tests.
  /// -> auto | array | function
  select: auto,
  /// Whether to display the final tally of passed/failed tests.
  /// -> bool
  total: true,
) = {
  let empty = analyze.check-empty(grammar)
  show-empty(grammar, empty)
  let lrec = analyze.check-leftrec(grammar, empty)
  show-leftrec(lrec)
  let closed = analyze.check-closed(grammar)
  show-closed(closed)
  check-unit-tests(grammar, lrec: lrec, closed: closed, select: select, total: total)
}

#let extract-line(input, idx) = {
  let lines = input.split("\n")
  let cumul = 0
  for (lineid, line) in lines.enumerate() {
    if lineid < lines.len() - 1 {
      line += "\n"
    }
    cumul += line.len()
    if cumul >= idx {
      return (line, lineid + 1, idx - (cumul - line.len()))
    }
  }
}

#let error-box = rect.with(stroke: red)

#let show-span(input, idx, highlight-len: 1, msg: none) = {
  let (ctx, lineid, offset) = extract-line(input, idx)
  box({
    {
      set text(fill: gray)
      raw(str(lineid) + " | ")
    }
    show-invisible(ctx, mode: "unicode")
    linebreak()
    raw(" " * (str(lineid).len() + 3 + offset))
    {
      set text(fill: red)
      raw("^" * highlight-len + " ")
      msg
    }
    linebreak()
  })
}

#let show-span2(input, idx, highlight-pre: 1, highlight-post: 1, msg-pre: none, msg-post: none) = {
  let (ctx, lineid, offset) = extract-line(input, idx)
  box({
    {
      set text(fill: gray)
      raw(str(lineid) + " | ")
    }
    show-invisible(ctx, mode: "unicode")
    linebreak()
    let pre-len = highlight-pre
    let post-len = calc.max(0, calc.min(highlight-post, ctx.len() - offset))
    raw(" " * (str(lineid).len() + 2))
    {
      set text(fill: green)
      raw("~" * offset + "|")
    }
    {
      set text(fill: red)
      raw("^" * post-len + " ")
      msg-post
      if post-len == 0 {
        [ on next line]
      }
    }
    linebreak()
    {
      set text(fill: green)
      raw(" " * (str(lineid).len() + 3 + offset - 1))
      raw("| ")
      msg-pre
    }
  })
}

#let error-inner(input, ans, fallback-stack: none) = {
  if "msg" not in ans {
    panic("No error message to print", ans)
  }
  if "stack" not in ans and fallback-stack == none {
    panic("Lost track of the recursive stack", ans)
  }
  box[
    #show-span(input, input.len() - ans.rest.len(), msg: ans.msg) \
    While trying to parse: #{ans.at("stack", default: fallback-stack).map(s => raw("<" + str(s) + ">")).join[ $->$ ]}.
  ]
}

#let error(input, ruleid, ans) = {
  error-box[
    #text(fill: red)[*Parsing error:*]
    The input does not match the expected format. \
    #error-inner(input, ans)
  ]
}

#let incomplete(input, ruleid, ans) = {
  error-box[
    #text(fill: red)[*Parsing error:*]
    The parser did not consume the entire input. \
    #show-span2(input, input.len() - ans.rest.len(), msg-post: [Surplus characters], highlight-post: ans.rest.len(), msg-pre: [Valid #raw("<" + str(ruleid) + ">")]) \
    #{
      while ans.next != none and ans.next.ok {
        ans.next = ans.next.next
      }
      if ans.next != none [
      Hint: halted due to the following: \
      #error-inner(input, ans.next, fallback-stack: ans.stack)
    ]}
  ]
  /*
  error-box[
    #ans
  ]
  */
}

