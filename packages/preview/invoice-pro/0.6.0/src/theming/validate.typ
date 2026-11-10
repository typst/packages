#import "../utils/patch.typ": did-you-mean
#import "schema.typ": auto-margin-floor, page-sets, places
#import "color.typ": contrast, on-color
#import "../validation/issue.typ": issue

#import "proof.typ": envelope-band

// Two kinds of findings live here. API misuse (`_fail`, plain `panic`) always
// panics: the input has no meaning. Everything else is returned as an issue
// (validation/issue.typ) and follows invoice(validation: ..).
#let _fail(path, msg) = panic(path.join("::") + " " + msg)

// --- requirements per document kind (mechanism frozen, table provisional) --------
// roles: a part name set that must be HOSTED (placed) by the layout.
//   where "tagged": a flow area or a fixed area drawn on page 1 (pages first|all)
//   where "first-page": any visible area drawn on page 1 (incl. running/layer places)
//   waived-by-stationery: satisfied by pre-printed / art stationery (the paper carries it)
// parts: may not be `none`, and a call that returns nothing panics. The same holds
//   for a part that alone hosts a role (title, recipient).
#let requirements-table = (
  invoice: (
    roles: (
      title: (
        hosts: ("title",),
        where: "tagged",
        count: "at least one",
        waived-by-stationery: false,
        why: "document identity: invoice number and date (§ 14 UStG; EN 16931 BT-1, BT-2)",
        ref: "§ 14 Abs. 4 Nr. 3, 4 UStG; EN 16931 BT-1, BT-2",
      ),
      recipient: (
        hosts: ("recipient",),
        where: "tagged",
        count: "exactly one",
        waived-by-stationery: false,
        why: "recipient name and address (§ 14 UStG; EN 16931 BG-7)",
        ref: "§ 14 Abs. 4 Nr. 1 UStG; EN 16931 BG-7",
      ),
      supplier: (
        hosts: ("sender", "company", "return-address"),
        where: "first-page",
        count: "at least one",
        waived-by-stationery: true,
        why: "supplier name and address (§ 14 UStG; EN 16931 BG-4)",
        ref: "§ 14 Abs. 4 Nr. 1 UStG; EN 16931 BG-4",
      ),
      tax-id: (
        hosts: ("registration", "references", "reference-list"),
        where: "first-page",
        count: "at least one",
        waived-by-stationery: true,
        why: "supplier VAT ID or tax number (§ 14 UStG; EN 16931 BT-31, BT-32)",
        ref: "§ 14 Abs. 4 Nr. 2 UStG; EN 16931 BT-31, BT-32",
      ),
    ),
    parts: ("line-items", "items-table", "totals", "notes"),
  ),
)
#let requirements-for(env) = requirements-table.at(env.at(
  "kind",
  default: "invoice",
))

// --- paper ------------------------------------------------------------------------
// ISO 216 A/B and ISO 269 C series computed (no hand-copied list), plus US sizes.
#let _iso(series) = {
  let (w, h) = (a: (841, 1189), b: (1000, 1414), c: (917, 1297)).at(series)
  let out = (:)
  for i in range(11) {
    out.insert(series + str(i), (w * 1mm, h * 1mm))
    (w, h) = (calc.floor(h / 2), w)
  }
  out
}
#let paper-sizes = (
  _iso("a")
    + _iso("b")
    + _iso("c")
    + (
      "us-letter": (215.9mm, 279.4mm),
      "us-legal": (215.9mm, 355.6mm),
      "us-executive": (184.15mm, 266.7mm),
      "us-tabloid": (279.4mm, 431.8mm),
    )
)

#let paper-dims(layout) = {
  let (w, h) = if type(layout.paper) == dictionary {
    (layout.paper.width, layout.paper.at("height", default: auto))
  } else if (
    layout.paper in paper-sizes
  ) { paper-sizes.at(layout.paper) } else {
    panic(
      "theme::layout::paper `"
        + str(layout.paper)
        + "` has no known size; use (width:, height:)."
        + did-you-mean(str(layout.paper), paper-sizes.keys())
        + " Known: ISO a0-a10, b0-b10, c0-c10, us-letter, us-legal, us-executive, us-tabloid",
    )
  }
  if layout.flipped { (h, w) } else { (w, h) }
}

