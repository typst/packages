// Dual-target perceptual `oklch` monochrome margin sidenotes, margin notes,
// and margin-routed bibliography citations (`mcite`).

#import "@preview/marge:0.1.0": container as marge-container, sidenote as marge-sidenote
#import "../text.typ": word-hint
#import "theme.typ": active-theme

#let blog-sn-counter = counter("blog/sidenote")
#let blog-html-id-counter = counter("blog/html-note-id")

#let reset-sidenotes() = {
  blog-sn-counter.update(0)
  blog-html-id-counter.update(0)
}

// Detect internal sidenote reference/backlink metadata inside `link.body` so outer
// `show link: underline(...)` rules do not draw a second underline at the prose baseline.
#let is-sidenote-link(node) = {
  if node == none {
    return false
  }
  if node.func() == metadata and node.value == "thyme-sn-link" {
    return true
  }
  if node.has("children") {
    return node.children.any(is-sidenote-link)
  }
  if node.has("body") {
    return is-sidenote-link(node.body)
  }
  if node.has("child") {
    return is-sidenote-link(node.child)
  }
  false
}

#let format-paged-note(num-content, source-loc, theme-config, body) = {
  set text(
    font: theme-config.serif-fonts,
    size: 0.85em,
    fill: theme-config.muted-light,
  )
  set par(leading: 0.48em, justify: false)
  if num-content != none {
    let badge = (
      super(
        typographic: false,
        size: 0.76em,
        baseline: -0.34em,
        link(
          source-loc,
          [#metadata("thyme-sn-link")]
            + text(
              fill: theme-config.text-light,
              weight: "regular",
              num-content,
            ),
        ),
      )
        + h(0.26em)
    )
    par(
      hanging-indent: measure(badge).width,
      badge + body,
    )
  } else {
    par(body)
  }
}

/// Place a numbered (or unnumbered) note in the right margin (`@preview/marge` in paged
/// previews; `<span class="sidenote">` float on desktop HTML and `@media print`, collapsing
/// into a tap- or keyboard-expandable numbered card on viewports `<= 1100px`).
/// -> content
#let sidenote(
  /// Vertical offset adjustment in paged mode.
  /// -> length | ratio | relative
  dy: 0pt,
  /// Minimum vertical separation between consecutive paged margin notes.
  /// -> length
  gap: 0.55em,
  /// Horizontal inset inside the right margin column in paged mode.
  /// -> length | dictionary
  padding: (left: 1.4em, right: 1.8cm),
  /// Display synchronized superscript numbers in prose and at the start of the margin note.
  /// -> bool
  numbered: true,
  /// Margin note content.
  /// -> content
  body,
) = {
  [#metadata((
    thyme-feed-node: true,
    kind: "sidenote",
    body: body,
  ))<thyme-feed-meta>]
  blog-html-id-counter.step()
  context {
    word-hint(body)
    if target() == "html" {
      let id-num = blog-html-id-counter.get().first()
      let clean-body = {
        show par: it => it.body + html.br()
        body
      }
      if numbered {
        let id = "sn-" + str(id-num)
        html.label(..("for": id), class: ("margin-toggle", "sidenote-number"))[]
        html.elem(
          "input",
          attrs: (
            type: "checkbox",
            id: id,
            class: "margin-toggle",
            "aria-label": "Toggle sidenote " + str(id-num),
          ),
        )
        html.span(class: "sidenote", clean-body)
      } else {
        let id = "mn-" + str(id-num)
        html.label(..("for": id), class: "margin-toggle", "[+]")
        html.elem(
          "input",
          attrs: (
            type: "checkbox",
            id: id,
            class: "margin-toggle",
            "aria-label": "Toggle margin note " + str(id-num),
          ),
        )
        html.span(class: "marginnote", clean-body)
      }
    } else {
      let t = active-theme()
      show link: it => {
        if type(it.dest) == dictionary and it.body.func() == super {
          (
            h(0.05em)
              + super(
                typographic: false,
                size: 0.7em,
                baseline: -0.42em,
                underline(
                  stroke: 0.5pt + t.text-light,
                  offset: 1.15pt,
                  link(
                    it.dest,
                    [#metadata("thyme-sn-link")]
                      + text(
                        fill: t.text-light,
                        weight: "regular",
                        it.body.body,
                      ),
                  ),
                ),
              )
              + h(0.06em)
          )
        } else {
          it
        }
      }
      marge-sidenote(
        side: right,
        dy: dy,
        gap: gap,
        padding: padding,
        numbering: if numbered { "1" } else { none },
        counter: blog-sn-counter,
        format: it => {
          let num-str = if it.numbering != none {
            it.counter.display(it.numbering)
          } else {
            none
          }
          set text(size: 1em / 0.85)
          format-paged-note(num-str, it.source, t, body)
        },
        body,
      )
    }
  }
}

/// Place an unnumbered margin note alongside the current paragraph (`[+]` toggle on `<= 1100px`).
/// -> content
#let marginnote(
  /// Vertical offset adjustment in paged mode.
  /// -> length | ratio | relative
  dy: 0pt,
  /// Minimum vertical separation between consecutive paged margin notes.
  /// -> length
  gap: 0.55em,
  /// Margin note content.
  /// -> content
  body,
) = sidenote(
  dy: dy,
  gap: gap,
  numbered: false,
  body,
)

/// Cite a bibliography entry (`label` or `str` key) while placing its full formatted
/// bibliographic entry directly into a right-margin sidenote alongside the paragraph.
/// -> content
#let mcite(
  /// Bibliography key (`<knuth84>` or `"knuth84"`).
  /// -> label | str
  key,
  /// Optional page/section supplement (e.g. `[p. 42]`).
  /// -> content | none
  supplement: none,
  /// Emit an inline short citation (`[1]` / `(Knuth, 1984)`) before the margin note (`false` uses only the numbered sidenote superscript).
  /// -> bool
  inline: false,
  /// Vertical offset adjustment in paged mode.
  /// -> length | ratio | relative
  dy: 0pt,
) = {
  let tgt = if type(key) == label { key } else { label(str(key)) }
  if inline {
    cite(tgt, supplement: supplement)
    marginnote(dy: dy, cite(tgt, form: "full"))
  } else {
    sidenote(
      dy: dy,
      {
        cite(tgt, form: "full")
        if supplement != none { [, ] + supplement }
      },
    )
  }
}

/// Short alias for `sidenote`.
/// -> function
#let sn = sidenote

/// Short alias for `marginnote`.
/// -> function
#let mn = marginnote

#let sidenote-bottom-guard() = context {
  if target() == "paged" and page.height == auto {
    let pg = here().page()
    let end-y = here().position().y
    let notes = state("marge:0.1.0/page-" + str(pg), ()).final()
    let max-y = notes.fold(end-y, (acc, n) => calc.max(
      acc,
      n.position.y + n.height,
    ))
    if max-y > end-y {
      v(max-y - end-y + 0.5em)
    }
  }
}

#let container = marge-container
