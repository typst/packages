// User-callable content helpers: titles, table of contents / figures,
// bibliography, appendix pages, the abstract footer and small utilities.

#import "includes.typ" as inc
#import "settings.typ": space-after-heading, chapter-font-size, chapter-font-weight, version, programme-name
#import "i18n.typ": i18n
#import "@preview/gentle-clues:1.3.1": clue
#import "@preview/tiaoma:0.3.0"

#let page-title(title, mult: 1.5, bottom: 2pt, top: 4em) = {
  set text(size: chapter-font-size * mult, weight: chapter-font-weight)
  block(fill: none, inset: (x: 0pt, bottom: bottom, top: top), below: space-after-heading * mult, {
    title
  })
}

// Enable the display of headers and footers
#let set-header-footer(enabled) = {
  context inc.header-footers-enabled.update(enabled)
}

// Make a page break so that the next page starts on an odd page
#let cleardoublepage() = {
  pagebreak(weak: true)
  inc.blank-page.update(true)
  pagebreak(to: "odd", weak: true)
  inc.blank-page.update(false)
}

// Indicate that something still needs to be done
#let todo(body, fill-color: yellow.lighten(50%)) = {
  set text(black)
  box(baseline: 25%, fill: fill-color, inset: 4pt, [*TODO* #body])
}

// Generate a lorem ipsum with paragraphs
#let lorem-pars(n-words, each: 5) = {
  let n = int(n-words / (each * 30))
  let sentences = lorem(n * (each * 30)).split(". ")

  range(n)
    .map(i => sentences.slice(i * each, count: each).join(". ") + [.])
    .join(parbreak())
}

// Cetz
#let scale-to-width(width, body) = layout(page-size => {
  let size = measure(body, ..page-size)
  let target-width = if type(width) == ratio {
    page-size.width * width
  } else if type(width) == relative {
    page-size.width * width.ratio + width.length
  } else {
    width
  }
  let multiplier = target-width.to-absolute() / size.width
  scale(reflow: true, multiplier * 100%, body)
})

#let _make-outline(font: auto, title, ..args) = {
  {
    show heading:none
    heading(bookmarked: true, numbering: none, outlined: false)[Table of contents]
  }

  let title = if font == auto { title } else {
    text(font: font, title)
  }

  outline(title: {
    v(2em)
    text(size: chapter-font-size, weight: chapter-font-weight, title)
    v(3em)
  }, indent: 2em, ..args)
  pagebreak(weak: true)
}

// Generates the special appendix page
#let appendix-page() = {
  context{
    {
      show heading: none
      heading(numbering:none)[#i18n(inc.global-language.get(), "appendix-title")]
    }

    // The appendix page
    place(center + horizon, [
      #{
        set text(size: chapter-font-size * 2, weight: chapter-font-weight)
        i18n(inc.global-language.get(), "appendix-title")
      }
    ])
  }
}

// Generate the table of contents with a given depth
#let table-of-contents(depth: 2) = {
  context {
    if inc.show-toc-enabled.get() {
      let f = inc.global-language.get()
      _make-outline(i18n(f, "toc-title"), depth: depth)
    }
  }
}

// Generate the table of figures
#let table-of-figures(depth: 1) = {
  context {
    let f = inc.global-language.get()
    outline(
      title: page-title(i18n(f, "figure-table-title"), mult: 1, top: 1em, bottom: 1em),
      depth: 1,
      indent: auto,
      target: figure.where(kind: image),
    )
  }
}

// Generate the proper header for the code samples appendix
#let code-samples() = {
  context{
    heading(
      numbering: none,
      depth: 2,
      outlined: false,
      bookmarked: false,
      text(
        page-title(i18n(inc.global-language.get(), "appendix-code-name"), mult: 1, top: 1em, bottom: 1em)),
    )
  }
}

#let the-bibliography(
  bib-file: none,
  full: false,
  style: "ieee"
) = {
  context {
    let title = i18n(inc.global-language.get(), "bibliography-title")
    show heading: none
    heading(bookmarked: true, numbering: none, outlined: true)[#title]
    page-title(title, mult: 1, top: 0.5em, bottom: 0.3em)
    bibliography(bib-file, full: full, style: style, title:none)
  }
}


// Pull a friendly "brand" out of a URL host: the first hostname component
// after stripping protocol and an optional www. (e.g. github.com → github,
// gitlab.hevs.ch → gitlab, isc.hevs.ch → isc).
#let _repo-host-brand(repo) = {
  let s = repo
  if s.starts-with("https://") { s = s.slice(8) }
  else if s.starts-with("http://") { s = s.slice(7) }
  let slash = s.position("/")
  let host = if slash == none { s } else { s.slice(0, slash) }
  if host.starts-with("www.") { host = host.slice(4) }
  let parts = host.split(".")
  if parts.len() > 0 { parts.first() } else { host }
}