#let _abs(v, total) = {
  if v == auto { return auto }
  if type(v) == ratio { return v / 100% * total }
  if type(v) == relative { return v.ratio / 100% * total + v.length }
  v
}

/// Page-absolute rectangle of a fixed/background area.
#let area-rect(r, pw, ph) = {
  let w = if r.width == auto { pw } else { _abs(r.width, pw) }
  let h = _abs(r.height, ph)
  let x = if r.left != auto { _abs(r.left, pw) } else if r.right != auto {
    pw - _abs(r.right, pw) - w
  } else { 0mm }
  let y = if r.top != auto { _abs(r.top, ph) } else if r.bottom != auto {
    assert(
      h != auto,
      message: "theme::layout::areas: an area anchored with `bottom` needs a `height`",
    )
    ph - _abs(r.bottom, ph) - h
  } else { 0mm }
  (x: x, y: y, w: w, h: h)
}

#let _intersect(a, b) = (
  a.h != auto
    and b.h != auto
    and a.x < b.x + b.w
    and b.x < a.x + a.w
    and a.y < b.y + b.h
    and b.y < a.y + a.h
)

/// Resolved `pages` (auto -> "first" for fixed and flow areas, "all" otherwise).
#let resolve-pages(r) = if r.pages != auto { r.pages } else if (
  r.place in ("fixed", "before", "after")
) { "first" } else { "all" }

/// Tagged first-page content: a flow area or a fixed area drawn on page 1.
#let is-tagged-first-page(r) = (
  r.place in ("before", "after")
    or (r.place == "fixed" and r.pages in ("first", "all"))
)
/// Drawn on page 1 at all (tagged or artifact).
#let is-on-first-page(r) = (
  r.place in ("before", "after") or r.pages in ("first", "all")
)

#let _check-area(name, r, parts, raw-pages, body-parts) = {
  let path = ("theme", "layout", "areas", name)
  if r.place in ("before", "after") and raw-pages != auto {
    _fail(
      path + ("pages",),
      "applies only to fixed, header, footer, background and foreground areas; flow areas appear once",
    )
  }
  if r.place == "fixed" {
    if (r.left == auto) == (r.right == auto) {
      _fail(path, "needs exactly one of `left` or `right` (place: \"fixed\")")
    }
    if (r.top == auto) == (r.bottom == auto) {
      _fail(path, "needs exactly one of `top` or `bottom` (place: \"fixed\")")
    }
  }
  if r.rule != none {
    if (
      type(r.rule) != dictionary
        or r.rule.keys().any(k => k not in ("side", "stroke", "gap"))
    ) {
      _fail(
        path + ("rule",),
        "must be none or (side: top | bottom, stroke: .., gap: ..), found "
          + repr(r.rule),
      )
    }
    if r.rule.at("side", default: top) not in (top, bottom) {
      _fail(
        path + ("rule", "side"),
        "must be `top` or `bottom`, found " + repr(r.rule.side),
      )
    }
  }
  if (
    type(r.cell-align) == array
      and not r.cell-align.all(a => type(a) == alignment)
  ) {
    _fail(
      path + ("cell-align",),
      "must be an alignment or an array of alignments (one per cell), found "
        + repr(r.cell-align),
    )
  }
  for p in r.parts {
    if type(p) == str and p in body-parts {
      _fail(
        path + ("parts",),
        "hosts `"
          + p
          + "`, a body part: it renders where its component is called in the invoice body, not in an area.",
      )
    }
    if type(p) == str and p not in parts {
      _fail(
        path + ("parts",),
        "references unknown part `"
          + p
          + "`."
          + did-you-mean(p, parts.keys())
          + " Known parts: "
          + parts.keys().join(", "),
      )
    }
  }
}

