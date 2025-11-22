#let hamnosys(it) = {
  let hamnosys-translations = json("hamnosys.json")
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
