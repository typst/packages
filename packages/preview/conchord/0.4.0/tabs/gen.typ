#let to-int(s) = {
  if s.matches(regex("^\d+$")).len() != 0 { int(s) } else { if s == "x" {s} else {panic("Bad number: " + s) }}
}

#let parse-note(n, s-num: 6) = {
  if n == "p" {
    return ()
  }

  return n.split("+").map(
    n => {
      let cont = if n.starts-with("^") { "^" } else if n.starts-with("`") { "`" } else { none }
      if cont != none { n = n.slice(1) }
      let bend = n.split("b")
      let bend-return = false
      if bend.len() > 1 {
        n = bend.at(0)
        bend = bend.at(-1)
        if bend.ends-with("r") {
          bend = bend.slice(0, -1)
          bend-return = true
        }
      }
      else {
        bend = none
      }

      let vib = n.ends-with("v")
      if vib {n = n.slice(0, -1)}

      let coords = n.split("/").map(to-int)
      if coords.len() != 2 {
        panic("Specify fret and string numbers separated by `/`: " + n)
      }
      if coords.at(1) > s-num {
        panic("Too large string number: " + n.at(1))
      }
      let res = (fret: coords.at(0), string: coords.at(1))
      res.connect = cont
      res.bend = bend
      res.bend-return = bend-return
      res.vib = vib

      return res
    },
  )
}

#let gen(s, s-num: 6) = {
  if type(s) == content {
    s = s.text
  }

  let bars = ()
  let cur-bar = ()
  let cur-dur = 2
  let code-mode = false
  let code = ()

  while regex("rep\((.*), (\d*)\)") in s {
    s = s.replace(regex("rep\((.*), (\d*)\)"), m => (m.captures.at(0) + " ") * int(m.captures.at(1)))
  }

  if regex("rep\(") in s {
    panic("rep expression not finished")
  }

  for (n, s,) in s.split(regex("\s+")).zip(s.matches(regex("\s+")) + ("",)) {
    if n == "##" and not code-mode {
      code-mode = true
      continue
    }

    if code-mode {
      if n.starts-with("##") {
        code-mode = false
        cur-bar.push(("##", n.slice(2), code.join()))
        code = ()
        continue
      }

      code.push(n)
      code.push(s.text)
      continue
    }

    if n == "<" {
      cur-bar.push(n)
      continue
    }

    if n == ":|" {
      cur-bar.push(":")
      cur-bar.push("|")
      cur-bar.push("<")
      cur-bar.push("||")
      bars.push(cur-bar)
      cur-bar = ()
      n = n.slice(2)
      continue
    }

    if n == "|:" {
      cur-bar.push("||")
      cur-bar.push("|")
      cur-bar.push(":")
      bars.push(cur-bar)
      cur-bar = ()
      n = n.slice(2)
      continue
    }

    if n == "||" {
      cur-bar.push("|")
      cur-bar.push("<")
      cur-bar.push("||")
      bars.push(cur-bar)
      cur-bar = ()
      continue
    }

    if n == "|" {
      cur-bar.push("|")
      bars.push(cur-bar)
      cur-bar = ()
      continue
    }

    if n == "\\" {
      //cur-bar.push("|")
      cur-bar.push("\\")
      bars.push(cur-bar)
      cur-bar = ()
      continue
    }

    if n == "" {
      continue
    }

    let note-and-dur = n.split("-")
    if note-and-dur.len() > 2 or note-and-dur == 0 {
      panic("Specify one duration per note")
    }

    if note-and-dur.len() == 2 {
      let dur = note-and-dur.at(1)
      let mul = 0.0
      while dur.ends-with(".") {
        mul -= calc.log(1.5) / calc.log(2)
        dur = dur.slice(0, -1)
      }
      cur-dur = to-int(dur) + mul
    }

    cur-bar.push((notes: parse-note(note-and-dur.at(0), s-num: s-num), duration: cur-dur))
  }

  if cur-bar.len() > 0 {
    bars.push(cur-bar)
  }

  if bars.len() > 0 and bars.at(-1) != ("\\") {
    bars.push(("\\",))
  }
  return bars
}
