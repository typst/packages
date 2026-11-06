#let plugin = plugin("scoryst.wasm")

/// Convert kebab-case to camelCase. Keys already in camelCase pass through unchanged.
#let _to-camel(s) = {
  let parts = s.split("-")
  parts.at(0) + parts.slice(1).map(p => upper(p.at(0)) + p.slice(1)).join()
}

/// Verovio's full option catalogue as a nested dictionary, grouped by category.
/// Each option maps to a dictionary with keys like `title`, `description`,
/// `type`, and `default`.
/// -> dictionary
#let available-options() = json(plugin.available_options())

// Verovio enum options: string→int mapping.
// Passing these as integers avoids a WASM hang in OptionIntMap::SetValue(string).
#let _enum-options = (
  breaks: ("none": 0, "auto": 1, "line": 2, "smart": 3, "encoded": 4),
  condense: ("none": 0, "auto": 1, "encoded": 2),
  footer: ("none": 0, "auto": 1, "always": 2, "encoded": 3),
  header: ("none": 0, "auto": 1, "encoded": 2),
  smuflTextFont: ("embedded": 0, "linked": 1, "none": 2),
  mensuralResponsiveView: ("none": 0, "auto": 1, "selection": 2),
  pedalStyle: ("auto": 0, "line": 1, "pedstar": 3, "altpedstar": 4),
  fontFallback: ("Leipzig": 0, "Bravura": 1),
  lyricElision: ("regular": 58705, "narrow": 58704, "wide": 58706, "unicode": 8255),
  multiRestStyle: ("auto": 0, "default": 1, "block": 2, "symbols": 3),
  systemDivider: ("none": 0, "auto": 1, "left": 2, "left-right": 3),
  durationEquivalence: ("brevis": 0, "semibrevis": 1, "minima": 2),
  ligatureOblique: ("auto": 0, "straight": 1, "curved": 2),
)

/// Serialize a Typst dictionary to a JSON options string for Verovio.
/// Merges with default options (adjustPageHeight crops SVG to content).
/// Accepts both kebab-case and camelCase option keys.
#let _serialize-options(options) = {
  let defaults = (adjust-page-height: true, input-from: "auto")
  let merged = if options != none { defaults + options } else { defaults }
  let pairs = merged.pairs().map(((k, v)) => {
    let key = _to-camel(k)
    let val = if type(v) == str and key in _enum-options {
      let mapping = _enum-options.at(key)
      assert(v in mapping, message: "invalid value \"" + v + "\" for option " + k + ", expected: " + mapping.keys().join(", "))
      str(mapping.at(v))
    } else if type(v) == str {
      "\"" + v + "\""
    } else if v == true { "true" } else if v == false { "false" } else { str(v) }
    "\"" + key + "\":" + val
  })
  "{" + pairs.join(",") + "}"
}

/// Verovio auto-detects every supported format from structural markers except
/// Volpiano (no distinctive header). Sniff its clef + hyphen prefix and set
/// `input-from` unless the caller already specified it.
#let _maybe-volpiano(data, options) = {
  let already-set = options != none and ("input-from" in options or "inputFrom" in options)
  if already-set { return options }
  let prefix = if type(data) == bytes {
    if data.len() == 0 { return options }
    str(data.slice(0, calc.min(8, data.len())))
  } else {
    data.slice(0, calc.min(8, data.len()))
  }
  if prefix.trim().starts-with(regex("[12]-{2,}")) {
    (if options == none { (:) } else { options }) + (input-from: "volpiano")
  } else {
    options
  }
}

/// Render music notation to an SVG image.
///
/// - data (str): Music data (MusicXML, MEI, ABC, Humdrum, EsAC, PAE, Volpiano, CMME); the format is auto-detected.
/// - options (dictionary): Verovio options (optional).
/// - page (int): Page number to render.
/// - ..args (arguments): Forwarded to Typst's `image` function (e.g. `width`, `height`, `fit`, `alt`).
/// -> content
#let score(data, options: none, page: 1, ..args) = {
  let options = _maybe-volpiano(data, options)
  let data-bytes = bytes(data)
  let options-bytes = bytes(_serialize-options(options))

  let svg-bytes = if page == 1 {
    plugin.render(data-bytes, options-bytes)
  } else {
    plugin.render_page(data-bytes, options-bytes, bytes(str(page)))
  }

  image(svg-bytes, format: "svg", ..args.named())
}

/// Get the number of pages for a music document.
///
/// - data (str): Music data (format auto-detected).
/// - options (dictionary): Verovio options (optional).
/// -> int
#let pages(data, options: none) = {
  let options = _maybe-volpiano(data, options)
  int(str(plugin.page_count(bytes(data), bytes(_serialize-options(options)))))
}

/// The bundled Verovio version string (e.g. "6.3.0").
/// -> str
// Verovio appends a build tag such as "[emscripten]"; drop it.
#let version() = str(plugin.version()).split("[").at(0)

/// Transcode music notation to another format.
///
/// - data (str): Music data (input format is auto-detected).
/// - to (str): Output format — "mei" (canonical MEI) or "pae" (Plaine & Easie).
/// - options (dictionary): Verovio options (optional).
/// -> str
#let convert(data, to: "mei", options: none) = {
  assert(
    to in ("mei", "pae"),
    message: "convert: `to` must be \"mei\" or \"pae\", got \"" + to + "\"",
  )
  let options = _maybe-volpiano(data, options)
  str(plugin.convert(bytes(data), bytes(_serialize-options(options)), bytes(to)))
}

/// Show-rule helper: auto-render fenced code blocks whose language is a
/// supported notation format (`abc`, `musicxml`, `mei`, `humdrum`/`kern`,
/// `esac`, `pae`, `volpiano`, `cmme`). Use as `#show: scoryst.music-blocks`, or
/// with options: `#show: scoryst.music-blocks.with(options: (font: "Bravura"))`.
///
/// - options (dictionary): Default Verovio options for rendered blocks (optional).
/// - body (content): Content the show rule is applied to.
/// -> content
#let music-blocks(options: none, body) = {
  let langs = (
    abc: "abc", musicxml: "musicxml", mei: "mei", humdrum: "humdrum",
    kern: "humdrum", esac: "esac", pae: "pae", volpiano: "volpiano", cmme: "cmme",
  )
  show raw.where(block: true): it => {
    let lang = if it.lang == none { none } else { lower(it.lang) }
    if lang != none and lang in langs {
      let base = if options == none { (:) } else { options }
      score(it.text, options: base + (input-from: langs.at(lang)))
    } else {
      it
    }
  }
  body
}

// Deprecated aliases for backward compatibility
#let render-music(data, options: none, page: 1, ..args) = score(data, options: options, page: page, ..args)
#let music-page-count(data, options: none) = pages(data, options: options)
