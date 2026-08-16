#import "@preview/based:0.2.0": base64
#import "@preview/percencode:0.1.0": percent-decode
#import "@preview/cmarker:0.1.10"
#import "@preview/mitex:0.2.7"

#import "util.typ": handle
#import "reading/rich-object.typ"
#import "reading/output.typ": outputs, all-output-types
#import "reading/cell.typ": cells
#import "header-pattern.typ"
#import "ansi.typ"
#import "latex.typ"

// A handler is a function called to process a value such as a cell's source,
// a cell output such as a PNG image, or even a whole cell.
// Each handler is associated with a "MIME type", which is really an arbitrary
// string used to identify the kind of value being processed: Rich items,
// which can be available in multiple formats, are rendered by calling the
// handler on the selected format. In this case the type is a real MIME type,
// for example "image/png". Other handlers use dummy MIME types such as
// "code-cell" (without slash character).
//
// Handlers are always called with a positional argument for the data to
// render, and a 'ctx' keyword argument for contextual data. Some handlers also
// take additional arguments:
// 
// - Image handlers must accept an 'alt' argument.
// 
// - Math handlers must accept a 'block' argument (true for block equations).
//
// - The "source-code-generic" handler (used by the default raw cell and
//   code input handlers) takes a 'lang' argument.
//
// - The "attachment" handler gets 'metadata', 'type' and
//   'subhandler-args' arguments.
//
// - The "placeholder-function-call" handler accepts a 'block' argument
//   (defaulting to auto) to specify if the placeholder should be inline or
//   block.
//
// When defining a handler, the user can choose to add an '..args' sink if
// they don't care about extra arguments, or omit this sink if they prefer to
// see an error when an unknown argument is passed.
//
// To call a handler, use the 'handle' function from common.typ.

// Handler for Typst source code
#let text-vnd-typst(data, ctx: none, ..args) = eval(data, mode: "markup")

// Generic image handler that supports image path and image bytes, used by
// several others to actually render the image.
#let image-generic(data, ctx: none, ..args) = {
  if type(data) == str {
    data = handle(data, mime: "path", ctx: ctx, ..args)
  }
  std.image(data, ..args)
}

// Handler for images in Markdown. Such images can be specified by a
// path of the form "attachment:name" where 'name' refers to a cell attachment.
// As all image handlers, this handler can receive extra arguments such as
// 'alt' that must be forwarded to the subhandler.
#let image-markdown(path, ctx: none, ..args) = {
  let (handlers, cell) = ctx
  if path.starts-with("attachment:") {
    let name = path.trim("attachment:", at: start)
    let attachments = cell.at("attachments", default: (:))
    if name in attachments {
      // Get data dict (keyed by MIME type) for this attachment
      let data = attachments.at(name)
      handle(
        data,
        mime: "attachment",
        ctx: ctx,
        metadata: (path: path),
        subhandler-args: args,
      )
    } else {
      panic("cell attachment " + name + " not found")
    }
  } else if path.starts-with("data:") {
    // This can happen for images in HTML in Markdown
    handle(path, mime: "image-data-url", ctx: ctx, ..args)
  } else {
    handle(path, mime: "image-generic", ctx: ctx, ..args)
  }
}

// Handler for images encoded as a 'data:' URL
#let image-data-url(url, ctx: none, ..args) = {
  // We assume there are no MIME parameter values with literal commas
  let comma = url.position(",")
  if comma == none { panic("invalid data URL") }
  let media-type = url.slice(0, comma).trim()
  let data = url.slice(comma + 1).trim()
  if media-type.ends-with(";base64") {
    handle(data, mime: "image-base64", ctx: ctx, ..args)
  } else {
    handle(percent-decode(data), mime: "image-text", ctx: ctx,  ..args)
  }
}

// Handler for base64-encoded images
#let image-base64(data, ctx: none, ..args) = {
  let data-bytes = base64.decode(data.replace("\n", ""))
  handle(data-bytes, mime: "image-generic", ctx: ctx, ..args)
}

// Handler for text-encoded images, for example svg+xml
#let image-text(data, ctx: none, ..args) = {
  handle(bytes(data), mime: "image-generic", ctx: ctx, ..args)
}

// Helper function to guess the SVG data encoding based on the first characters
// in the given data string.
#let _encoded-svg-mime(data) = {
  // base64 encoded version of:     "<?xml "                        "<sv"
  if data.starts-with("PD94bWwg") or data.starts-with("PHN2") {
    return "image-base64"
  } else if data.starts-with("<?xml ") or data.starts-with("<svg") {
    return "image-text"
  }
  panic("unrecognized svg+xml data")
}

