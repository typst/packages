// pdf.artifact wrapping and PDF metadata setup — a dedicated module for
// accessibility-adjacent code, not scattered across whichever files happen
// to need it.

#let artifact(body, kind: "layout") = pdf.artifact(kind: kind, body)

#let set-metadata(name: none, tagline: none, doc-kind: "CV", keywords: none) = {
  let role = if tagline != none { tagline } else { "" }
  let kw = if keywords != none {
    keywords
  } else if tagline != none {
    tagline.split("·").map(s => s.trim())
  } else {
    ()
  }
  set document(
    title: name + (if role != "" { " — " + role } else { "" }) + " — " + doc-kind,
    author: name,
    description: role,
    keywords: kw,
  )
}
