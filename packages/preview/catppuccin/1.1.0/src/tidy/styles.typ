#import "../flavors.typ": flavors, get-or-validate-flavor
#import "../utils.typ": dict-at
#import "@preview/tidy:0.4.3": utilities
#import utilities: *

#import "@preview/tidy:0.4.3" as tidy: show-example as example, styles

/// A style that can be used to generate documentation using #link("https://typst.app/universe/package/tidy")[Tidy]
/// for the Catppuccino theme. The returned dictionary is a tidy styles dictionary with some additional keys,
/// such as `ctp-palette` whose value is the associated with the `colors` field of #show-type("flavor").
///
/// -> dictionary
#let get-tidy-colors(
  /// The flavor to use -> string | flavor
  flavor: flavors.mocha,
) = {
  let palette = get-or-validate-flavor(flavor).colors

  let function-name-color = palette.blue.rgb
  let rainbow-map = (
    (palette.sky.rgb, 0%),
    (palette.green.rgb, 33%),
    (palette.yellow.rgb, 66%),
    (palette.red.rgb, 100%),
  )

  let gradient-for-color-types = gradient.linear(angle: 7deg, ..rainbow-map)
  let default-type-color = palette.overlay2.rgb

  let colors = (
    "ctp-palette": palette,
    "flavor": palette.pink.rgb,
    "default": default-type-color,
    "content": palette.teal.rgb,
    "string": palette.green.rgb,
    "str": palette.green.rgb,
    "none": palette.mauve.rgb,
    "auto": palette.mauve.rgb,
    "boolean": palette.yellow.rgb,
    "integer": palette.peach.rgb,
    "int": palette.peach.rgb,
    "float": palette.peach.rgb,
    "ratio": palette.peach.rgb,
    "length": palette.peach.rgb,
    "angle": palette.peach.rgb,
    "relative length": palette.peach.rgb,
    "relative": palette.peach.rgb,
    "fraction": palette.peach.rgb,
    "symbol": palette.red.rgb,
    "array": palette.yellow.rgb,
    "dictionary": palette.yellow.rgb,
    "arguments": palette.maroon.rgb,
    "selector": palette.red.rgb,
    "module": palette.yellow.rgb,
    "stroke": default-type-color,
    "version": palette.blue.rgb,
    "function": palette.blue.rgb,
    "color": gradient-for-color-types,
    "gradient": gradient-for-color-types,
    "signature-func-name": palette.blue.rgb,
  )

  colors
}

#let show-outline(module-doc, style-args: (:)) = {
  let prefix = module-doc.label-prefix
  let gen-entry(name) = {
    if (
      "enable-cross-references" in style-args
        and style-args.enable-cross-references
    ) {
      link(label(prefix + name), name)
    } else {
      name
    }
  }
  if module-doc.functions.len() > 0 {
    list(..module-doc.functions.map(fn => gen-entry(fn.name + "()")))
  }

  if module-doc.variables.len() > 0 {
    text(get-local-name("variables", style-args: style-args), weight: "bold")
    list(..module-doc.variables.map(var => gen-entry(var.name)))
  }
}

#let show-type(type, style-args: (:)) = {
  h(2pt)
  let clr = style-args.colors.at(type, default: style-args.colors.at("default"))
  let text-fill = dict-at(style-args.colors, "ctp-palette", "base", "rgb")
  box(outset: 2pt, fill: clr, radius: 2pt, text(fill: text-fill, raw(
    type,
    lang: none,
  )))
  h(2pt)
}

