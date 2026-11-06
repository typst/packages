#import "../utils/patch.typ": did-you-mean, flatten-patches, is-wrap, merge
#import "schema.typ": (
  area-derivable, area-types, composite-parts, defaults-of, document-kinds,
  make-schema, part-options, supported-kinds, types-of,
)
#import "layout-ops.typ": apply-layout-patch, complete-layout
#import "resolve.typ": (
  check-types, resolve-area, resolve-options, resolve-tokens,
)
#import "validate.typ": (
  requirements-for, validate-assets, validate-contrast, validate-layout,
  validate-parts, validate-tokens,
)
#import "parts/frame.typ": frame-parts
#import "parts/body.typ": body-parts
#import "../validation/issue.typ": enforce, resolve-level

/// The master schema object of THIS package version. `invoice()` injects it;
/// theme factories never import it (forward compatibility, as with locales).
#let schema = make-schema(frame-parts + body-parts)

#let theme-tag = "__invoice-pro-theme__"
#let groups = ("tokens", "options", "parts", "layout", "checks")
/// Option groups read by frame parts (document-level, rejected inside `themed`).
#let frame-option-groups = ("logo", "title", "page-number", "continuation")

/// Parameter names of the 0.5 (and 0.4) `themes.DIN-5008(..)` call: named-argument panics
/// point to the migration table instead of the generic hint.
#let v04-args = (
  "form",
  "font",
  "hole-mark",
  "folding-marks",
  "color-row-odd",
  "color-row-even",
  "margin",
  "footer",
)

/// Unresolved theme ("spec") from the schema and a layout.
#let _spec(base, layout) = (
  layout: complete-layout(layout),
  tokens: defaults-of(base.tokens),
  options: defaults-of(base.options),
  parts: base.parts,
  checks: defaults-of(base.checks),
  replaced: (), // internal: parts whose built-in renderer was replaced (`part`, not `wrap`)
)

#let apply-patch(spec, patch, base, scope: "theme") = {
  let spec = spec
  for (g, v) in patch {
    if g not in groups {
      panic(
        scope
          + ": unknown patch group `"
          + g
          + "`."
          + did-you-mean(g, groups)
          + " Allowed groups: "
          + groups.join(", "),
      )
    }
    if scope == "themed" {
      if g == "layout" {
        panic(
          "themed: layout patches are document-level (the page master cannot change mid-document); pass them to `invoice(theme: ..)`",
        )
      }
      let frame-hit = if g == "parts" {
        v.keys().filter(k => k in frame-parts)
      } else if g == "options" {
        v.keys().filter(k => k in frame-option-groups)
      } else { () }
      if frame-hit.len() > 0 {
        panic(
          "themed: `"
            + g
            + "::"
            + frame-hit.first()
            + "` belongs to the page frame, which is drawn once per document; pass it to `invoice(theme: ..)`",
        )
      }
    }
    if g == "parts" and type(v) == dictionary {
      // `part` replaces the built-in (a replacement decides which options it honours);
      // `wrap` keeps whatever renderer is inside; the built-in itself counts as built-in
      for (k, fn) in v {
        if is-wrap(fn) { continue }
        let others = spec.replaced.filter(x => x != k)
        spec.replaced = if (
          fn != none and fn != base.parts.at(k, default: none)
        ) { others + (k,) } else { others }
      }
    }
    if g == "layout" {
      spec.layout = apply-layout-patch(spec.layout, v)
    } else {
      spec.insert(g, merge(spec.at(g), v, ("theme", g), base.rules, key: g))
    }
  }
  spec
}

#let validate-env(env) = {
  let kind = env.at("kind", default: none)
  if kind not in document-kinds {
    panic(
      "theme::env::kind `"
        + str(kind)
        + "` is not a document kind."
        + did-you-mean(str(kind), document-kinds.keys())
        + " Known kinds: "
        + document-kinds.keys().join(", "),
    )
  }
  if kind not in supported-kinds {
    panic(
      "theme::env::kind `"
        + kind
        + "` is reserved but not supported in 0.6.0 (supported: "
        + supported-kinds.join(", ")
        + ")",
    )
  }
}

