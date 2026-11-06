// The page frame: owned by invoice-pro (letter-pro dropped), driven by layout data.
// Called by root.draw AFTER the compliance output (metadata, lang, ZUGFeRD).

#import "schema.typ": auto-margin-floor, defaults-of, token-schema, types-of
#import "validate.typ": area-rect, paper-dims
#import "proof.typ": proof-overlay
#import "resolve.typ": resolve-tokens
#import "access.typ": unsealed
#import "../loom-wrapper.typ": eval-content
#import "../validation/issue.typ": issue
#import "../validation/render.typ" as feedback
#import "../logic/document-type.typ": document-title

#let page-matches(pages, cur, total) = {
  if pages == "all" { true } else if pages == "first" { cur == 1 } else if (
    pages == "rest"
  ) { cur > 1 } else if (
    pages == "last"
  ) { cur == total } else if pages == "not-last" { cur < total } else { false }
}

/// The pages of invoice `k` of the document: (first, last) physical pages of the
/// invoice proper. Each invoice marks its first element (<ip-invoice-start>) and
/// the end of its content (<ip-invoice-end>, before the draft report); a floated
/// reserved zone may land later. Page roles and page numbers are relative to
/// this span, so a document with several invoices numbers each one on its own,
/// and draft report pages (after `last`) carry no running areas. Needs `context`.
#let invoice-span(k) = {
  let starts = query(<ip-invoice-start>).map(m => m.location().page())
  if starts.len() < k { return (first: 1, last: 1) } // first layout pass
  let first = starts.at(k - 1)
  let next = starts.at(k, default: none)
  let within(p) = p >= first and (next == none or p < next)
  let ends = (
    query(<ip-invoice-end>).map(m => m.location().page())
      + query(<ip-reserve>).map(m => m.location().page())
  )
  (first: first, last: calc.max(first, ..ends.filter(within)))
}

#let _money(v, f) = (value: v, text: f)

#let _blank(v) = v == none or v == "" or v == []

// The characters with a meaning in a regular expression, to match a text as it is.
#let _regex-special = regex("[\\\\.+*?()|\\[\\]{}^$#&\\-~]")

/// A party record: the normalized input plus `lines` (formatted address lines).
/// Under `validation: "draft"` a missing name or address is replaced by its
/// inline marker (`mark(id)` returns the marker or none).
#let _party(p, role, mark) = {
  let lines = (
    p.at("address", default: none),
    p.at("city", default: none),
  ).filter(x => not _blank(x))
  let name = p.at("name", default: none)
  let name-mark = mark(role + "-name")
  let address-mark = mark(role + "-address")
  (
    p
      + (
        name: if name-mark != none { name-mark } else if _blank(name) {
          []
        } else { name },
        name-inline: if name-mark != none { name-mark } else {
          p.at("name-inline", default: none)
        },
        lines: if address-mark != none { (address-mark,) } else { lines },
      )
  )
}

/// The due date: `(value: datetime | none, text)` or none. `invoice(due-date:)`
/// wins, then `payment-terms(date:)`, then `days:` counted from a datetime invoice
/// date (the same order as `references.due-date()`).
#let _due(ctx) = {
  let pt = ctx.at("payment-terms", default: none)
  let pt = if type(pt) == dictionary { pt } else { (:) }
  let d = ctx.at("due-date", default: none)
  if d == none { d = pt.at("date", default: none) }
  if (
    d == none
      and pt.at("days", default: none) != none
      and type(ctx.invoice-date) == datetime
  ) {
    d = ctx.invoice-date + duration(days: pt.days)
  }
  if d == none { return none }
  if type(d) == datetime {
    (value: d, text: (ctx.locale.format.date)(d))
  } else { (value: none, text: d) }
}

/// The validation state core put into ctx (level, issues, ..).
#let validation-of(ctx) = ctx.at("validation", default: (
  level: none,
  issues: (),
))

