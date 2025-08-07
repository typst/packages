#import "src/lib.typ": (
  codly-init,
  codly-reset,
  no-codly,
  yes-codly,
  codly-enable,
  codly-disable,
  codly-range,
  codly-offset,
  codly-skip,
  typst-icon,
)

#let __codly-default = context [ Codly Default ]

/// See the full documentation: https://raw.githubusercontent.com/Dherse/codly/main/docs.pdf
/// 
/// - enabled (bool, function): enabled
/// - header (content, none, function): header
/// - header-repeat (bool, function): header-repeat
/// - header-cell-args (array, dictionary, arguments, function): header-cell-args
/// - header-transform (function): header-transform
/// - footer (content, none, function): footer
/// - footer-repeat (bool, function): footer-repeat
/// - footer-cell-args (array, dictionary, arguments, function): footer-cell-args
/// - footer-transform (function): footer-transform
/// - offset (int, function): offset
/// - offset-from (none, label, function): offset-from
/// - range (none, array, function): range
/// - ranges (none, array, function): ranges
/// - smart-skip (bool, dictionary, function): smart-skip
/// - languages (dictionary, function): languages
/// - default-color (color, gradient, tiling, function): default-color
/// - radius (length, function): radius
/// - inset (length, dictionary, function): inset
/// - fill (none, color, gradient, tiling, function): fill
/// - zebra-fill (none, color, gradient, tiling, function): zebra-fill
/// - stroke (none, stroke, function): stroke
/// - lang-inset (length, dictionary, function): lang-inset
/// - lang-outset (dictionary, function): lang-outset
/// - lang-radius (length, function): lang-radius
/// - lang-stroke (none, stroke, function): lang-stroke
/// - lang-fill (none, color, gradient, tiling, function): lang-fill
/// - lang-format (auto, none, function): lang-format
/// - display-name (bool, function): display-name
/// - display-icon (bool, function): display-icon
/// - filename (str, content, none, function): filename
/// - filename-separator (str, content, function): filename-separator
/// - number-format (function, none): number-format
/// - number-align (alignment, function): number-align
/// - number-placement (str): number-placement
/// - smart-indent (bool): smart-indent
/// - skip-last-empty (bool, function): skip-last-empty
/// - breakable (bool): breakable
/// - skips (array, none, function): skips
/// - skip-line (content, none, function): skip-line
/// - skip-number (content, none, function): skip-number
/// - annotations (array, none, function): annotations
/// - annotation-format (none, function): annotation-format
/// - highlighted-lines (array, none, function): highlighted-lines
/// - highlighted-default-color (color, tiling, gradient, function): highlighted-default-color
/// - highlights (array, none, function): highlights
/// - highlight-radius (length, function): highlight-radius
/// - highlight-fill (function): highlight-fill
/// - highlight-stroke (stroke, function): highlight-stroke
/// - highlight-inset (length, dictionary, function): highlight-inset
/// - highlight-outset (length, dictionary, function): highlight-outset
/// - highlight-clip (bool, function): highlight-clip
/// - reference-by (str, function): reference-by
/// - reference-sep (str, content, function): reference-sep
/// - reference-number-format (function): reference-number-format
/// - aliases (dictionary): aliases
/// -> content
#let codly(
  enabled: __codly-default,
  header: __codly-default,
  header-repeat: __codly-default,
  header-cell-args: __codly-default,
  header-transform: __codly-default,
  footer: __codly-default,
  footer-repeat: __codly-default,
  footer-cell-args: __codly-default,
  footer-transform: __codly-default,
  offset: __codly-default,
  offset-from: __codly-default,
  range: __codly-default,
  ranges: __codly-default,
  smart-skip: __codly-default,
  languages: __codly-default,
  default-color: __codly-default,
  radius: __codly-default,
  inset: __codly-default,
  fill: __codly-default,
  zebra-fill: __codly-default,
  stroke: __codly-default,
  lang-inset: __codly-default,
  lang-outset: __codly-default,
  lang-radius: __codly-default,
  lang-stroke: __codly-default,
  lang-fill: __codly-default,
  lang-format: __codly-default,
  display-name: __codly-default,
  display-icon: __codly-default,
  filename: __codly-default,
  filename-separator: __codly-default,
  number-format: __codly-default,
  number-align: __codly-default,
  number-placement: __codly-default,
  smart-indent: __codly-default,
  skip-last-empty: __codly-default,
  breakable: __codly-default,
  skips: __codly-default,
  skip-line: __codly-default,
  skip-number: __codly-default,
  annotations: __codly-default,
  annotation-format: __codly-default,
  highlighted-lines: __codly-default,
  highlighted-default-color: __codly-default,
  highlights: __codly-default,
  highlight-radius: __codly-default,
  highlight-fill: __codly-default,
  highlight-stroke: __codly-default,
  highlight-inset: __codly-default,
  highlight-outset: __codly-default,
  highlight-clip: __codly-default,
  reference-by: __codly-default,
  reference-sep: __codly-default,
  reference-number-format: __codly-default,
  aliases: __codly-default,
) = {
  import "src/lib.typ": __codly-inner
  let out = (:)
  if enabled != __codly-default {
    out.insert("enabled", enabled)
  }
  if header != __codly-default {
    out.insert("header", header)
  }
  if header-repeat != __codly-default {
    out.insert("header-repeat", header-repeat)
  }
  if header-cell-args != __codly-default {
    out.insert("header-cell-args", header-cell-args)
  }
  if header-transform != __codly-default {
    out.insert("header-transform", header-transform)
  }
  if footer != __codly-default {
    out.insert("footer", footer)
  }
  if footer-repeat != __codly-default {
    out.insert("footer-repeat", footer-repeat)
  }
  if footer-cell-args != __codly-default {
    out.insert("footer-cell-args", footer-cell-args)
  }
  if footer-transform != __codly-default {
    out.insert("footer-transform", footer-transform)
  }
  if offset != __codly-default {
    out.insert("offset", offset)
  }
  if offset-from != __codly-default {
    out.insert("offset-from", offset-from)
  }
  if range != __codly-default {
    out.insert("range", range)
  }
  if ranges != __codly-default {
    out.insert("ranges", ranges)
  }
  if smart-skip != __codly-default {
    out.insert("smart-skip", smart-skip)
  }
  if languages != __codly-default {
    out.insert("languages", languages)
  }
  if default-color != __codly-default {
    out.insert("default-color", default-color)
  }
  if radius != __codly-default {
    out.insert("radius", radius)
  }
  if inset != __codly-default {
    out.insert("inset", inset)
  }
  if fill != __codly-default {
    out.insert("fill", fill)
  }
  if zebra-fill != __codly-default {
    out.insert("zebra-fill", zebra-fill)
  }
  if stroke != __codly-default {
    out.insert("stroke", stroke)
  }
  if lang-inset != __codly-default {
    out.insert("lang-inset", lang-inset)
  }
  if lang-outset != __codly-default {
    out.insert("lang-outset", lang-outset)
  }
  if lang-radius != __codly-default {
    out.insert("lang-radius", lang-radius)
  }
  if lang-stroke != __codly-default {
    out.insert("lang-stroke", lang-stroke)
  }
  if lang-fill != __codly-default {
    out.insert("lang-fill", lang-fill)
  }
  if lang-format != __codly-default {
    out.insert("lang-format", lang-format)
  }
  if display-name != __codly-default {
    out.insert("display-name", display-name)
  }
  if display-icon != __codly-default {
    out.insert("display-icon", display-icon)
  }
  if filename != __codly-default {
    out.insert("filename", filename)
  }
  if filename-separator != __codly-default {
    out.insert("filename-separator", filename-separator)
  }
  if number-format != __codly-default {
    out.insert("number-format", number-format)
  }
  if number-align != __codly-default {
    out.insert("number-align", number-align)
  }
  if number-placement != __codly-default {
    out.insert("number-placement", number-placement)
  }
  if smart-indent != __codly-default {
    out.insert("smart-indent", smart-indent)
  }
  if skip-last-empty != __codly-default {
    out.insert("skip-last-empty", skip-last-empty)
  }
  if breakable != __codly-default {
    out.insert("breakable", breakable)
  }
  if skips != __codly-default {
    out.insert("skips", skips)
  }
  if skip-line != __codly-default {
    out.insert("skip-line", skip-line)
  }
  if skip-number != __codly-default {
    out.insert("skip-number", skip-number)
  }
  if annotations != __codly-default {
    out.insert("annotations", annotations)
  }
  if annotation-format != __codly-default {
    out.insert("annotation-format", annotation-format)
  }
  if highlighted-lines != __codly-default {
    out.insert("highlighted-lines", highlighted-lines)
  }
  if highlighted-default-color != __codly-default {
    out.insert("highlighted-default-color", highlighted-default-color)
  }
  if highlights != __codly-default {
    out.insert("highlights", highlights)
  }
  if highlight-radius != __codly-default {
    out.insert("highlight-radius", highlight-radius)
  }
  if highlight-fill != __codly-default {
    out.insert("highlight-fill", highlight-fill)
  }
  if highlight-stroke != __codly-default {
    out.insert("highlight-stroke", highlight-stroke)
  }
  if highlight-inset != __codly-default {
    out.insert("highlight-inset", highlight-inset)
  }
  if highlight-outset != __codly-default {
    out.insert("highlight-outset", highlight-outset)
  }
  if highlight-clip != __codly-default {
    out.insert("highlight-clip", highlight-clip)
  }
  if reference-by != __codly-default {
    out.insert("reference-by", reference-by)
  }
  if reference-sep != __codly-default {
    out.insert("reference-sep", reference-sep)
  }
  if reference-number-format != __codly-default {
    out.insert("reference-number-format", reference-number-format)
  }
  if aliases != __codly-default {
    out.insert("aliases", aliases)
  }

  __codly-inner(..out)
}

