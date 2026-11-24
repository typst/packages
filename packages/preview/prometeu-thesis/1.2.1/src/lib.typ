#import "colors.typ"
#import "cover.typ": render-cover
#import "state.typ"

#let thesis(
  author: "",
  title: [],
  date: [],
  supervisors: (),
  cover-images: (),
  cover-gray-images: (),
  school: [],
  degree: [],
  language: "en",
) = doc => {
  if language != "en" and language != "pt" {
    panic("Language must be either 'en' or 'pt'")
  }

  set text(
    font: "NewsGotT",
    size: 12pt,
    lang: language,
    region: if language == "pt" { "PT" } else { "US" },
  )
  // NewsGotT's font kerning makes accented letters (é, á, ...) overlap the letters next to them. Disable kerning to fix this.
  show regex("[À-ÿ]"): set text(kerning: false)

  set par(leading: 0.95em, spacing: 1.9em, justify: true)
  show footnote.entry: set text(size: 8pt)

  // Typst takes the superscript size from the font's own metrics, and NewsGotT
  // declares a very small one (4.8pt at 12pt text). 
  // Setting it explicitly to be readable, but still smaller than the text.
  show footnote: set super(size: 0.7em)
  show footnote.entry: set super(size: 0.7em)

  show footnote: set text(fill: colors.blueuminho)
  show cite: set text(fill: colors.blueuminho)
  show link: set text(fill: colors.blueuminho)

  set document(title: title, author: author)

  state.author.update(author)
  state.title.update(title)
  state.date.update(date)
  state.language.update(language)

  render-cover(
    author: author,
    title: title,
    date: date,
    supervisors: supervisors,
    images: cover-images,
    gray-images: cover-gray-images,
    school: school,
    degree: degree,
    language: language,
  )

  // Fake italic as NewsGotT doesn't have an italic style.
  // Same slant as Word's fake italic (a 1/3 shear, about 18.4deg).
  let slant = 18.4deg
  // We try to slant around half the x-height (0.475em) so the spaces on both sides stay even.
  // but skew can only pivot at the baseline or the centre, so we pivot at the baseline and shift left.
  let shift = calc.tan(slant) * 0.475em / 2
  let fake-italic(word) = box(move(dx: -shift, skew(ax: -slant, origin: bottom, reflow: false, word)))

  show emph: it => {
    // Slant each word separately so lines can still break between them.
    // Change regex if italic is broken when changing lines
    show regex("\S+"): fake-italic
    it
  }

  set page(margin: 25mm, numbering: "1")

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    block(inset: (top: 30mm, bottom: 15mm), {
      if it.supplement != [] and it.numbering != none {
        block(
          text(15pt, {
            it.supplement + [ ] + counter(heading).display(it.numbering)
          }),
          below: 7mm,
        )
      }
      block(text(18pt, it.body))
    })
  }

  show heading.where(level: 2): it => {
    set text(16pt)
    set block(above: 2.5em, below: 1.5em)
    it
  }

  doc
}

// Appendix numbering: headings as `A`, `A.1`, ... and figures as `A.1`, `A.2`, `B.1`, ...
#let appendix(body) = {
  counter(heading).update(0)
  set heading(
    numbering: "A.1",
    supplement: context if text.lang == "pt" [Apêndice] else [Appendix],
  )

  show heading.where(level: 1): it => {
    // Restart figure numbering in each appendix. Each figure kind has its own
    // counter, so reset all of them, including custom ones like `figure(kind: "algorithm")`
    context for kind in query(figure).map(f => f.kind).dedup() {
      counter(figure.where(kind: kind)).update(0)
    }
    it
  }
  set figure(numbering: n => numbering("A.1", counter(heading).get().first(), n))

  body
}
