// ilkman — im-explain: highlighted term with an arrow to a note in the
// left note column (docs). On slides the note becomes a footnote.
#import "../core.typ": *

#let _notes-bottom = state("ilkman-notes-bottom", (:))

/// ```typst
/// #im-explain("INVITE", fill: "yellow")[Çağrıyı başlatan istek.]
/// ```
#let im-explain(term, fill: "yellow", note) = context {
  let c = ctx()
  let pal = c.pal
  let hl = light-fill(pal, fill, level: "z1")
  let ac = if type(fill) == str { hue-tones(pal, fill).strong } else if type(fill) == color { fill } else { pal.accent }
  let marked = box(fill: hl, inset: (x: 2pt), outset: (y: 2.5pt), radius: 2pt, text(fill: box-ink(c), term))

  if c.mode == "slides" or c.note-column == 0 {
    return marked + footnote(note)
  }

  let pos = here().position()
  let page-w = page.width
  let side = 20mm
  let gap = 6mm
  let usable = page-w - 2 * side
  let note-w = usable * c.note-column - gap
  let note-x = side // page x of the note column

  let note-box = block(
    width: note-w,
    {
      set par(justify: true, first-line-indent: 0pt, spacing: 0.6em)
      set text(size: c.sizes.note * 1em, fill: pal.ink, hyphenate: true)
      note
    },
  )
  let h = measure(note-box).height

  // avoid overlapping a previous note on the same page
  let key = str(pos.page)
  let prev = _notes-bottom.get().at(key, default: 0pt)
  let y = calc.max(pos.y - 0.9em.to-absolute(), prev + 6pt)
  _notes-bottom.update(d => {
    d.insert(key, y + h)
    d
  })

  let dx = note-x - pos.x
  let dy = y - pos.y          // note top, relative to the baseline origin
  let mid = -0.32em.to-absolute() // vertical middle of the term
  let first = dy + 0.6em.to-absolute() // first line of the note
  let ex = dx + note-w + 1.5pt
  let tx = note-x + note-w + gap - pos.x // left edge of the text column
  box(width: 0pt, height: 0pt, {
    place(top + left, dx: dx, dy: dy, note-box)
    place(top + left, curve(
      stroke: 0.6pt + ac,
      curve.move((ex, first)),
      curve.line((ex + gap * 0.45, first)),
      curve.line((tx - 3pt, mid)),
    ))
    place(top + left, dx: tx - 3pt - 1.5pt, dy: mid - 1.5pt, circle(radius: 1.5pt, fill: ac))
  })
  marked
}