/// Allows setting codly setting locally.
/// Anything that happens inside the block will have the settings applied only to it.
/// The pre-existing settings will be restored after the block. This is useful
/// if you want to apply settings to a specific block only.
///
/// *Special:*
/// #local(default-color: red)[
///   ```
///   Hello, world!
///   ```
/// ]
///
/// *Normal:*
/// ```
/// Hello, world!
/// ```
///
/// See the full documentation: https://raw.githubusercontent.com/Dherse/codly/main/docs.pdf
/// 
/// - body (content): the content to be locally styled
/// - nested (bool): whether to enable nested local states
/// - enabled (bool, function): enabled
/// - header (content, none, function): header
/// - header-repeat (bool, function): header-repeat
/// - header-cell-args (array, dictionary, arguments, function): header-cell-args
/// - header-transform (function): header-transform
/// - footer (content, none, function): footer
/// - footer-repeat (bool, function): footer-repeat
/// - footer-cell-args (array, dictionary, arguments, function): footer-cell-args
/// - footer-transform (function): footer-transform
/// - offset (int, function): offset
/// - offset-from (none, label, function): offset-from
/// - range (none, array, function): range
/// - ranges (none, array, function): ranges
/// - smart-skip (bool, dictionary, function): smart-skip
/// - languages (dictionary, function): languages
/// - default-color (color, gradient, tiling, function): default-color
/// - radius (length, function): radius
/// - inset (length, dictionary, function): inset
/// - fill (none, color, gradient, tiling, function): fill
/// - zebra-fill (none, color, gradient, tiling, function): zebra-fill
/// - stroke (none, stroke, function): stroke
/// - lang-inset (length, dictionary, function): lang-inset
/// - lang-outset (dictionary, function): lang-outset
/// - lang-radius (length, function): lang-radius
/// - lang-stroke (none, stroke, function): lang-stroke
/// - lang-fill (none, color, gradient, tiling, function): lang-fill
/// - lang-format (auto, none, function): lang-format
/// - display-name (bool, function): display-name
/// - display-icon (bool, function): display-icon
/// - filename (str, content, none, function): filename
/// - filename-separator (str, content, function): filename-separator
/// - number-format (function, none): number-format
/// - number-align (alignment, function): number-align
/// - number-placement (str): number-placement
/// - smart-indent (bool): smart-indent
/// - skip-last-empty (bool, function): skip-last-empty
/// - breakable (bool): breakable
/// - skips (array, none, function): skips
/// - skip-line (content, none, function): skip-line
/// - skip-number (content, none, function): skip-number
/// - annotations (array, none, function): annotations
/// - annotation-format (none, function): annotation-format
/// - highlighted-lines (array, none, function): highlighted-lines
/// - highlighted-default-color (color, tiling, gradient, function): highlighted-default-color
/// - highlights (array, none, function): highlights
/// - highlight-radius (length, function): highlight-radius
/// - highlight-fill (function): highlight-fill
/// - highlight-stroke (stroke, function): highlight-stroke
/// - highlight-inset (length, dictionary, function): highlight-inset
/// - highlight-outset (length, dictionary, function): highlight-outset
/// - highlight-clip (bool, function): highlight-clip
/// - reference-by (str, function): reference-by
/// - reference-sep (str, content, function): reference-sep
/// - reference-number-format (function): reference-number-format
/// - aliases (dictionary): aliases
/// -> content
#let local(
  body,
  nested: false,
  enabled: __codly-default,
  header: __codly-default,
  header-repeat: __codly-default,
  header-cell-args: __codly-default,
  header-transform: __codly-default,
  footer: __codly-default,
  footer-repeat: __codly-default,
  footer-cell-args: __codly-default,
  footer-transform: __codly-default,
  offset: __codly-default,
  offset-from: __codly-default,
  range: __codly-default,
  ranges: __codly-default,
  smart-skip: __codly-default,
  languages: __codly-default,
  default-color: __codly-default,
  radius: __codly-default,
  inset: __codly-default,
  fill: __codly-default,
  zebra-fill: __codly-default,
  stroke: __codly-default,
  lang-inset: __codly-default,
  lang-outset: __codly-default,
  lang-radius: __codly-default,
  lang-stroke: __codly-default,
  lang-fill: __codly-default,
  lang-format: __codly-default,
  display-name: __codly-default,
  display-icon: __codly-default,
  filename: __codly-default,
  filename-separator: __codly-default,
  number-format: __codly-default,
  number-align: __codly-default,
  number-placement: __codly-default,
  smart-indent: __codly-default,
  skip-last-empty: __codly-default,
  breakable: __codly-default,
  skips: __codly-default,
  skip-line: __codly-default,
  skip-number: __codly-default,
  annotations: __codly-default,
  annotation-format: __codly-default,
  highlighted-lines: __codly-default,
  highlighted-default-color: __codly-default,
  highlights: __codly-default,
  highlight-radius: __codly-default,
  highlight-fill: __codly-default,
  highlight-stroke: __codly-default,
  highlight-inset: __codly-default,
  highlight-outset: __codly-default,
  highlight-clip: __codly-default,
  reference-by: __codly-default,
  reference-sep: __codly-default,
  reference-number-format: __codly-default,
  aliases: __codly-default,
) = {
  import "src/lib.typ": __local-inner
  let out = (:)
  if enabled != __codly-default {
    out.insert("enabled", enabled)
  }
  if header != __codly-default {
    out.insert("header", header)
  }
  if header-repeat != __codly-default {
    out.insert("header-repeat", header-repeat)
  }
  if header-cell-args != __codly-default {
    out.insert("header-cell-args", header-cell-args)
  }
  if header-transform != __codly-default {
    out.insert("header-transform", header-transform)
  }
  if footer != __codly-default {
    out.insert("footer", footer)
  }
  if footer-repeat != __codly-default {
    out.insert("footer-repeat", footer-repeat)
  }
  if footer-cell-args != __codly-default {
    out.insert("footer-cell-args", footer-cell-args)
  }
  if footer-transform != __codly-default {
    out.insert("footer-transform", footer-transform)
  }
  if offset != __codly-default {
    out.insert("offset", offset)
  }
  if offset-from != __codly-default {
    out.insert("offset-from", offset-from)
  }
  if range != __codly-default {
    out.insert("range", range)
  }
  if ranges != __codly-default {
    out.insert("ranges", ranges)
  }
  if smart-skip != __codly-default {
    out.insert("smart-skip", smart-skip)
  }
  if languages != __codly-default {
    out.insert("languages", languages)
  }
  if default-color != __codly-default {
    out.insert("default-color", default-color)
  }
  if radius != __codly-default {
    out.insert("radius", radius)
  }
  if inset != __codly-default {
    out.insert("inset", inset)
  }
  if fill != __codly-default {
    out.insert("fill", fill)
  }
  if zebra-fill != __codly-default {
    out.insert("zebra-fill", zebra-fill)
  }
  if stroke != __codly-default {
    out.insert("stroke", stroke)
  }
  if lang-inset != __codly-default {
    out.insert("lang-inset", lang-inset)
  }
  if lang-outset != __codly-default {
    out.insert("lang-outset", lang-outset)
  }
  if lang-radius != __codly-default {
    out.insert("lang-radius", lang-radius)
  }
  if lang-stroke != __codly-default {
    out.insert("lang-stroke", lang-stroke)
  }
  if lang-fill != __codly-default {
    out.insert("lang-fill", lang-fill)
  }
  if lang-format != __codly-default {
    out.insert("lang-format", lang-format)
  }
  if display-name != __codly-default {
    out.insert("display-name", display-name)
  }
  if display-icon != __codly-default {
    out.insert("display-icon", display-icon)
  }
  if filename != __codly-default {
    out.insert("filename", filename)
  }
  if filename-separator != __codly-default {
    out.insert("filename-separator", filename-separator)
  }
  if number-format != __codly-default {
    out.insert("number-format", number-format)
  }
  if number-align != __codly-default {
    out.insert("number-align", number-align)
  }
  if number-placement != __codly-default {
    out.insert("number-placement", number-placement)
  }
  if smart-indent != __codly-default {
    out.insert("smart-indent", smart-indent)
  }
  if skip-last-empty != __codly-default {
    out.insert("skip-last-empty", skip-last-empty)
  }
  if breakable != __codly-default {
    out.insert("breakable", breakable)
  }
  if skips != __codly-default {
    out.insert("skips", skips)
  }
  if skip-line != __codly-default {
    out.insert("skip-line", skip-line)
  }
  if skip-number != __codly-default {
    out.insert("skip-number", skip-number)
  }
  if annotations != __codly-default {
    out.insert("annotations", annotations)
  }
  if annotation-format != __codly-default {
    out.insert("annotation-format", annotation-format)
  }
  if highlighted-lines != __codly-default {
    out.insert("highlighted-lines", highlighted-lines)
  }
  if highlighted-default-color != __codly-default {
    out.insert("highlighted-default-color", highlighted-default-color)
  }
  if highlights != __codly-default {
    out.insert("highlights", highlights)
  }
  if highlight-radius != __codly-default {
    out.insert("highlight-radius", highlight-radius)
  }
  if highlight-fill != __codly-default {
    out.insert("highlight-fill", highlight-fill)
  }
  if highlight-stroke != __codly-default {
    out.insert("highlight-stroke", highlight-stroke)
  }
  if highlight-inset != __codly-default {
    out.insert("highlight-inset", highlight-inset)
  }
  if highlight-outset != __codly-default {
    out.insert("highlight-outset", highlight-outset)
  }
  if highlight-clip != __codly-default {
    out.insert("highlight-clip", highlight-clip)
  }
  if reference-by != __codly-default {
    out.insert("reference-by", reference-by)
  }
  if reference-sep != __codly-default {
    out.insert("reference-sep", reference-sep)
  }
  if reference-number-format != __codly-default {
    out.insert("reference-number-format", reference-number-format)
  }
  if aliases != __codly-default {
    out.insert("aliases", aliases)
  }

  __local-inner(body, nested: nested, ..out)
}
