#let parse-codepoints(path) = {
  // Read the file and split it into lines
  let content = read(path)
  let lines = content.split("\n")
  
  // Build a dictionary mapping keys to hex strings
  let codepoints = (:)
  for line in lines {
    let trimmed = line.trim()
    if trimmed != "" {
      let parts = trimmed.split(regex("\\s+"))
      if parts.len() >= 2 {
        codepoints.insert(parts.at(0), parts.at(1))
      }
    }
  }
  return codepoints
}

#let get-codepoint(codepoints, name) = {
  // Look up the query key and convert the hex string to a character/codepoint
  let hex-str = codepoints.at(name, default: none)
  if hex-str != none {
    // Parse hex string into a decimal integer and convert to a unicode character
    // let code = int("0x" + hex-str)
    let code = int(hex-str, base: 16)
    return code
  } else {
    panic("Key not found: " + query-key)
  }
}


#let symbol(name, font:none, codepoints:none) = {
  let codepoint = get-codepoint(codepoints, name)
  text(font:font, str.from-unicode(codepoint))
}

// Outlined, Rounded, Sharp
#let init(style:"Outlined") = {
  let path = "variablefont/MaterialSymbols"+style+"[FILL,GRAD,opsz,wght].codepoints"
  let codepoints = parse-codepoints(path)

  return (name) => {
    return symbol(name, font:"Material Symbols "+style, codepoints: codepoints)
  }
}