#let show-parameter-list(fn, style-args: (:)) = {
  pad(x: 10pt, {
    set text(font: "DejaVu Sans Mono", size: 0.85em, weight: 340)
    text(fn.name, fill: style-args.colors.at("signature-func-name"))
    "("
    let inline-args = fn.args.len() < 2
    if not inline-args { "\n  " }
    let items = ()
    let args = fn.args
    for (name, info) in fn.args {
      if style-args.omit-private-parameters and name.starts-with("_") {
        continue
      }
      let types
      if "types" in info {
        types = (
          ": "
            + info
              .types
              .map(x => show-type(x, style-args: style-args))
              .join(" ")
        )
      }
      if (
        style-args.enable-cross-references
          and not (
            info.at("description", default: "") == ""
              and style-args.omit-empty-param-descriptions
          )
      ) {
        name = link(
          label(style-args.label-prefix + fn.name + "." + name.trim(".")),
          name,
        )
      }
      items.push(name + types)
    }
    items.join(if inline-args { ", " } else { ",\n  " })
    if not inline-args { "\n" } + ")"
    if "return-types" in fn and fn.return-types != none {
      " -> "
      fn.return-types.map(x => show-type(x, style-args: style-args)).join(" ")
    }
  })
}

// Create a parameter description block, containing name, type, description and optionally the default value.
#let show-parameter-block(
  function-name: none,
  name,
  types,
  content,
  style-args,
  show-default: false,
  default: none,
) = block(
  inset: 10pt,
  fill: dict-at(style-args.colors, "ctp-palette", "surface0", "rgb"),
  width: 100%,
  breakable: style-args.break-param-descriptions,
  [
    #box(heading(level: style-args.first-heading-level + 3, name))
    #if function-name != none and style-args.enable-cross-references {
      label(function-name + "." + name.trim("."))
    }
    #h(1.2em)
    #(
      types
        .map(x => (style-args.style.show-type)(x, style-args: style-args))
        .join([ #text("or", size: .6em) ])
    )

    #content
    #if show-default [
      #parbreak()
      #get-local-name("default", style-args: style-args): #raw(lang: "typc", default)
    ]
  ],
)

#let show-function(
  fn,
  style-args,
) = {
  if style-args.colors == auto { style-args.colors = colors }

  [
    #heading(fn.name, level: style-args.first-heading-level + 1)
    #if style-args.enable-cross-references {
      label(style-args.label-prefix + fn.name + "()")
    }
  ]

  eval-docstring(fn.description, style-args)

  block(breakable: style-args.break-param-descriptions, {
    heading(
      get-local-name("parameters", style-args: style-args),
      level: style-args.first-heading-level + 2,
    )
    (style-args.style.show-parameter-list)(fn, style-args: style-args)
  })

  for (name, info) in fn.args {
    if style-args.omit-private-parameters and name.starts-with("_") {
      continue
    }
    let types = info.at("types", default: ())
    let description = info.at("description", default: "")
    if description == "" and style-args.omit-empty-param-descriptions {
      continue
    }
    (style-args.style.show-parameter-block)(
      name,
      types,
      eval-docstring(description, style-args),
      style-args,
      show-default: "default" in info,
      default: info.at("default", default: none),
      function-name: style-args.label-prefix + fn.name,
    )
  }
  v(4.8em, weak: true)
}

#let show-variable(
  var,
  style-args,
) = {
  if style-args.colors == auto { style-args.colors = colors }
  let type = if "type" not in var { none } else {
    show-type(var.type, style-args: style-args)
  }

  stack(
    dir: ltr,
    spacing: 1.2em,
    if style-args.enable-cross-references [
      #heading(var.name, level: style-args.first-heading-level + 1)
      #label(style-args.label-prefix + var.name)
    ] else [
      #heading(var.name, level: style-args.first-heading-level + 1)
    ],
    type,
  )

  eval-docstring(var.description, style-args)
  v(4.8em, weak: true)
}

#let show-reference(label, name, style-args: none) = {
  link(label, raw(name, lang: none))
}

