#import "aref.typ" as r
#import "quote.typ" as q
#import "told.typ" as t

#let header_supplements_hun = (
  part: "rész",
  volume: "kötet",
  chapter: "fejezet",
  section: "szakasz",
  subsection: "alszakasz",
  subsubsection: "alalszakasz",
)

#let supplements_hun = (
  equation: "egyenlet",
  image: "ábra",
  table: "táblázat",
  page: "oldal",
  raw: "kódrészlet",
)

/// Az alapértelmezett beállítások, amelyek átadásra kerülnek az @cmd:init függvénynek.
/// -> dict
#let config_default = (
  lang: "hu",
  headers: header_supplements_hun,
  supplements: supplements_hun,
)

/// A modul inicializálása.
#let init(
  /// Beállítások
  conf: config_default,
  /// Minden a ```typ #show: pt.init``` sor után
  it,
) = {
  set text(lang: conf.lang)

  // Page supplement
  set page(supplement: conf.supplements.page)

  // Header supplement setup
  show heading.where(level: 1): set heading(supplement: conf.headers.part)
  show heading.where(level: 2): set heading(supplement: conf.headers.volume)
  show heading.where(level: 3): set heading(supplement: conf.headers.chapter)
  show heading.where(level: 4): set heading(supplement: conf.headers.section)
  show heading.where(level: 5): set heading(supplement: conf.headers.subsection)
  show heading.where(level: 6): set heading(
    supplement: conf.headers.subsubsection,
  )

  // Image, table and raw supplements
  show figure.where(kind: image): set figure(supplement: conf.supplements.image)
  show figure.where(kind: table): set figure(supplement: conf.supplements.table)
  show figure.where(kind: raw): set figure(supplement: conf.supplements.raw)

  // Equation supplement
  show math.equation: set math.equation(supplement: conf.supplements.equation)

  // Sets up Hungarian caption style
  show figure.caption: it => {
    let counter_text = context it.counter.display(it.numbering)
    box(counter_text + " " + it.supplement + it.separator) + it.body
  }

  // Sets up Hungarian reference style.
  show ref: it => {
    //
    // Page reference
    //
    if it.form == "page" {
      let num_style = none
      if page.numbering == none {
        num_style = "1"
      } else {
        num_style = page.numbering
      }
      let pn = numbering(num_style, ..counter(page).at(it.target))

      // if page numbering is without closing dot add it in the reference
      if pn.last() != "." {
        pn += "."
      }

      // compose supplement
      let supp = it.supplement
      if it.supplement == auto {
        supp = page.supplement
      }

      link(it.target, box(pn + " " + supp))
      return
      //
      // Normal reference
      //
    } else {
      // Headings
      if it.element != none and it.element.func() == heading {
        let nums = numbering(
          it.element.numbering,
          ..counter(heading).at(it.target),
        )

        let supp = it.supplement
        if it.supplement == auto {
          supp = it.element.supplement
        }

        link(it.target, box(nums + " " + supp))
        return
      }

      // Figures
      if it.element != none and it.element.func() == figure {
        let nums = numbering(
          it.element.numbering,
          ..it.element.counter.at(it.target),
        )
        let supp = it.supplement
        if it.supplement == auto {
          if (
            it.element.kind == image
              or it.element.kind == table
              or it.element.kind == raw
          ) {
            supp = it.element.supplement
          } else {
            return it // for unknown types use their default setup
          }
        }

        link(it.target, box(nums + " " + supp))
        return
      }

      // Equations
      if it.element != none and it.element.func() == math.equation {
        // numbering
        let nums = numbering(
          it.element.numbering,
          ..counter(math.equation).at(it.target),
        )

        // supplement
        let supp = it.supplement
        if it.supplement == auto {
          supp = conf.supplements.equation
        }

        link(it.target, box(nums + " " + supp))
        return
      }
    }
    it // ref: fallback to default
  }

  // Add main content
  it
}

/// Referencia hivatkozás létrehozása megfelelő nagybetűs névelővel.
///
/// ```example
/// #Aref(<checkmark>) azt mutatja...
/// ```
/// -> content
#let Aref(
  /// A hivatkozni kívánt címke. -> label
  target,
  /// A hivatkozás típusa. -> "normal" | "page"
  form: "normal",
  /// Tetszőleges azonosító szöveg. -> none | auto | content | function
  supplement: auto,
) = r.Aref(target, form: form, supplement: supplement)

/// Referencia hivatkozás létrehozása megfelelő kisbetűs névelővel.
///
/// ```example
/// Ahogy #aref(<intro>)ben bemutattuk.
/// ```
///
/// -> content
#let aref(
  /// A hivatkozni kívánt címke. -> label
  target,
  /// A hivatkozás típusa. -> "normal" | "page"
  form: "normal",
  /// Tetszőleges azonosító szöveg. -> none | auto | content | function
  supplement: auto,
) = r.aref(target, form: form, supplement: supplement)

/// Magyar tipográfiai szabályoknak megfelelő idézőjel.
///
/// ```example
/// #hq[...#hq[...#hq[minta]...]...]
/// ```
///
/// -> content
#let hq(
  /// A szöveg, amit idézőjelbe kell tenni. -> content
  body,
) = q.hq(body)

/// Referenciák magyar toldalékolása.
/// ```example
/// #told(<funkciok>, "es")
/// ```
/// ```example
/// #told(<funkciok>, "es", form: "page")
/// ```
/// -> content
#let told(
  /// A toldalékolni kívánt elem. -> label
  prefix,
  /// Az első toldalék. -> str
  rag,
  /// A második toldalék. -> str | none
  rag2: none,
  /// A hivatkozás típusa. -> "normal" | "page"
  form: "normal",
  /// Tetszőleges azonosító szöveg. -> none | auto | content | function
  supplement: auto,
) = t.told(prefix, rag, rag2: rag2, form: form, supplement: supplement)

/// @cmd:Aref és @cmd:told kombinációja.
#let Atold(target, rag, rag2: none, form: "normal", supplement: auto) = {
  r.anoref(target, form: form, supplement: "")
  t.told(target, rag, rag2: rag2, form: form, supplement: supplement)
}

/// @cmd:aref és @cmd:told kombinációja.
#let atold(target, rag, rag2: none, form: "normal", supplement: auto) = {
  r.anoref(target, form: form, supplement: "")
  t.told(target, rag, rag2: rag2, form: form, supplement: supplement)
}
