// Default BODY parts, called by components in their draw pass.
// They reuse the generic renderers in src/themes/ (table, notes, payment terms, signature).
//
// Body views (provisional, 0.6.0). v1 fields stay available while parts use them;
// the v2 fields are the documented ones for new parts:
//   line-items / items-table / totals / notes:
//     view.totals.rows     array of (kind, label, value: (value, text), emphasis,
//                          rate, name, marker, payable) in the LEGAL ORDER of the tax
//                          mode; 0 % tax rows are removed in measure. kinds:
//                          "subtotal" "discount" "surcharge" "net-total" "tax" "total"
//                          "prepayment" "amount-due"; emphasis: none | "strong" | "total";
//                          `label` is complete (name, date, tax marker) without a
//                          trailing colon; `name` = the modifier's / prepayment's own
//                          name (none for fixed rows); `rate` = signed percentage of a
//                          relative modifier or the tax rate; `payable` marks the row
//                          the recipient pays.
//     view.totals.payable  that row (the total, or the amount due after prepayments)
//     v1 (provisional): items, entries, discounts, surcharges, prepayments, taxes
//     (incl. 0 %), total, unmodified-total, layout-information, tax-mode,
//     tax-exempt-small-biz
//   bank-details: view.iban (value: normalised, text: grouped in fours),
//     view.payment-reference (the reference or the unstructured text; none = none),
//     view.show-reference, view.qr; v1: sender (name, bank, iban, bic), reference, text
//   payment-terms: view.amount (value, text), view.amount-kind ("total" | "amount-due"),
//     view.deadline (content), view.payment-means (the kind of payment means the
//     sentence is for: "transfer" | "direct-debit" | "card" | none), view.discounts
//     (the cash discounts with their printed `note`); v1: days, date, total
//   payment-means (direct-debit, card-payment, paid): view.kind, view.text (a
//     sentence or none), view.details: array of (label, value, valid),
//     view.report-problems (mark an invalid identifier where it is printed)
//   zugferd-report: the result of the e-invoice (`zugferd-errors: "report"`):
//     view.profile, view.diagnostics (errors first); called by core, not by a
//     component
//   internal: view.tail (items-table, from the line-items composite): the totals
//     block the built-in table binds to its last entry (see `line-items`)

#import "../../themes/components/line-items/table.typ": render-table
#import "../../themes/components/line-items/global-info.typ": render-global-info
#import "../../themes/base-theme/payment-terms.typ": render-payment-terms
#import "../../themes/base-theme/payment-means.typ": render-payment-means
#import "../../themes/base-theme/signature.typ": render-signature
#import "../access.typ": unsealed
#import "../color.typ": on-color
#import "../../validation/issue.typ": issue
#import "../../validation/render.typ": part-marker

/// Body parts are set ragged: a justified payment sentence or note shows rivers
/// in the narrow columns many looks use (design review).
#let _ragged = (
  "line-items",
  "items-table",
  "totals",
  "notes",
  "bank-details",
  "payment-means",
  "payment-terms",
  "signature",
)

/// Calls a part by name from the effective (possibly scoped) theme.
/// `required: auto` = the document kind's requirements decide (theme.requirements).
/// A required part that renders nothing follows the validation level: strict
/// panics, draft puts a marker in its place, none renders nothing.
#let call-part(ctx, name, view, required: auto) = {
  let ctx = unsealed(ctx)
  let fn = ctx.theme.parts.at(name, default: none)
  let required = if required == auto {
    name in ctx.theme.requirements.parts
  } else { required }
  let out = if fn == none { none } else { fn(ctx, view) }
  if required and (out == none or out == [] or out == "") {
    let level = ctx.at("validation", default: (level: none)).level
    // `none` as a renderer was reported when the theme resolved (theme/part-*)
    if fn != none {
      let msg = (
        "theme::parts::"
          + name
          + " returned no content, but it must render legally required output"
      )
      if level == "strict" { panic(msg) }
      if level == "draft" {
        return part-marker(ctx, name, issue(
          "theme/empty-" + name,
          "theme",
          msg,
          key: "part-empty",
          args: (part: name),
        ))
      }
    } else if level == "draft" {
      let known = ctx.theme.issues.find(x => x.id == "theme/part-" + name)
      return part-marker(ctx, name, if known != none { known } else {
        issue(
          "theme/part-" + name,
          "theme",
          "theme::parts::"
            + name
            + " carries legally required output and cannot be `none`",
          key: "part-none",
          args: (part: name),
        )
      })
    }
  }
  if out != none and name in _ragged {
    set par(justify: false)
    out
  } else { out }
}

/// Set by `view.tail` itself when it is placed (the built-in table, or a
/// replaced items-table that renders it), so the totals never print twice.
/// `line-items` resets it before each table. It starts as `true`: the first
/// layout pass knows no state yet and reads this value, and printing the
/// fallback totals there would make a one-page invoice two pages long (a
/// page count the frame's margins can then hold on to).
#let _tail-bound = state("ip-tail-bound", true)