// Smart svg+xml handler that handles both text and base64 data
#let image-svg-xml(data, ctx: none, ..args) = {
  let mime = _encoded-svg-mime(data)
  handle(data, mime: mime, ctx: ctx, ..args)
}

// Handler for Markdown markup to be rendered inline, without block wrapper.
// (This is useful for Markdown that must be included seamlessly in the flow
// of the document, so that e.g. spacing around headings can be configured
// without interference from a container block, see
// https://github.com/sijow/callisto/issues/13 )
#let markdown-generic(data, ctx: none, ..args) = cmarker.render(
  data,
  math: handle.with(mime: "math-markdown", ctx: ctx),
  scope: (
    // Note that for images specified by disk path, the default image-generic
    // handler uses the path handler to resolve the path. Users must define
    // that handler to have working path resolution (unfortunately this
    // probably won't change when Typst gets a 'path' type as that won't give
    // access to other files in the notebook directory, but the path type will
    // make it easier to define the path handler).
    image: handle.with(mime: "image-markdown", ctx: ctx),
  ),
  heading-labels: "jupyter",
  ..ctx.cmarker,
  ..args,
)

// Handler for Markdown outputs
#let text-markdown(data, ctx: none, ..args) = {
  block(handle(data, mime: "markdown-generic", ctx: ctx, ..args))
}

// Handler for HTML outputs
#let text-html(data, ctx: none, ..args) = {
  block(handle(data, mime: "markdown-generic", ctx: ctx, ..args))
}

// Handler for LaTeX markup
#let text-latex(data, ctx: none, ..args) = mitex.mitext(data, ..args)

// Handler for text to render as console output, in particular text that can
// include ANSI escape sequences for colors, etc. and box-drawing characters.
#let text-console-block(data, ctx: none, ..args) = {
  let (render, ..render-args) = ctx.console-text

  if render == auto {
    render = data.contains(ansi.escape-regex)
  }

  if render in (false, "strip") {
    if render == "strip" {
      data = ansi.strip(data)
    }
    return raw(block: true, lang: "txt", data)
  }

  // Do render
  
  // Give precedence to render-args: it's a user value that might be used to
  // override arguments preconfigured by the theme
  ansi.console-block(data, ..args, ..render-args)
}

// Handler for simple text
#let text-plain(data, ctx: none, ..args) = data

// Handler for JSON data
#let application-json(data, ctx: none, ..args) = data

// Handler for LaTeX equations
#let math-generic(data, ctx: none, ..args) = mitex.mitex(data, ..args)

// Handler for LaTeX equations in Markdown cells.
#let math-markdown(data, ctx: none, ..args) = {
  let txt = data
  // If the preamble is set, we must use it and remove definitions from the
  // math item itself to avoid duplicates.
  if ctx.latex-preamble != none {
    // Remove definitions from this item's body and prepend all defs
    txt = ctx.latex-preamble + txt.replace(latex.definition-regex(), "")
  }
  // Render equation with the latex math handler
  return handle(txt, mime: "math-generic", ctx: ctx, ..args)
}

// Handler for attachments, where data is a dict keyed by MIME types, and
// metadata can be a simple metadata dict or a dict with metadata dicts keyed
// by MIME types. If given, the subhandler args will be forwarded to
// the subhandler called by this handler to handle a particular format.
#let attachment(
  data,
  ctx: none,
  metadata: none,
  subhandler-args: none,
  ..args,
) = {
  // Make item
  let item = (data: data, metadata: metadata)
  // Update context item desc
  ctx.item-desc = (index: none, type: "attachment")
  // Get dict with normalized data for this item
  let preprocessed = rich-object.preprocess(item, ctx: ctx)
  if preprocessed == none { return none }
  return rich-object.process(
    preprocessed,
    ctx: ctx,
    handler-args: subhandler-args,
  )
}

// Default handler for path: raise an error
#let path-handler(cell, ctx: none, ..args) = {
  panic("\"path\" handler undefined. You can define it with callisto.config(..., handlers: (path: (x, ..args) => path(x)))")
}

// Generic stream handler
#let stream-generic(data, ctx: none, ..args) = data

// Handler for stream output items
#let stream(item, ctx: none, ..args) = {
  let mime = (
    "stdout": "stream-stdout",
    "stderr": "stream-stderr",
    "all": "stream-merged",
  ).at(item.name)
  handle(item.text, mime: mime, ctx: ctx, ..args)
}

// Handler for error output items
#let error(item, ctx: none, ..args) = item.message

// Handler for rich output items (display and result)
#let rich-output-generic(data, ctx: none, ..args) = {
  rich-object.process(data, ctx: ctx, ..args)
}

// Handler for any type of code cell output
#let output(data, ctx: none, ..args) = {
  handle(data, mime: ctx.item-desc.type, ctx: ctx, ..args)
}