// Repository "card": magenta accent bar + title + brand affordance + scaled QR.
// Reads the repo URL from global-project-repos. Sizes are em-relative so the
// card scales with the surrounding text size. Returns content (not placed).
// The entire text pane is wrapped in link(repo, …) so click-readers can hit it
// anywhere; print readers use the QR.
#let repo-block(lang, accent: inc.hei-purple) = context {
  let repo-val   = inc.global-project-repos.get()
  // No repository set yet (unset -> none, or emptied -> ""). Rendering a link()/QR
  // with an empty URL would panic, so we draw nothing — the thesis completeness
  // box already flags the missing `project-repos`. Test none before str(), since
  // str(none) itself errors.
  if repo-val == none or str(repo-val) == "" {
    none
  } else {
  let repo       = str(repo-val)
  let repo-title = i18n(lang, "repository")
  let brand      = _repo-host-brand(repo)
  let on-prep    = i18n(lang, "repo-on")

  // Right-pointing chevron drawn as a vector (not a font glyph): a "›" relies on
  // whatever font happens to cover U+203A and sits oddly on the baseline, so we
  // stroke our own. `cw`/`ch` size it; the box baseline shift centers it on the
  // text x-height instead of resting the box bottom on the baseline.
  let chevron(cw: 0.3em, ch: 0.48em, color: black) = box(baseline: -0.07em, curve(
    stroke: (paint: color, thickness: 1.1pt, cap: "round", join: "round"),
    curve.move((0em, 0em)),
    curve.line((cw, ch / 2)),
    curve.line((0em, ch)),
  ))

  let text-pane = block(
    stroke: (left: 3.5pt + accent),
    inset: (left: 0.8em, right: 0.9em, top: 0.45em, bottom: 0.45em),
    link(repo, stack(spacing: 0.55em,
      text(0.9em, fill: black, weight: "bold", tracking: 0.06em, upper(repo-title)),
      text(0.82em, fill: black, [#chevron()#h(0.35em)#on-prep #text(fill: accent, weight: "bold", brand)]),
    )),
  )
  let pane-h = measure(text-pane).height

  // Scale the QR uniformly so its height matches the text pane.
  let qr-raw = tiaoma.barcode(repo, "QRCode", options: (
    scale: 1.0, fg-color: black, bg-color: white,
  ))
  let qr-scaled = scale(
    (pane-h / measure(qr-raw).height) * 100%,
    origin: top + left, reflow: true, qr-raw,
  )

  let qr-pane = block(
    stroke: (left: 0.6pt + luma(70%)),
    inset: (left: 7pt, right: 0pt, y: 0pt),
    link(repo, qr-scaled),
  )

  stack(dir: ltr, spacing: 0pt, text-pane, qr-pane)
  }
}

// A discreet end-of-document colophon. project() auto-appends it to the
// bachelor thesis; it is also callable on its own. Renders on its own
// page with the running header/footer suppressed — a small, centred credit to
// the toolchain pushed to the bottom of the page. Tasteful enough to ship in a
// graded document; the last line is the only wink. Real flow content (the 1fr
// struts) is used rather than place() so the page is actually emitted.
//
// The header/footer are cleared with a local `set page(...)` rather than the
// blank-page/header-footer state: page headers are evaluated at the *top* of the
// page, before any in-flow state update on that page runs, so a mid-page state
// flip suppresses only the footer. `set page` placed right after the break
// applies to the colophon page itself and reliably drops both.
#let colophon() = {
  pagebreak(weak: true)
  set page(header: none, footer: none)
  v(1fr)
  align(center, block(width: 75%, {
    set align(center)
    set text(size: 9pt, fill: luma(45%))
    line(length: 26%, stroke: 0.5pt + luma(70%))
    v(0.9em)
    text(weight: "bold", "Typeset with Typst")
    linebreak()
    [ISC-HEI template by P.-A. Mudry · v#version]
    linebreak()
    text(size: 8.5pt)[#programme-name — Sion, HES-SO Valais]
    v(0.9em)
    text(size: 8pt, style: "italic", fill: luma(60%),
      "No LaTeX was harmed in the making of this document.")
  }))
  v(2.5cm)
}

#let abstract-footer(lang) = {
  context {
    let kw-list  = inc.global-keywords.get().join(", ")
    let kw-title = i18n(lang, "keywords")

    place(top + right, repo-block(lang))

    v(1fr)

    // Plain keywords block (no box, no icon)
    align(left, {
      text(1em, weight: "bold", kw-title)
      linebreak()
      text(0.9em, kw-list)
    })
  }
}
