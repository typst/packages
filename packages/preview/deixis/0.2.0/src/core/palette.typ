#import "state.typ": deixis-system
#import "targets.typ": _deixis-setup-guard

// Discrete annotation accents. Published sets keep their canonical order;
// the house set starts with the documentation's original three accents.
#let _deixis-palettes = (
  okabe-ito: "E69F00 56B4E9 009E73 0072B2 D55E00 CC79A7".split().map(rgb),
  tol-bright: "4477AA EE6677 228833 CCBB44 66CCEE AA3377".split().map(rgb),
  tol-muted: "CC6677 332288 DDCC77 117733 88CCEE 882255 44AA99 999933 AA4499".split().map(rgb),
  tableau: "1F77B4 FF7F0E 2CA02C D62728 9467BD 8C564B E377C2 7F7F7F BCBD22 17BECF".split().map(rgb),
  deixis: "3B6D9A 387C69 9A663F 7D5A87 397D86 A05268 73783E".split().map(rgb),
)

// Palettes are opt-in configuration, not numbering streams. Each explicit
// setting starts an independent cycle; inherited scopes share its saved token.
#let _deixis-palette-policy(sys) = {
  for level in sys.stack.rev() {
    if "palette" in level { return level.palette }
  }
  sys.at("palette", default: none)
}

#let _deixis-check-palette(colors) = {
  if type(colors) == str {
    assert(colors in _deixis-palettes,
      message: "deixis: palette must be none or an array of colors, or a known palette name; unknown name "
        + repr(colors) + ". Valid names: " + _deixis-palettes.keys().join(", ") + ".")
    return
  }
  assert(colors == none or (type(colors) == array and colors.len() > 0
    and colors.all(c => type(c) == color)),
    message: "deixis: palette must be none or an array of colors; the array cannot be empty.")
}

#let _deixis-palette-setting(sys, colors) = {
  _deixis-check-palette(colors)
  if type(colors) == str { colors = _deixis-palettes.at(colors) }
  let policy = none
  if colors != none {
    let token = sys.at("palette-uid", default: 0) + 1
    sys.insert("palette-uid", token)
    policy = (token: str(token), colors: colors)
  }
  if sys.stack.len() > 0 { sys.stack.last().insert("palette", policy) }
  else { sys.insert("palette", policy) }
  sys
}

// Pure registry transform. The transient accent is visible only while that
// declaration resolves its defaults, and is removed before committing state.
#let _deixis-palette-next(sys) = {
  let policy = _deixis-palette-policy(sys)
  let accent = none
  if policy != none {
    let counts = sys.at("palette-counts", default: (:))
    let ordinal = counts.at(policy.token, default: 0)
    accent = policy.colors.at(calc.rem(ordinal, policy.colors.len()))
    counts.insert(policy.token, ordinal + 1)
    sys.insert("palette-counts", counts)
  }
  sys + (annotation-accent: accent)
}

#let _deixis-accent-context(sys, accent) = sys + (annotation-accent: accent)
#let _deixis-palette-finish(sys) = {
  let _ = sys.remove("annotation-accent", default: none)
  sys
}

// Anonymous decorations/bodies do not enter the semantic note registry or
// consume a numbering counter. Record their accent at their own native origin,
// once in live declaration order. The body helper can supply an owner's accent
// even when the current main-flow palette has since been disabled.
#let _deixis-palette-anonymous(sys, paint) = {
  // Native locations hash this payload. Keep only declaration settings: the
  // growing registry changes between layout passes and would move `here()`.
  let settings = sys
  let _ = settings.remove("registry", default: none)
  // Only setup paints this output; without it, report instead of dropping the passage.
  [#_deixis-setup-guard()#metadata((sys: settings, paint: paint))<deixis-palette-output>]
}

// Anonymous decoration within a note body extends that annotation's accent.
// The live body helper supplies it without allocating from the outer stream;
// named originals within bodies still create their own semantic annotations.
#let _deixis-live-palette-output(it, accent: auto) = {
  let paint = it.value.paint
  if accent != auto { return paint(_deixis-accent-context(it.value.sys, accent)) }
  let declaration = it.value.sys
  let policy = _deixis-palette-policy(declaration)
  if policy == none { return paint(_deixis-accent-context(declaration, none)) }
  let allocated = _deixis-palette-next(declaration)
  deixis-system.update(s => {
    // Only commit the ordinal. Paint uses the same declaration's resolved
    // color directly, without a later state lookup or location-index scan.
    let frame = s + (palette: policy, stack: ())
    let next = _deixis-palette-next(frame)
    s.insert("palette-counts", next.at("palette-counts", default: (:)))
    s
  })
  paint(_deixis-accent-context(declaration, allocated.annotation-accent))
}
