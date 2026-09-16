// jurlstify — URL typesetting with line-break opportunities.
//
// Ported from Donald Arseneau's LaTeX `url.sty` (LPPL).
//
// Raggedness note:
//   url.sty sets every math-mode muskip to `0mu` — zero natural width AND
//   zero stretch/shrink. That means a line that falls entirely inside a
//   URL has no stretchable glue in LaTeX either, so it can only reach the
//   right margin by luck of where break points fall. The common sense
//   that "url.sty makes URLs justify" is a misconception propagated by
//   TeX's Knuth-Plass breaker, which is aggressive enough that ragged
//   URL-internal lines are rare in practice. We cannot reproduce Knuth-
//   Plass, so we offer the same two trade-offs LaTeX has:
//
//     1. `stretch: false` (default, matches url.sty): emit U+200B at
//        break points — zero-width, breakable, non-stretchable. Lines
//        that fall entirely inside a URL may end short of the right
//        margin. This is the honest port of url.sty.
//
//     2. `stretch: true`: emit a real U+0020 space wrapped in
//        `text(tracking: …)` that pulls the space advance to zero. The
//        space is invisible when the line is not justified, but the
//        paragraph justifier will expand it like any word space on
//        justified URL-internal lines — buying right-margin alignment
//        at the cost of small visible gaps between URL segments on
//        those lines.
//
// Hyphen handling:
//   Unicode assigns "-" to line-break class HY (break after). url.sty
//   keeps hyphens in UrlOrds by default (no break) and only promotes
//   them to UrlBigBreaks under the `hyphens` option. We emit U+2060
//   (WORD JOINER) after "-" when `hyphens: false` to suppress Typst's
//   default break at hyphens.

// ─────────────────────────────────────────────────────────────────────────────
// Break-class tables — kept identical to `url.sty` defaults.
// \UrlBreaks / \UrlBigBreaks / \UrlNoBreaks  (url.sty §32–35)

#let breaks-default = (
  ".", "@", "\\", "/", "!", "_", "|", ";", ">", "]",
  ")", ",", "?", "&", "'", "+", "=", "#",
)

#let big-breaks-default = (":",)

#let no-breaks-default = ("(", "[", "{", "<")

// Invisible characters used internally.
#let _zwsp = "\u{200B}"  // ZERO WIDTH SPACE — break, zero width, no stretch
#let _wj   = "\u{2060}"  // WORD JOINER     — forbids line break
#let _nbsp = "\u{00A0}"  // NO-BREAK SPACE

// Stretchable invisible break. A real U+0020 with enough negative tracking to
// cancel its advance — invisible on unjustified lines, but *does* participate
// in paragraph justification on URL-internal lines. Opt-in via `stretch: true`.
#let _stretch-break = text(tracking: -1em, " ")

// ─────────────────────────────────────────────────────────────────────────────
// Core: render a URL with break+stretch opportunities.
//
// Arguments
// ---------
// url         : str    — the URL text.
// hyphens     : bool   — allow breaks after "-" (url.sty `hyphens` option).
// stretch     : bool   — if true, URL-internal lines can stretch to reach
//                        the right margin in a justified paragraph. Trade-
//                        off: visible gaps appear at break points on those
//                        lines. Default false (matches url.sty's
//                        zero-stretch muskips; lines may be ragged).
// spaces      : str    — "nobreak" | "break" | "strip".  url.sty default is
//                        "nobreak" (\penalty\@M); `spaces` option gives "break".
// breaks      : array  — override normal break chars.
// big-breaks  : array  — override high-priority break chars.
// no-breaks   : array  — chars explicitly suppressed from breaking (a break
//                        opportunity that would otherwise land *before* one
//                        of these is dropped, matching url.sty's `\mathopen`
//                        class).
// font        : auto | str | array — URL font; `auto` inherits the
//                        surrounding body font. Pass a font name or array
//                        (e.g. monospace stack) to override.
// size        : auto | length
// fill        : auto | color
// every       : none | int — insert a soft hyphen (U+00AD) after every N
//                        consecutive non-break characters. The hyphen is
//                        invisible unless the line actually breaks there.
//                        Disabled by default (none). Useful when URLs contain
//                        long unbroken letter/digit runs that resist all
//                        natural break points.

#let jurlstify(
  url,
  hyphens: false,
  stretch: false,
  spaces: "nobreak",
  breaks: breaks-default,
  big-breaks: big-breaks-default,
  no-breaks: no-breaks-default,
  font: auto,
  size: auto,
  fill: auto,
  every: none,
) = {
  assert(
    type(url) == str,
    message: "jurlstify: expected a string, got " + str(type(url)),
  )
  assert(
    spaces in ("nobreak", "break", "strip"),
    message: "jurlstify: `spaces` must be \"nobreak\", \"break\", or \"strip\"",
  )
  assert(
    every == none or (type(every) == int and every >= 1),
    message: "jurlstify: `every` must be none or a positive integer",
  )

  let big = if hyphens { big-breaks + ("-",) } else { big-breaks }
  let all-breaks = breaks + big

  // url.sty runs inside math mode, which suppresses automatic hyphenation
  // and ligatures. Typst has no math-mode escape for strings, so we disable
  // those features directly; otherwise Typst would insert fake hyphens
  // ("exam-ple.com") and apply language-specific ligatures inside URLs.
  set text(
    hyphenate: false,
    historical-ligatures: false,
    discretionary-ligatures: false,
  )
  set text(font: font) if font != auto
  set text(size: size) if size != auto
  set text(fill: fill) if fill != auto

  let break-marker = if stretch { _stretch-break } else { _zwsp }

  // Emit content incrementally: text runs punctuated by break markers.
  let chars = url.clusters()
  let n = chars.len()
  let i = 0
  let word-run = 0  // consecutive non-break chars since the last natural break
  while i < n {
    let c = chars.at(i)

    if c == " " {
      word-run = 0
      if spaces == "nobreak" { _nbsp }
      else if spaces == "break" { c }
      // "strip": drop the space
      i += 1
      continue
    }

    c

    if c in all-breaks {
      word-run = 0
      let nxt = if i + 1 < n { chars.at(i + 1) } else { none }
      if nxt not in no-breaks {
        break-marker
      }
    } else if c == "-" and not hyphens {
      word-run = 0
      _wj
    } else {
      word-run += 1
      if every != none and word-run >= every and i + 1 < n {
        "\u{00AD}"  // soft hyphen — visible only when the line breaks here
        word-run = 0
      }
    }

    i += 1
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Convenience wrapper: hyperlink + jurlstify
//
//   #jurl("https://example.com/long/path")
//   #jurl("https://example.com/long/path", display: "example")

#let jurl(
  dest,
  display: none,
  ..opts,
) = {
  let shown = if display == none { dest } else { display }
  let body = if type(shown) == str {
    jurlstify(shown, ..opts.named())
  } else {
    shown
  }
  link(dest, body)
}

// ─────────────────────────────────────────────────────────────────────────────
// Show-rule helper: make the built-in `link` element use jurlstify's breaking
// wherever its body is a plain text run (`link("http://…")`, etc).
//
//   #show: jurlstify-links.with()
//   #link("https://example.com/foo/bar")   // auto-formatted

#let jurlstify-links(
  ..opts,
  body,
) = {
  let kwargs = opts.named()
  show link: it => {
    // Only rewrite when the body is the auto-generated textual form of
    // `dest` (the common `link("http://…")` case). Explicit display
    // content such as `link(dest, "click me")` is left untouched — the
    // user picked it on purpose and almost certainly isn't a URL.
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
