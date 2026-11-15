// Optional CSL processor. Imported only when the opt-in authoring API is used.

/// Initialize citations from BibTeX text.
///
/// This is an opt-in alternative to native `bibliography()`. Selected keys are
/// rendered in bold by `proposal-publications()`. Ordinary `@key` citations stay
/// available, and the BibTeX file is never rewritten.
///
/// - bib (str): BibTeX **text**, normally `read("references.bib")`, not a path
/// - highlight (array of str): unique BibTeX keys to emphasize; defaults to empty
/// - style (str, none): CSL **XML text**, usually `read("custom.csl")`; `none`
///   uses the bundled author-date style
/// - body (content): document body using this citation backend
///
/// Use exactly one `proposal-citations` show rule per document.
#let proposal-citations(bib, highlight: (), style: none, body) = {
  import "@preview/citrus:0.2.1": init-csl
  import "@preview/citegeist:0.2.1": load-bibliography
  assert(type(bib) == str, message: "Pass BibTeX text using read(\"references.bib\").")
  assert(type(highlight) == array and highlight.all(k => type(k) == str),
    message: "highlight must be an array of BibTeX key strings.")
  assert(highlight.dedup().len() == highlight.len(), message: "Duplicate highlighted publication key.")
  let entries = load-bibliography(bib)
  for key in highlight {
    assert(key in entries, message: "Unknown highlighted publication key: " + key)
  }
  let csl = if style == none { read("styles/author-date.csl") } else { style }
  [#metadata(highlight) <satz-publication-highlights>]
  init-csl(bib, csl, body)
}

/// Print the opt-in CSL bibliography, automatically bolding selected entries.
///
/// Preserves processor-generated bibliography labels and citation hyperlinks.
/// `max-highlight` is a compilation limit, not truncation: too many highlighted
/// entries abort compilation. A missing or duplicate `proposal-citations` setup
/// also fails. NWO Vici full proposals reject any highlighted own publication.
/// Use `citrus.nocite` to include uncited entries with the CSL backend.
///
/// - size (length): bibliography text size; defaults to 11pt
/// - max-highlight (none, int): maximum highlighted entries printed; `none`
///   leaves the count unrestricted
#let proposal-publications(size: 11pt, max-highlight: none) = context {
  import "@preview/citrus:0.2.1": csl-bibliography
  let selections = query(<satz-publication-highlights>)
  assert(selections.len() == 1, message: "Use one proposal-citations show rule before printing publications.")
  let selected = selections.first().value
  set text(size: size)
  csl-bibliography(title: none, full-control: entries => {
    let count = entries.filter(e => e.key in selected).len()
    let nwo = state("satz-nwo-profile").get()
    if type(nwo) == dictionary and nwo.stage == "full" {
      assert(count == 0, message: "NWO Vici full proposals prohibit highlighting your own publications.")
    }
    if max-highlight != none {
      assert(count <= max-highlight, message: "At most " + str(max-highlight) + " highlighted publications may be printed.")
    }
    set par(first-line-indent: 0pt, hanging-indent: 1.5em, spacing: 0.65em)
    for entry in entries {
      // Individual CSL nodes can set weight: normal, so apply a local show rule
      // to all text in a selected entry, including italic journal names.
      let doi = entry.fields.at("doi", default: "")
      let url = entry.fields.at("url", default: "")
      let destination = if doi != "" {
        if doi.starts-with("https://") or doi.starts-with("http://") { doi } else { "https://doi.org/" + doi }
      } else if url != "" { url } else { none }
      let rendered = if destination == none { entry.rendered } else { link(destination, entry.rendered) }
      if entry.key in selected {
        show text: set text(weight: "bold")
        [#rendered #entry.ref-label]
      } else {
        [#rendered #entry.ref-label]
      }
      parbreak()
    }
  })
}
