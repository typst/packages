// pages/indices.typ
// Verzeichnisse: TOC, Abkürzungsverzeichnis, Glossar, Abbildungsverzeichnis, Tabellenverzeichnis
// STR-03: Inhaltsverzeichnis (Pflicht)
// STR-04: Abkürzungsverzeichnis (nur wenn Abkürzungen verwendet)
// STR-11: Glossar (optional, direkt nach Abkürzungsverzeichnis — kein expliziter §, DECIDED)
// STR-05: Abbildungsverzeichnis (nur ab 5 Abbildungen)
// STR-06: Tabellenverzeichnis (nur ab 5 Tabellen)
// STR-41: Abkürzungen alphabetisch, keine Seitenangaben
// Alle Heading-Titel aus l10n

#import "@preview/linguify:0.5.0": linguify
#import "@preview/glossarium:0.5.10": print-glossary
#import "../helper/abbreviations.typ": _abk-dict

/// Render all front-matter indices.
///
/// - abbreviations: dict ("KI": "Künstliche Intelligenz", ...) from hwr() param
/// - glossary: array of glossary entries (from hwr() param)
/// - lang: "de" | "en"
/// - include-appendix-in-lists: bool — if false (default), figures/tables inside
///   the appendix are excluded from the Abbildungs-/Tabellenverzeichnis
#let render-indices(abbreviations, glossary, lang, include-appendix-in-lists: false) = {

  // Helper: returns the page number of the appendix start anchor, or none if no appendix.
  let appendix-start-page() = {
    let anchors = query(<appendix-start>)
    if anchors.len() > 0 { anchors.first().location().page() } else { none }
  }

  // Helper: filter figures/tables to exclude those in the appendix (when requested).
  let filter-figures(figs) = {
    if include-appendix-in-lists { return figs }
    let app-page = appendix-start-page()
    if app-page == none { return figs }
    figs.filter(f => f.location().page() < app-page)
  }

  // ── 1. Inhaltsverzeichnis ────────────────────────────────────────────────
  // set outline() depth and indent already configured globally in lib.typ
  heading(level: 1, numbering: none, outlined: false)[#linguify("toc-title")]
  // Filter out the bibliography's auto-generated heading ("Bibliografie"/"Bibliography")
  // from the TOC. The bibliography element always creates its own heading which cannot
  // be suppressed via show rules or set rules on a pre-constructed element.
  // We render our own l10n heading ("Literaturverzeichnis"/"References") in lib.typ,
  // so the auto-generated one is a duplicate that must be removed from the outline.
  show outline.entry: entry => {
    let r = repr(entry.element.body)
    if "Bibliografie" in r or "Bibliography" in r {
      // Consume the duplicate bibliography heading entry
    } else {
      entry
    }
  }
  outline(title: none)

  pagebreak()

  // ── 2. Abkürzungsverzeichnis (nur wenn Abkürzungen im Text verwendet) ───
  // Queries the <abk> metadata labels placed by abk() calls.
  // Renders only if at least one abbreviation was actually used in the body.
  context {
    let used-nodes = query(<abk>)
    // Collect all defined abbreviations: from central dict (abbreviations param)
    // merged with any inline-defined entries stored in _abk-dict state.
    // Use final() to get the complete inline dict — abk() calls in the body come
    // AFTER this index page, so get() would return an empty dict here.
    let inline-dict = _abk-dict.final()
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

  // ── 3. Glossar (nur wenn Einträge vorhanden — STR-11/DECIDED) ───────────
  if glossary.len() > 0 {
    heading(level: 1, numbering: none, outlined: true)[#linguify("glossary-title")]
    // Reduce block spacing to avoid 1.5em gaps between entries (which come from
    // the global block(spacing: 1.5em) set for body text).
    set block(spacing: 0.65em)
    print-glossary(glossary, disable-back-references: true)
    pagebreak()
  }

  // ── 4. Abbildungsverzeichnis (nur ab 5 Abbildungen) ─────────────────────
  // STR-05, FMT requirement: show only if ≥5 figures
  context {
    let figs = filter-figures(query(figure.where(kind: image)))
    if figs.len() >= 5 {
      heading(level: 1, numbering: none, outlined: true)[#linguify("figures-title")]
      v(1em)

      let fig-prefix = linguify("figure-prefix")

      grid(
        columns: (60pt, 1fr, auto),
        align: left,
        [*#fig-prefix #linguify("index-col-number")*], [*#linguify("index-col-title")*], [*#linguify("index-col-page")*],
      )
      v(0.5em)

      for fig in figs {
        let num = fig.counter.at(fig.location()).first()
        let pg  = fig.location().page()
        let ttl = fig.caption.body
        grid(
          columns: (60pt, 1fr, auto),
          [#fig-prefix #num],
          [#ttl #box(width: 1fr, repeat[.])],
          [#pg],
        )
      }

      pagebreak()
    }
  }

  // ── 5. Tabellenverzeichnis (nur ab 5 Tabellen) ──────────────────────────
  context {
    let tabs = filter-figures(query(figure.where(kind: table)))
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

      for tab in tabs {
        let num = tab.counter.at(tab.location()).first()
        let pg  = tab.location().page()
        let ttl = tab.caption.body
        grid(
          columns: (60pt, 1fr, auto),
          [#tab-prefix #num],
          [#ttl #box(width: 1fr, repeat[.])],
          [#pg],
        )
      }

      pagebreak()
    }
  }
}
