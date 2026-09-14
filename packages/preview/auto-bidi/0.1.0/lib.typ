/// State controlling the detection algorithm mid-document.
/// Values: `"first"` (first script char wins) or `"auto"` (majority wins).
#let detect-by-state = state("auto-dir.detect-by", "first")

/// State for section-level language override.
/// `none` means auto-detect; `"he"`, `"ar"`, `"fa"`, or `"en"` forces that language.
#let lang-state = state("auto-dir.lang", none)

/// Force all subsequent blocks to Hebrew until `#setauto`.
#let sethebrew = lang-state.update(_ => "he")

/// Force all subsequent blocks to Arabic until `#setauto`.
#let setarabic = lang-state.update(_ => "ar")

/// Force all subsequent blocks to Farsi (Persian) until `#setauto`.
#let setfarsi = lang-state.update(_ => "fa")

/// Force all subsequent blocks to English until `#setauto`.
#let setenglish = lang-state.update(_ => "en")

/// Return to automatic language detection.
#let setauto = lang-state.update(_ => none)

/// Force a specific language on a content block, overriding auto-detection.
/// Affects paragraphs, headings, lists, and enums within `body`.
///
/// - lang (string): A BCP 47 language code, e.g. `"he"`, `"ar"`, `"fa"`, `"en"`.
/// - body (content): The content to apply the language to.
/// -> content
#let force-lang(lang, body) = {
  show par: it => [#set text(lang: lang); #it]
  show heading: it => [#set text(lang: lang); #it]
  show list: it => [#set text(lang: lang); #it]
  show enum: it => [#set text(lang: lang); #it]
  [#set text(lang: lang); #body]
}

/// Convenience wrapper for forcing Hebrew language on a content block.
///
/// - body (content): The content to render.
/// - lang (string): Language code, defaults to `"he"` (Hebrew).
/// -> content
#let rl(body, lang: "he") = force-lang(lang, body)

/// Convenience wrapper for forcing English language on a content block.
///
/// - body (content): The content to render.
/// - lang (string): Language code, defaults to `"en"` (English).
/// -> content
#let lr(body, lang: "en") = force-lang(lang, body)

/// Invisible hebrew/english/arabic character — use to bias detection toward lang
#let hechar = text(size: 0pt)[א]
#let archar = text(size: 0pt)[ا]
#let enchar = text(size: 0pt)[a]

/// Shorthand aliases for direction hint characters
#let r = text(size: 0pt)[י]
#let l = text(size: 0pt)[i]

/// Extract plain text from a content block, ignoring math and raw.
#let _plain(c) = {
  if type(c) == str { return c }
  let f = c.func()
  if f == math.equation or f == raw { return "" }
  let fields = c.fields()
  if "children" in fields { return fields.children.map(_plain).join("") }
  if "child" in fields { return _plain(fields.child) }
  if "body" in fields { return _plain(fields.body) }
  if "text" in fields { return _plain(fields.text) }
  ""
}

/// Detect the dominant language of a content block.
/// Returns `"he"`, `"ar"`, `"fa"`, or `"en"`.
///
/// - body (content): The content to inspect.
/// - detect-by (string): `"first"` (first script char) or `"auto"` (majority of chars).
/// - arabic-script-lang (string): Language for Arabic-script text (`"ar"` or `"fa"`).
/// - default-lang (string): Fallback when no script is detected.
/// -> string
#let detect-lang(
  body,
  detect-by: "first",
  arabic-script-lang: "ar",
  default-lang: "en",
) = {
  let heb = regex("\p{Hebrew}")
  let ara = regex("\p{Arabic}")
  let lat = regex("\p{Latin}")
  let txt = _plain(body)
  if detect-by == "auto" {
    let nh = txt.matches(heb).len()
    let na = txt.matches(ara).len()
    let nl = txt.matches(lat).len()
    if nh + na + nl == 0 { default-lang } else if nh + na > nl {
      if nh >= na { "he" } else { arabic-script-lang }
    } else { "en" }
  } else {
    // "first" mode (default)
    for ch in txt.clusters() {
      if ch.matches(heb).len() > 0 { return "he" }
      if ch.matches(ara).len() > 0 { return arabic-script-lang }
      if ch.matches(lat).len() > 0 { return "en" }
    }
    default-lang
  }
}

/// Detect the direction of a content block.
/// Returns `"rtl"` or `"ltr"`.
///
/// - body (content): The content to inspect.
/// - detect-by (string): `"first"` (first script char) or `"auto"` (majority of chars).
/// - arabic-script-lang (string): Language for Arabic-script text (`"ar"` or `"fa"`).
/// - default-lang (string): Fallback when no script is detected.
/// -> string
#let detect-dir(
  body,
  detect-by: "first",
  arabic-script-lang: "ar",
  default-lang: "en",
) = {
  let lang = detect-lang(body, detect-by: detect-by, arabic-script-lang: arabic-script-lang, default-lang: default-lang)
  if lang in ("he", "ar", "fa") { "rtl" } else { "ltr" }
}

/// Apply automatic language detection to the document.
///
/// Wraps the document with show rules that detect the dominant script in each
/// paragraph, heading, list, and enum, then sets `text(lang:)` accordingly.
/// Typst then applies directionality, shaping, and hyphenation from `lang`.
///
/// - hebrew-font (string, array): Font(s) used for Hebrew text.
/// - english-font (string, array): Font(s) used for English text.
/// - arab-font (string, array): Font(s) used for Arabic text.
/// - detect-by (string): Detection algorithm — `"first"` (first recognised
///   script char, like Apple Notes) or `"auto"` (majority of chars).
/// - arabic-script-lang (string): Language tag for Arabic-script detection
///   (supported: `"ar"` or `"fa"`).
/// - default-lang (string): Fallback language when no script is detected.
/// - doc (content): The document body (passed automatically via `show:`).
/// -> content
#let auto-dir(
  hebrew-font: ("David CLM", "Libertinus Math"),
  english-font: ("New Computer Modern", "Libertinus Serif"),
  arab-font: "Libertinus Serif",
  base-font: "New Computer Modern",
  detect-by: "first",
  arabic-script-lang: "ar",
  default-lang: "en",
  doc,
) = {
  let heb = regex("\p{Hebrew}")
  let ara = regex("\p{Arabic}")
  let lat = regex("\p{Latin}")

  let with-covers(fonts, rgx) = if type(fonts) == str {
    ((name: fonts, covers: rgx),)
  } else {
    fonts.map(f => (name: f, covers: rgx))
  }

  set text(font: (
    ..with-covers(arab-font, ara),
    ..with-covers(hebrew-font, heb),
    ..with-covers(english-font, lat),
    base-font,
  ))

  let detect-char(ch) = {
    if ch.matches(heb).len() > 0 { "he" } else if ch.matches(ara).len() > 0 { arabic-script-lang } else if (
      ch.matches(lat).len() > 0
    ) {
      "en"
    } else { none }
  }

  let detect-first(c) = {
    for ch in _plain(c).clusters() {
      let lang = detect-char(ch)
      if lang != none { return lang }
    }
    default-lang
  }

  let detect-auto(c) = {
    let txt = _plain(c)
    let nh = txt.matches(heb).len()
    let na = txt.matches(ara).len()
    let nl = txt.matches(lat).len()
    if nh + na + nl == 0 { default-lang } else if nh + na > nl {
      if nh >= na { "he" } else { arabic-script-lang }
    } else { "en" }
  }

  let apply(it, source) = context {
    let lang = if lang-state.get() != none {
      lang-state.get()
    } else if detect-by-state.get() == "auto" {
      detect-auto(source)
    } else {
      detect-first(source)
    }
    [#set text(lang: lang); #it]
  }

  show par: it => apply(it, it.body)
  show heading: it => apply(it, it.body)
  show title: it => apply(it, it.body)
  show list: it => apply(it, it)
  show enum: it => apply(it, it)

  [#detect-by-state.update(_ => detect-by) #doc]
}

