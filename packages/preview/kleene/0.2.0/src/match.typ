#import "stackframe.typ"

#let apply-rw(fun, data) = {
  if "val" in data {
    if fun == none {
      let _ = data.remove("val")
    } else {
      data.val = fun(data.val)
    }
  }
  data
}

#let commit() = (subparse, input) => {
  (ok: true, backtrack: false, next: none, rest: input)
}

#let eof() = (subparse, input) => {
  if input == "" {
    (ok: true, backtrack: true, next: none, rest: input)
  } else {
    (ok: false, backtrack: true, msg: [Expected end of stream], next: none, rest: input)
  }
}

#let regex(
  arg: auto,
) = {
  let re = std.regex("^(" + arg + ")")
  (subparse, input) => {
    let match = input.find(re)
    if match != none {
      let len = match.len()
      let rest = input.slice(len)
      let next = (
        ok: false, backtrack: true, msg: [No longer part of the regex match '#raw(arg)'], rest: rest)
      (ok: true, backtrack: true, val: match, next: next, rest: rest)
    } else {
      (ok: false, backtrack: true, msg: [Regex '#raw(arg)' does not match], next: none, rest: input)
    }
  }
}

#let seq(
  pats: auto,
  array: true,
) = (subparse, input) => {
  let step(env) = {
    if env.pats.len() > 0 {
      let pat = env.pats.pop()
      stackframe.pause(subparse)(pat, env.input)(env)(
        (ans, env) => {
          if not ans.backtrack {
            env.backtrack = false
          }
          if not ans.ok {
            return (: ..ans, backtrack: env.backtrack)
          }
          if ans.next != none {
            env.next = ans.next
          }
          if "val" in ans {
            env.matches.push(ans.val)
          }
          env.input = ans.rest
          return step(env)
        }
      )
    } else {
      if (not array) and env.matches.len() == 1 {
        env.matches = env.matches.at(0)
      }
      (ok: true, backtrack: env.backtrack, val: env.matches, next: env.next, rest: env.input)
    }
  }
  let env = (
    matches: (),
    backtrack: true,
    input: input,
    next: none,
    pats: pats.rev(),
  )
  step(env)
}

#let str(
  arg: auto,
) = (subparse, input) => {
  if input.starts-with(arg) {
    (ok: true, backtrack: true, val: arg, next: none, rest: input.slice(arg.len()))
  } else {
    (ok: false, backtrack: true, msg: [Can't match string "#std.raw(arg)"], next: none, rest: input)
  }
}

#let iter(
  pat: auto,
) = (subparse, input) => {
  let step(env) = {
    stackframe.pause(subparse)(pat, env.input)(env)(
      (ans, env) => {
        if not ans.backtrack { env.backtrack = false }
        if not ans.ok {
          if env.count == 0 {
            return (: ..ans, backtrack: env.backtrack)
          } else {
            return (ok: true, backtrack: env.backtrack, val: env.matches, next: ans, rest: env.input)
          }
        }
        env.count += 1
        if "val" in ans {
          env.matches.push(ans.val)
        }
        if ans.ok and ans.rest == env.input {
          if env.matches.len() == 0 {
            return (: ..ans, backtrack: env.backtrack)
          } else {
            return (ok: true, backtrack: env.backtrack, val: env.matches, next: ans, rest: env.input)
          }
        }
        env.input = ans.rest
        step(env)
      }
    )
  }
  let env = (
    matches: (),
    count: 0,
    backtrack: true,
    input: input,
  )
  step(env)
}

#let star(
  pat: auto,
) = (subparse, input) => {
  let step(env) = {
    stackframe.pause(subparse)(pat, env.input)(env)(
      (ans, env) => {
        if not ans.backtrack { env.backtrack = false }
        if not ans.ok {
          return (ok: true, backtrack: env.backtrack, val: env.matches, next: ans, rest: env.input)
        }
        if "val" in ans {
          env.matches.push(ans.val)
        }
        if ans.ok and ans.rest == env.input {
          return (ok: true, backtrack: env.backtrack, val: env.matches, next: ans, rest: env.input)
        }
        env.input = ans.rest
        step(env)
      }
    )
  }
  let env = (
    matches: (),
    backtrack: true,
    input: input,
  )
  step(env)
}


#let fork(
  pats: auto,
) = (subparse, input) => {
  let step(env) = {
    if env.pats.len() > 0 {
      let pat = env.pats.pop()
      stackframe.pause(subparse)(pat, input)(env)(
        (ans, env) => {
          if not ans.backtrack {
            env.backtrack = false
          }
          if ans.ok {
            return (: ..ans, backtrack: env.backtrack)
          } else if not env.backtrack {
            return ans
          } else {
            env.latest-msg = ans
          }
          step(env)
        }
      )
    } else {
      //env.latest-msg.msg = [#env.latest-msg.msg]
      env.latest-msg
    }
  }
  let env = (
    latest-msg: (ok: false, backtrack: true, msg: [Empty rule], next: none, rest: input),
    backtrack: true,
    pats: pats.rev(),
  )
  step(env)
}

#let maybe(
  pat: auto,
) = (subparse, input) => {
  stackframe.pause(subparse)(pat, input)()(
    ans => {
      if ans.ok {
        (: ..ans, val: (ans.at("val", default: none),))
      } else if not ans.backtrack {
        ans
      } else {
        (ok: true, backtrack: true, val: (), next: ans, rest: input)
      }
    }
  )
}

#let try(
  pat: auto,
) = (subparse, input) => {
  stackframe.pause(subparse)(pat, input)()(
    ans => {
      (: ..ans, backtrack: true)
    }
  )
}

#let peek(
  pat: auto,
) = (subparse, input) => {
  stackframe.pause(subparse)(pat, input)()(
    ans => {
      if ans.ok {
        (ok: true, backtrack: ans.backtrack, next: none, rest: input)
      } else {
        ans
      }
    }
  )
}

#let neg(
  pat: auto,
) = (subparse, input) => {
  stackframe.pause(subparse)(pat, input)()(
    ans => {
      if ans.ok {
        (ok: false, backtrack: ans.backtrack, msg: [Lookahead of length #{input.len() - ans.rest.len()} should have failed], rest: input)
      } else {
        (ok: true, backtrack: ans.backtrack, next: none, rest: input)
      }
    }
  )
}

#let error(
  msg: auto,
  pat: auto,
) = (subparse, input) => {
  stackframe.pause(subparse)(pat, input)()(
    ans => {
      if ans.ok {
        (ok: false, backtrack: false, msg: msg, rest: input)
      } else {
        (ok: false, backtrack: true, msg: [No match], next: none, rest: input)
      }
    }
  )
}

#let hint(
  len: auto,
  mapping: auto,
) = (subparse, input) => {
  let key = if input.len() >= len {
    input.slice(0, len)
  } else {
    "__"
  }
  if key in mapping {
    stackframe.tailcall(subparse)(mapping.at(key), input)
  } else if "__" in mapping {
    stackframe.tailcall(subparse)(mapping.__, input)
  } else {
    (ok: false, backtrack: true, msg: [Recognized none of the hinted prefixes], rest: input)
  }
}

