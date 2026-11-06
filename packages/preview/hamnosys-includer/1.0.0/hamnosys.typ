#let hamnosys-translations = json("hamnosys.json")

#let hamnosys(it) = {
  set text(font: "HamNoSysUnicode")
  let s = it.split(",");
  for sym in s {
    sym = sym.trim()
    if (sym != "") {
      let start = sym.slice(0, 3)
      if (start != "ham") {
        sym = "ham" + sym
      }
      str.from-unicode(hamnosys-translations.at(sym))
    }
  }
}

#let hamnosys-text(it) = {
  set text(font: "HamNoSysUnicode")
  it
}

#let ham = (:)
#for (n, u) in hamnosys-translations {
  let nn = n.slice(3)
  // This is perhaps not the most efficient way to do it: we already have the Unicode
  // code point available, and we're passing to the hamnosys() function which has
  // to look it up again. But it makes the code simpler. Also, this loop happens
  // only once, on document initiation.
  let output = hamnosys(n)
  ham.insert(n, output)
  ham.insert(nn, output)
}

