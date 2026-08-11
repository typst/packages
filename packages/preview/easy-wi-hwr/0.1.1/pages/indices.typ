// pages/indices.typ
// Verzeichnisse: TOC, Abkürzungsverzeichnis, Abbildungsverzeichnis, Tabellenverzeichnis
// STR-03: Inhaltsverzeichnis (Pflicht)
// STR-04: Abkürzungsverzeichnis (nur wenn Abkürzungen verwendet)
// STR-05: Abbildungsverzeichnis (nur ab 5 Abbildungen)
// STR-06: Tabellenverzeichnis (nur ab 5 Tabellen)
// STR-41: Abkürzungen alphabetisch, keine Seitenangaben
// Alle Heading-Titel aus l10n

#import "@preview/linguify:0.5.0": linguify
#import "../helper/abbreviations.typ": _abk-dict

/// Render all front-matter indices.
///
/// - abbreviations: dict ("KI": "Künstliche Intelligenz", ...) from hwr() param
/// - lang: "de" | "en"
#let render-indices(abbreviations, lang) = {

  // ── 1. Inhaltsverzeichnis ────────────────────────────────────────────────
  // set outline() depth and indent already configured globally in lib.typ
  heading(level: 1, numbering: none, outlined: false)[#linguify("toc-title")]
  // Use a custom show rule to suppress the redundant auto-heading from outline()
  show outline: it => {
    // Skip the outline's own title (we rendered it above)
    show heading: none
    it
  }
  outline(title: none)

  pagebreak()

  // ── 2. Abkürzungsverzeichnis (nur wenn Abkürzungen im Text verwendet) ───
  // Queries the <abk> metadata labels placed by abk() calls.
  // Renders only if at least one abbreviation was actually used in the body.
  context {
    let used-nodes = query(<abk>)
    // Collect all defined abbreviations: from central dict (abbreviations param)
    // merged with any inline-defined entries stored in _abk-dict state
    let inline-dict = _abk-dict.get()
    let all-abbrs = abbreviations + inline-dict

    let used-keys = used-nodes.map(n => n.value)
    let unique-keys = ()
    for k in used-keys {
      if k not in unique-keys and k in all-abbrs.keys() {
        unique-keys.push(k)
      }
    }
    unique-keys = unique-keys.sorted()

    if unique-keys.len() > 0 {
      heading(level: 1, numbering: none, outlined: true)[#linguify("abbreviations-title")]
      v(1em)

      table(
        columns: (auto, 1fr),
        align: left,
        stroke: none,
        ..unique-keys.map(k => (
          // Invisible anchor label so abk() links work (STR-41: no page numbers needed)
          [#strong(k) #label("abk-list-" + k)],
          all-abbrs.at(k),
        )).flatten()
      )

      pagebreak()
    }
  }

  // ── 3. Abbildungsverzeichnis (nur ab 5 Abbildungen) ─────────────────────
  // STR-05, FMT requirement: show only if ≥5 figures
  context {
    let figs = query(figure.where(kind: image))
    if figs.len() >= 5 {
      heading(level: 1, numbering: none, outlined: true)[#linguify("figures-title")]
      v(1em)

      let fig-prefix = linguify("figure-prefix")

      // Header row
      grid(
        columns: (60pt, 1fr, auto),
        align: left,
        [*#fig-prefix #linguify("index-col-number")*], [*#linguify("index-col-title")*], [*#linguify("index-col-page")*],
      )
      v(0.5em)

      show outline.entry.where(level: 1): it => {
        let num = it.element.counter.at(it.element.location()).first()
        let pg  = it.element.location().page()
        let ttl = it.element.caption.body
        grid(
          columns: (60pt, 1fr, auto),
          [#fig-prefix #num],
          [#ttl #box(width: 1fr, repeat[.])],
          [#pg],
        )
      }
      outline(title: none, target: figure.where(kind: image))

      pagebreak()
    }
  }

  // ── 4. Tabellenverzeichnis (nur ab 5 Tabellen) ──────────────────────────
  context {
    let tabs = query(figure.where(kind: table))
    if tabs.len() >= 5 {
      heading(level: 1, numbering: none, outlined: true)[#linguify("tables-title")]
      v(1em)

      let tab-prefix = linguify("table-prefix")

      grid(
        columns: (60pt, 1fr, auto),
        align: left,
        [*#tab-prefix #linguify("index-col-number")*], [*#linguify("index-col-title")*], [*#linguify("index-col-page")*],
      )
      v(0.5em)

      show outline.entry.where(level: 1): it => {
        let num = it.element.counter.at(it.element.location()).first()
        let pg  = it.element.location().page()
        let ttl = it.element.caption.body
        grid(
          columns: (60pt, 1fr, auto),
          [#tab-prefix #num],
          [#ttl #box(width: 1fr, repeat[.])],
          [#pg],
        )
      }
      outline(title: none, target: figure.where(kind: table))

      pagebreak()
    }
  }
}
