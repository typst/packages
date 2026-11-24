#let reshiki = plugin("reshikist.wasm")

// -----------------------------------------------------------------------
//  Internal helpers
// -----------------------------------------------------------------------

/// Build the CBOR options dictionary.
#let _opts(background, outline-text) = {
  let opts = (:)
  if background == "transparent" {
    opts.background = "transparent"
  } else if type(background) == color {
    let c = background.components()
    opts.background = (color: (
      r: int(c.at(0) / 100% * 255),
      g: int(c.at(1) / 100% * 255),
      b: int(c.at(2) / 100% * 255),
    ))
  } else if background != "canvas" {
    opts.background = background
  }
  if outline-text {
    opts.outline-text = true
  }
  opts
}

/// Load fonts into the WASM plugin.
#let _load-fonts(fonts) = {
  for font in fonts {
    let _ = reshiki.add_font(read(font, encoding: none))
  }
}

/// Heuristic to decide whether a string is a file path.
///
/// Paths are detected by containing `/` or `\`, or by ending with a
/// known chemical file extension: `.rsk`, `.mol`, `.cdxml`, `.smi`,
/// `.sdf`, `.rxn`.
///
/// When a path is detected, also returns the inferred format from the
/// extension so that `format: "auto"` does not mis-detect RSK JSON as
/// SMILES.
#let _detect-path(s) = {
  let ext-format = (
    ".rsk": "rsk",
    ".mol": "mol",
    ".cdxml": "cdxml",
    ".smi": "smiles",
    ".sdf": "mol",
    ".rxn": "rxn",
  )
  if s.contains("/") or s.contains("\\") {
    for (ext, fmt) in ext-format {
      if s.ends-with(ext) {
        return (true, fmt)
      }
    }
    return (true, "auto")
  }
  for (ext, fmt) in ext-format {
    if s.ends-with(ext) {
      return (true, fmt)
    }
  }
  (false, "auto")
}

// -----------------------------------------------------------------------
//  Unified chemical image renderer
// -----------------------------------------------------------------------

/// Render a chemical drawing from any supported format.
///
/// `data` can be:
/// - `bytes` — raw file contents (use `#read("path.rsk", encoding: none)`).
/// - `str`  — a file path (e.g. `"molecule.rsk"`) or an inline structure
///   string (e.g. `"c1ccccc1"`).  Paths are auto-detected by extensions
///   (`".rsk"`, `".mol"`, `".cdxml"`, `".smi"`, `".sdf"`, `".rxn"`) or by
///   containing `/` or `\\`. Any other string is treated as SMILES.
///
/// Supported formats: `"rsk"`, `"cdxml"`, `"mol"`, `"smiles"`, `"rxn"`,
/// `"rsmi"`. Use `"auto"` to let the plugin infer the format from file
/// content.
///
/// # Parameters
/// - `data`: Input data (`bytes` or `str`).
/// - `format`: Format name string (`"auto"`, `"rsk"`, `"mol"`, `"cdxml"`,
///   `"smiles"`, `"rxn"`, `"rsmi"`). Default is `"auto"`.
/// - `width`, `height`: Optional sizing constraints (passed to `#image`).
/// - `background`: `"canvas"`, `"transparent"`, or a `color`.
/// - `outline-text`: When `true`, convert text to SVG paths. Default `false`.
/// - `fonts`: Array of font file paths to load before rendering.
///
/// # Returns
/// An `image` element on success; returns `none` on failure.
#let chem-image(
  data,
  format: "auto",
  width: auto,
  height: auto,
  background: "canvas",
  outline-text: false,
  fonts: (),
) = {
  _load-fonts(fonts)

  let (render-data, render-format) = if type(data) == str {
    let (is-path, inferred) = _detect-path(data)
    if is-path {
      let fmt = if format == "auto" { inferred } else { format }
      (read(data, encoding: none), fmt)
    } else {
      let fmt = if format == "auto" { "smiles" } else { format }
      (bytes(data), fmt)
    }
  } else {
    (data, format)
  }

  let opts = _opts(background, outline-text)
  let format-bytes = bytes(render-format)
  let result = if opts.len() == 0 {
    reshiki.render_from_format(render-data, format-bytes)
  } else {
    reshiki.render_from_format_with_options(render-data, format-bytes, cbor.encode(opts))
  }
  if result.len() == 0 {
    return none
  }
  image(result, format: "svg", width: width, height: height)
}

// -----------------------------------------------------------------------
//  Deprecated — kept for backward compatibility
// -----------------------------------------------------------------------

/// Render ReShiki `.rsk` bytes as a Typst image.
///
/// *Deprecated:* Use `#chem-image(data, format: "rsk")` instead.
#let rsk-image(data, ..args) = chem-image(data, format: "rsk", ..args)

/// Convenience: render with a transparent background.
///
/// *Deprecated:* Use `#chem-image(data, format: "rsk", background: "transparent")` instead.
#let rsk-transparent(data, ..args) = chem-image(data, format: "rsk", background: "transparent", ..args)