// Handler for source code
#let source-code-generic(txt, ctx: none, lang: none, ..args) = {
  // Ensure the source has at least one (possibly empty) line
  // (without this the raw block looks weird for empty cells)
  if txt == "" {
    txt = "\n"
  }
  raw(txt, lang: lang, block: true)
}

// Handler for raw cell
#let raw-cell(cell, ctx: none, ..args) = {
  handle(
    cell.source,
    mime: "source-code-generic",
    ctx: ctx,
    lang: ctx.raw-lang,
    ..args,
  )
}

// Handler for Markdown cell
#let markdown-cell(cell, ctx: none, ..args) = {
  parbreak()
  handle(cell.source, mime: "markdown-generic", ctx: ctx, ..args)
  parbreak()
}

// Handler for code cell input
#let code-cell-input(cell, ctx: none, ..args) = {
  handle(
    cell.source,
    mime: "source-code-generic",
    ctx: ctx,
    lang: ctx.lang,
    ..args,
  )
}

// Handler for code cell output
#let code-cell-output(cell, ctx: none, ..args) = {
  // Get outputs with user config, but override 'result' to get just the values
  outputs(cell, ..ctx.cfg, result: "value").join()
}

// Handler for code cell
#let code-cell(cell, ctx: none, ..args) = {
  if ctx.input {
    handle(cell, mime: "code-cell-input", ctx: ctx, ..args)
  }
  if ctx.output {
    handle(cell, mime: "code-cell-output", ctx: ctx, ..args)
  }
}

// Handler for cells
#let cell(cell, ctx: none, ..args) = {
  // Delegate to cell-type-specific handler
  handle(cell, mime: cell.cell_type + "-cell", ctx: ctx, ..args)
}

// Check if the cell spec is a raw element
#let _is-raw-spec(spec) = type(spec) == content and spec.func() == raw

// Truncate given string to one line and ad most the given length,
// with an ellipsis at the end to indicate truncation if applicable.
#let _short-string(txt, max-length) = {
  let truncated = false

  // Keep only first line
  let lines = txt.split("\n")
  if lines.len() > 1 {
    txt = lines.first()
    truncated = true
  }

  // Cut line if too long
  let clusters = txt.clusters()
  if clusters.len() >= max-length {
    // Reserve 1 character for ellipsis
    txt = clusters.slice(0, count: max-length - 1).join()
    truncated = true
  }

  // Add ellipsis if truncated
  if truncated {
    txt += "…"
  }

  return txt
}

// Return a string that summarizes the given cell spec
#let _cell-spec-summary(spec) = {
  if _is-raw-spec(spec) {
    return "`" + _short-string(spec.text.trim(), 48) + "`"
  }
  if type(spec) == dictionary {
    return "`" + _short-string(spec.source, 48) + "`"
  }
  return _short-string(repr(spec), 50)
}

// Return true if the placeholder is likely for block content
#let _is-placeholder-likely-block(ctx: none) = {
  if _is-raw-spec(ctx.cell-spec) {
    return ctx.cell-spec.block
  }
  // See if only one cell matches the cell-spec: if yes and that cell was
  // exported, use the block metadata
  let cs = cells(ctx.cell-spec, ..ctx.cfg)
  if cs.len() == 1 and "export" in cs.first().metadata.callisto {
    return cs.first().metadata.callisto.export.block
  }
  return true
}

// Return placeholder for rendered code cell input using the raw spec
#let _placeholder-input-from-raw-spec(ctx: none, ..args) = {
  let source = ctx.cell-spec.text
  if not ctx.keep-cell-header {
    // Remove cell header
    let pattern = ctx.cell-header-pattern
    source = header-pattern.parse-text(source, pattern: pattern).code
  }
  return handle(
    source,
    mime: "placeholder-input-from-source",
    ctx: ctx,
    ..args,
  )
}

// Handler that shows the given block in generic placeholder style
#let placeholder-block-generic(data, ctx: none, ..args) = block(
  stroke: (dash: "dashed", paint: black, thickness: 1pt),
  inset: 1em,
  data,
)

// Handler that shows the given inline content in generic placeholder style
#let placeholder-inline-generic(data, ctx: none, ..args) = box(
  stroke: (dash: "dashed", paint: black, thickness: 1pt),
  inset: (x: 0.5em),
  outset: (y: 0.5em),
  data,
)

// Placeholder that shows `func(spec)` where func is given as argument and
// spec is a summary of a the cell specification.
#let placeholder-function-call(func, block: auto, ctx: none, ..args) = {
  if block == auto {
    block = _is-placeholder-likely-block(ctx: ctx)
  }
  let txt = func + "(" + _cell-spec-summary(ctx.cell-spec) + ")"
  let elem = raw(txt, block: block)
  if block {
    handle(elem, mime: "placeholder-block-generic", ctx: ctx, ..args)
  } else {
    handle(elem, mime: "placeholder-inline-generic", ctx: ctx, ..args)
  }
}