/// Frame view: built by core from root's FRESH draw ctx (core may read internals;
/// parts only see this record). Frozen fields: document.{kind, title, subject,
/// number, date}, sender/recipient.{name, lines}, page, layout, area.
/// Provisional (0.6.0): payment.due, area.{place, window, fill, surface}.
/// `links: false` builds the view for page furniture (running and layer
/// areas are artifacts, which may not contain links under PDF/UA-1).
#let frame-view(ctx, layout, links: true) = {
  let d = ctx.invoice-date
  let date-text = if type(d) == datetime { (ctx.locale.format.date)(d) } else {
    d
  }
  let t = ctx.global.total
  let f = ctx.global.formated-total
  let kind = ctx.theme.env.at("kind", default: "invoice")
  let (pw, ph) = paper-dims(layout)
  // draft: missing required fields become inline markers (core-built, so every
  // part that prints the field shows the marker, whatever theme renders it)
  let val = validation-of(ctx)
  let open = if val.level == "draft" {
    val.issues.filter(x => x.field != none)
  } else { () }
  let mark(id) = {
    let hit = open.find(x => x.id == id)
    if hit == none { none } else { feedback.marker(ctx, hit, link: links) }
  }
  let sender = _party(ctx.sender, "sender", mark)
  let tax-mark = mark("sender-tax-id")
  if tax-mark != none { sender.vat-id = tax-mark }
  let number-mark = mark("invoice-number")
  let pt = ctx.at("payment-terms", default: none)
  (
    document: (
      kind: kind,
      // the title of the document type (`invoice(document-type: ..)`), e.g.
      // "Rechnungskorrektur" for a credit note
      title: document-title(
        ctx.at("document-type", default: none),
        ctx.locale.strings,
      ),
      subject: ctx.at("subject-text", default: ctx.subject),
      number: if number-mark != none { number-mark } else { ctx.invoice-nr },
      date: (value: d, text: date-text),
      place: ctx.sender.at("city-name", default: none),
    ),
    sender: sender,
    recipient: _party(ctx.recipient, "recipient", mark),
    currency: ctx.locale.at("currency", default: (:)).at("code", default: none),
    references: ctx.references,
    bank: ctx.at("bank", default: none),
    totals: (
      net: _money(t.net, f.at("net", default: none)),
      gross: _money(t.gross, f.at("gross", default: none)),
      due: _money(t.at("due", default: t.gross), f.at("due", default: none)),
      prepaid: _money(t.at("prepaid", default: 0), f.at(
        "prepaid",
        default: none,
      )),
    ),
    // payment terms as given (days, date) and the due date derived from them
    payment: (
      days: if type(pt) == dictionary { pt.at("days", default: none) },
      due: _due(ctx),
    ),
    page: none,
    layout: (name: layout.name, width: pw, height: ph),
    marks: layout.marks,
    area: none,
  )
}

#let _empty(c) = c == none or c == [] or c == ""

#let render-cell(ctx, p, view) = {
  if type(p) == str {
    let fn = ctx.theme.parts.at(p)
    let out = if fn == none { none } else { fn(ctx, view) }
    if p in ctx.theme.requirements.roles.keys() and _empty(out) {
      let level = validation-of(ctx).level
      // `none` as a renderer was reported when the theme resolved (theme/part-*)
      let known = ctx.theme.issues.find(x => x.id == "theme/part-" + p)
      if known != none {
        return if level == "draft" { feedback.part-marker(ctx, p, known) }
      }
      let msg = (
        "theme::parts::"
          + p
          + " returned no content, but it carries legally required output"
      )
      if level == "strict" { panic(msg) }
      if level == "draft" {
        return feedback.part-marker(ctx, p, issue(
          "theme/empty-" + p,
          "theme",
          msg,
          key: "part-empty",
          args: (part: p),
        ))
      }
    }
    out
  } else if type(p) == function { p(ctx, view) } else {
    // content cells are woven, so `info.*` motifs work in area content (#18)
    eval-content(ctx, p)
  }
}

