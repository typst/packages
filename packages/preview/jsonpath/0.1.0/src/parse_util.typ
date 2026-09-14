#import "tokens.typ": token_str
#import "scan_util.typ": runes, peek, EOF
#import "util.typ": ok, error

#let expecting_msg(see, ..expected) = {
  let wants = expected.pos()
  if wants.len() == 0 {
    return "postion " + str(see.pos.start) + ": unexpected token '" + token_str(see) + "'"
  }
  return (
    "postion "
      + str(see.pos.start)
      + ": see '"
      + token_str(see)
      + "' expected "
      + wants.map(it => if it.len() == 1 { "'" + it + "'" } else { "<" + it + ">" }).join(", ")
  )
}

#let string_lit(s) = {
  let q = s.at(0)
  s = s.replace("'", "\\'")
  s = s.replace("\n", "\\n")
  s = s.replace("\r", "\\r")
  s = s.replace("\t", "\\t")
  return "'" + s + "'"
}

#let hex_to_int(hex) = {
  let n = hex.len()
  let i = 1
  let r = 0
  while n > 0 {
    let c = hex.at(n - 1)
    let v = 0
    let code = c.to-unicode()
    if code >= 65 and code <= 70 {
      // A-F
      v = code - 55 // A-F -> 10-15
    } else if code >= 97 and code <= 102 {
      // a-f
      v = code - 87 // a-f -> 10-15
    } else if code >= 48 and code <= 57 {
      // 0-9
      v = code - 48
    } else {
      return error("invalid hex digit: " + c)
    }
    r += v * i
    i *= 16
    n -= 1
  }
  return ok(r)
}

#let parse_string(s) = {
  if s == "" { return "" }
  let r = ()
  let runes = runes(s)
  let quoter = runes.at(0)
  let pos = 1
  let ch = peek(runes, pos)
  while ch != EOF {
    if ch == quoter {
      break
    }
    if ch != "\\" {
      r.push(ch)
    } else {
      pos += 1
      ch = peek(runes, pos)
      if ch == "t" {
        r.push("\t")
      } else if ch == "n" {
        r.push("\n")
      } else if ch == "r" {
        r.push("\r")
      } else if ch == "\\" {
        r.push("\\")
      } else if ch == "/" {
        r.push("/")
      } else if ch == quoter {
        r.push(quoter)
      } else if ch == "u" {
        let hex = ""
        for _ in range(4) {
          pos += 1
          ch = peek(runes, pos)
          if ch == EOF { break }
          hex += ch
        }
        let (v, err) = hex_to_int(hex)
        if err != none { return error(err) }
        r.push(str.from-unicode(v))
      } else {
        r.push(ch)
      }
    }
    pos += 1
    ch = peek(runes, pos)
  }
  return ok(r.join())
}
