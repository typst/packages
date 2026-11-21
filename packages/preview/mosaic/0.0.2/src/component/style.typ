// Shared semantic role resolution, structural defaults, and style resolution
// for components.
#import "../shared.typ": fail, validate-dictionary
#import "../deck-state.typ": deck-settings, inverted-slide-colors
#import "../palettes.typ": light

// The role names a component's `role` argument accepts. Every name but
// `neutral` is a key in the deck palette, so a role is one color the deck
// already states rather than a parallel record of its own. `neutral` is the
// deck's own surface, which needs no palette entry.
#let role-names = ("neutral", "accent", "warning", "error")

// Geometry every component shares, kept apart from the palette so a theme
// states its colors without restating its shapes. Before the split, a themed
// component module had to repeat the stroke thickness, radius, and inset just to
// change a fill, and the two copies drifted.
#let component-tokens = (
  stroke-thickness: 0.8pt,
  radius: 6pt,
  inset: 0.65em,
  // The rail a callout hangs its accent on, replacing the full border.
  callout-rail: 4pt,
  divider-gap: 0.45em,
  badge-radius: 3pt,
  badge-inset: (x: 0.7em, y: 0.3em),
  progress-size: 1em,
  // The drawn-rule weight shared by progress bars, dividers, and the section
  // baseline rule, matched to the heft of the title layout's rules so every
  // horizontal gesture in a deck reads at one weight.
  rule-thickness: 3pt,
  // A conic gradient starts due east; a progress ring reads from the top.
  progress-start-angle: -90deg,
  quote-attribution-gap: 0.45em,
  quote-attribution-size: 0.72em,
  // How far the quotation's wash is lightened toward the canvas it sits on.
  quote-tint: 94%,
  // How much of a role's color goes into its panel fill, the rest being the
  // deck canvas. Mixing toward the canvas rather than toward white is what
  // lets a dark theme reuse the same rule: the tint follows the deck in both
  // directions, so no theme needs a hand-tuned table of panel fills.
  role-tint: 15%,
)

// The deck's own colors, for component defaults that should follow the theme
// rather than a fixed value. Components call this inside `context`; outside a
// deck they render in the library's light palette rather than an ad-hoc gray.
// On an inverted slide the runtime publishes the swapped palette, so a
// component drawn there paints against the ground it actually sits on.
#let deck-colors() = {
  let inverted = inverted-slide-colors.get()
  if inverted != none {
    return inverted
  }
  let settings = deck-settings()
  if settings == none { light } else { settings.colors }
}

// Resolves a role name to the three paints a component draws with. All three
// come from the deck palette: the accent is the named color itself, the text is
// the deck's text color, and the fill is the accent tinted into the canvas.
#let role-colors(name, contextual: false) = {
  if type(name) != str or name not in role-names {
    fail(
      "unknown semantic role " + repr(name) + "; expected "
        + role-names.map(repr).join(", "),
    )
  }
  let colors = if contextual { deck-colors() } else { light }
  if name == "neutral" {
    return (fill: colors.surface, accent: colors.line, text: colors.text)
  }
  let accent = colors.at(name)
  (
    // Mixed in oklab, which keeps a small amount of a saturated color from
    // reading as muddy, then converted back to sRGB so the resolved fill is an
    // ordinary hex color in the exported PDF and SVG rather than an `oklab()`
    // literal.
    fill: rgb(color.mix(
      (accent, component-tokens.role-tint),
      (colors.canvas, 100% - component-tokens.role-tint),
    )),
    accent: accent,
    text: colors.text,
  )
}

// Resolves a component's paint and geometry from its role plus the flat
// overrides its caller was given. `auto` on any argument means "take it from
// the role", which is resolved here and never stored, so no sentinel escapes
// this call. `defaults` is the calling component's own baseline: it overrides
// the role-derived values and is in turn overridden by anything the user
// passed explicitly.
#let resolve-style(
  role: "neutral",
  fill: auto,
  accent: auto,
  stroke: auto,
  radius: auto,
  inset: auto,
  align: auto,
  text: (:),
  defaults: (:),
  contextual: false,
) = {
  _ = validate-dictionary(text, "component text")
  let colors = role-colors(role, contextual: contextual)
  let base = (
    fill: colors.fill,
    accent: colors.accent,
    stroke: auto,
    radius: component-tokens.radius,
    inset: component-tokens.inset,
    align: left,
  ) + defaults
  let accent = if accent == auto { base.accent } else { accent }
  let stroke = if stroke != auto {
    stroke
  } else if base.stroke == auto {
    component-tokens.stroke-thickness + accent
  } else {
    base.stroke
  }
  (
    fill: if fill == auto { base.fill } else { fill },
    accent: accent,
    stroke: stroke,
    radius: if radius == auto { base.radius } else { radius },
    inset: if inset == auto { base.inset } else { inset },
    align: if align == auto { base.align } else { align },
    // Merged rather than replaced: setting a size should not silently drop the
    // role's text color.
    text: (fill: colors.text) + text,
  )
}

#let styled-body(style, body) = {
  let text-style = style.text
  align(style.align, text(..text-style, body))
}