#let items-table(ctx, view) = {
  let t = ctx.theme.tokens
  let o = ctx.theme.options.items-table
  let li = ctx.theme.options.line-items
  let (odd, even, row-fill) = if type(o.zebra) == function {
    (none, none, o.zebra)
  } else { (..o.zebra, none) }
  set text(number-width: t.fonts.number-width)
  // header voice: label font and the strong weight, then the look's header-style
  let header-style = (
    (font: t.fonts.label, weight: t.weights.strong) + o.header-style
  )
  render-table(
    ctx,
    view,
    color-subtitle: t.colors.text-muted,
    color-desc: t.colors.text-muted,
    color-discount: li.discount-color,
    color-surcharge: li.surcharge-color,
    size-subtitle: t.sizes.small,
    size-small: t.sizes.small,
    weight-bold: t.weights.strong,
    header-text-style: header-style,
    number-font: t.fonts.numeric,
    leading: t.spacing.leading,
    row-rule: o.row-rule,
    color-row-odd: odd,
    color-row-even: even,
    row-fill: row-fill,
    stroke-thin: t.strokes.thin + o.rule,
    stroke-regular: t.strokes.regular + o.rule,
    item-inset: (x: t.spacing.small * 0.75, y: o.row-inset),
    cell-inset: t.spacing.small,
    header-cell-inset: (x: t.spacing.small, y: t.spacing.medium),
    header-bg: o.header-fill,
    header-color: if o.header-text != auto {
      o.header-text
    } else if o.header-fill == none { t.colors.text } else {
      on-color(o.header-fill)
    },
    header-repeat: o.repeat-header,
    tail: view.at("tail", default: none),
    column-order: o.column-order,
    description-colspan: ("quantity", "unit-price"),
    align-header: (pos: center, description: left, quantity: right),
    align-body: (pos: center, description: left),
  )
}

/// Totals from the ROW MODEL (view.totals.rows, built in measure: legal order of
/// the tax mode, 0 % rates already removed). This renderer only styles: rules
/// follow the row kinds, emphasis "strong" | "total" sets the weight
/// (weights.strong) and size (sizes.large), values use fonts.numeric.
#let totals(ctx, view) = {
  let t = ctx.theme.tokens
  let o = ctx.theme.options.totals
  let li = ctx.theme.options.line-items
  let rows = view.totals.rows
  let inclusive = view.tax-mode != "exclusive"
  let filled = o.fill != none
  let fg = if o.color != auto { o.color } else if filled {
    on-color(o.fill)
  } else { t.colors.text }
  let num(x) = text(font: t.fonts.numeric, x)
  set text(number-width: t.fonts.number-width)
  set text(fill: fg) if filled

  let pair(r) = {
    let label = if r.name == none and r.label != [] [#r.label:] else { r.label }
    let value = if (
      r.rate != none and r.kind != "tax"
    ) [(#r.rate) #h(0.5em) #r.value.text] else { r.value.text }
    let (label, value) = if r.kind in ("discount", "prepayment", "surcharge") {
      let c = if r.kind == "surcharge" { li.surcharge-color } else {
        li.discount-color
      }
      (text(fill: c, size: t.sizes.small, label), text(fill: c, value))
    } else if r.kind == "tax" {
      (
        text(fill: if filled { fg } else { t.colors.text-muted }, label),
        text(fill: fg, value),
      )
    } else if r.emphasis == "total" {
      (
        text(weight: t.weights.strong, size: t.sizes.large, label),
        text(weight: t.weights.strong, size: t.sizes.large, value),
      )
    } else if r.emphasis == "strong" {
      (
        text(weight: t.weights.strong, label),
        text(weight: t.weights.strong, value),
      )
    } else { (label, value) }
    (grid.cell(label), grid.cell(num(value)))
  }
  // rule above a row, from the kinds (the legal grouping): thin above the tax and
  // prepayment groups (thick above the taxes in inclusive mode), thick above the
  // total and the amount due; thick below the last row unless inclusive taxes end it
  let rule-above(prev, r) = {
    if r.kind == "tax" and prev != "tax" {
      if inclusive { t.strokes.thick } else { t.strokes.thin }
    } else if (
      r.kind == "total" and prev != none
    ) { t.strokes.thick } else if (
      r.kind == "prepayment" and prev != "prepayment"
    ) { t.strokes.thin } else if (
      r.kind == "amount-due"
    ) { t.strokes.thick } else { none }
  }
  let null-row = grid.cell(colspan: 2, inset: 0pt, none)
  let rule-paint = if filled { fg } else { t.colors.border }
  let cells = ()
  let prev = none
  for r in rows {
    let s = rule-above(prev, r)
    if s != none { cells += (grid.hline(stroke: s + rule-paint), null-row) }
    cells += pair(r)
    prev = r.kind
  }
  if rows.len() > 0 and not (inclusive and prev == "tax") {
    cells += (grid.hline(stroke: t.strokes.thick + rule-paint), null-row)
  }

  let body = grid(columns: (
      1fr,
      auto,
    ), row-gutter: 0.6em, column-gutter: 1em, align: (left, right), ..cells)
  let block-of(w) = if filled {
    box(
      width: w,
      fill: o.fill,
      inset: t.spacing.medium,
      radius: t.radii.small,
      body,
    )
  } else { box(width: w, body) }
  // right-aligned with or without fill; `min-width` floors the width in narrow
  // columns and never exceeds the column
  align(right, if o.min-width == none { block-of(o.width) } else {
    layout(size => {
      let w = o.width
      let abs = if type(w) == ratio { w * size.width } else if (
        type(w) == relative
      ) {
        w.ratio * size.width + w.length.to-absolute()
      } else { w.to-absolute() }
      block-of(calc.min(size.width, calc.max(abs, o.min-width.to-absolute())))
    })
  })
}

/// Legal notes: WHAT is decided by the component (view.required); this only styles.
#let notes(ctx, view) = {
  let t = ctx.theme.tokens
  render-global-info(
    ctx,
    view,
    color-desc: t.colors.text-muted,
    size-small: t.sizes.small,
  )
}

/// Composite: table then totals. `notes` is NOT called here: the line-items
/// component appends it itself, so replacing `line-items` can never drop it.
/// The totals never start a page alone: the composite hands them to the table as
/// `view.tail`, and the built-in table (also when wrapped) keeps them with its
/// last entry. A replaced items-table leaves the tail alone; the totals then
/// follow the table as before.
#let line-items(ctx, view) = {
  let gap = ctx.theme.options.line-items.gap
  let totals = if view.layout-information.show-total {
    call-part(ctx, "totals", view)
  }
  if totals == none { return call-part(ctx, "items-table", view) }
  _tail-bound.update(false)
  call-part(
    ctx,
    "items-table",
    view
      + (
        // placing the tail marks it as placed
        tail: [#_tail-bound.update(true)#block(
            width: 100%,
            above: 0pt,
            below: 0pt,
            inset: (top: gap),
            totals,
          )],
      ),
  )
  context if not _tail-bound.get() {
    // weak spacing replaces the block spacing: exactly `gap` between the two
    v(gap, weak: true)
    totals
  }
}