/// Option groups whose value differs from the schema default but that no active
/// BUILT-IN renderer reads (schema: part-options). Informational, never an issue:
/// a replacement renderer may honour them. `hosted: none` skips the hosting test.
#let unread-options(spec, base, hosted) = {
  let defaults = defaults-of(base.options)
  let active(p) = {
    let fn = spec.parts.at(p, default: none)
    let parent = composite-parts.at(p, default: none)
    (
      fn != none
        and p not in spec.replaced
        and (hosted == none or p in hosted or p not in frame-parts)
        and (parent == none or active(parent))
    )
  }
  part-options
    .pairs()
    .filter(((g, readers)) => (
      spec.options.at(g) != defaults.at(g) and not readers.any(active)
    ))
    .map(((g, _)) => g)
}

/// Resolves and validates a spec into the theme value stored in ctx.
/// `light: true` (scopes) skips the document-level layout and asset checks.
/// Misuse panics here; compliance and lint findings are collected in
/// `theme.issues` and the caller applies the validation level.
#let finalize(spec, base, env, name, light: false) = {
  let ttypes = types-of(base.tokens)
  let otypes = types-of(base.options)
  // literal leaves first, so a wrong literal is reported before a derivation uses it
  check-types(spec.tokens, ttypes, ("theme", "tokens"), skip-fns: true)
  check-types(spec.options, otypes, ("theme", "options"), skip-fns: true)
  check-types(
    spec.checks,
    types-of(base.checks),
    ("theme", "checks"),
    derivable: false,
  )
  let tokens = resolve-tokens(spec.tokens, ttypes, defaults-of(base.tokens))
  check-types(tokens, ttypes, ("theme", "tokens"))
  let issues = validate-tokens(tokens)
  let options = resolve-options(spec.options, otypes, tokens)
  check-types(options, otypes, ("theme", "options"))
  let layout = spec.layout
  let requirements = requirements-for(env)
  let hosted = ()
  if not light {
    for (n, r) in layout.areas {
      if r != none {
        check-types(
          r,
          area-types,
          ("theme", "layout", "areas", n),
          skip-fns: true,
          derivable: false,
        )
      }
    }
    layout.areas = layout
      .areas
      .pairs()
      .map(((n, r)) => (n, resolve-area(r, tokens, area-derivable)))
      .to-dict()
    if (
      type(layout.marks) == dictionary and type(layout.marks.stroke) == function
    ) {
      layout.marks.stroke = (layout.marks.stroke)(tokens)
    }
    let v = validate-layout(
      layout,
      spec.parts,
      requirements,
      body-parts: body-parts.keys(),
    )
    layout = v.layout
    hosted = v.hosted
    issues += v.issues
    issues += validate-parts(
      spec.parts,
      hosted,
      base.parts.keys(),
      requirements,
    )
  } else {
    issues += validate-parts(
      spec.parts.pairs().filter(((k, _)) => k not in frame-parts).to-dict(),
      spec.parts.keys(),
      base.parts.keys(),
      requirements,
    )
  }
  let theme = (
    (theme-tag): base.version,
    // option groups changed from their default that no active built-in renderer reads
    // (every reader replaced, set to none or, for frame parts, hosted by no area)
    unread-options: unread-options(spec, base, if light { none } else {
      hosted
    }),
    meta: (name: name, schema: base.version),
    env: env,
    layout: layout,
    parts: spec.parts,
    tokens: tokens,
    options: options,
    checks: spec.checks,
    requirements: requirements,
    issues: (), // compliance and lint findings (validation/issue.typ), filled below
    spec: spec, // internal: `themed` re-resolves from here (derived tokens re-derive)
    base: base, // internal: the injected schema object
  )
  if not light { issues += validate-assets(theme, env) }
  issues += validate-contrast(theme)
  theme.issues = issues
  theme
}

