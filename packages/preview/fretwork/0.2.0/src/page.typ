// Page furniture: the title block, section headings, running head and footer.
//
// The layout follows the convention of published guitar sheets: the source or
// arranger small at the top left, the title large and centred, the writing
// credits right-aligned beneath it, the tempo indication and first section
// heading left-aligned above the music, and the copyright centred in the foot.

#import "theme.typ": default-theme
#import "tuning.typ": tunings
#import "render/glyphs.typ" as g

/// A tempo indication such as "Moderately ♩ = 116".
///
/// The note value is a drawn glyph rather than U+2669, which most sans faces do
/// not cover and the rest draw at an unrelated weight.
#let tempo-mark(tempo, words: none, note-flags: 0, theme: default-theme) = {
  let sp = theme.staff-space * 0.8
  let glyph = g.tempo-note(sp, flags: note-flags, fill: theme.color)
  set text(font: theme.font, size: theme.tempo-size, weight: 700, fill: theme.color)
  if words != none [#words #h(0.4em)]
  box(height: glyph.height, baseline: glyph.height * 0.34, glyph.body)
  // Written as a string: an "=" opening a markup block would be read as a
  // heading marker.
  text(" = " + str(tempo))
}

/// A section heading such as "Intro" or "Main Riff / Verse".
#let section(title, theme: default-theme) = block(
  above: theme.staff-space * 1.6,
  below: theme.staff-space * 0.9,
  text(font: theme.font, size: theme.section-size, weight: 700, fill: theme.color, title),
)

/// The writing credits, right-aligned under the title.
#let credits(words: none, music: none, arranged: none, theme: default-theme) = {
  set text(font: theme.font, size: theme.credit-size, fill: theme.color)
  let lines = ()
  if words != none and music != none and words == music {
    lines.push("Words and Music by " + words)
  } else {
    if words != none { lines.push("Words by " + words) }
    if music != none { lines.push("Music by " + music) }
  }
  if arranged != none { lines.push("Arranged by " + arranged) }
  if lines.len() == 0 { return }
  align(right, lines.map(l => [#l]).join(linebreak()))
}

/// Set up a song sheet.
///
/// Used as a show rule:
///
/// ```typc
/// show: song.with(title: "Twelve Past Nine", music: "A. Guitarist", tempo: 132)
/// ```
///
/// `words` and `music` name the writers; passing the same value to both prints
/// the single "Words and Music by" line the published sheets use.
#let song(
  title: none,
  subtitle: none,
  words: none,
  music: none,
  arranged: none,
  artist: none,
  source: none,
  copyright: none,
  tempo: none,
  tempo-words: none,
  tempo-note-flags: 0,
  tuning: tunings.standard,
  capo: 0,
  theme: default-theme,
  paper: "a4",
  margin: (x: 18mm, top: 16mm, bottom: 18mm),
  body,
) = {
  let thm = theme

  set document(title: if title != none { title } else { "" })
  set page(
    paper: paper,
    margin: margin,
    // The running head repeats the identification on continuation pages only,
    // which is what multi-page published sheets do.
    header: context {
      if counter(page).get().first() <= 1 { return }
      set text(font: thm.font, size: thm.copyright-size, fill: thm.faint)
      // Without a source or a title there is nothing to join the page number
      // to, and a leading dash would dangle.
      let parts = (source, title).filter(p => p != none)
      let head = if parts.len() == 0 { "" } else { parts.join(" — ") + " — " }
      align(center, [#head p.#counter(page).display()])
    },
    footer: context {
      if copyright == none { return }
      set text(font: thm.font, size: thm.copyright-size, fill: thm.color)
      align(center, copyright)
    },
  )
  set text(font: thm.font, size: thm.credit-size, fill: thm.color)
  set par(justify: false)

  if source != none {
    text(size: thm.copyright-size * 1.15, fill: thm.faint, source)
    v(thm.staff-space * 0.4)
  }

  if title != none {
    align(center, text(font: thm.font, size: thm.title-size, weight: 700, title))
  }
  if subtitle != none {
    v(thm.staff-space * 0.2)
    align(center, text(size: thm.credit-size * 1.1, fill: thm.faint, subtitle))
  }
  if artist != none {
    v(thm.staff-space * 0.3)
    align(center, text(size: thm.credit-size, fill: thm.faint, artist))
  }

  v(thm.staff-space * 0.5)
  credits(words: words, music: music, arranged: arranged, theme: thm)

  // Performance notes that apply to the whole sheet.
  let notes = ()
  if tuning.name != none and tuning.name != "Standard" {
    notes.push("Tuning: " + tuning.name)
  }
  if capo > 0 { notes.push("Capo " + str(capo)) }

  v(thm.staff-space * 1.2)
  if tempo != none or notes.len() > 0 {
    if tempo != none {
      tempo-mark(tempo, words: tempo-words, note-flags: tempo-note-flags, theme: thm)
    }
    if notes.len() > 0 {
      if tempo != none { h(1.2em) }
      text(size: thm.technique-size, fill: thm.faint, notes.join("  ·  "))
    }
    v(thm.staff-space * 0.6)
  }

  body
}
