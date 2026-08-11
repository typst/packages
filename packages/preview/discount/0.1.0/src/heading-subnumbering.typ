#let subtract-arrays(a1, a2) = {
  for (v1, v2) in array.zip(a1, a2, exact: true) {
    (v1 - v2,)
  }
}

#let get-last-heading(max-level) = {
  let headings = for level in range(1, max-level + 1) {
    let headings = query(heading.where(level: level).before(here()))
    if headings != () {
      (headings.last(),)
    } else {
      (none,)
    }
  }

  let last-heading-index = {
    let index = 0
    let counter-value = 0
    for (i, h) in headings.enumerate().rev() {
      let num = if h != none {
        counter(heading).at(h.location())
      } else {
        (0,) * (i + 1)
      }

      if num.at(-1, default: 0) > counter-value {
        index = i
        counter-value = num.at(-2, default: 0)
      }
    }
    index
  }

  headings.at(last-heading-index)
}

#let normalize-length(arr, len) = {
  if arr.len() >= len {
    return arr.slice(0, len)
  } 
  arr + (0,) * (len - arr.len())
}

#let heading-subnumbering(self, level, pattern, heading-keyword: "H") = (..num) => {
  let last-heading = get-last-heading(level)
  if last-heading == none {
    numbering(pattern, ..normalize-length((), level), ..num)
  } else {
    let last-heading-num = counter(heading).at(last-heading.location())
    let self-at-last-heading = counter(self).at(last-heading.location())

    if pattern.contains(heading-keyword) {
      let heading-tag = numbering(last-heading.numbering, ..normalize-length(last-heading-num, level))
      numbering(pattern, ..(subtract-arrays(num.pos(), self-at-last-heading))).replace("H", heading-tag)
    } else {
      numbering(
        pattern,
        ..(normalize-length(last-heading-num, level) + subtract-arrays(num.pos(), self-at-last-heading)),
      )
    }
  }
}