/// The page master for `env`: a layout dict as is, a resolver `env => layout` called.
#let _pick-layout(layout, env, name) = {
  if type(layout) != function { return layout } // complete-layout type-checks it
  let picked = layout(env)
  if type(picked) != dictionary {
    panic(
      "theme `"
        + name
        + "`: the layout resolver `env => ..` must return a layout dictionary (such as `theme.layout.din-5008-b`), found "
        + repr(picked),
    )
  }
  picked
}

/// Builds a LAZY THEME from a default layout and look patches. Internal in
/// 0.6.0 (the presets use it); users and packages write `theme.classic.with(..)`.
///
/// -> function
#let build-theme(
  /// Name shown in errors.
  /// -> str
  name: "custom",
  /// Default page master: a layout dict, or a resolver `env => layout` that picks
  /// one for the document environment (e.g. by the sender's `env.region`). Used
  /// when the document passes no `layout:`. Required.
  /// -> dictionary | function
  layout: none,
  /// Look patches (dicts or `theme.custom` results), applied before user patches.
  /// -> dictionary | array
  ..look,
) = {
  assert(
    type(layout) in (dictionary, function),
    message: "variable `theme::build-theme::layout`("
      + repr(layout)
      + ") must be of dictionary | function",
  )
  if look.named().len() > 0 {
    panic(
      "theme::build-theme: unexpected named argument(s) `"
        + look.named().keys().join("`, `")
        + "`",
    )
  }
  let look = flatten-patches(look.pos(), "theme `" + name + "` (look)")
  let default-layout = layout
  let self(..args, layout: auto, base: none, env: none) = {
    if args.named().len() > 0 {
      let ks = args.named().keys()
      let v04 = ks.filter(k => k in v04-args)
      panic(
        "theme `"
          + name
          + "`: unexpected named argument(s) `"
          + ks.join("`, `")
          + "`."
          + did-you-mean(ks.first(), ("layout",))
          + " A theme takes patches (e.g. `.with(theme.custom.colors(primary: teal))`) and `layout:`"
          + " (e.g. `layout: theme.layout.din-5008-b`)."
          + if v04.len() > 0 {
            (
              " `"
                + v04.first()
                + "` is a 0.5 `themes.DIN-5008` parameter; see the migration table in the theme docs."
            )
          } else { "" },
      )
    }
    // Idempotent called form: without an injected base, calling == `.with`.
    if base == none { return self.with(..args, layout: layout) }
    validate-env(env)
    let spec = _spec(base, _pick-layout(
      if layout == auto { default-layout } else { layout },
      env,
      name,
    ))
    for p in look + flatten-patches(args.pos(), "theme `" + name + "`") {
      spec = apply-patch(spec, p, base)
    }
    finalize(spec, base, env, name)
  }
  self
}

/// Applies patches to a resolved theme (for `themed`).
#let scope-theme(theme, patches, scope: "themed") = {
  let spec = theme.spec
  for p in flatten-patches(patches, scope) {
    spec = apply-patch(spec, p, theme.base, scope: scope)
  }
  let out = finalize(spec, theme.base, theme.env, theme.meta.name, light: true)
  out.layout = theme.layout // the frame is document-level; keep the validated layout
  out
}

/// Evaluates a lazy theme outside an invoice (unit tests, third-party CI).
/// The result carries `issues` (compliance and lint findings of the theme).
/// -> dictionary
#let resolve(
  /// A lazy theme such as `theme.classic.with(..)`.
  /// -> function
  theme,
  /// The document environment to resolve for.
  /// -> dictionary
  env: (kind: "invoice", lang: "de", region: "de", e-invoice: none),
  /// What happens with the theme's issues: `"strict"` panics (the default, so a
  /// package CI fails on a non-compliant theme), `"draft"` and `none` return
  /// them in `issues`. `--input invoice-pro-validation=..` overrides it.
  /// -> none | str
  validation: "strict",
) = {
  assert(
    type(theme) == function,
    message: "variable `theme::resolve::theme` must be of function",
  )
  let out = theme(base: schema, env: env)
  let _ = enforce(out.issues, resolve-level(validation))
  out
}
