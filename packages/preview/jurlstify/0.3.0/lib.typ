// jurlstify — URL typesetting with line-break opportunities.
// Ported from Donald Arseneau's LaTeX `url` package. MIT-licensed.
//
// Two independent axes control the output:
//   • where a line may break  — `break-chars` / `big-break-chars` /
//     `no-break-chars`, `break-at-literal-hyphens`, `extra-break-every`.
//   • whether a visible "-" is shown at a break — `show-hyphens-after-delimiters`
//     for the natural breaks, `show-hyphens-at-extra-breaks` for the extra ones.
// Every option defaults to the copy-safe behaviour of the url package: break
// only at the delimiter characters and never show a hyphen.

// The internal break characters are defined locally inside `jurlstify` so a
// wildcard `import` of this module never exposes them.

// Default normal break characters, identical to the url package's \UrlBreaks.
#let break-chars-default = (
  ".", "@", "\\", "/", "!", "_", "|", ";", ">", "]",
  ")", ",", "?", "&", "'", "+", "=", "#",
)

// Default high-priority break characters (the url package's \UrlBigBreaks).
#let big-break-chars-default = (":",)

// Default characters that suppress a break landing right before them
// (the url package's \UrlNoBreaks, the \mathopen class).
#let no-break-chars-default = ("(", "[", "{", "<")

