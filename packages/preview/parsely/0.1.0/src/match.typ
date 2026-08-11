#import "util.typ"

#let slot(name, ..args) = {
  let (name, many, greedy) = name.match(regex("([^*?]*)(\*?)(\??)")).captures
  metadata((
    slot: name,
    many: many == "*",
    greedy: greedy != "?",
    ..args.named(),
  ))
}

#let is-slot(it, ..args) = (
  type(it) == content and
  it.func() == metadata and
  type(it.value) == dictionary and
  "slot" in it.value and
  args.named().pairs().all(((k, v)) => {
    it.value.at(k, default: false) == v
  })
)
#let slot-name(it) = it.value.slot

#let substitute-slots(it, map) = util.walk-content(it, post: it => {
  if is-slot(it) and slot-name(it) in map {
    map.at(slot-name(it))
  } else {
    it
  }
})


#let tight = metadata((tight: true))
#let loose = metadata((loose: true))

#let tighten(tokens) = {
  let out = ()
  let pending = ()
  let to-remove = false
  for t in tokens {
    if util.is-space(t) {
      if not to-remove { pending.push(t) }
    } else if t in (tight, loose) {
      to-remove = true
      out.push(t)
      pending = ()
    } else {
      if not to-remove {
        out += pending
        pending = ()
      }
      to-remove = false
      out.push(t)
    }
  }
  return out
}


#let match-sequence(pattern, expr, match: none, ctx: (:)) = {
  pattern = tighten(util.as-array(pattern))

  let (pi, ei) = (0, 0)
  let is-tight = false
  let is-loose = false
  let p-space = false
  while pi < pattern.len() {

    // no match if expression tokens run out before whole pattern has been used
    if ei >= expr.len() { return false }

    let p = pattern.at(pi)
    let e = expr.at(ei)

    if p == tight {
      is-tight = true
      pi += 1
      continue
    }

    if p == loose {
      is-loose = true
      p = [ ]
    }

    // pattern is a slot
    if is-slot(p, many: true) {
      let p-next = pattern.at(pi + 1, default: none)
      if p-next == none {
        // trailing slot matches rest of expr
        ctx.insert(slot-name(p), expr.slice(ei).join())
        
      } else {
        // slot matches until next pattern token is seen
        let ei-end = ei
        if is-slot(p, greedy: false) {
          while ei-end < expr.len() {
            let m = match(p-next, expr.at(ei-end), ctx: ctx)
            if m != false { break }
            ei-end += 1
          }
        } else {
          ei-end = expr.len() - 1
          while ei-end >= ei {
            let m = match(p-next, expr.at(ei-end), ctx: ctx)
            if m != false { break }
            ei-end -= 1
          }
        }
        ctx.insert(slot-name(p), expr.slice(ei, ei-end).join())
        pi += 1
        ei = ei-end
        continue 
      }


    } else {
      let m = match(p, e, ctx: ctx)
      if m == false {
        // ignore whitespace mismatches
        if util.is-space(p) and not is-loose {
          pi += 1
          continue
        } else if util.is-space(e) and not is-tight {
          ei += 1
          continue
        }
        return false
      } else {
        ctx = m
      }
    }

    pi += 1
    ei += 1

    is-tight = false
  }

  return (ctx, expr.slice(ei))
}


// unwrap structures that should be ignored for matching
#let unwrap(it) = {
  if type(it) == content {
    if it.func() == math.equation {
      return unwrap(it.body)
    } else if repr(it.func()) == "styled" {
      return unwrap(it.child)
    }
  }
  return it
}

#let match(pattern, expr, ctx: (:)) = {
  pattern = unwrap(pattern)
  expr = unwrap(expr)

  let test-slot-guard(slot, expr) = {
    if "any" in slot {
      // this is a sum slot / enum slot
      for subpattern in slot.any {
        let m = match(subpattern, expr)
        if m == false { continue }
        return m
      }
      false
    } else if "guard" in slot {
      let guard = slot.guard
      if type(guard) == regex {
        guard = it => util.stringify(it).match(guard) != none
      }
      if (guard)(expr) { (:) } else { false }
    } else {
      (:)
    }
  }

  if is-slot(pattern) {
    let name = slot-name(pattern)

    // by default, don't let slots match whitespace
    if util.is-space(expr) { return false }
    if name in ctx {
      if ctx.at(name) != expr { return false }
    } else {
      let guard = test-slot-guard(pattern.value, expr)
      if guard == false { return false }
      ctx.insert(name, expr)
      ctx += guard
    }

  // pattern is an uncalled content function
  } else if type(pattern) == function and type(expr) == content {
    if pattern == expr.func() {
      for (k, v) in expr.fields() {
        ctx.insert(k, v)
      }
    } else {
      return false
    }

  // pattern is normal content
  } else if type(pattern) == content {
    if type(expr) != content { return false }

    if pattern.func() != expr.func() { return false }

    for (key, left) in pattern.fields() {
      if key not in expr.fields() { return false }
      let right = expr.at(key)
      ctx = match(left, right, ctx: ctx)
      if ctx == false { return false }
    }

  } else if type(pattern) == array {
    if type(expr) != array { return false }

    let m = match-sequence(pattern, expr, ctx: ctx, match: match)
    if m == false { return false }
    let (new-ctx, rest) = m
    ctx = new-ctx


  } else {
    if pattern != expr { return false }
  }

  return ctx
}