/// Validates the resolved layout; returns (layout with resolved `pages`, hosted
/// part names, issues). Undefined geometry panics; compliance and lint findings
/// are issues.
#let validate-layout(layout, parts, requirements, body-parts: ()) = {
  let (pw, ph) = paper-dims(layout)
  let m = layout.margin
  // stationery is a mode: none (the theme draws everything), "pre-printed" or art per page
  let st = layout.stationery
  let st-ok = (
    st == none
      or st == "pre-printed"
      or (type(st) == dictionary and st.keys().all(k => k in ("first", "rest")))
  )
  if not st-ok {
    _fail(
      ("theme", "layout", "stationery"),
      "must be none (the theme draws everything), \"pre-printed\" or (first: content, rest: content), found "
        + repr(st),
    )
  }
  for side in ("top", "left", "right") {
    if m.at(side) == auto {
      _fail(
        ("theme", "layout", "margin", side),
        "cannot be auto; only margin.bottom is computed (from the footer)",
      )
    }
  }
  if type(layout.footer-clearance) != length or layout.footer-clearance < 0pt {
    _fail(
      ("theme", "layout", "footer-clearance"),
      "must be a length of at least 0pt, found "
        + repr(layout.footer-clearance),
    )
  }
  let areas = (:)
  for (n, r) in layout.areas {
    if r == none {
      areas.insert(n, none)
      continue
    }
    let raw = r.pages
    let r = r + (pages: resolve-pages(r))
    _check-area(n, r, parts, raw, body-parts)
    if (
      ph == auto
        and (r.bottom != auto or type(r.height) in (ratio, relative) or r.float)
    ) {
      _fail(
        ("theme", "layout", "areas", n),
        "cannot be anchored to the bottom or sized relative to the page on paper with `height: auto` (continuous roll)",
      )
    }
    areas.insert(n, r)
  }
  let layout = layout + (areas: areas)
  let live = areas.pairs().filter(((n, r)) => r != none)
  let hosted = live
    .map(((n, r)) => r.parts.filter(p => type(p) == str))
    .flatten()
  let printed = layout.stationery != none
  let visible = live.filter(((n, r)) => not (printed and r.stationery))
  let issues = ()

  // required roles (document kind decides which)
  for (role, rule) in requirements.roles {
    if rule.waived-by-stationery and printed { continue }
    let hosts = visible.filter(((n, r)) => {
      let where = if rule.where == "tagged" { is-tagged-first-page(r) } else {
        is-on-first-page(r)
      }
      where and rule.hosts.any(h => h in r.parts)
    })
    if hosts.len() == 0 or (rule.count == "exactly one" and hosts.len() > 1) {
      let place-txt = if rule.where == "tagged" {
        "first-page (tagged) or flow area"
      } else { "area drawn on page 1" }
      let parts-txt = rule.hosts.map(h => "`" + h + "`").join(" or ")
      issues.push(issue(
        "theme/role-" + role,
        "theme",
        "theme::layout ("
          + layout.name
          + ") must host "
          + parts-txt
          + " in "
          + rule.count
          + " "
          + place-txt
          + " (found "
          + str(hosts.len())
          + "). It carries legally required output: "
          + rule.why
          + ". Restyle it by replacing its renderer, but keep it placed.",
        ref: rule.ref,
        fix: "theme.custom.area(\"..\", parts: (\""
          + rule.hosts.first()
          + "\", ..))",
        key: "role",
        args: (
          role: role,
          why: rule.why,
          layout: layout.name,
          parts: rule.hosts,
          exactly: rule.count == "exactly one",
          tagged: rule.where == "tagged",
          found: hosts.len(),
        ),
      ))
    }
  }
  if ph != auto {
    // fixed areas on following pages must stay in the margins (else they overprint the body)
    // a computed bottom margin is at least 20 mm (auto-margin-floor)
    let mb = if m.bottom == auto { auto-margin-floor } else { m.bottom }
    let body = (
      x: m.left,
      y: m.top,
      w: pw - m.left - m.right,
      h: ph - m.top - mb,
    )
    for (n, r) in live.filter(((n, r)) => (
      r.place == "fixed" and r.pages in ("all", "rest", "not-last", "last")
    )) {
      if _intersect(area-rect(r, pw, ph), body) {
        issues.push(issue(
          "lint/overprint-" + n,
          "lint",
          "theme::layout::areas::"
            + n
            + " is a fixed area on following pages (pages: \""
            + r.pages
            + "\") and would overprint the body there; use pages: \"first\" or move it into the margins",
          fix: "theme.custom.area(\"" + n + "\", pages: \"first\")",
          key: "overprint",
          args: (area: n, pages: r.pages),
        ))
      }
    }
    // overlap lint: nothing drawn on page 1 may overlap the address window
    let fixed1 = live.filter(((n, r)) => (
      r.place == "fixed" and r.pages in ("first", "all")
    ))
    for (wn, wr) in fixed1.filter(((n, r)) => "recipient" in r.parts) {
      let a = area-rect(wr, pw, ph)
      for (n, r) in fixed1 {
        if n != wn and _intersect(a, area-rect(r, pw, ph)) {
          issues.push(issue(
            "lint/window-" + n,
            "lint",
            "theme::layout::areas::"
              + n
              + " overlaps the address window area `"
              + wn
              + "`; move it or shrink it (envelope windows must stay clear)",
            ref: "DIN 5008; DIN 680 (window envelopes)",
            key: "window",
            args: (area: n, window: wn),
          ))
        }
      }
    }
  }
  // regulated payment slips are A4 artefacts (SIX QR-bill: 210 x 105 mm at the bottom of A4)
  if (
    visible.any(((n, r)) => "qr-bill" in r.parts) and (pw, ph) != (210mm, 297mm)
  ) {
    issues.push(issue(
      "lint/qr-bill-paper",
      "lint",
      "theme::layout ("
        + layout.name
        + ") hosts `qr-bill`, which needs A4 portrait paper (SIX QR-bill: 210 x 105 mm slip)",
      ref: "SIX Swiss Implementation Guidelines QR-bill",
      key: "qr-bill-paper",
      args: (layout: layout.name),
    ))
  }
  // envelopes: malformed records and unknown proof names are misuse (panic); a folded
  // sheet that does not fit a declared envelope is a lint finding (the page itself renders)
  if type(layout.envelopes) != array {
    _fail(
      ("theme", "layout", "envelopes"),
      "must be an array of envelope records",
    )
  }
  if ph != auto {
    for (i, e) in layout.envelopes.enumerate() {
      let b = envelope-band(e, layout, pw, ph, path: (
        "theme",
        "layout",
        "envelopes",
        str(i),
      ))
      if b != none and b.misfit != none {
        issues.push(issue(
          "lint/envelope-" + b.name,
          "lint",
          b.misfit,
          ref: "DIN 680; postal window-envelope specifications",
          fix: "theme.custom.envelopes(..) with envelopes that take the folded sheet",
          key: "envelope",
          args: b.misfit-args,
        ))
      }
    }
  } else if layout.envelopes.len() > 0 {
    _fail(
      ("theme", "layout", "envelopes"),
      "needs paper with a height (a roll has no envelope)",
    )
  }
  if type(layout.proof) == array {
    let names = layout.envelopes.map(e => e.name)
    for n in layout.proof {
      if n not in names {
        _fail(
          ("theme", "layout", "proof"),
          "names envelope `"
            + n
            + "`, which the layout does not list."
            + did-you-mean(n, names)
            + " Listed: "
            + if names.len() == 0 { "none" } else { names.join(", ") },
        )
      }
    }
  } else if type(layout.proof) != bool {
    _fail(
      ("theme", "layout", "proof"),
      "must be true, false or an array of envelope names, found "
        + repr(layout.proof),
    )
  }
  (layout: layout, hosted: hosted, issues: issues)
}

