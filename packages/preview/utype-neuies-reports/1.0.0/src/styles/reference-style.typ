#import "/src/constants/separator-constants.typ": APPENDIX-REFERENCE-PREFIX-SEPARATOR

// Atıfların stilini ayarla. [Set the style of references.]
#let reference-style(content) = {
  // Atıfların stilini ayarla. [Set the style of references.]
  show ref: it => {
    let element = it.element
    if it.form != "normal" { return it }
    if element == none { return it }
    if element.func() == heading or element.func() == figure or element.func() == math.equation {
      set text(style: "italic")
      if element.numbering == none {
        link(element.location(), element.supplement + APPENDIX-REFERENCE-PREFIX-SEPARATOR + element.body)
      } else {
        it
      }
    } else {
      // Diğer atıflar olduğu gibi kalsın. [Other references remain as they are.]
      it
    }
  }

  content
}