#let bank-details(ctx, view) = {
  let t = ctx.theme.tokens
  let s = ctx.locale.strings.bank-details
  let o = ctx.theme.options.bank-details
  let qr = if o.show-qr and view.qr != none {
    (view.qr)(if o.qr-size == auto { 25mm } else { o.qr-size })
  }
  let num(x) = text(
    font: t.fonts.numeric,
    number-width: t.fonts.number-width,
    x,
  )
  let label(body) = text(font: t.fonts.label, body)
  // an invalid IBAN is a data issue of the core (view.iban.valid); the display
  // form comes from the view. With `zugferd-errors: "report"`, the e-invoice
  // report lists it, and a note next to it says so.
  let iban-note = if (
    not view.iban.valid and view.at("report-problems", default: false)
  ) {
    text(
      fill: rgb("#b91c1c"),
    )[ (#if view.iban.value == "" [missing] else [invalid])]
  }
  // a line without a value (no bank given, `name: none`) is left out
  let given(value) = value not in (none, "", [])
  let lines = (
    if given(view.sender.name) [#label(s.account-holder): #view.sender.name],
    if given(view.sender.bank) [#label(s.bank): #view.sender.bank],
    [#label(s.iban): #num(text(weight: t.weights.strong, view.iban.text))#iban-note],
    if given(view.sender.bic) [#label(s.bic): #view.sender.bic],
    if view.show-reference
      and view.payment-reference
        != none [#label(s.reference): #num(view.payment-reference)],
  ).filter(x => x != none)
  grid(
    columns: (1fr, auto),
    gutter: 1em,
    {
      set par(leading: 0.4em)
      set text(number-type: "lining")
      lines.join(linebreak())
    },
    qr,
  )
}

#let payment-terms(ctx, view) = render-payment-terms(ctx, view)
#let payment-means(ctx, view) = render-payment-means(ctx, view)
#let signature(ctx, view) = render-signature(ctx, view)

/// The e-invoice report of `zugferd-errors: "report"`, printed at the top of
/// the body: every problem the validation of the e-invoice found. `none`
/// shows no report; the errors then stop the compilation as with
/// `zugferd-errors: "panic"`. Its module loads only when a report is shown,
/// so that invoices without an e-invoice load no e-invoice code.
#let zugferd-report(ctx, view) = {
  import "../../zugferd/report.typ": render-zugferd-report
  render-zugferd-report(ctx, view)
}

#let body-parts = (
  line-items: line-items,
  items-table: items-table,
  totals: totals,
  notes: notes,
  bank-details: bank-details,
  payment-means: payment-means,
  payment-terms: payment-terms,
  signature: signature,
  zugferd-report: zugferd-report,
)