/// Returns issues (a required part set to `none`); naming errors panic.
#let validate-parts(parts, hosted, builtin, requirements) = {
  let required = (
    requirements.parts
      + requirements
        .roles
        .values()
        .filter(r => r.hosts.len() == 1)
        .map(r => r.hosts.first())
  )
  let issues = ()
  for (name, fn) in parts {
    if name not in builtin {
      if not name.contains("/") {
        _fail(
          ("theme", "parts", name),
          "is not a built-in part."
            + did-you-mean(name, builtin)
            + " Custom parts need a package prefix, e.g. `acme/rail` (un-prefixed names are reserved for built-ins).",
        )
      }
      if name not in hosted {
        _fail(
          ("theme", "parts", name),
          "is registered but hosted by no area; add it to an area's `parts`.",
        )
      }
    }
    if fn == none and name in required {
      issues.push(issue(
        "theme/part-" + name,
        "theme",
        "theme::parts::"
          + name
          + " carries legally required output and cannot be `none`; wrap it or replace its renderer instead",
        fix: "theme.custom.wrap(\"" + name + "\", (ctx, view, inner) => ..)",
        key: "part-none",
        args: (part: name),
      ))
      continue
    }
    if fn != none and type(fn) != function {
      _fail(
        ("theme", "parts", name),
        "must be a function (ctx, view) => content or none, found " + repr(fn),
      )
    }
  }
  issues
}

