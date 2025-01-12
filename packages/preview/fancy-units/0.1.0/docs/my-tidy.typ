#import "@preview/tidy:0.4.0"

#let show-tag(tag) = text(
  tag,
  style: "italic",
  size: 0.8em,
)

#let show-component(component, padding: 0pt) = {
  h(padding)
  box(outset: 2pt, fill: luma(75%), radius: 2pt, raw(component, lang: none))
  h(padding)
}

// Show possible parameter values in a table
// 
// The design is taken from the Typst documentation. As an example see
// https://typst.app/docs/reference/visualize/gradient/#definitions-linear-relative
// 
// - values (dictionary): Each value must have the keys "type" and "details"
// -> (content)
#let show-parameter-values(values) = {
  let header = table.header([*Variant*], [*Details*])
  let items = ()
  for (name, info) in values {
    if info.type == "string" { items.push(raw("\"" + name + "\"", lang: "typc")) } else { items.push(raw(name, lang: "typc")) }
    items.push(info.details)
  }

  table(
    columns: 2,
    stroke: none,
    header,
    table.hline(),
    ..items
  )
}
  
// Show a parameter in a block
// 
// Based on the function with the same name from the package https://typst.app/universe/package/tidy.
// 
// - name (string): The name of the parameter
// - info (dictionary): The metadata of the parameter, can include "types", "tags", "description" and "default"
// - style-args (dictionary)
// -> (content)
#let show-parameter-block(name, info, style-args) = block(
  inset: 8pt, fill: luma(234), width: 100%, radius: 2pt,
  breakable: style-args.break-param-descriptions,
  [
    #box(heading(numbering: none, level: style-args.first-heading-level + 2, name))
    #h(1.2em)
    #info.at("types", default: ()).map(x => (style-args.style.show-type)(x, style-args: style-args)).join([ #text("or", size:.6em) ])
    #h(0.5em)
    #info.at("tags", default: ()).map(x => (style-args.style.show-tag)(x)).join(h(0.5em))

    #info.at("description", default: [])
    #if "values" in info.keys() [ #(style-args.style.show-parameter-values)(info.values) ]
    #if "default" in info.keys() [
      #parbreak() #style-args.local-names.default: #raw(lang: "typc", info.default)
    ]
  ]
)

// Show a function and its parameters
// 
// Based on the function with the same name from the package https://typst.app/universe/package/tidy.
// 
// - fn (dictionary): The function with the parameters in the metadata
// - style-args (dictionary)
// -> (content)
#let show-function(fn, style-args) = {
  block(breakable: style-args.break-param-descriptions, {
    (style-args.style.show-parameter-list)(fn, style-args: style-args)
  })

  for (name, info) in fn.args {
    (style-args.style.show-parameter-block)(name, info, style-args)
  }

  // v(4.8em, weak: true)
}


