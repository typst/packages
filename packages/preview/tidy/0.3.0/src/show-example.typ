


/// Takes given code and both shows it and previews the result of its evaluation. 
/// 
/// The code is by default shown in the language mode `lang: typc` (typst code)
/// if no language has been specified. Code in typst markup lanugage (`lang: typ`)
/// is automatically evaluated in markup mode. 
/// 
/// - code (raw): Raw object holding the example code. 
/// - scope (dictionary): Additional definitions to make available for the evaluated 
///          example code.
/// - scale-preview (auto, ratio): How much to rescale the preview. If set to auto, the the preview is scaled to fit the box. 
/// - inherited-scope (dictionary): Definitions that are made available to the entire parsed
///          module. This parameter is only used internally.
#let show-example(
  code, 
  dir: ltr,
  scope: (:),
  preamble: "",
  ratio: 1,
  scale-preview: auto,
  mode: "code",
  inherited-scope: (:),
  code-block: block,
  preview-block: block,
  col-spacing: 5pt,
  ..options
) = {
  set raw(block: true)
  let lang = if code.has("lang") { code.lang } else { "typc" }
  if lang == "typ" {
    mode = "markup"
  }
  if mode == "markup" and not code.has("lang") { 
    lang = "typ" 
  }
  set raw(lang: lang)
  if code.has("block") and code.block == false {
    code = raw(code.text, lang: lang, block: true)
  }
        
  let preview = [#eval(preamble + code.text, mode: mode, scope: scope + inherited-scope)]
  
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