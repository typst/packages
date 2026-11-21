// Visual feedback of `validation: "draft"`. Core-owned and brand-immune: fixed
// colours with a contrast of at least 7:1, so no theme can hide a problem.
//
// Every open issue is emitted once as `metadata(issue) <ip-issue>` in the flow.
// Badge, watermark, marker numbers and the report all query that one source,
// so issues found while rendering (footer fit, identity, empty parts) count
// exactly like the ones known up front.

#import "issue.typ": dedupe

#let ink = rgb("#9f1239") // rose-800: 7.9:1 on white, 6.6:1 on the soft fill
#let soft = rgb("#ffe4e6") // rose-100
#let edge = rgb("#e11d48") // rose-600

/// The invoice (1, 2, ..) that page `p` belongs to. Each invoice places a start
/// marker as the first element of its first page (see the frame), so a
/// document with several invoices keeps their issues apart. Needs `context`.
/// -> int
#let invoice-at(p) = calc.max(
  1,
  query(<ip-invoice-start>).filter(m => m.location().page() <= p).len(),
)

/// Link target of an issue's report row (unique per invoice).
#let issue-label(instance, id) = label(
  "ip-issue:" + str(instance) + ":" + id,
)

/// Emits issues as metadata (flow content; invisible, no layout effect). Each
/// record notes the invoice it belongs to.
/// -> content
#let emit(issues) = context {
  let k = invoice-at(here().page())
  for x in issues { [#metadata(x + (instance: k))<ip-issue>] }
}

/// The emitted issues of invoice `k`, deduplicated, in document order. Needs
/// `context`.
/// -> array
#let collected(k) = dedupe(
  query(<ip-issue>)
    .map(m => m.value)
    .filter(x => x.at("instance", default: 1) == k),
)

#let _strings(ctx) = ctx.locale.strings.validation

/// Inline marker for a missing field, e.g. ‹fehlt: Rechnungsnummer›¹. It is real
/// text (read by assistive technology and text extraction) and carries the
/// issue number. In the flow it links to its report row; in page furniture
/// (`link: false`) it does not, because PDF/UA-1 forbids links in artifacts.
/// -> content
#let marker(ctx, issue, link: true) = {
  let s = _strings(ctx)
  let body = if issue.field != none {
    (s.marker)(s.fields.at(issue.field, default: issue.field))
  } else { (s.part-empty)(issue.id) }
  context {
    let k = invoice-at(here().page())
    let n = collected(k).position(x => x.id == issue.id)
    let num = if n == none { none } else {
      super(typographic: false, str(n + 1))
    }
    let mark = highlight(fill: soft, extent: 1.5pt, text(
      fill: ink,
      weight: "bold",
      style: "normal",
      [#body#num],
    ))
    if link { std.link(issue-label(k, issue.id), mark) } else { mark }
  }
}

/// Marker for a required part that rendered nothing (render-time issue). Not a
/// link: the part may sit in page furniture (artifacts).
/// -> content
#let part-marker(ctx, name, issue) = {
  let s = _strings(ctx)
  [#emit((issue,))#highlight(fill: soft, extent: 1.5pt, text(
      fill: ink,
      weight: "bold",
      (s.part-empty)(name),
    ))]
}

/// Page badge: top centre, in the page foreground (an artifact; the same facts
/// are in the tagged markers and the report).
/// -> content
#let badge(ctx, n, withheld) = {
  let s = _strings(ctx)
  let label = (
    (s.badge)(n) + if withheld { " · " + s.e-invoice-short } else { "" }
  )
  place(top + center, dy: 3mm, box(
    fill: ink,
    radius: 2pt,
    inset: (x: 7pt, y: 3.5pt),
    text(
      size: 7.5pt,
      fill: white,
      weight: "bold",
      tracking: 0.04em,
      font: ctx.theme.tokens.fonts.body,
      label,
    ),
  ))
}

