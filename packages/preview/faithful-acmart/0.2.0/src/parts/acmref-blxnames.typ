// Build and disambiguate BibLaTeX citation names using Biber's rules.

#import "tex.typ": tex-to-string, decode-chars
#import "acmref-common.typ": is-others

#let max-cite-names = 2
#let min-cite-names = 1

// Biber initials names before removing structural braces (Utils.pm, gen_initials).
// Decode character commands first so a foreign letter contributes one initial.
#let outer-braced(s) = {
  let t = s.trim()
  if not (t.starts-with("{") and t.ends-with("}")) { return false }
  let depth = 0
  for (i, c) in t.clusters().enumerate() {
    if c == "{" { depth += 1 } else if c == "}" {
      depth -= 1
      if depth == 0 { return i == t.clusters().len() - 1 }
    }
  }
  false
}
#let split-unbraced(s, sep) = {
  let out = ()
  let cur = ""
  let depth = 0
  for c in s.clusters() {
    if c == "{" { depth += 1; cur += c }
    else if c == "}" { depth -= 1; cur += c }
    else if depth == 0 and c.contains(sep) { if cur != "" { out.push(cur) }; cur = "" }
    else { cur += c }
  }
  if cur != "" { out.push(cur) }
  out
}
#let strip-noinit(s) = {
  s.replace(regex("\\b\\p{Ll}\\p{Ll}\\p{Pd}(\\S)"), m => m.captures.at(0))
    .replace(regex("[\u{02BF}\u{2018}]"), "")
}
// gen_initials takes a second character when the first has the Unicode Diacritic property.
#let word-initial(w) = {
  let raw = w.trim(regex("^\{+"))
  // Slice before TeX input ligatures combine backticks into quotes.
  if raw.starts-with(regex("\p{Diacritic}")) {
    let cl = raw.clusters()
    return tex-to-string(cl.slice(0, calc.min(2, cl.len())).join("")).trim() + "."
  }
  let t = tex-to-string(raw).trim()
  if t == "" { "" } else { t.clusters().first() + "." }
}
// gen_initials uses Unicode Dash; noinit and nosort use the narrower Dash_Punctuation property.
#let blx-dash = regex("\\p{Dash}")
#let name-initials(raw) = {
  if raw.trim() == "" { return "" }
  let raw = decode-chars(raw)
  let whole = outer-braced(raw)
  let part = strip-noinit(raw)
  let hyphenated = w => {
    not outer-braced(w) and w.replace(regex("\\{\\p{Dash}\\}"), "").contains(blx-dash)
  }
  let word = w => {
    if hyphenated(w) { split-unbraced(w, blx-dash).map(word-initial).join("-") }
    else { word-initial(w) }
  }
  let words = if whole { (part,) } else { split-unbraced(part, regex("[\\s~]")) }
  words.map(word).join(" ")
}

// Normalize comparison keys so precomposed and TeX-accented spellings identify the same name.
#let name-forms(n) = {
  let part = raw => str.normalize(tex-to-string(raw), form: "nfc")
  let ini = raw => str.normalize(name-initials(raw), form: "nfc")
  let (family, prefix, given, suffix) = (part(n.last), part(n.von), part(n.first), part(n.jr))
  (
    family: family, prefix: prefix, given: given, suffix: suffix,
    giveni: ini(n.first), prefixi: ini(n.von), suffixi: ini(n.jr),
  )
}

#let name-ladder(f) = if f.given == "" { (f.family,) } else {
  (f.family, f.family + "\u{0}i" + f.giveni, f.family + "\u{0}f" + f.given)
}

#let render-name(f, level, useprefix: false) = {
  if level == 0 { return if useprefix and f.prefix != "" { f.prefix + " " + f.family } else { f.family } }
  let (given, prefix, suffix) = if level == 1 { (f.giveni, f.prefixi, f.suffixi) }
    else { (f.given, f.prefix, f.suffix) }
  (given, prefix, f.family, suffix).filter(p => p != "").join(" ")
}

#let join-label(parts, truncated) = {
  if parts.len() == 0 { "" }
  else if truncated { parts.join(", ") + if parts.len() > 1 { "," } else { "" } + " et al." }
  else if parts.len() <= 2 { parts.join(" and ") }
  else { parts.slice(0, -1).join(", ") + ", and " + parts.last() }
}

#let _join(toks) = toks.join("\u{1}")
#let _bump(counts, k) = counts + ((k): counts.at(k, default: 0) + 1)
#let _add(pool, ns, nskey) = pool + ((ns): pool.at(ns, default: (:)) + ((nskey): true))

#let visible-count(lst, ul) = if lst.names.len() > max-cite-names {
  ul.at(lst.key, default: min-cite-names)
} else { lst.names.len() }

// Biber leaves a name at level zero when even its full form cannot distinguish it.
#let _level(pool, ladder) = {
  for (i, ns) in ladder.enumerate() {
    if pool.at(ns, default: (:)).len() == 1 { return i }
  }
  0
}