/// Arranges the rendered cells of an area. `cells`: array of (name, body), where
/// name is the part name (none for content and function cells); `area`: the
/// content box (width, height) inside the inset (height auto for flow areas).
/// A function `arrange` receives exactly these: (ctx, cells, area) => content.
#let arrange-cells(ctx, r, cells, area) = {
  let a = r.arrange
  if type(a) == function { return a(ctx, cells, area) }
  let ca = r.cell-align
  let align-of(i) = if ca == auto or ca == () { auto } else if (
    type(ca) == array
  ) { ca.at(i, default: ca.last()) } else { ca }
  let bodies = cells.map(((n, c)) => if c == none { [] } else { c })
  if a == "stack" {
    let items = bodies
      .enumerate()
      .filter(((i, c)) => c != [])
      .map(((i, c)) => {
        let al = align-of(i)
        block(width: 100%, if al == auto { c } else { align(al, c) })
      })
    return stack(spacing: r.gap, ..items)
  }
  // cell-align wins over arrange.align (it is the look-safe way to align cells)
  let grid-cells = bodies
    .enumerate()
    .map(((i, c)) => {
      let al = align-of(i)
      if al == auto { c } else { grid.cell(align: al, c) }
    })
  if a == "row" {
    return grid(columns: (auto,)
        * bodies.len(), column-gutter: 2em, ..grid-cells)
  }
  if type(a) == dictionary {
    let a = a
    let grid-cells = grid-cells
    if a.at("skip-empty", default: false) == true {
      // An empty cell gives up its place, with its track and its alignment
      // where `columns` (or `rows`) and `align` list one per cell.
      let keep = range(cells.len()).filter(i => not _empty(cells.at(i).last()))
      if keep.len() == 0 { return [] }
      let pick(xs) = if type(xs) == array and xs.len() == cells.len() {
        keep.map(i => xs.at(i))
      } else { xs }
      for key in ("columns", "rows", "align") {
        if key in a { a.insert(key, pick(a.at(key))) }
      }
      grid-cells = keep.map(i => grid-cells.at(i))
    }
    let args = (:)
    if "columns" in a {
      args.columns = a.columns
      args.column-gutter = r.gap
    }
    if "rows" in a {
      args.rows = a.rows
      args.row-gutter = r.gap
    }
    if "align" in a {
      // with `rows` only, an alignment array is per ROW (grid would read it per column)
      args.align = if (
        "rows" in a and "columns" not in a and type(a.align) == array
      ) { (x, y) => a.align.at(y, default: a.align.last()) } else { a.align }
    }
    return grid(..args, ..grid-cells)
  }
  panic("theme::layout::areas: unknown arrange " + repr(a))
}

#let _side(v, total) = {
  if type(v) == ratio { v / 100% * total } else if type(v) == relative {
    v.ratio / 100% * total + v.length
  } else { v }
}

