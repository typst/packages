#import "/src/constants/document-settings-constants.typ": SINGLE-LINE-PARAGRAPH-LEADING-SIZE
#import "/src/constants/separator-constants.typ": FIGURE-OUTLINE-ENTRY-PREFIX-SEPARATOR
#import "/src/styles/outline-entry-fill-style.typ": outline-entry-fill-style

// Şekiller listesinin girdilerinin stili. [Style of the entries of the figures lists.]
#let figure-outline-entry-style(content) = {
  // Ana hattaki girdi satırlarının içeriğindeki doldurma stili. [Outline entry content's fill style.]
  show: outline-entry-fill-style

  // Ön ek ("Şekil 2.1") kısmını kalın yazıdır ve sonuna bir "." daha koy. [Bold the prefix ("Figure 2.1") and put another "." at the end.]
  show outline.entry: it => {
    link(
      it.element.location(),
      it.indented(
        text(
          weight: "bold",
          it.prefix() + FIGURE-OUTLINE-ENTRY-PREFIX-SEPARATOR,
        ),
        it.inner(),
      ),
    )
  }

  content
}
