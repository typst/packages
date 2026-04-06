#import "stackframe.typ"
#import "operators.typ" as ops
#import "match.typ"


// Manages the mutual recursion between operators
// and tracks the current state of the rule stack.
#let _subparse(rules, stack) = (id, input) => {
  let stack = stack
  if type(id) != dictionary {
    panic(id, stack)
  }
  let rws = ()
  while "lab" in id {
    stack.push(id.lab)
    if "rw" in id {
      rws.push(id.rw)
    }
    let rule = rules.at(id.lab)
    let select = rule.pat
    id = select
  }
  let call = id.remove("call")
  if "rw" in id {
    rws.push(id.remove("rw"))
  }
  stackframe.pause(call(..id))(_subparse(rules, stack), input)(stack)(
    (ans, stack) => {
      if "stack" not in ans {
        ans.stack = stack
      }
      if "val" in ans {
        for rw in rws.rev() {
          if rw == none {
            let _ = ans.remove("val")
            break
          } else if rw == auto {
            panic("rw=auto should be elided at this stage")
          } else {
            ans.val = rw(ans.val)
          }
        }
      }
      ans
    }
  )
}

#let subparse(..args) = stackframe.run(_subparse(..args))

/// Initiate parsing.
/// Returns a dictionary of the result.
/// The boolean `ok` indicates if the parsing is successful.
/// If #typ.v.true, then `val` contains the last produced value.
/// Otherwise `msg` contains the error message in a manner than can be displayed.
/// -> (ok: bool, val: any, msg: content)
#let parse(
  /// Typically constructed by @cmd:kleene:grammar.
  /// -> grammar
  rules,
  /// Indicates the entry point for the parsing.
  /// -> label
  pat,
  /// Input data to parse.
  /// -> str
  input,
) = {
  let ans = subparse(rules, ())(ops.auto-cast(pat), input)
  if not ans.ok {
    import "ui.typ"
    (ok: false, val: none, msg: ui.error(input, pat, ans))
  } else if ans.rest != "" {
    import "ui.typ"
    (ok: false, val: none, msg: ui.incomplete(input, pat, ans))
  } else {
    (ok: true, val: ans.at("val", default: none), msg: none)
  }
}

