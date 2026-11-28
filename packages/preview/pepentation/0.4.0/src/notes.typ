// Speaker notes: content that is invisible on the slide but travels with it
// into a pdfpc sidecar. A note is stored as zero-size metadata carrying plain
// text, and `pdfpc-payload` collects those markers into the single JSON object
// that `typst query` (or, on Typst 0.15, the bundle asset API) writes out.

#import "utils.typ"
#import "bundle.typ": _within-current-document

/// Returns the plain text a note contributes to the pdfpc sidecar.
///
/// Strings are used as-is and a `raw` block keeps its text verbatim so a
/// fenced Markdown note survives intact. Any other content is flattened with
/// `utils.plain-text`.
///
/// = Parameters
/// - `body` (content): The note body.
///
/// = Returns
/// The note as a string, without surrounding whitespace.
#let _note-text(body) = {
  let text = if body == none {
    ""
  } else if type(body) == str {
    body
  } else if type(body) == content and body.func() == raw {
    body.text
  } else if type(body) == content and body.has("children") {
    let meaningful = body.children.filter(child => child != none and child != [ ])
    if meaningful.len() == 1 and meaningful.first().func() == raw {
      meaningful.first().text
    } else {
      utils.plain-text(body)
    }
  } else {
    utils.plain-text(body)
  }
  text.trim()
}

/// Attaches a speaker note to the current slide.
///
/// The note never appears on the slide; it is collected into a `.pdfpc` sidecar
/// for presenter consoles such as `pdfpc`. Place it anywhere in the slide body.
///
/// = Example
/// ```typ
/// #speaker-note[Greet the audience before the first point.]
///
/// #speaker-note(```md
/// # Reminder
/// - speak slowly
/// - show the demo at the end
/// ```)
/// ```
///
/// = Parameters
/// - `body` (content): The note. A `raw` block is treated as Markdown, any
///   other content as plain text.
#let speaker-note(body) = {
  [#metadata(_note-text(body))<speaker-note>]
}

/// Builds the `<pepentation-pdfpc>` metadata payload.
///
/// Collects every `<speaker-note>` marker, groups them by physical page and
/// emits one dense `pages` entry per page, the shape pdfpc reads from a
/// `.pdfpc` file. Call it once, after the slides.
///
/// = Returns
/// Content holding the pdfpc payload as metadata.
#let pdfpc-payload() = context {
  // Scoped to this document so that a bundle containing several presentations
  // does not merge their notes into one payload.
  let notes = query(_within-current-document(<speaker-note>, here()))
  let by-page = (:)
  for note in notes {
    let key = str(note.location().page())
    let text = note.value
    if text != "" {
      if by-page.keys().contains(key) {
        by-page.insert(key, by-page.at(key) + "\n\n" + text)
      } else {
        by-page.insert(key, text)
      }
    }
  }

  let total = counter(page).final().first()
  let pages = ()
  for i in range(total) {
    let entry = (
      idx: i,
      label: str(i + 1),
      overlay: 0,
      forcedOverlay: false,
      hidden: false,
    )
    let key = str(i + 1)
    if by-page.keys().contains(key) {
      entry.insert("note", by-page.at(key))
    }
    pages.push(entry)
  }

  [ #metadata((pdfpcFormat: 2, disableMarkdown: false, pages: pages)) <pepentation-pdfpc> ]
}
