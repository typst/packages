#import "stackframe.typ"

#let commit() = (subparse, stack, input) => {
  (ok: true, backtrack: false, next: none, rest: input)
}

#let label(arg: auto) = (subparse, stack, input) => {
  stackframe.tailcall(subparse)(std.label(arg), input)
}

#let eof() = (subparse, stack, input) => {
  if input == "" {
    (ok: true, backtrack: true, next: none, rest: input)
  } else {
    (ok: false, backtrack: true, msg: [Expected end of stream], next: none, stack: stack, rest: input)
  }
}

#let regex(
  arg: auto,
) = {
  let re = std.regex(arg)
  (subparse, stack, input) => {
    if input.starts-with(re) {
      let match = input.find(re)
      let len = match.len()
      let rest = input.slice(len)
      let next = (
        ok: false, backtrack: true, msg: [No longer part of the regex match '#raw(arg)'], stack: stack, rest: rest)
      (ok: true, backtrack: true, val: match, next: next, rest: rest)
    } else {
      (ok: false, backtrack: true, msg: [Regex '#raw(arg)' does not match], next: none, stack: stack, rest: input)
    }
  }
}

#let seq(
  pats: auto,
  array: true,
) = (subparse, stack, input) => {
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
) = (subparse, stack, input) => {
  if input.starts-with(arg) {
    (ok: true, backtrack: true, val: arg, next: none, rest: input.slice(arg.len()))
  } else {
    (ok: false, backtrack: true, msg: [Can't match string "#std.raw(arg)"], next: none, stack: stack, rest: input)
  }
}

#let iter(
  pat: auto,
) = (subparse, stack, input) => {
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
) = (subparse, stack, input) => {
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
) = (subparse, stack, input) => {
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
      env.latest-msg.msg = [#env.latest-msg.msg]
      env.latest-msg
    }
  }
  let env = (
    latest-msg: (ok: false, backtrack: true, stack: stack, msg: [Empty rule], next: none, rest: input),
    backtrack: true,
    pats: pats.rev(),
  )
  step(env)
}

#let maybe(
  pat: auto,
) = (subparse, stack, input) => {
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
) = (subparse, stack, input) => {
  stackframe.pause(subparse)(pat, input)()(
    ans => {
      (: ..ans, backtrack: true)
    }
  )
}

#let drop(
  pat: auto,
) = (subparse, stack, input) => {
  stackframe.pause(subparse)(pat, input)()(
    ans => {
      if "val" in ans {
        let _ = ans.remove("val")
      }
      ans
    }
  )
}

#let rewrite(
  fun: auto,
  pat: auto,
) = (subparse, stack, input) => {
  stackframe.pause(subparse)(pat, input)()(
    ans => {
      if "val" in ans {
        ans.val = fun(ans.val)
      }
      ans
    }
  )
}

#let peek(
  pat: auto,
) = (subparse, stack, input) => {
  stackframe.pause(subparse)(pat, input)()(
    ans => {
      if ans.ok {
        (ok: true, backtrack: ans.backtrack, next: [Successful lookahead of length #{input.len() - ans.rest.len()}], stack: stack, rest: input)
      } else {
        ans
      }
    }
  )
}

#let neg(
  pat: auto,
) = (subparse, stack, input) => {
  stackframe.pause(subparse)(pat, input)()(
    ans => {
      if ans.ok {
        (ok: false, backtrack: ans.backtrack, msg: [Lookahead of length #{input.len() - ans.rest.len()} should have failed], stack: stack, rest: input)
      } else {
        (ok: true, backtrack: ans.backtrack, next: [Lookahead of length #{input.len() - ans.rest.len()} failed as expected], stack: stack, rest: input)
      }
    }
  )
}