/// Faint diagonal watermark, in the page background (behind all content):
/// survives printing when the badge falls into the printer's unprintable edge.
/// -> content
#let watermark(ctx, pw, ph) = {
  let s = _strings(ctx)
  place(top + left, box(width: pw, height: ph, align(center + horizon, rotate(
    -35deg,
    reflow: true,
    text(
      size: calc.min(pw, ph) / 6,
      weight: "bold",
      fill: edge.transparentize(90%),
      font: ctx.theme.tokens.fonts.body,
      s.watermark,
    ),
  ))))
}

/// A developer message with `code` spans set as raw text (the report shows theme
/// and lint messages verbatim; the backticks mark identifiers).
#let _code-spans(msg) = if type(msg) != str { msg } else {
  msg
    .split("`")
    .enumerate()
    .map(((i, part)) => if calc.odd(i) { raw(part) } else { [#part] })
    .join()
}

/// The report text of an issue in the document's language: the locale's
/// `issues.<key>` applied to the issue's args (a role issue also gets the
/// localised `roles.<role>`); the English developer message when the locale has
/// no text for the key (a user override that drops keys, a future issue).
/// -> content
#let localized(s, x) = {
  let key = x.at("key", default: none)
  let texts = s.at("issues", default: (:))
  if key == none or key not in texts { return _code-spans(x.message) }
  let args = x.at("args", default: (:))
  if "role" in args {
    args.why = s.at("roles", default: (:)).at(args.role, default: args.why)
  }
  (texts.at(key))(args)
}

/// The validation report page. Real, tagged content (heading and a table with
/// a header row, PDF/UA reading order). Placed after the invoice, excluded from
/// the invoice's page count and running areas.
/// -> content
#let report(ctx, issues, withheld, profile) = {
  let s = _strings(ctx)
  let t = ctx.theme.tokens
  set text(font: t.fonts.body, size: 9.5pt, fill: black)
  set par(justify: false)
  heading(level: 1, outlined: false, bookmarked: true, text(
    fill: ink,
    size: 16pt,
  )[#s.report-title])
  v(0.2em)
  (s.report-intro)(issues.len())
  if withheld {
    block(
      width: 100%,
      fill: soft,
      stroke: (left: 3pt + edge),
      inset: 8pt,
      above: 1em,
      (s.e-invoice-withheld)(profile),
    )
  }
  v(0.6em)
  let chip(c) = box(
    stroke: 0.5pt + ink,
    radius: 2pt,
    inset: (x: 3pt, y: 1.5pt),
    text(size: 7pt, fill: ink, weight: "bold", s.classes.at(c)),
  )
  table(
    columns: (auto, 1fr, 11em),
    stroke: (x, y) => (
      bottom: 0.4pt + luma(200),
      top: if y == 0 { 0.8pt + ink },
    ),
    inset: (x: 5pt, y: 6pt),
    align: (right + top, left + top, left + top),
    table.header(
      text(weight: "bold", s.number),
      text(weight: "bold", s.problem),
      text(weight: "bold", s.reference),
    ),
    ..issues
      .enumerate()
      .map(((i, x)) => {
        let what = if x.field != none and x.class == "data" {
          (s.missing)(s.fields.at(x.field, default: x.field))
        } else { localized(s, x) }
        (
          [#text(fill: ink, weight: "bold", str(i + 1))#issue-label(
              x.at("instance", default: 1),
              x.id,
            )],
          {
            chip(x.class)
            h(0.5em)
            what
            if x.fix != none {
              let fixes = if type(x.fix) == array { x.fix } else { (x.fix,) }
              linebreak()
              let alternatives = fixes.map(raw).join([ #s.fix-or ])
              text(size: 8pt, fill: luma(80))[#s.fix: #alternatives]
            }
          },
          text(size: 8.5pt, if x.ref == none { [–] } else { x.ref }),
        )
      })
      .flatten(),
  )
  v(0.8em)
  text(size: 8.5pt, fill: luma(60), s.report-strict)
}