/// This function is temporarily used as the default layouter
/// until the resolution of #link("https://github.com/Mc-Zen/tidy/issues/27", "this issue").
#let default-layout-example(
  /// Code `raw` element to display.
  /// -> raw
  code,
  /// Rendered preview.
  /// -> content
  preview,
  /// Direction for laying out the code and preview boxes.
  /// -> direction
  dir: ltr,
  /// Configures the ratio of the widths of the code and preview boxes.
  /// -> int
  ratio: 1,
  /// How much to rescale the preview. If set to auto, the the preview is scaled to fit the box.
  /// -> auto | ratio
  scale-preview: auto,
  /// The code is passed to this function. Use this to customize how the code is shown.
  /// -> function
  code-block: block,
  /// The preview is passed to this function. Use this to customize how the preview is shown.
  /// -> function
  preview-block: block,
  /// Spacing between the code and preview boxes.
  /// -> length
  col-spacing: 5pt,
) = {
  let preview-outer-padding = 5pt
  let preview-inner-padding = 5pt

  layout(size => context {
    let code-width
    let preview-width

    if dir.axis() == "vertical" {
      code-width = size.width
      preview-width = size.width
    } else {
      code-width = ratio / (ratio + 1) * size.width - 0.5 * col-spacing
      preview-width = size.width - code-width - col-spacing
    }

    let available-preview-width = (
      preview-width - 2 * (preview-outer-padding + preview-inner-padding)
    )

    let preview-size
    let scale-preview = scale-preview

    if scale-preview == auto {
      preview-size = measure(preview)
      assert(
        preview-size.width != 0pt,
        message: "The code example has a relative width. Please set `scale-preview` to a fixed ratio, e.g., `100%`",
      )
      scale-preview = (
        calc.min(1, available-preview-width / preview-size.width) * 100%
      )
    } else {
      preview-size = measure(block(
        preview,
        width: available-preview-width / (scale-preview / 100%),
      ))
    }

    set par(
      hanging-indent: 0pt,
    ) // this messes up some stuff in case someone sets it

    // We first measure this thing (code + preview) to find out which of the two has
    // the larger height. Then we can just set the height for both boxes.
    let arrangement(width: 100%, height: auto) = block(
      width: width,
      inset: 0pt,
      stack(
        dir: dir,
        spacing: col-spacing,
        code-block(width: code-width, height: height, inset: 5pt, {
          set text(size: .9em)
          set raw(block: true)
          code
        }),
        preview-block(
          height: height,
          width: preview-width,
          inset: preview-outer-padding,
          box(
            width: 100%,
            height: if height == auto { auto } else {
              height - 2 * preview-outer-padding
            },
            // fill: white,
            inset: preview-inner-padding,
            box(
              inset: 0pt,
              width: preview-size.width * (scale-preview / 100%),
              height: preview-size.height * (scale-preview / 100%),
              place(scale(scale-preview, origin: top + left, block(
                preview,
                height: preview-size.height,
                width: preview-size.width,
              ))),
            ),
          ),
        ),
      ),
    )
    let height = if dir.axis() == "vertical" { auto } else {
      measure(arrangement(width: size.width)).height
    }
    arrangement(height: height)
  })
}

#let show-example(
  ..args,
) = {
  example.show-example(..args, layout: default-layout-example.with(
    code-block: (..args) => block(..args),
    preview-block: (..args) => block(..args),
    col-spacing: 5mm,
  ))
}

/// Create a style dictionary to be used with Tidy.
///
/// The returned dictionary contains the following keys:
/// - `colors`: The color palette for the style.
/// - `show-outline`: A function to show the outline of a module.
/// - `show-type`: A function to show the type of a variable.
/// - `show-parameter-list`: A function to show the parameter list of a function.
/// - `show-parameter-block`: A function to show a parameter block.
/// - `show-function`: A function to show a function.
/// - `show-variable`: A function to show a variable.
/// - `show-reference`: A function to show a reference.
/// - `show-example`: A function to show an example.
///
/// -> dictionary
#let ctp-tidy-style(
  /// The Catppuccin flavor to use for the style -> flavor
  flavor: flavors.mocha,
) = {
  return (
    colors: get-tidy-colors(flavor: flavor),
    show-outline: show-outline,
    show-type: show-type,
    show-parameter-list: show-parameter-list,
    show-parameter-block: show-parameter-block,
    show-function: show-function,
    show-variable: show-variable,
    show-reference: show-reference,
    show-example: show-example,
  )
}