/// Renders one area; returns none when every cell is empty and the area has
/// no explicit height (empty stubs never paint a look's fill).
#let render-area(ctx, name, r, rect, view) = {
  let ctx = ctx
  if r.isolate {
    // Brand-immune scope (0.6.x): default tokens, regulated font, black on white.
    ctx.theme.tokens = resolve-tokens(
      defaults-of(token-schema),
      types-of(token-schema),
      defaults-of(token-schema),
    )
  }
  let t = ctx.theme.tokens
  let fill = if r.isolate and r.fill == none { white } else { r.fill } // covers marks + stationery
  // the colour under the area's content: its own fill, else the page background
  let surface = if type(fill) == color { fill } else if fill == none {
    t.colors.background
  } else { none }
  let view = (
    view
      + (
        area: (
          name: name,
          place: r.place,
          width: rect.w,
          height: rect.h,
          // a fixed recipient box: the area shows through an envelope window
          window: r.place == "fixed" and "recipient" in r.parts,
          // names of the parts this area hosts
          parts: r.parts.filter(p => type(p) == str),
          fill: fill,
          surface: surface,
        ),
      )
  )
  let cells = r.parts.map(p => (
    if type(p) == str { p } else { none },
    render-cell(ctx, p, view),
  ))
  if cells.all(((n, c)) => _empty(c)) and r.height == auto { return none }
  let ins = r.inset
  let inner = (
    width: rect.w - _side(ins.left, rect.w) - _side(ins.right, rect.w),
    height: if rect.h == auto { auto } else {
      rect.h - _side(ins.top, rect.w) - _side(ins.bottom, rect.w)
    },
  )
  let body = arrange-cells(ctx, r, cells, inner)
  let content = if r.isolate {
    set text(
      font: ctx.theme.tokens.fonts.regulated,
      fill: black,
      size: 10pt,
      weight: "regular",
      style: "normal",
    )
    body
  } else {
    set par(..r.par)
    set text(..r.text)
    body
  }
  let box = block(
    width: rect.w,
    height: if rect.h == auto { auto } else { rect.h },
    inset: r.inset,
    fill: fill,
    stroke: r.stroke,
    radius: r.radius,
    above: 0pt,
    below: 0pt,
    align(r.align, content),
  )
  if r.rule == none { return box }
  // zero-height decoration outside the box: it adds nothing to the area's height
  let side = r.rule.at("side", default: top)
  let gap = r.rule.at("gap", default: t.spacing.small)
  let rule = line(length: rect.w, stroke: r.rule.at(
    "stroke",
    default: t.strokes.thin + t.colors.border,
  ))
  block(width: rect.w, above: 0pt, below: 0pt, {
    place(
      if side == top { top + left } else { bottom + left },
      dy: if side == top { -gap } else { gap },
      rule,
    )
    box
  })
}

// footer-descent split into (ratio of the bottom margin, absolute part). Needs context.
#let _descent-parts(fd) = {
  if type(fd) == ratio { (fd / 100%, 0pt) } else if type(fd) == relative {
    (fd.ratio / 100%, fd.length.to-absolute())
  } else {
    (0, fd.to-absolute())
  }
}

