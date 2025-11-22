#let EOF = str.from-unicode(0)

#let expecting_msg(see, ..expected) = {
  let rune_preprocess(v) = {
    if v == EOF {
      v = "EOF"
    }
    if v.len() == 1 {
      return "'" + v + "'"
    }
    return "<" + v + ">"
  }
  let wants = expected.pos().map(rune_preprocess)
  return "see " + rune_preprocess(see) + " expected " + wants.join(", ")
}

#let runes(s) = {
  let chs = ()
  for ch in s {
    chs.push(ch)
  }
  return chs
}

#let runes_str(runes, start, end) = {
  let a = runes.slice(start, end)
  if a.len() == 0 {
    return ""
  }
  if a.len() == 1 {
    return a.at(0)
  }
  return a.join()
}

#let peek(s, pos) = {
  let slen = s.len()
  if pos >= slen {
    return EOF
  }
  return s.at(pos)
}

#let skip_sp(s, i) = {
  // SPACE TAB \r \n
  while peek(s, i).to-unicode() in (0x20, 0x9, 0xa, 0xd) {
    i += 1
  }
  return i
}
