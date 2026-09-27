// src/config.typ
// Configuration state and merge engine for Basho DI architecture

#import "kinsoku/kinsoku.typ": default-resolver
#import "components/tcy.typ": default-tcy
#import "kinsoku/spacing.typ": default-spacing

// ---------------------------------------------------------------------------
// Default rendering module factory — self-contained
// ---------------------------------------------------------------------------

/// Default rendering module factory.
/// Bundles character normalization, dash scaling, and custom node renderers.
///
/// - dash-scale (length): Font size for horizontal-bar character. Default: 1.25em.
/// - node-renderers (dictionary): Custom token-type renderers. Default: (:).
/// -> dictionary: A rendering module dict with `dash-scale`, `node-renderers`, and `transform`.
#let default-rendering-params(
  dash-scale: 1.25em,
  node-renderers: (:),
) = {
  (
    dash-scale: dash-scale,
    node-renderers: node-renderers,
    transform: (tokens, config) => {
      tokens.map(t => {
        if t.type == "char" and (t.text == "—" or t.text == "─") {
          t.text = "―"
        }
        t
      })
    },
  )
}

// ---------------------------------------------------------------------------
// Default sizing factory
// ---------------------------------------------------------------------------

/// Sizing parameters factory.
///
/// - char-box (length): Width/height of the character box. Default: 1em.
/// - ruby-size (length): Font size for ruby text. Default: 0.5em.
/// - ruby-offset (length): Horizontal offset for ruby text from the left edge. Default: 1em.
/// - heading-scales (array): Font scale factors for h1, h2, h3. Default: (1.5, 1.3, 1.15).
/// -> dictionary: A sizing dict.
#let default-sizing-params(
  char-box: 1em,
  ruby-size: 0.5em,
  ruby-offset: 1em,
  heading-scales: (1.5, 1.3, 1.15),
) = {
  (
    char-box: char-box,
    ruby-size: ruby-size,
    ruby-offset: ruby-offset,
    heading-scales: heading-scales,
  )
}

// ---------------------------------------------------------------------------
// Default categories factory
// ---------------------------------------------------------------------------

/// Categories parameters factory.
/// Provides the TCY classification function used by the default TCY filter.
///
/// - classify (function): (text, config) => "horizontal" | "rotated" | "char".
///   Default: 1-2 digit numbers → "horizontal", rest → "rotated".
/// -> dictionary: A categories dict.
#let default-categories(
  classify: (text, config) => {
    if text.match(regex("^[0-9]{1,2}$")) != none { return "horizontal" }
    return "rotated"
  },
) = {
  (classify: classify)
}

// ---------------------------------------------------------------------------
// Default layout factory
// ---------------------------------------------------------------------------

/// Layout parameters factory.
///
/// - columns (int): Number of horizontal rows (段組み). Default: 1.
/// - gap (length): Gap between columns within a row. Default: 1em.
/// - column-gap (length): Gap between rows (vertical). Default: 2em.
/// - paragraph-indent (length): First-line indent for each paragraph (字下げ). Default: 1em.
/// - paragraph-spacing (length): Extra spacing inserted between paragraphs. Default: 0em.
/// - hooks (array): Array of (cols, font, gap, config) => content; last wins. Default: ().
/// -> dictionary: A layout config dict.
#let default-layout-params(
  columns: 1,
  gap: 1em,
  column-gap: 2em,
  paragraph-indent: 1em,
  paragraph-spacing: 0em,
  hooks: (),
) = {
  (
    columns: columns,
    gap: gap,
    column-gap: column-gap,
    paragraph-indent: paragraph-indent,
    paragraph-spacing: paragraph-spacing,
    hooks: hooks,
  )
}

#import "components/turn.typ": default-turn
#import "components/vblock.typ": default-vblock
#import "components/hblock.typ": default-hblock
#import "components/list.typ": (
  default-bullet-list-params, default-numbered-list-params,
)


// ---------------------------------------------------------------------------
// Default options
// ---------------------------------------------------------------------------

/// Default options dictionary for Basho.
#let default-opts = (
  font: none,
  features: ("vert", "vrt2"),
  sizing: default-sizing-params(),
  categories: default-categories(),
  layout: default-layout-params(),
  kinsoku: default-resolver(),
  tcy: (default-tcy(),),
  rendering: (
    default-rendering-params(),
    default-spacing(),
    default-turn,
    default-vblock,
    default-hblock,
  ),
  list: (
    bullet: default-bullet-list-params(),
    numbered: default-numbered-list-params(),
  ),
)

// ---------------------------------------------------------------------------
// Merge engine
// ---------------------------------------------------------------------------

/// Recursively merges a user configuration dictionary into a base configuration.
/// Ensures nested dictionaries are merged rather than overwritten completely.
/// Arrays (like kinsoku, tcy, rendering) are replaced wholesale — this is
/// intentional so users can swap out entire module arrays.
///
/// - base (dictionary): The base configuration (e.g., default-opts).
/// - user (dictionary): The user's configuration overrides.
/// -> dictionary: The merged configuration.
#let merge-config(base, user) = {
  let result = base
  for (key, val) in user {
    if (
      key in result
        and type(result.at(key)) == dictionary
        and type(val) == dictionary
    ) {
      result.insert(key, merge-config(result.at(key), val))
    } else {
      result.insert(key, val)
    }
  }
  result
}