// The visible-name pool controls labels; the full pool lets uniquelist evaluate hidden names.
#let un-pass(lists, ul) = {
  let seen = (visible: (:), all: (:))
  let visible-of = lst => {
    let u = ul.at(lst.key, default: 0)
    lst.names.enumerate().map(((i, _)) => lst.morenames
      or lst.names.len() <= max-cite-names
      or i < u
      or i < min-cite-names)
  }
  for lst in lists {
    for (i, vis) in visible-of(lst).enumerate() {
      let ladder = name-ladder(lst.names.at(i))
      let nskey = _join(ladder)
      for ns in ladder {
        if vis { seen.visible = _add(seen.visible, ns, nskey) }
        seen.all = _add(seen.all, ns, nskey)
      }
    }
  }
  let levels = (:)
  let levels-all = (:)
  for lst in lists {
    let vis = visible-of(lst)
    let ladders = lst.names.map(name-ladder)
    levels.insert(lst.key, ladders.enumerate().map(((i, l)) =>
      if vis.at(i) { _level(seen.visible, l) } else { 0 }))
    levels-all.insert(lst.key, ladders.map(l => _level(seen.all, l)))
  }
  (visible: levels, all: levels-all)
}

// Biber, namelist_differs_index: a strict prefix reports its last position, exposing the whole list.
#let _differs-index(list, finals) = {
  let index = none
  for l in finals {
    if l == list { continue }
    let i = 0
    while i < list.len() and i < l.len() and list.at(i) == l.at(i) {
      if index == none or i > index { index = i }
      i += 1
    }
  }
  if index == none { none }
  else if index == list.len() - 1 { index }
  else { index + 1 }
}

#let _differs-nth(list, n, finals) = finals.any(l =>
  l.len() >= list.len()
    and l.at(n - 1) != list.at(n - 1)
    and l.slice(0, n - 1) == list.slice(0, n - 1))

#let ul-pass(lists, levels-all) = {
  let tokens = (:)
  for lst in lists {
    tokens.insert(lst.key, lst.names.enumerate().map(((i, f)) =>
      name-ladder(f).at(levels-all.at(lst.key).at(i))))
  }
  let prefixes = (:)
  let finals = (:)
  for lst in lists {
    let t = tokens.at(lst.key)
    for j in range(1, t.len() + 1) { prefixes = _bump(prefixes, _join(t.slice(0, j))) }
    finals = _bump(finals, _join(t))
  }
  let final-lists = lists.map(lst => tokens.at(lst.key)).dedup()
  let out = (:)
  for lst in lists {
    let t = tokens.at(lst.key)
    let n = t.len()
    let cut = n
    for j in range(1, n + 1) {
      if prefixes.at(_join(t.slice(0, j))) == 1 { cut = j; break }
    }
    let namelist = t.slice(0, cut)
    let value = if cut <= 1 or n <= max-cite-names or (cut <= min-cite-names and min-cite-names != n) {
      none
    } else if finals.at(_join(namelist), default: 0) > 1 {
      // Identical lists cannot disambiguate each other; widen only as far as another list requires.
      let idx = _differs-index(namelist, final-lists)
      if idx == none { none } else { idx + 1 }
    } else if n > cut and not _differs-nth(namelist, cut, final-lists) {
      // The truncation marker already distinguishes this list from the shorter one.
      cut - 1
    } else { cut }
    if value != none { out.insert(lst.key, value) }
  }
  out
}

// Name expansion and list expansion depend on each other; iterate until both stabilize.
#let disambiguate(lists, unique: true) = {
  if not unique {
    return lists.map(lst => {
      let visible = visible-count(lst, (:))
      (key: lst.key, levels: lst.names.map(_ => 0), visible: visible,
       truncated: visible < lst.names.len() or lst.morenames)
    })
  }
  let ul = (:)
  let un = (:)
  let rounds = 0
  while rounds < 16 {
    let pass = un-pass(lists, ul)
    let next-ul = ul-pass(lists, pass.all)
    let settled = pass.visible == un and next-ul == ul
    un = pass.visible
    ul = next-ul
    if settled { break }
    rounds += 1
  }
  lists.map(lst => {
    let visible = visible-count(lst, ul)
    (key: lst.key, levels: un.at(lst.key), visible: visible,
     truncated: visible < lst.names.len() or lst.morenames)
  })
}

#let list-label(lst, dis, useprefix: false) = join-label(
  lst.names.slice(0, dis.visible).enumerate().map(((i, f)) =>
    render-name(f, dis.levels.at(i), useprefix: useprefix)),
  dis.truncated)

// Biber's _getnamehash uses full visible names, even when their printed labels coincide.
#let list-namehash(lst, dis) = {
  let one = f => f.prefix + f.family + f.given + f.suffix
  lst.names.slice(0, dis.visible).map(one).join("") + if dis.truncated { "+" } else { "" }
}

// Biber's _getnamehash_u includes prefixes even when useprefix hides them from the label.
#let list-context(lst, dis) = {
  let one = ((i, f)) => f.prefix + f.family + (
    if dis.levels.at(i) == 1 { f.giveni } else if dis.levels.at(i) == 2 { f.given } else { "" })
  lst.names.slice(0, dis.visible).enumerate().map(one).join("") + if dis.truncated { "+" } else { "" }
}

#let name-list(key, people) = {
  let morenames = people.len() > 0 and is-others(people.last())
  let names = if morenames { people.slice(0, -1) } else { people }
  if names.len() == 0 { return none }
  (key: key, names: names.map(name-forms), morenames: morenames)
}
