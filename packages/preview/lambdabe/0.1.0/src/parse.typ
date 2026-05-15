#import "struct.typ": *

// multi char variable names should be manually tokenized
#let parse(..s, color: auto) = {
  s = s.pos()
  assert(s.all(si => type(si) == str))
  s = s.map(si => si.replace("/", "λ"))
  if s.len() == 1 {
    s = s //
      .first()
      .replace(" ", "")
      .replace("/", "λ")
      .clusters()
  }
  assert(s.len() > 0)
  // Returns: (the index of the char after current expression, parse result).
  let impl(i) = {
    if s.at(i) == "λ" {
      i += 1
      let vars = ()
      while s.at(i) != "." {
        vars.push(var(s.at(i), color: color))
        i += 1
      }
      assert(vars.len() >= 1)
      i += 1
      let (j, body) = impl(i)
      (j, func(vars, body, color: color))
    } else {
      // apply
      let items = ()
      while i < s.len() {
        if s.at(i) == "(" {
          i += 1
          let (j, item) = impl(i)
          items.push(item)
          assert(s.at(j) == ")")
          i = j + 1
        } else if s.at(i) == "λ" {
          let (j, item) = impl(i)
          items.push(item)
          i = j
        } else if s.at(i) != ")" {
          items.push(var(s.at(i), color: color))
          i += 1
        } else {
          // s.at(i) == ")"
          break
        }
      }
      assert(items.len() >= 1)
      (
        i,
        if items.len() == 1 {
          items.first()
        } else {
          apply(..items, color: color)
        },
      )
    }
  }
  let (j, result) = impl(0)
  assert(j == s.len())
  result
}