#let validate-tokens(t) = {
  let f = t.sizes.fine
  if f.em != 0 or f.abs < 6pt {
    return (
      issue(
        "lint/fine-size",
        "lint",
        "theme::tokens::sizes::fine ("
          + repr(f)
          + ") must be an absolute length of at least 6pt (DIN 5008 minimum for the return address and legal footer)",
        ref: "DIN 5008",
        fix: "theme.custom.sizes(fine: 7pt)",
        key: "fine-size",
        args: (size: repr(f)),
      ),
    )
  }
  ()
}

#let _is-pdf-image(c) = (
  type(c) == content
    and c.func() == image
    and type(c.source) == str
    and lower(c.source).ends-with(".pdf")
)

#let _colors-of(v, path) = {
  if type(v) == color { ((path, v),) } else if type(v) == dictionary {
    v
      .pairs()
      .map(((k, x)) => _colors-of(x, path + "::" + k))
      .flatten()
      .chunks(2)
  } else if type(v) == array {
    v
      .enumerate()
      .map(((i, x)) => _colors-of(x, path + "::" + str(i)))
      .flatten()
      .chunks(2)
  } else { () }
}

#let validate-assets(theme, env) = {
  let issues = ()
  let logo = theme.options.logo.image
  if (
    type(logo) == content
      and logo.func() == image
      and logo.at("alt", default: none) == none
  ) {
    issues.push(issue(
      "lint/logo-alt",
      "lint",
      "theme::options::logo::image needs alt text, e.g. image(\"logo.svg\", alt: \"ACME GmbH\") (checked always: a document cannot see --pdf-standard, and PDF/UA-1 requires it)",
      ref: "PDF/UA-1 (ISO 14289-1)",
      fix: "image(\"logo.svg\", alt: \"..\")",
      key: "logo-alt",
    ))
  }
  if env.at("e-invoice", default: none) != none {
    let colors = (
      _colors-of(theme.tokens.colors, "theme::tokens::colors")
        + _colors-of(theme.options, "theme::options")
    )
    for (n, r) in theme.layout.areas {
      if r != none {
        colors += _colors-of((fill: r.fill), "theme::layout::areas::" + n)
      }
    }
    for (path, c) in colors {
      if c.space() == cmyk {
        issues.push(issue(
          "lint/cmyk-" + path,
          "lint",
          path
            + " is a CMYK colour; Typst cannot embed a CMYK output profile, so PDF/A-3 (ZUGFeRD) rejects it. Use rgb() or oklch().",
          ref: "PDF/A-3 (ISO 19005-3)",
          key: "cmyk",
          args: (path: path),
        ))
      }
    }
    let st = theme.layout.stationery
    if type(st) == dictionary {
      for (k, c) in st {
        if _is-pdf-image(c) {
          issues.push(issue(
            "lint/pdf-image-" + k,
            "lint",
            "theme::layout::stationery::"
              + k
              + " embeds a PDF image; PDF/A and PDF/UA exports cannot embed PDF images (Typst limitation). Convert the letterhead to SVG",
            key: "pdf-image-stationery",
            args: (page: k),
          ))
        }
      }
    }
    if _is-pdf-image(logo) {
      issues.push(issue(
        "lint/pdf-image-logo",
        "lint",
        "theme::options::logo::image is a PDF image; PDF/A and PDF/UA exports cannot embed PDF images (Typst limitation). Use SVG or PNG",
        key: "pdf-image-logo",
      ))
    }
  }
  issues
}

