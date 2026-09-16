#import "sym.typ": mac-key, biolinum-key, svg-key
#import "cap.typ": keycap, svg-keycap, style-text
#import "themes.typ": themes

/// Generate examples for the given keyboard rendering function.
/// -> content
#let gen-examples(
  /// The keyboard rendering function.
  /// -> function
  kbd,
) = [
  #kbd("Ctrl", "A") #h(1em) #kbd("Alt", "P", compact: true)

  #kbd("Home") #kbd("End") #kbd("Ins") #kbd("Del")
]

/// Join rendered keys with a delimiter between them.
/// -> content
#let join-keys(keys, theme, delim) = {
  let items = keys.map(k => [#theme(k)])
  if delim == biolinum-key.delim_plus or delim == biolinum-key.delim_minus {
    items.join(theme(delim))
  } else {
    context {
      let sep = box(
        height: measure(theme("A")).height,
        inset: 2pt,
        align(horizon, delim),
      )
      items.join(sep)
    }
  }
}

// Backward-compatible theme aliases (pre-0.3 names).
#let theme-func-standard = themes.standard
#let theme-func-stardard = themes.standard
#let theme-func-deep-blue = themes.deep-blue
#let theme-func-type-writer = themes.type-writer
#let theme-func-biolinum = themes.biolinum

/// Config function to generate keyboard rendering helper function.
/// -> function
#let config(
  /// The theme function to use. Any preset from `themes`, optionally extended
  /// with `.with(...)`, or a custom `sym => content` function.
  /// -> function
  theme: themes.standard,
  /// Whether to render keys in a compact format.
  /// -> bool
  compact: false,
  /// The delimiter to use between keys.
  /// -> str
  delim: "+",
) = (
  (..keys, compact: compact, delim: delim) => {
    let key-list = keys.pos()
    if compact {
      theme(key-list.join(delim))
    } else {
      join-keys(key-list, theme, delim)
    }
  }
)
