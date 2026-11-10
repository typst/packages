#import "sym.typ": mac-key, biolinum-key, svg-key, svg-icon, key-aliases, mac-aliases
#import "cap.typ": keycap, svg-keycap, style-text, _delim-probe, _delim-ack, _delim-mark
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

/// Resolve a theme given by name or by renderer function.
/// -> function
#let resolve-theme(
  /// A key from `themes` (e.g. `"flowbite"`) or a `sym => content` function.
  /// -> str | function
  theme,
) = {
  if type(theme) == str {
    assert(
      theme in themes,
      message: "unknown keyle theme " + repr(theme) + "; available: " + themes.keys().join(", "),
    )
    themes.at(theme)
  } else {
    theme
  }
}

/// Split shortcut strings on `+`: `"Ctrl+Shift+P"` -> `("Ctrl", "Shift", "P")`.
/// A string without `+`, or one that would produce an empty part (e.g. `"+"`
/// itself), is kept as a single key -- pass a literal plus as its own
/// argument: `kbd("Ctrl", "+")`.
/// -> array
#let expand-shortcuts(keys) = {
  keys
    .map(k => {
      if type(k) == str and k.contains("+") {
        let parts = k.split("+").map(p => p.trim())
        if parts.len() >= 2 and parts.all(p => p.len() > 0) { parts } else { (k,) }
      } else {
        (k,)
      }
    })
    .flatten()
}

/// Map a key name through an alias table, case-insensitively.
/// Non-string keys (e.g. `svg-key` glyphs) pass through untouched.
/// -> any
#let normalize-key(key, aliases) = {
  if type(key) != str { return key }
  aliases.at(lower(key.trim()), default: key)
}

/// Join rendered keys with a delimiter between them.
///
/// The delimiter is rendered through the theme itself: themes that answer
/// the delimiter handshake (`keycap`/`svg-keycap`/`type-writer` based)
/// render it as if it were a key -- same box, baseline and centering -- but
/// with an invisible shell, so it aligns with the keys by construction.
/// Themes that don't know the handshake -- plain custom functions -- fall
/// back to measurement: the cap's descent below the text baseline is
/// recovered by measuring a line that pairs a cap with a zero-width probe
/// of known height.
/// -> content
#let join-keys(keys, theme, delim) = {
  let items = keys.map(k => [#theme(k)])
  if delim == biolinum-key.delim_plus or delim == biolinum-key.delim_minus {
    items.join(theme(delim))
  } else if theme(_delim-probe) == _delim-ack {
    items.join(theme(_delim-mark(delim)))
  } else {
    context {
      let cap = theme("A")
      let height = measure(cap).height
      // Line extent = (height - descent) above the baseline + 2*height
      // from the probe box, so the cap's descent falls out. Text
      // delimiters get an extra optical raise.
      let descent = measure(cap + box(width: 0pt, height: 2 * height)).height - 2 * height
      let sep-baseline = descent + if type(delim) == str { -0.25em } else { 0em }
      let sep = box(
        height: height,
        baseline: sep-baseline,
        inset: (x: 2pt),
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

/// Config function to generate a keyboard rendering function.
///
/// The generated function accepts any number of keys plus per-call
/// `compact` and `delim` overrides:
/// `kbd("Ctrl", "Shift", "P")`, `kbd("Ctrl+Shift+P")`, `kbd("cmd", "K")`.
/// -> function
#let config(
  /// The theme to use: a name from `themes` (e.g. `"flowbite"`), any preset
  /// optionally extended with `.with(...)`, or a custom `sym => content`
  /// function.
  /// -> str | function
  theme: themes.standard,
  /// Whether to render keys in a compact format.
  /// -> bool
  compact: false,
  /// The delimiter to use between keys.
  /// -> str | content
  delim: "+",
  /// Key-name normalization layout. `auto` maps only unambiguous aliases
  /// (`"cmd"` -> ⌘, `"up"` -> ↑, ...); `"mac"` additionally maps
  /// `"ctrl"`/`"shift"`/`"enter"`/... to their Apple glyphs.
  /// -> auto | str
  layout: auto,
  /// Whether to map key-name aliases at all. Set to `false` to render every
  /// key name exactly as written.
  /// -> bool
  normalize: true,
  /// Whether to split shortcut strings such as `"Ctrl+Shift+P"` into
  /// individual keys.
  /// -> bool
  parse: true,
  /// Output mode under HTML export (`typst compile --features html`):
  /// `"frame"` embeds the exact themed rendering as inline SVG, `"kbd"`
  /// emits semantic `<kbd>` elements styled by the browser, `none` outputs
  /// the raw themed content unchanged. PDF/PNG/SVG export is unaffected.
  /// -> str | none
  html: "frame",
) = {
  let theme = resolve-theme(theme)
  let aliases = if layout == "mac" {
    mac-aliases
  } else {
    assert(layout == auto, message: "unknown keyle layout " + repr(layout) + "; expected auto or \"mac\"")
    key-aliases
  }
  (..keys, compact: compact, delim: delim) => {
    let key-list = keys.pos()
    if parse { key-list = expand-shortcuts(key-list) }
    if normalize { key-list = key-list.map(k => normalize-key(k, aliases)) }
    let render() = if compact {
      theme(key-list.join(delim))
    } else {
      join-keys(key-list, theme, delim)
    }
    context {
      if html != none and target() == "html" {
        if html == "kbd" {
          key-list.map(k => std.html.elem("kbd", k)).join(delim)
        } else {
          // Wrapped in `box` so the frame stays inline with surrounding text.
          box(std.html.frame(render()))
        }
      } else {
        render()
      }
    }
  }
}

/// Ready-to-use keyboard renderer with default settings, so that
/// `#import "@preview/keyle:0.4.0": kbd` works out of the box.
/// Use `config(...)` for a customized renderer.
/// -> function
#let kbd = config()