#let _frame(ctx, body) = {
  let L = ctx.theme.layout
  let t = ctx.theme.tokens
  let (pw, ph) = paper-dims(L)
  let m = L.margin
  let text-w = pw - m.left - m.right

  let areas = L.areas.pairs().filter(((n, r)) => r != none)
  // Mode wins over styling: stationery other than none drops the `stationery: true` areas, whatever renders them.
  let printed = L.stationery != none
  let visible = areas.filter(((n, r)) => not (printed and r.stationery))
  let by-place(where) = visible.filter(((n, r)) => r.place == where)

  // body-top: first-page fixed areas AND first-page background areas with an
  // explicit height (bands) reserve space. Geometry counts even when suppressed.
  let reserving = areas.filter(((n, r)) => {
    let first = r.pages in ("first", "all")
    let default = (
      (r.place == "fixed" and first)
        or (
          r.place == "background"
            and r.pages == "first"
            and r.height != auto
            and r.parts.len() > 0
        )
    )
    first and (if r.reserve == auto { default } else { r.reserve })
  })
  let lowest = reserving
    .map(((n, r)) => {
      let rr = area-rect(r, pw, ph)
      rr.y + if rr.h == auto { 0mm } else { rr.h }
    })
    .fold(0mm, calc.max)
  let body-top = if L.body-top != auto { L.body-top } else if (
    reserving.len() == 0
  ) { m.top } else {
    calc.max(m.top, lowest + L.body-gap)
  }

  let val = validation-of(ctx)
  let draft = val.level == "draft"
  // A render-time finding: strict panics (message unchanged), draft emits an
  // issue into the flow (badge, watermark and report pick it up), none ignores it.
  let finding(id, class, msg, ref: none, fix: none, key: none, args: (:)) = {
    if val.level == "strict" { panic(msg) }
    if draft {
      feedback.emit((
        issue(id, class, msg, ref: ref, fix: fix, key: key, args: args),
      ))
    }
  }
  // This invoice's number in the document (its start marker follows this point).
  let k = query(selector(<ip-invoice-start>).before(here())).len() + 1
  // Pages of the invoice proper: the draft report page(s) at the end are not
  // counted and carry no running areas.
  let invoice-pages() = {
    let s = invoice-span(k)
    s.last - s.first + 1
  }
  // page `p` relative to this invoice: (current, total), none on a report page
  // or on a page of another invoice
  let page-role(p) = {
    let s = invoice-span(k)
    if p < s.first or p > s.last { none } else {
      (current: p - s.first + 1, total: s.last - s.first + 1)
    }
  }
  let base-view = frame-view(ctx, L)
  // furniture (header, footer, background, foreground) is made of artifacts
  let artifact-view = if draft { frame-view(ctx, L, links: false) } else {
    base-view
  }
  let reserved = by-place("after").filter(((n, r)) => r.float)
  let footer-stack(cur, total, view) = {
    let hits = by-place("footer").filter(((n, r)) => page-matches(
      r.pages,
      cur,
      total,
    ))
    let out = hits
      .map(((n, r)) => render-area(ctx, n, r, (w: text-w, h: auto), view))
      .filter(x => x != none)
    if out.len() > 0 { stack(spacing: 0.4em, ..out) }
  }

  // --- bottom margin, footer fit and clearance -------------------------------------
  // The tallest footer stack over the page roles (first/rest x last/not-last). The
  // footer starts footer-descent below the body and must end footer-clearance above
  // the sheet edge. margin.bottom: auto is computed from that (at least 20 mm); an
  // explicit margin that is too small is a lint finding (strict panics, draft marks
  // the overflow on the page).
  let clearance = L.footer-clearance
  let (d-ratio, d-abs) = _descent-parts(L.footer-descent)
  if d-ratio >= 1 {
    panic(
      "theme::layout::footer-descent must be below 100% of the bottom margin, found "
        + repr(L.footer-descent),
    )
  }
  let explicit = m.bottom != auto
  // A computed margin on a one-page invoice is sized for the page-1-of-1 footer
  // only (no "Page 1 of n" folio), so a small invoice keeps that room for the body.
  // Monotonic (more pages never make the margin smaller), so the page count
  // settles. The footer-fit lint of an explicit margin still checks every role.
  let roles = if not explicit and invoice-pages() <= 1 { ((1, 1),) } else {
    ((1, 2), (2, 2), (1, 1), (2, 3))
  }
  let need = if ph == auto { 0pt } else {
    roles
      .map(((cur, total)) => {
        let s = footer-stack(
          cur,
          total,
          artifact-view + (page: (current: cur, total: total)),
        )
        if s == none { 0pt } else { measure(block(width: text-w, s)).height }
      })
      .fold(0pt, calc.max)
  }
  // a block ends at its last baseline: the descenders of the last footer line (fine
  // size) must stay clear of the edge too
  if need > 0pt {
    need += measure(text(
      size: t.sizes.fine,
      top-edge: "baseline",
      bottom-edge: "descender",
    )[gjpqy]).height
  }
  let mb = if explicit { m.bottom } else {
    calc.max(auto-margin-floor, (need + clearance + d-abs) / (1 - d-ratio))
  }
  let m = m + (bottom: mb)
  let descent = d-ratio * mb + d-abs
  let avail = mb - descent - clearance
  let overflow = explicit and ph != auto and need > avail + 0.01mm

  let running(where) = context {
    let role = page-role(here().page())
    if role == none { return none }
    let (current: cur, total: total) = role
    // On the page that carries a reserved zone, footers are relocated into the flow above it.
    let rq = query(<ip-reserve>)
    if (
      where == "footer" and rq.any(q => q.location().page() == here().page())
    ) { return none }
    let view = artifact-view + (page: (current: cur, total: total))
    if where == "footer" { return footer-stack(cur, total, view) }
    let hits = by-place(where).filter(((n, r)) => page-matches(
      r.pages,
      cur,
      total,
    ))
    let out = hits
      .map(((n, r)) => render-area(ctx, n, r, (w: text-w, h: auto), view))
      .filter(x => x != none)
    if out.len() > 0 { stack(spacing: 0.4em, ..out) }
  }

  // draft: the footer overflow is marked where it happens (the clearance zone at the
  // sheet edge), with the number of its report row. Core-owned, brand-immune colours.
  let overflow-marker() = {
    let n = feedback.collected(k).position(x => x.id == "lint/footer-fit")
    place(top + left, dx: m.left, dy: ph - clearance, box(
      width: text-w,
      height: clearance,
      fill: feedback.soft.transparentize(30%),
      stroke: (top: (paint: feedback.edge, thickness: 0.8pt, dash: "dashed")),
      inset: (x: 2pt),
      align(right + horizon, text(
        size: 7pt,
        fill: feedback.ink,
        weight: "bold",
        font: t.fonts.body,
        [#ctx.locale.strings.validation.classes.lint#if n != none [ #(n + 1)]],
      )),
    ))
  }

  let layer(where, extra) = context {
    let s = invoice-span(k)
    let p = here().page()
    if p < s.first { return } // a page of an earlier invoice
    let cur = p - s.first + 1
    let total = s.last - s.first + 1
    let view = artifact-view + (page: (current: cur, total: total))
    // draft feedback: badge on every page (foreground), watermark behind the
    // invoice pages (background, drawn after the stationery)
    let open = if draft { feedback.collected(k) } else { () }
    if cur > total {
      if open.len() > 0 and where == "foreground" {
        feedback.badge(ctx, open.len(), val.at(
          "e-invoice-withheld",
          default: false,
        ))
      }
      return
    }
    extra(cur)
    if open.len() > 0 and where == "background" {
      feedback.watermark(ctx, pw, ph)
    }
    let hits = by-place(where)
    // fixed areas drawn on page 1 are tagged flow content; later pages get artifacts
    if where == "foreground" {
      hits += by-place("fixed").filter(((n, r)) => (
        r.pages != "first" and not (r.pages == "all" and cur == 1)
      ))
    }
    for (n, r) in hits.filter(((n, r)) => page-matches(r.pages, cur, total)) {
      let rr = area-rect(r, pw, ph)
      place(top + left, dx: rr.x, dy: rr.y, render-area(ctx, n, r, rr, view))
    }
    if draft and overflow and where == "foreground" { overflow-marker() }
    if open.len() > 0 and where == "foreground" {
      feedback.badge(ctx, open.len(), val.at(
        "e-invoice-withheld",
        default: false,
      ))
    }
  }

  let stationery(cur) = {
    if type(L.stationery) == dictionary {
      let img = L.stationery.at(
        if cur == 1 { "first" } else { "rest" },
        default: none,
      )
      // stretched to the sheet
      if img != none {
        place(top + left, box(width: pw, height: ph, clip: true, {
          set image(width: pw, height: ph, fit: "stretch")
          img
        }))
      }
    }
  }

  // Print proof (theme.custom.proof): envelope windows, folds and the recipient box,
  // with line metrics measured in the recipient's own text settings.
  let proof-layer = context {
    if page-role(here().page()) == none { return } // not on the draft report page(s)
    let addr = L
      .areas
      .pairs()
      .find(((n, r)) => r != none and "recipient" in r.parts)
    let rt = if addr == none { (:) } else { addr.last().text }
    let lead = if addr == none { 0.65em } else {
      addr.last().par.at("leading", default: 0.65em)
    }
    let st(..args, body) = text(
      font: t.fonts.body,
      size: t.sizes.body,
      ..rt,
      ..args,
      body,
    )
    let one = measure(st[Xg]).height
    let two = measure(st(par(leading: lead, [Xg \ Xg]))).height // the recipient area's line spacing
    let metrics = (
      first: measure(st(
        top-edge: "cap-height",
        bottom-edge: "descender",
      )[Xg]).height,
      pitch: two - one,
    )
    proof-overlay(
      L + (margin: m),
      pw,
      ph,
      area-rect,
      L.proof,
      page-role(here().page()).current,
      metrics,
    )
  }

  let page-args = if type(L.paper) == dictionary {
    (width: pw, height: ph)
  } else { (paper: L.paper, flipped: L.flipped) }

  // ONE unconditional `set page` (the 0.4 dead-footer bug came from `set page` in an `if`).
  set page(
    ..page-args,
    margin: m,
    fill: if t.colors.background == white { auto } else { t.colors.background },
    header-ascent: L.header-ascent,
    footer-descent: L.footer-descent,
    header: running("header"),
    footer: running("footer"),
    background: layer("background", stationery),
    foreground: {
      layer("foreground", cur => none)
      if L.proof != false { proof-layer }
    },
  )

  // first element of the invoice (page roles and draft issues are per invoice)
  [#metadata(k)<ip-invoice-start>]
  // up-front issues (theme, document data, measured data), in their order
  if draft { feedback.emit(val.issues) }
  // Running footers must fit between footer-descent and footer-clearance (they are
  // legal content: a footer that runs off the paper is lost silently otherwise).
  if overflow and val.level != none {
    finding(
      "lint/footer-fit",
      "lint",
      "theme::layout::areas::footer is "
        + str(calc.round(need / 1mm, digits: 1))
        + "mm tall, but the bottom margin leaves "
        + str(calc.round(avail / 1mm, digits: 1))
        + "mm between footer-descent and the "
        + str(calc.round(clearance / 1mm, digits: 1))
        + "mm footer-clearance; use the computed margin (theme.custom.page(margin: (bottom: reset()))), raise margin.bottom or shorten the footer",
      fix: (
        "theme.custom.page(margin: (bottom: reset()))",
        "theme.custom.page(margin: (bottom: "
          + str(calc.ceil((need + descent + clearance) / 1mm) + 1)
          + "mm))",
      ),
      key: "footer-fit",
      args: (
        need: calc.round(need / 1mm, digits: 1),
        avail: calc.round(avail / 1mm, digits: 1),
        clearance: calc.round(clearance / 1mm, digits: 1),
      ),
    )
  }

  // First-page content drawn in the flow (tagged, reading order = area order):
  // fixed areas of page 1, then the flow areas before the body.
  // Identity guard (core, not a role test): number and date must be in the tagged
  // first-page output. String values stay strings in the view (parts may measure,
  // truncate or lay them out); a show rule tags them with labelled metadata
  // wherever they are typeset. Content values are wrapped in the view. The check
  // runs after layout, so title parts may use layout(), measure() and context.
  let d = base-view.document
  let needles = (("number", ctx.invoice-nr), ("date", d.date.text))
    .map(((w, n)) => (
      w,
      if type(n) in (int, float, decimal) { str(n) } else { n },
    ))
    .filter(((w, n)) => not _blank(n))
  let check-identity = val.level != none and needles.len() > 0
  let first-view = base-view
  for (what, n) in needles.filter(((w, n)) => type(n) == content) {
    let tagged = [#n#metadata(what)<ip-identity>]
    if what == "number" { first-view.document.number = tagged } else {
      first-view.document.date.text = tagged
    }
  }
  // One show rule for all string values, the longest first: with a rule per
  // value, the inner rule wins where both match (the number "1" at the start of
  // the date "16.10.2026"), and the date then no longer matches. A match tags
  // the value it is, so the number inside the date does not count.
  let strings = needles
    .filter(((w, n)) => type(n) == str)
    .sorted(key: ((w, n)) => -n.len())
  let any = regex(
    strings
      .map(((w, n)) => n.replace(_regex-special, m => "\\" + m.text))
      .join("|", default: ""),
  )
  let tag-identity(c) = {
    if strings == () { return c }
    show any: it => {
      it
      for (what, n) in strings {
        if it.text == n [#metadata(what)<ip-identity>]
      }
    }
    c
  }
  let first-fixed = by-place("fixed")
    .filter(((n, r)) => r.pages in ("first", "all"))
    .map(((n, r)) => {
      let rr = area-rect(r, pw, ph)
      (rr, render-area(ctx, n, r, rr, first-view))
    })
  let before = by-place("before").map(((n, r)) => render-area(
    ctx,
    n,
    r,
    (w: text-w, h: r.height),
    first-view,
  ))
  if check-identity { [#metadata(none)<ip-identity-probe>] }
  for (rr, c) in first-fixed {
    if c != none {
      place(top + left, dx: rr.x - m.left, dy: rr.y - m.top, tag-identity(c))
    }
  }
  v(body-top - m.top)
  for c in before {
    if c != none {
      tag-identity(c)
      v(t.spacing.medium)
    }
  }
  if check-identity {
    context {
      // the probe is missing only in the first layout pass (introspection not ready yet)
      if query(<ip-identity-probe>).len() == 0 { return }
      // the tags on this invoice's first page (positions, not the invoice number k:
      // in the first pass every invoice still counts itself as the first)
      let first = invoice-span(k).first
      let seen = query(<ip-identity>)
        .filter(x => x.location().page() == first)
        .map(x => x.value)
      for (what, n) in needles {
        if what not in seen {
          let shown = if type(n) == str { n } else { repr(n) }
          let bt = if what == "number" { "BT-1" } else { "BT-2" }
          finding(
            "theme/identity-" + what,
            "theme",
            "theme: the invoice "
              + what
              + " ("
              + shown
              + ") does not appear in the first-page content; the area hosting `title` must render view.document."
              + (if what == "number" { "number" } else { "date.text" })
              + " (§ 14 UStG; EN 16931 "
              + bt
              + ")",
            ref: "§ 14 Abs. 4 Nr. "
              + (if what == "number" { "4" } else { "3" })
              + " UStG; EN 16931 "
              + bt,
            key: "identity",
            args: (what: what, shown: shown),
          )
        }
      }
    }
  }
  {
    set par(justify: true)
    body
  }
  for (n, r) in by-place("after").filter(((n, r)) => not r.float) {
    render-area(ctx, n, r, (w: text-w, h: r.height), base-view)
  }
  // Reserved zones (0.6.x): float to the paper's bottom edge; every footer area of
  // that page moves INTO the flow above the zone (with its real page number).
  for (n, r) in reserved {
    let rect = area-rect(r + (top: auto, bottom: 0mm), pw, ph)
    let reserve = rect.h - m.bottom
    place(
      bottom + left,
      float: true,
      clearance: 0pt,
      dx: rect.x - m.left,
      block(width: rect.w, breakable: false, {
        [#metadata(n) <ip-reserve>]
        context {
          let sp = invoice-span(k)
          let cur = here().page() - sp.first + 1
          let total = sp.last - sp.first + 1
          let s = footer-stack(
            cur,
            total,
            artifact-view + (page: (current: cur, total: total)),
          )
          if s != none {
            pad(left: m.left - rect.x, right: m.right, s)
            v(2mm)
          }
        }
        block(width: rect.w, height: reserve, place(top + left, render-area(
          ctx,
          n,
          r,
          rect,
          base-view,
        )))
      }),
    )
  }
  // end of the invoice proper (a draft report follows on its own pages)
  [#metadata(k)<ip-invoice-end>]
  // Draft report: after the invoice, on its own page(s), outside the page count.
  if draft {
    context {
      let open = feedback.collected(k)
      if open.len() > 0 {
        pagebreak(weak: true)
        [#metadata(k)<ip-report>]
        feedback.report(
          ctx,
          open,
          val.at("e-invoice-withheld", default: false),
          val.at("e-invoice-profile", default: none),
        )
      }
    }
  }
}

#let render-frame(ctx, body) = {
  let ctx = unsealed(ctx)
  let t = ctx.theme.tokens
  set text(font: t.fonts.body, size: t.sizes.body, fill: t.colors.text)
  set par(leading: t.spacing.leading)
  show heading: set text(font: t.fonts.heading)
  // in context: the bottom margin may be computed from the measured footer
  context _frame(ctx, body)
}