// Placeholder for code cell input rendering using source (from raw spec)
#let placeholder-input-from-source(source, ctx: none, ..args) = {
  // Make new raw element with canonical lang (the lang on the raw-spec
  // element might be a "fake" value like "python-x" for selection in a show
  // rule, and in any case reusing in the output the value used for show rule
  // the selector would lead to infinite recursion).
  // For code cell input rendering we render as block even if the raw spec
  // was inline (e.g. from #execute(`...`)).
  let raw-elem = handle(source, mime: "source-code-generic", ctx: ctx, lang: ctx.lang, ..args)
  return handle(raw-elem, mime: "placeholder-block-generic", ctx: ctx, ..args)
}

// Placeholder for an output item
#let placeholder-output(data, ctx: none, ..args) = {
  let func = if ctx.output-type in all-output-types {
    // Use the function name for this specific output type
    ctx.output-type
  } else {
    "output"
  }
  handle(func, mime: "placeholder-function-call", ctx: ctx, ..args)
}

// Placeholder for In() calls
#let placeholder-In(data, ctx: none, ..args) = {
  if _is-raw-spec(ctx.cell-spec) {
    // Source is available!
    return _placeholder-input-from-raw-spec(ctx: ctx, ..args)
  }
  return handle("In", mime: "placeholder-function-call", block: true, ctx: ctx, ..args)
}

// Placeholder for Out() calls
#let placeholder-Out(data, ctx: none, ..args) = {
  handle("Out", mime: "placeholder-function-call", block: true, ctx: ctx, ..args)
}

// Placeholder Cell() calls
#let placeholder-Cell(data, ctx: none, ..args) = {
  if _is-raw-spec(ctx.cell-spec) {
    // Raw spec implies that this is a code cell, and we have the source
    return _placeholder-input-from-raw-spec(ctx: ctx, ..args)
  }
  return handle("Cell", mime: "placeholder-function-call", block: true, ctx: ctx, ..args)
}

// Default handlers
#let default = (
  // Handlers for specific formats of rich items (outputs and cell attachments)
  "text/vnd.typst"  : text-vnd-typst,
  "image/svg+xml"   : image-svg-xml,
  "image/png"       : handle.with(mime: "image-base64"),
  "image/jpeg"      : handle.with(mime: "image-base64"),
  "image/gif"       : handle.with(mime: "image-base64"),
  "text/markdown"   : text-markdown,
  "text/html"       : text-html,
  "text/latex"      : text-latex,
  "text/plain"      : text-plain,
  "application/json": application-json,
  // Generic image handlers
  "image-generic" : image-generic, // base handler used by others
  "image-base64"  : image-base64,  // base64 encoded image
  "image-text"    : image-text,    // text encoded image
  "image-data-url": image-data-url, // data: URL encoded image
  "image-markdown": image-markdown, // image in Markdown
  // Handlers for output items
  "rich-output-generic": rich-output-generic,
  "display": handle.with(mime: "rich-output-generic"),
  "result": handle.with(mime: "rich-output-generic"),
  "error": error,
  "stream-generic": stream-generic,
  "stream-stdout": handle.with(mime: "stream-generic"),
  "stream-stderr": handle.with(mime: "stream-generic"),
  "stream-merged": handle.with(mime: "stream-generic"), // used when both streams are merged
  "stream": stream, // called before stream-type-specific handler
  "output": output, // called before output-type-specific handler
  // Handlers for Markdown as part of the document flow
  "markdown-generic": markdown-generic, // returns inline content
  // Handlers for LaTeX math
  "math-generic": math-generic, // base handler for math
  "math-markdown": math-markdown, // Markdown math
  // Handlers for cell rendering
  "raw-cell": raw-cell,
  "markdown-cell": markdown-cell,
  "code-cell-input": code-cell-input,
  "code-cell-output": code-cell-output,
  "code-cell": code-cell,
  "cell": cell, // called before the cell-type-specific handler
  // Placeholders
  "placeholder-inline-generic": placeholder-inline-generic,
  "placeholder-block-generic": placeholder-block-generic,
  "placeholder-function-call": placeholder-function-call,
  "placeholder-input-from-source": placeholder-input-from-source,
  "placeholder-output": placeholder-output,
  "placeholder-In": placeholder-In,
  "placeholder-Out": placeholder-Out,
  "placeholder-Cell": placeholder-Cell,
  // Other handlers
  "text-console-block": text-console-block,
  "source-code-generic": source-code-generic,
  "attachment": attachment,
  "path": path-handler,
)
