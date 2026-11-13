// Speaker notes embedded in the PDF, in the pdfpc interchange format.
//
// The `speaker`, `notes` and `split` outputs put notes on paper or on the
// presenter's half of a double-wide page. This module is the fourth channel and
// the only one a console reads as data: a `*.pdfpc` payload in the PDF's
// `/EmbeddedFiles` name tree, written whenever the deck holds a note at all.
//
// It is a sidecar in content but not a companion file, which is the point. The
// conventional `.pdfpc` file lives beside the PDF and is lost the moment the
// deck is mailed, copied to a conference laptop, or dropped in a shared
// folder; the same bytes inside the document travel with it. Typst's
// `pdf.attach` takes computed bytes rather than a path on disk, so the notes
// the document already carries can be serialized into the document that
// carries them, with no post-processing step and nothing for the presenter to
// remember.
//
// The embed is unconditional on output mode. A `slides` deck with notes is the
// case this exists for — ordinary slides, no doubled pages, notes riding along
// invisibly — and a `split` deck emits it too, so a console can take the notes
// as text or as the right half of the page, whichever it does better.
//
// pdfpc itself does not read attachments; its lookup is filesystem-only. This
// is written for consoles that do, and for `pdftk unpack_files` or `mutool
// extract` to recover the conventional sidecar from the PDF when they don't.
#import "../shared.typ": tag

// The attachment's name inside the PDF.
//
// Typst cannot know what the output file will be called, so the name after
// which a console would look this up (`talk.pdf` -> `talk.pdfpc`) is not
// available to state. A fixed name is the honest alternative: a reader that
// prefers the document's own stem falls back to the sole `.pdfpc` member, and
// there is only ever one. The stem also says what the file is when it is
// unpacked into a directory of its own.
// Root-relative on purpose. `pdf.attach` names the attachment after the path
// it is given, resolved the way any Typst path is: a bare name would resolve
// against this file's own directory and ship the deck an attachment called
// `src/note/speaker-notes.pdfpc`, publishing the package's internal layout in
// every PDF. The leading slash resolves against the package root instead,
// which leaves the bare name. Nothing is read from disk — the bytes are the
// second argument — so the path names the attachment and nothing else.
#let attachment-name = "/speaker-notes.pdfpc"

// Flattens one note body to the plain text the format carries.
//
// Notes are prose written as ordinary content, so this is a text extraction,
// not a renderer: what a console displays is a string, and everything about the
// note that is layout rather than words has no reading here. Unknown elements
// are therefore skipped rather than refused. That is the opposite of
// `plain-name`, which returns `none` for anything it cannot flatten because a
// half-flattened author list would misattribute the deck; half a note is still
// the note, and dropping every note on a slide because one of them held a
// figure would be the worse failure.
#let note-text(value) = {
  if type(value) == str { return value }
  if type(value) != content { return "" }
  let func = value.func()
  if func == text { return value.text }
  if func == [ ].func() { return " " }
  if func == linebreak { return "\n" }
  if func == parbreak { return "\n\n" }
  if func == raw { return value.text }
  if func == smartquote {
    return if value.at("double", default: true) { "\"" } else { "'" }
  }
  // List and enum items keep a marker, because a note's structure is part of
  // how the presenter reads it under pressure. The marker is written flat
  // rather than nested: the format carries no depth, and a bullet that says
  // "another item" is worth more than an indent that says how deep it was.
  if func == list.item or func == enum.item {
    return "\n- " + note-text(value.body)
  }
  let children = value.at("children", default: none)
  if children != none { return children.map(note-text).join("") }
  let body = value.at("body", default: none)
  if body != none { return note-text(body) }
  ""
}

// Collapses the whitespace flattening leaves behind.
//
// Every space in the source becomes a space here, so a note broken across
// source lines arrives with runs of them, and the markers above open with a
// newline whether or not one was needed. Paragraph breaks survive as blank
// lines because they are the note's own structure; anything more than one is
// not.
#let tidy-note(value) = {
  let value = value.replace(regex("[ \t]+"), " ")
  let value = value.replace(regex(" ?\n ?"), "\n")
  let value = value.replace(regex("\n{3,}"), "\n\n")
  value.trim()
}

// One page's worth of notes, as the format's page record.
//
// Several notes on one frame are separate blocks of prose, so they are joined
// by a blank line rather than run together: the presenter wrote them apart.
#let page-record(page, notes) = (
  // The format counts physical pages from one, which is what `page()` gives.
  idx: page,
  note: tidy-note(notes.map(note-text).join("\n\n")),
)

// Every note in the deck, keyed by the physical page it renders on.
//
// The slide runtime emits one `<mosaic-speaker-notes>` record per frame,
// already resolved to the notes visible on that frame's step, so the work here
// is grouping rather than extraction: a query after the document has converged
// gives each record's location, and the location gives the page. Reading the
// page from the document rather than counting frames means the mapping stays
// correct however the deck paginates — handout mode collapsing steps, a
// `split` deck's doubled pages, or anything a later output mode does.
#let collect-pages() = {
  let pages = (:)
  for record in query(selector(<mosaic-speaker-notes>)) {
    let value = record.value
    if value.at("mosaic", default: none) != tag { continue }
    if value.notes.len() == 0 { continue }
    let page = str(record.location().page())
    pages.insert(page, pages.at(page, default: ()) + value.notes)
  }
  pages
    .pairs()
    .map(((page, notes)) => page-record(int(page), notes))
    .filter(record => record.note != "")
    .sorted(key: record => record.idx)
}

// The payload, or `none` when the deck holds no note worth carrying.
#let pdfpc-payload() = {
  let pages = collect-pages()
  if pages.len() == 0 { return none }
  (
    pdfpcFormat: 2,
    // The bodies are flattened Typst content, not Markdown source. A console
    // that formats them anyway does no harm to prose, but the file should say
    // what it holds.
    disableMarkdown: true,
    pages: pages,
  )
}

// Attaches the deck's notes to the PDF, if it has any.
//
// Called once from `setup-core` after the deck is compiled. The query needs
// introspection to have converged, and `pdf.attach` is document-level, so
// where this sits in the document affects nothing but when it can read.
#let attach-notes() = context {
  let payload = pdfpc-payload()
  if payload == none { return }
  pdf.attach(
    attachment-name,
    bytes(json.encode(payload)),
    mime-type: "application/json",
    description: "Speaker notes in the pdfpc format",
    relationship: "supplement",
  )
}
