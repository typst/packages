#import "prelude.typ"
#import "unicode.typ" as _unicode
#import "convert.typ"
#import "utils.typ" as _utils: is-html

/// Transform the content if `html`-export is active.
///
/// Returns the content as-is, if `html` is not active.
/// -> content
#let maybe-html(
  /// This function which will be called to transform the content.
  ///
  /// The first parameter of the function will be @maybe-html.inner, the other parameters are @maybe-html.args.
  /// -> function
  transform,
  /// The content to transform.
  /// -> content | any
  inner,
  /// Controls if the transform function should be called even on paged targets (pdf, png etc.).
  /// -> bool
  force: false,
  /// Extra arguments to pass to @maybe-html.transform.
  /// -> arguments
  ..args,
) = context {
  if force or is-html() {
    transform(inner, ..args)
  } else {
    inner
  }
}

#let html-framed(content, block: true, attrs: none, class: none, center: auto) = {
  let maybe-center = if block {
    if center == auto or center == true {
      "mathyml-block-center "
    } else {
      ""
    }
  } else {
    if center != auto and center != none {
      panic("center is only supported for blocks")
    } else {
      ""
    }
  }
  let default-class = if class != none {
    let r = maybe-center + class
    if not r.ends-with(" ") {
      r += " "
    }
    r
  } else {
    maybe-center
  }
  let elem = if block {
    "div"
  } else {
    default-class += "mathyml-inline-span "
    "span"
  }
  html.elem(elem, attrs: (class: default-class) + attrs, html.frame(content))
}

#let _mathml-ignore(inner) = {
  if type(inner) == content and inner.func() == math.equation {
    let fields = inner.fields()
    let body = fields.remove("body")
    let ignore = metadata((_utils._type-ident: _utils._dict-types.ignore, body: []))
    math.equation(
      [#ignore #body],
      ..fields,
    )
  } else {
    inner
  }
}

/// Convert content to MathML.
///
/// -> content
#let to-mathml-raw(
  /// The equation/ content to convert.
  /// -> content | math.equation
  inner,
  /// Whether the equation is rendered as a separate block.
  ///
  /// If `block` is auto, it will be inferred from the input.
  /// -> bool | auto
  block: auto,
  /// This callback will be called with every error.
  ///
  /// The function should take a single argument sink as parameter.
  /// If you overwrite this parameter, don't forget to overwrite @to-mathml-raw.is-error.
  /// `is-error` should return true if and only if `on-error` was called.
  ///
  /// For example you could return a custom dictionary on each error and check in `is-error` for that.
  /// -> function
  on-error: panic,
  /// This function will be called with every warning.
  ///
  /// The function should take a single argument sink as parameter.
  /// If you overwrite this parameter, don't forget to overwrite @to-mathml-raw.is-error.
  /// In combination with `is-error`, you can `panic` on the warning, silence it or propagate it.
  /// -> function
  on-warn: (..args) => (),
  /// This callback will be called to determine if a result is an error.
  ///
  /// Errors will be propagated directly.
  /// -> function
  is-error: res => false,
) = {
  if type(inner) == content and inner.func() == math.equation {
    if block == auto {
      block = inner.block
      inner = inner.body
    } else {
      inner = inner.body
    }
  }
  if block == auto {
    block = false
  }
  let converted = convert.convert-mathml(
    inner,
    on-error: on-error,
    on-warn: on-warn,
    is-error: is-error,
    size: if block { "display" } else { "text" },
  )
  if is-error(converted) {
    return converted
  }
  if block {
    return html.elem("math", attrs: (display: "block"), converted)
  } else {
    return html.elem("span", html.elem("math", converted))
  }
}


/// Try to convert the inner body to MathML, but fallback to a svg frame on error.
///
/// Note that for non-html targets, this function does nothing (you can change this with @try-to-mathml.force).
///
/// -> content
#let try-to-mathml(
  /// The equation/ content to convert.
  /// -> content | math.equation
  inner,
  /// Whether the equation is rendered as a separate block.
  ///
  /// If `block` is auto, it will be inferred from the input.
  /// -> bool | auto
  block: auto,
  /// Whether to consider warnings as errors.
  /// -> bool
  strict: false,
  /// Whether to build an html tree even on paged targets (pdf, png etc.).
  /// -> bool
  force: false,
) = {
  let on-error(..args) = (_utils._err-tag: true, pos: args.pos()) + args.named()
  let on-warn = if strict {
    on-error
  } else {
    (..args) => ()
  }
  let is-error(item) = type(item) == dictionary and _utils._err-tag in item

  let run(inner) = {
    let res = to-mathml-raw(
      inner,
      block: block,
      on-error: on-error,
      on-warn: on-warn,
      is-error: is-error,
    )
    if is-error(res) {
      // return repr(res) // FIXME fix all errors with this and `strict = true` above
      html-framed(inner)
    } else {
      res
    }
  }

  maybe-html(run, inner, force: force)
}



