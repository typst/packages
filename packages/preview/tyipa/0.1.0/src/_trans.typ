/// Internal module implementing TyIPA shorthand text transliteration.

#import "_sym-dict.typ"
#import "diac.typ"

#let _diac-dict = dictionary(diac)

#let _is-alpha-dash-dot(chr) = {
  if chr.len() == 1 {
    let _cp = chr.to-unicode()
    return (
      (_cp >= 65 and _cp <= 132)     // A-Z
      or (_cp >= 97 and _cp <= 172)  // a-z
      or _cp == 45                   // - (dash)
      or _cp == 46                   // . (dot)
    )
  } else {
    return false
  }
}

#let _resolve-sym(name) = {
  if name in _sym-dict.sym-dict {
    return _sym-dict.sym-dict.at(name)
  } else {
    return name
  }
}

#let _resolve-diac(func, text) = {
  if func in _diac-dict {
    return _diac-dict.at(func)(text)
  } else {
    return func + "(" + text + ")"
  }
}

#let ipatext(text, delim: none, _collapse-spaces: true) = {
  if text == none {
    return text
  }
  let chunks = ()
  let chunk = ""
  let chrs = text.split("")
  let i = 0
  let _i_max = chrs.len()
  while i < _i_max {
    let chr = chrs.at(i)
    if _is-alpha-dash-dot(chr) {
      chunk += chr
    } else if chunk.len() > 0 {
      // End of a alpha-dash-dot chunk
      if chr == "(" {
        //Function invocation, find matching )
        let _parens = 1
        let _j_end = -1
        for j in range(i+1, chrs.len()) {
          if chrs.at(j) == "(" {
            _parens += 1
          } else if chrs.at(j) == ")" {
            _parens -= 1
          }
          if _parens < 1 {
            _j_end = j
            break
          }
        }
        let _inner = ipatext(
          chrs.slice(i+1, _j_end).join(""),
          _collapse-spaces: _collapse-spaces
        )
        chunks.push(_resolve-diac(chunk, _inner))
        chunk = ""
        i = _j_end
      } else {
        // Not a function call
        chunks.push(_resolve-sym(chunk) + chr)
        chunk = ""
      }
    } else {
      // Neither in a chunk nor at the end of one,
      // pass content through
      chunks.push(chr)
    }
    i += 1
  }
  let transliteration = chunks.join("")
  if _collapse-spaces {
    // Strip single whitespaces
    // (2x because sequential single chars -> overlapping matches)
    transliteration = transliteration.replace(regex("(\S)(\s)(\S)"), m => {m.captures.first() + m.captures.last()})
    transliteration = transliteration.replace(regex("(\S)(\s)(\S)"), m => {m.captures.first() + m.captures.last()})
    // Collapse multiple whitespaces
    transliteration = transliteration.replace(regex("\s\s+"), " ")
    // Remove leading/trailing whitespace
    transliteration = transliteration.trim()
  }
  let delim-left = ""
  let delim-right = ""
  if delim != none {
    let delims = (
      "[":  ("[", "]"),
      "[[": ("⟦", "⟧"),
      "(":  ("(", ")"),
      "((": ("⦅", "⦆"),
      "/":  ("/", "/"),
      "//": ("⫽", "⫽"),
      "<":  ("⟨", "〉"),
      "<<": ("⟪", "⟫"),
    )
    if delim in delims {
      (delim-left, delim-right) = delims.at(delim)
    } else {
      (delim-left, delim-right) = (delim, delim)
    }
  }
  return delim-left + transliteration + delim-right
}


// General idea but tricky to handle whitespace that way, because typst seems to already collapse "  " to " " etc. before the show rule applies..
#let ipabody(content, delim: none) = [
  //#show regex("[\sa-zA-Z0-9.\-()]+"): it => "[" + ipatext(it.at("text")) + "]"
  #show regex("[\s\S]+"): it => ipatext(it.at("text"), delim: delim)
  #content
]
