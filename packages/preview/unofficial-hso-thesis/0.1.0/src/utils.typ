#let thesis-page-numbering(..args) = context {
  let page-num = args.pos().first()
  
  let roman-matter-start = query(<roman-matter-start>)
  let main-matter-start = query(<main-matter-start>)
  
  // 1. Hauptteil (Arabisch)
  if main-matter-start.len() > 0 {
    let main-start = main-matter-start.first().location().page()
    if page-num >= main-start {
      return numbering("1", page-num - main-start + 1)
    }
  }

  // 2. Römischer Teil (Verzeichnisse, Erklärung, etc.)
  if roman-matter-start.len() > 0 {
    let roman-start = roman-matter-start.first().location().page()
    if page-num >= roman-start {
      return numbering("I", page-num - roman-start + 1)
    }
  }

  // 3. Davor (z.B. Deckblatt) -> Keine Nummerierung
  return none
}