/// Evaluates `checks.pairs` (name -> `t => (fg, bg)` or a literal pair; `none` =
/// dropped) against the resolved tokens. A malformed pair is misuse and panics at
/// every validation level, whether or not `min-contrast` is set.
/// -> array of (name, fg, bg)
#let declared-pairs(checks, tokens) = {
  let out = ()
  for (name, p) in checks.pairs {
    if p == none { continue }
    let path = ("theme", "checks", "pairs", name)
    let v = if type(p) == function { p(tokens) } else { p }
    if type(v) != array or v.len() != 2 or v.any(x => type(x) != color) {
      _fail(
        path,
        "must be a derivation `t => (foreground, background)` or a pair of colours, found "
          + repr(v)
          + if type(p) == function { " (returned by the derivation)" } else {
            ""
          },
      )
    }
    out.push((name, ..v))
  }
  out
}

/// Checked pairs (concept §3.7): body text and secondary text on the page, text on
/// every filled surface the theme knows (tint, primary, header fill, totals fill,
/// every area fill with its text colour), the title colour and discount colour,
/// plus the pairs a look or user declares in `checks.pairs`.
#let validate-contrast(theme) = {
  let min = theme.checks.min-contrast
  let declared = declared-pairs(theme.checks, theme.tokens)
  if min == none { return () }
  let c = theme.tokens.colors
  let o = theme.options
  let pairs = (
    ("colors::text", c.text, "colors::background", c.background),
    ("colors::text-muted", c.text-muted, "colors::background", c.background),
    ("colors::on-primary", c.on-primary, "colors::primary", c.primary),
    (
      "options::title::color",
      o.title.color,
      "colors::background",
      c.background,
    ),
    (
      "options::line-items::discount-color",
      o.line-items.discount-color,
      "colors::background",
      c.background,
    ),
  )
  if c.tint != none {
    pairs.push(("colors::text-muted", c.text-muted, "colors::tint", c.tint))
  }
  let hf = o.items-table.header-fill
  if hf != none {
    let hs = o.items-table.header-style.at("fill", default: none)
    let (hn, ht) = if type(hs) == color {
      ("options::items-table::header-style::fill", hs)
    } else {
      (
        "options::items-table::header-text",
        if o.items-table.header-text == auto { on-color(hf) } else {
          o.items-table.header-text
        },
      )
    }
    pairs.push((hn, ht, "options::items-table::header-fill", hf))
  }
  let tf = o.totals.fill
  if tf != none {
    pairs.push((
      "options::totals::color",
      if o.totals.color == auto { on-color(tf) } else { o.totals.color },
      "options::totals::fill",
      tf,
    ))
  }
  for (n, r) in theme.layout.areas {
    if r != none and type(r.fill) == color {
      let fg = r.text.at("fill", default: c.text)
      if type(fg) == color {
        pairs.push((
          "layout::areas::" + n + "::text::fill",
          fg,
          "layout::areas::" + n + "::fill",
          r.fill,
        ))
      }
    }
  }
  // (id, subject, fg, bg, names for the localised report text)
  let checked = pairs.map(((fname, fg, bname, bg)) => (
    fname + "-" + bname,
    fname + " on " + bname,
    fg,
    bg,
    (fg-name: fname, bg-name: bname),
  ))
  for (name, fg, bg) in declared {
    checked.push((
      "checks::pairs::" + name,
      "checks::pairs::"
        + name
        + " ("
        + fg.to-hex()
        + " on "
        + bg.to-hex()
        + ")",
      fg,
      bg,
      (fg-name: "checks::pairs::" + name, bg-name: none),
    ))
  }
  let issues = ()
  for (id, subject, fg, bg, names) in checked {
    let r = contrast(fg, bg)
    if r < min {
      issues.push(issue(
        "lint/contrast-" + id,
        "lint",
        "theme: "
          + subject
          + " has contrast "
          + str(calc.round(r, digits: 2))
          + ":1, below checks.min-contrast "
          + str(min)
          + ":1",
        ref: "WCAG 2.2 SC 1.4.3",
        key: "contrast",
        args: names
          + (
            fg: fg.to-hex(),
            bg: bg.to-hex(),
            ratio: calc.round(r, digits: 2),
            min: min,
          ),
      ))
    }
  }
  issues
}