/// Convert the inner body to MathML and panic on error.
///
/// If you want to embed a svg-frame on error instead, use @try-to-mathml.
/// If you want to handle errors yourself, use @to-mathml-raw.
///
/// Note that for non-html targets, this function does nothing (you can change this with @to-mathml.force).
///
/// -> content
#let to-mathml(
  /// The equation/ content to convert.
  /// -> content | math.equation
  inner,
  /// Whether the equation is rendered as a separate block.
  ///
  /// If `block` is auto, it will be inferred from the input.
  /// -> bool | auto
  block: auto,
  /// Whether to build an html tree even on paged targets (pdf, png etc.).
  /// -> bool
  force: false,
) = {
  maybe-html(to-mathml-raw.with(block: block), inner, force: force)
}

#let _include-mathfont-inner(font, trimmed: "") = {
  let fonts = (
    "asana": "Asana",
    "cambria": "Cambria",
    "tex gyre dejavu": "DejaVu",
    "dejavu": "DejaVu",
    "dejavu math tex gyre": "DejaVu",
    "euler": "Euler",
    "fira": "FiraMath",
    "gfs neohellenic": "GFS_NeoHellenic",
    "gnu free sans": "GNUFreeSans",
    "free sans": "GNUFreeSans",
    "gnu free serif": "GNUFreeSerif",
    "free serif": "GNUFreeSerif",
    "garamond": "Garamond",
    "garamond-math": "Garamond",
    "eb garamond": "Garamond",
    "lmroman12": "LatinModern",
    "latin modern": "LatinModern",
    "lete sans": "LeteSansMath",
    "libertinus serif": "Libertinus",
    "libertinus": "Libertinus",
    "lucida bright": "LucidaBright",
    "minion": "Minion",
    "new computer modern": "NewComputerModern",
    "new computer modern10": "NewComputerModern",
    "new computer modern sans": "NewComputerModernSans",
    "noto sans": "NotoSans",
    "ibmplexmath": "Plex",
    "ibmplex": "Plex",
    "ibmplexserif": "Plex",
    "ibmplex serif": "Plex",
    "stix two text": "STIX",
    "stix two": "STIX",
    "tex gyre bonum": "TeXGyreBonum",
    "bonum": "TeXGyreBonum",
    "bonum math tex gyre": "TeXGyreBonum",
    "tex gyre pagella": "TeXGyrePagella",
    "pagella": "TeXGyrePagella",
    "pagella math tex gyre": "TeXGyrePagella",
    "tex gyre schola": "TeXGyreSchola",
    "schola": "TeXGyreSchola",
    "schola math tex gyre": "TeXGyreSchola",
    "tex gyre termes": "TeXGyreTermes",
    "termes": "TeXGyreTermes",
    "termes math tex gyre": "TeXGyreTermes",
    "xits": "XITS",
  )
  let prefix = "https://fred-wang.github.io/MathFonts/"
  if font == auto {
    let s = state("mathyml-font-detection", none)
    return {
      // switch to context in equation to get the font set for them
      let _temp = {
        show math.equation: it => {
          s.update(text.font)
          it
        }
        html.elem("div", attrs: (style: "display:none"), html.frame($$))
      }
      context {
        let font = s.final()
        if font == none {
          font = "NewComputerModern"
        }
        _include-mathfont-inner(font)
      }
    }
  } else {
      font = lower(font)
      let found = false
      for f in fonts.values() {
        if font == lower(f) {
          font = f
          found = true
        }
      }
      font = if found { font } else if font in fonts.keys() {
        fonts.at(font)
      } else {
        if font.ends-with("math") {
          return _include-mathfont-inner(font.trim(repeat: false, at: end, "math").trim(), trimmed: " math" + trimmed)
        }
        panic("unsupported font `" + font + trimmed + "`. See " + prefix + " for a list of supported fonts")
      }
    }
  let href = prefix + font + "/mathfonts.css"
  html.elem("link", attrs: (rel: "stylesheet", href: href))
}

/// Include a math font in the html document.
///
/// See https://github.com/fred-wang/MathFonts for a list of supported fonts.
#let include-mathfont(
  /// The name of the font to include.
  /// -> auto | str
  font: auto,
) = {
  _include-mathfont-inner(font)
}

