#let geometry(doc, target: none) = {

  // Eigenes Layout, abgeleitet von Heftrandlayout
  if target == "digital" {
    set page(
      paper: "a4",
      margin: (
        top: 18mm,

        left: 20mm,
        right: 20mm,
        
        bottom: 20mm
      ),
    )
    doc
  }

  // TUD Heftrandlayout (z.B. allgemeine Word Vorlage)
  if target == "print" {
    set page(
      paper: "a4",
      binding: left,
      margin: (
        top: 18mm,
        
        left: 25mm,
        right: 10mm,
        
        bottom: 20mm
      ),
    )

    doc
  }

  // TUD Heftrandlayout (z.B. allgemeine Word Vorlage)
  if target == "print-alternating" {
    set page(
      paper: "a4",
      binding: left,
      margin: (
        top: 18mm,
        
        inside: 25mm,
        outside: 10mm,
        
        bottom: 20mm
      ),
    )

    doc
  }
}