/// = `jurlstify`
/// Render a URL string as inline content, with line-break opportunities at
/// positions compatible with LaTeX's `url` package. Automatic hyphenation and
/// ligatures are disabled inside the URL, matching that package's behaviour.
///
/// With no options set, only the delimiter breaks are active and no hyphen is
/// shown — the copy-safe default. Opt into extra breaks and visible hyphens
/// with the options below.
///
/// url <- str <required>
///   The URL string to render.
///
/// break-chars <- array
///   Characters after which a normal break may occur. Defaults to
///   `. @ \ / ! _ | ; > ] ) , ? & ' + = #`.
///
/// big-break-chars <- array
///   Higher-priority break characters. Defaults to `(":",)`.
///
/// no-break-chars <- array
///   Characters that drop a break landing immediately before them. Defaults to
///   `("(", "[", "{", "<")`.
///
/// break-at-literal-hyphens <- bool
///   Allow a break after a literal `-` already present in the URL. Defaults to
///   `false`, so `my-domain.com` never breaks mid-word.
///
/// extra-break-every <- none | int
///   Insert one extra break opportunity every N consecutive non-break
///   characters, for long unbroken runs. Defaults to `none` (disabled).
///
/// show-hyphens-after-delimiters <- bool
///   Show a `-` at a delimiter break when the line breaks there. Defaults to
///   `false`. Also places a `-` after punctuation, e.g. a line ending in `com/-`.
///
/// show-hyphens-at-extra-breaks <- bool
///   Show a `-` at an `extra-break-every` break when the line breaks there.
///   Defaults to `false`.
///
/// show-spaces-as <- str | none
///   How to render a literal space in the URL: `"nbsp"` (non-breaking space),
///   `"normal"` (ordinary breakable space), or `none` (remove it). Defaults to
///   `"nbsp"`.
///
/// stretch <- bool
///   Make break points stretchable so URL-internal lines reach the right margin
///   in justified paragraphs, at the cost of small gaps at breaks. Defaults to
///   `false`.
///
/// font <- auto | str | array
///   URL font; `auto` inherits the body font. Defaults to `auto`.
///
/// size <- auto | length
///   Font size; `auto` inherits from context. Defaults to `auto`.
///
/// fill <- auto | color
///   Text colour; `auto` inherits from context. Defaults to `auto`.
///
#let jurlstify(
  url,
  break-chars: break-chars-default,
  big-break-chars: big-break-chars-default,
  no-break-chars: no-break-chars-default,
  break-at-literal-hyphens: false,
  extra-break-every: none,
  show-hyphens-after-delimiters: false,
  show-hyphens-at-extra-breaks: false,
  show-spaces-as: "nbsp",
  stretch: false,
  font: auto,
  size: auto,
  fill: auto,
) = {
  assert(
    type(url) == str,
    message: "jurlstify: expected a string, got " + str(type(url)),
  )
  assert(
    show-spaces-as in ("nbsp", "normal", none),
    message: "jurlstify: `show-spaces-as` must be \"nbsp\", \"normal\", or none",
  )
  assert(
    extra-break-every == none
      or (type(extra-break-every) == int and extra-break-every >= 1),
    message: "jurlstify: `extra-break-every` must be none or a positive integer",
  )

  let big = if break-at-literal-hyphens { big-break-chars + ("-",) } else { big-break-chars }
  let all-breaks = break-chars + big

  // url.sty runs in math mode, which suppresses hyphenation and ligatures;
  // disable them directly so Typst adds no fake hyphens or ligatures in URLs.
  set text(hyphenate: false, historical-ligatures: false, discretionary-ligatures: false)
  set text(font: font) if font != auto
  set text(size: size) if size != auto
  set text(fill: fill) if fill != auto

  // Internal characters, kept local so a wildcard `import` never exposes them.
  let _zwsp = "\u{200B}"  // ZERO WIDTH SPACE — breakable, zero width, no stretch
  let _wj   = "\u{2060}"  // WORD JOINER      — forbids a line break
  let _nbsp = "\u{00A0}"  // NO-BREAK SPACE
  let _shy  = "\u{00AD}"  // SOFT HYPHEN      — shows "-" only if broken here
  // Stretchable invisible break: a space with negative tracking, so it is
  // invisible yet still stretches under justification (used when `stretch`).
  let _stretch-break = text(tracking: -1em, " ")

  let plain-break = if stretch { _stretch-break } else { _zwsp }

  // Emit content incrementally: text runs punctuated by break markers.
  let chars = url.clusters()
  let n = chars.len()
  let i = 0
  let run = 0  // consecutive non-break chars since the last break
  while i < n {
    let c = chars.at(i)

    if c == " " {
      run = 0
      if show-spaces-as == "nbsp" { _nbsp } else if show-spaces-as == "normal" { c }
      // none: drop the space
      i += 1
      continue
    }

    c

    if c in all-breaks {
      run = 0
      let nxt = if i + 1 < n { chars.at(i + 1) } else { none }
      if nxt not in no-break-chars {
        // A literal "-" is already its own visible hyphen — never stack a soft
        // one on top, which would render an ugly "--" at the line end.
        if show-hyphens-after-delimiters and c != "-" { _shy } else { plain-break }
      }
    } else if c == "-" and not break-at-literal-hyphens {
      run = 0
      _wj
    } else {
      run += 1
      if extra-break-every != none and run >= extra-break-every and i + 1 < n {
        if show-hyphens-at-extra-breaks { _shy } else { plain-break }
        run = 0
      }
    }

    i += 1
  }
}

/// = `jurl`
/// A clickable hyperlink whose visible text is formatted by `jurlstify`.
/// Accepts every `jurlstify` option as a trailing keyword argument.
///
/// dest <- str <required>
///   Link destination (the URL).
///
/// display <- none | str | content
///   Visible content. `none` shows `dest` itself (formatted by `jurlstify`);
///   a string is likewise formatted; content is used verbatim. Defaults to `none`.
///
#let jurl(dest, display: none, ..opts) = {
  let shown = if display == none { dest } else { display }
  let body = if type(shown) == str { jurlstify(shown, ..opts.named()) } else { shown }
  link(dest, body)
}

/// = `jurlstify-links`
/// A document-level show rule that routes every `link("http://…")` whose body
/// equals its destination through `jurlstify`. Links with explicit display
/// content are left untouched. All `jurlstify` options are forwarded.
///
/// body <- content <required>
///   The content the rule applies to.
#let jurlstify-links(..opts, body) = {
  let kwargs = opts.named()
  show link: it => {
    if (
      type(it.dest) == str
        and it.body.func() == text
        and type(it.body.text) == str
        and it.body.text == it.dest
    ) {
      link(it.dest, jurlstify(it.body.text, ..kwargs))
    } else {
      it
    }
  }
  body
}
