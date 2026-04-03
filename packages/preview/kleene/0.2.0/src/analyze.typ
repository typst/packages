#import "match.typ"

#let reachable(grammar) = {
  let explore(pat) = {
    if "lab" in pat {
      (pat.lab,)
    } else if "pat" in pat {
      explore(pat.pat)
    } else if "pats" in pat {
      for sub in pat.pats {
        explore(sub)
      }
    } else {
      ()
    }
  }
  let reach = (:)
  for (id, rule) in grammar {
    reach.insert(id, explore(rule.pat).dedup())
  }
  reach
}

#let reachable-closure(grammar, start) = {
  let step = reachable(grammar)
  let reach = start
  while true {
    let new = ()
    for id in reach {
      for next in step.at(id, default: ()) {
        if next not in reach {
          reach.push(next)
          new.push(next)
        }
      }
    }
    if new == () {
      break
    }
  }
  reach
}

#let inv-reachable-closure(grammar, start) = {
  let step = reachable(grammar)
  let reach = start
  while true {
    let new = ()
    for (ruleid, _) in grammar {
      if ruleid not in reach {
        for next in step.at(ruleid) {
          if next in reach {
            reach.push(ruleid)
            new.push(ruleid)
            break
          }
        }
      }
    }
    if new == () {
      break
    }
  }
  reach
}

#let check-closed(
  grammar,
) = {
  let all-rules = grammar.keys()
  let all-reachable = reachable-closure(grammar, all-rules)
  let dangling = all-reachable.filter(r => r not in all-rules)
  let undef = all-rules.filter(r => grammar.at(r).pat == ())
  (
    undef: undef,
    dangling: dangling,
    dangerous: inv-reachable-closure(grammar, dangling + undef),
  )
}

#let check-empty(
  grammar,
) = {
  let _and(l, r) = {
    if l == false or r == false {
      false
    } else if l == true {
      r
    } else if r == true {
      l
    } else {
      none
    }
  }
  let _or(l, r) = {
    if l == true or r == true {
      true
    } else if l == false {
      r
    } else if r == false {
      l
    } else {
      none
    }
  }
  let known-nonempty(pat, known) = {
    if pat == () {
      none
    } else if "lab" in pat {
      known.at(pat.lab, default: none)
    } else if pat.call == match.regex {
      let re = std.regex(pat.arg)
      if "".starts-with(re) {
        false
      } else {
        true
      }
    } else if pat.call in (match.star, match.commit, match.maybe, match.peek, match.neg, match.eof) {
      false
    } else if pat.call == match.str {
      pat.arg != ""
    } else if pat.call == match.fork {
      let ans = true
      for sub in pat.pats {
        ans = _and(ans, known-nonempty(sub, known))
      }
      ans
    } else if pat.call == match.hint {
      let ans = true
      for (_, sub) in pat.mapping {
        ans = _and(ans, known-nonempty(sub, known))
      }
      ans
    } else if pat.call == match.seq {
      let ans = false
      for sub in pat.pats {
        ans = _or(ans, known-nonempty(sub, known))
      }
      ans
    } else if pat.call in (match.error,) {
      true
    } else if pat.call in (match.iter, match.try) {
      known-nonempty(pat.pat, known)
    } else {
      panic(pat)
    }
  }
  let emps = (:)
  while true {
    let new = ()
    for (id, rule) in grammar {
      if emps.at(id, default: none) == none {
        let nonempty = known-nonempty(rule.pat, emps)
        emps.insert(id, nonempty)
        if nonempty != none {
          new.push(id)
        }
      }
    }
    if new == () {
      break
    }
  }
  emps
}

#let check-leftrec(grammar, nonempty) = {
  let next-left(pat) = {
    if pat == () {
      ((), true)
    } else if "lab" in pat {
      if nonempty.at(pat.lab, default: none) == true {
        ((pat.lab,), false)
      } else {
        ((pat.lab,), true)
      }
    } else if pat.call == match.regex {
      let re = std.regex(pat.arg)
      if "".starts-with(re) {
        ((), true)
      } else {
        ((), false)
      }
    } else if pat.call == match.str {
      if pat.arg != "" {
        ((), false)
      } else {
        ((), true)
      }
    } else if pat.call == match.fork {
      let ans = ()
      let after = true
      for sub in pat.pats {
        let (also, go-on) = next-left(sub)
        ans += also
        after = after or go-on
      }
      (ans, after)
    } else if pat.call == match.hint {
      let ans = ()
      let after = true
      for (_, sub) in pat.mapping {
        let (also, go-on) = next-left(sub)
        ans += also
        after = after or go-on
      }
      (ans, after)
    } else if pat.call == match.seq {
      let ans = ()
      for sub in pat.pats {
        let (also, go-on) = next-left(sub)
        ans += also
        if not go-on {
          return (ans, false)
        }
      }
      (ans, true)
    } else if pat.call in (match.commit,) {
      ((), true)
    } else if pat.call in (match.maybe, match.peek, match.neg, match.star) {
      let (ans, _) = next-left(pat.pat)
      (ans, true)
    } else if pat.call in (match.eof,) {
      ((), false)
    } else if pat.call in (match.iter, match.try, match.error) {
      next-left(pat.pat)
    } else {
      panic(pat)
    }
  }

  let next = (:)
  for (id, rule) in grammar {
    let (nl, _) = next-left(rule.pat)
    next.insert(id, nl)
  }
  let chains = ()
  for (id, nxs) in next {
    for nx in nxs {
      chains.push((id, nx))
    }
  }
  let cycles = ()
  while true {
    let new = ()
    for c in chains {
      if c.first() == c.last() {
        cycles.push(c)
      } else if c.last() in c.slice(0, -1) {
      } else {
        for nx in next.at(c.last(), default: ()) {
          new.push((..c, nx))
        }
      }
    }
    chains = new
    if new == () {
      break
    }
  }
  (
    cycles: cycles,
    dangerous: inv-reachable-closure(grammar, cycles.flatten()),
  )
}

