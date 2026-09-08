// Small brace-depth scanners shared by the BibTeX reader and BibLaTeX renderer.

#let ws = (" ", "\n", "\t", "\r")

#let match-delim(cp, i, open: "{", close: "}") = {
  let depth = 0
  let j = i
  while j < cp.len() {
    let c = cp.at(j)
    if c == "\\" { j += 2; continue }
    if open == "(" and c == "{" {
      j = match-delim(cp, j) + 1
      continue
    }
    if open == "(" and c == "\"" {
      j += 1
      let brace-depth = 0
      while j < cp.len() and not (cp.at(j) == "\"" and brace-depth == 0) {
        let q = cp.at(j)
        if q == "\\" { j += 2; continue }
        if q == "{" { brace-depth += 1 } else if q == "}" { brace-depth -= 1 }
        j += 1
      }
      j += 1
      continue
    }
    if c == open { depth += 1 } else if c == close {
      depth -= 1
      if depth == 0 { return j }
    }
    j += 1
  }
  j
}

#let match-brace(cp, i) = match-delim(cp, i)

// Split a name/list field on a top-level whitespace-bounded "and".
#let split-list-and(raw, trim: false, filter-empty: false) = {
  let cp = raw.codepoints()
  let n = cp.len()
  let parts = ()
  let cur = ""
  let depth = 0
  let i = 0
  while i < n {
    let c = cp.at(i)
    if c == "{" { depth += 1 } else if c == "}" { depth -= 1 }
    if (depth == 0 and c == "a" and i > 0 and i + 3 < n
        and cp.at(i + 1) == "n" and cp.at(i + 2) == "d"
        and cp.at(i - 1) in ws and cp.at(i + 3) in ws) {
      parts.push(if trim { cur.trim() } else { cur })
      cur = ""
      i += 3
      continue
    }
    cur += c; i += 1
  }
  parts.push(if trim { cur.trim() } else { cur })
  if filter-empty { parts.filter(p => p != "") } else { parts }
}