/// Takes given code and both shows it and previews the result of its evaluation. 
/// 
/// The code is by default shown in the language mode `lang: typc` (typst code)
/// if no language has been specified. Code in typst markup lanugage (`lang: typ`)
/// is automatically evaluated in markup mode. 
/// 
/// - code (raw): Raw object holding the example code. 
/// - scope (dictionary): Additional definitions to make available for the evaluated 
///          example code.
/// - dir (direction): Direction for laying out the code and preview boxes. 
/// - preamble (str): Code to prepend to the snippet. This can for example be used to configure imports. 
/// - ratio (int): Configures the ratio of the widths of the code and preview boxes. 
/// - scale-preview (auto, ratio): How much to rescale the preview. If set to auto, the the preview is scaled to fit the box. 
/// - inherited-scope (dictionary): Definitions that are made available to the entire parsed
///          module. This parameter is only used internally.
/// - code-block (function): The code is passed to this function. Use this to customize how the code is shown. 
/// - preview-block (function): The preview is passed to this function. Use this to customize how the preview is shown. 
/// - col-spacing (length): Spacing between the code and preview boxes. 
#let show-example-blocks(
  codes,
  scope: (:),
  dir: ltr,
  preamble: "",
  ratio: 1,
  scale-preview: auto,
  mode: auto,
  inherited-scope: (:),
  code-block: block,
  preview-block: block,
  col-spacing: 5pt,
  ..options
) = {
  codes = codes.map(code => {
    let lang = if code.has("lang") { code.lang } else if mode == "markup" { "typ" } else { "typc" }
    if code.has("block") and code.block == false { return raw(code.text, lang: lang, block: true) }
    return code
  })
  
  let preview = codes.map(code => {
    let mode = if mode == auto { if code.lang == "type" { "markup" } else { "code" } } else { auto }
    // if mode == auto {
    //   if code.lang == "typ" { mode = "markup" }
    //   else { mode = "code" }
    // }
    return eval(preamble + code.text, mode: mode, scope: scope + inherited-scope)
  }).join("\n")
  
  // let code = block[#codes.join("\n")]
  let code = codes.join()
  let abc = code
  
  let preview-outer-padding = 5pt
  let preview-inner-padding = 5pt

  layout(size => style(styles => {
    let code-width
    let preview-width
    
    if dir.axis() == "vertical" {
      code-width = size.width
      preview-width = size.width
    } else {
      code-width = ratio / (ratio + 1) * size.width - 0.5 * col-spacing
      preview-width = size.width - code-width - col-spacing
    }
  
    let available-preview-width = preview-width - 2 * (preview-outer-padding + preview-inner-padding)

    let preview-size
    let scale-preview = scale-preview

    if scale-preview == auto {
      preview-size = measure(preview, styles)
      assert(preview-size.width != 0pt, message: "The code example has a relative width. Please set `scale-preview` to a fixed ratio, e.g., `100%`")
      scale-preview = calc.min(1, available-preview-width / preview-size.width) * 100%
    } else {
      preview-size = measure(block(preview, width: available-preview-width / (scale-preview / 100%)), styles)
    }

    set par(hanging-indent: 0pt) // this messes up some stuff in case someone sets it


    // We first measure this thing (code + preview) to find out which of the two has
    // the larger height. Then we can just set the height for both boxes. 
    let arrangement(width: 100%, height: auto) = block(width: width, inset: 0pt, stack(dir: dir, spacing: col-spacing,
      code-block(
        width: code-width, 
        height: height,
        inset: 5pt, 
        {
          set text(size: .9em)
          set raw(block: true)
          code
        }
      ),
      preview-block(
        height: height, width: preview-width, 
        inset: preview-outer-padding,
        box(
          width: 100%, 
          height: if height == auto {auto} else {height - 2*preview-outer-padding}, 
          fill: white,
          inset: preview-inner-padding,
          box(
            inset: 0pt,
            width: preview-size.width * (scale-preview / 100%), 
            height: preview-size.height * (scale-preview / 100%), 
            place(scale(
              scale-preview, 
              origin: top + left, 
              block(preview, height: preview-size.height, width: preview-size.width)
            ))
          )
        )
      )
    ))
    let height = if dir.axis() == "vertical" { auto } 
      else { measure(arrangement(width: size.width), styles).height }
    arrangement(height: height)
  })
  )
}




// Default style-args
// 
// A simplified version of the style-args in the package https://typst.app/universe/package/tidy.
#let style-args = (
  style: (
    show-type: tidy.styles.default.show-type,
    show-tag: show-tag,
    show-function: show-function,
    show-parameter-list: tidy.styles.default.show-parameter-list,
    show-parameter-block: show-parameter-block,
    show-parameter-values: show-parameter-values,
  ),
  colors: tidy.styles.default.colors,
  omit-private-parameters: true,
  break-param-descriptions: false,
  enable-cross-references: false,
  first-heading-level: 1,
  local-names: (parameters: [Parameters], default: [Default]),
)


// Render examples in a table
#let show-example-table(columns: (), scope: (:), ..args) = {
  let examples = args.pos()
  let column-raw = examples.map(example => raw(example, lang: "typc"))
  let columns-formatted = if columns.len() > 0 {
    columns.map(column => {
      return examples.map(example => {
        let split = example.position("[")
        let params = column.pairs().map(pair => pair.at(0) + ": \"" + pair.at(1) + "\"").join(", ")
        let func = example.slice(0, split) + "(" + params + ")" + example.slice(split, none)
        return eval(func, scope: scope)
      })
    })
  } else {
    (examples.map(example => eval(example, scope: scope)),)
  }

  let unique-options = (:)
  for key in columns.map(column => column.keys()).flatten() { unique-options.insert(key, none) }
  let header = unique-options.keys().map(key => {
    return (
      raw(key + ":", lang: "typc"),
      ..columns.map(column => {
        let value = column.at(key, default: none)
        if value == none { return [] }
        return raw("\"" + value + "\"", lang: "typc")
      })
    )
  }).flatten()

  let children = ()
  if header.len() > 0 { children.push(table.header(..header)) }
  children += column-raw.zip(..columns-formatted).flatten()

  table(
    columns: 1 + columns-formatted.len(),
    ..children
  )
}