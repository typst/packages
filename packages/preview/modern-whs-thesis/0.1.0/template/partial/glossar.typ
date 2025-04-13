#import "@preview/glossarium:0.5.1": (
  make-glossary,
  register-glossary,
  print-glossary,
  gls,
  glspl,
)

#let glossar(acronyms) = {
  heading(outlined: false, numbering: none)[Abkürzungsverzeichnis]

  register-glossary(acronyms)

  let __has_attribute(entry, key) = {
    let attr = entry.at(key, default: "")
    return attr != "" and attr != []
  }

  let has-long(entry) = __has_attribute(entry, "long")

  let my-print-title(entry) = {
    let caption = []
    let txt = text.with(weight: 600)

    if has-long(entry) {
      caption += txt(emph(entry.short)) + [ #h(20pt) ] + entry.long
    } else {
      caption += txt(emph(entry.short))
    }
    return caption
  }

  print-glossary(
    acronyms,
    disable-back-references: true,
    user-print-title: my-print-title,
  )
}
