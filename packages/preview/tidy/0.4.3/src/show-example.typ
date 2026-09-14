
/// Default example layouter used with @show-example. 
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
  col-spacing: 5pt
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
  
    
  
    let available-preview-width = preview-width - 2 * (preview-outer-padding + preview-inner-padding)

    let preview-size
    let scale-preview = scale-preview

    if scale-preview == auto {
      preview-size = measure(preview)
      assert(preview-size.width != 0pt, message: "The code example has a relative width. Please set `scale-preview` to a fixed ratio, e.g., `100%`")
      scale-preview = calc.min(1, available-preview-width / preview-size.width) * 100%
    } else {
      preview-size = measure(block(preview, width: available-preview-width / (scale-preview / 100%)))
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
      else { measure(arrangement(width: size.width)).height }
    arrangement(height: height)
  })
}



/// Takes a `raw` elements and both displays the code and previews the result of
/// its evaluation. 
/// 
/// The code is by default shown in the language mode `lang: typc` (typst code)
/// if no language has been specified. Code in typst markup lanugage (`lang: typ`)
/// is automatically evaluated in markup mode. 
/// 
/// Lines in the raw code that start with `>>>` are removed from the outputted code
/// but evaluated in the preview. 
///
/// Lines starting with `<<<` are displayed in the preview, but not evaluated.
#let show-example(

  /// Raw object holding the example code. 
  /// -> raw
  code, 

  /// Additional definitions to make available in the evaluation of the preview.
  /// -> dictionary
  scope: (:),

  /// Code to prepend to the snippet. This can for example be used to configure imports. 
  /// This is currently only supported in `markup` mode, see @show-example.mode. 
  /// -> str
  preamble: "",

  /// Language mode. Can be `auto`, `"markup"`, or `"code"`. 
  /// -> auto | str
  mode: auto,

  /// This parameter is only used internally. Definitions that are made available to the 
  /// entire parsed module. 
  /// -> dictionary
  inherited-scope: (:),

  /// Layout function which is passed to code, the preview and all other options, 
  /// see @show-example.options. 
  /// -> function
  layout: default-layout-example,

  /// Additional options to pass to the layout function. 
  /// -> any
  ..options

) = {
  let displayed-code = code
    .text
    .split("\n")
    .filter(x => not x.starts-with(">>>"))
    .map(x => x.trim("<<<", at: start))
    .join("\n")
  let executed-code = code
    .text
    .split("\n")
    .filter(x => not x.starts-with("<<<"))
    .map(x => x.trim(">>>", at: start))
    .join("\n")
  
  let lang = if code.has("lang") { code.lang } else { auto }
  if mode == auto {
    if lang == "typ" { mode = "markup" }
    else if lang == "typc" { mode = "code" }
    else if lang == "typm" { mode = "math" }
    else if lang == auto { mode = "markup" }
  }
  if lang == auto {
    if mode == "markup" { lang = "typ" }
    if mode == "code" { lang = "typc" }
    if mode == "math" { lang = "typm" }
  }
  if mode == "code" {
    preamble = ""
  }
  assert(lang in ("typ", "typc", "typm"), message: "Previewing code only supports the languages \"typ\", \"typc\", and \"typm\"")
  
  layout(
    raw(displayed-code, lang: lang, block: true),
    [#eval(preamble + executed-code, mode: mode, scope: scope + inherited-scope)],
    ..options
  )
}



/// Adds the two languages `example` and `examplec` to `raw` that can be used
/// to render code examples side-by-side with an automatic preview. 
/// 
/// This function is intended to be used in a show rule
/// ```typ
/// #show: render-example
/// ```
#let render-examples(
  /// Body to apply the show rule to. 
  /// -> any
  body,

  /// Scope
  /// -> dictionary
  scope: (:), 

  /// Layout function which is passed the code, the preview and all other options, 
  /// see @show-example.options. 
  /// -> function
  layout: default-layout-example
) = {
  show raw.where(lang: "example"): it => {
    set text(4em / 3)

    show-example(
      raw(it.text, block: true, lang: "typ"), 
      mode: "markup", 
      scope: scope, 
      layout: layout,
    )
  }
  show raw.where(lang: "examplec"): it => {
    set text(4em / 3)

    show-example(
      raw(it.text, block: true, lang: "typc"), 
      mode: "code", 
      scope: scope,
      layout: layout,
      ..args
    )
  }
  body
}
