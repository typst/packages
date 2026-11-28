// import external figures into the current Typst layout context.
#let panfig = {
  import "@preview/typwire:0.2.0"
  let wasm = plugin("panfig.wasm")

  let escape(s) = s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;")
  let number(size) = json.encode(size / 1pt)
  let point(p) = p.map(n => n * 1pt)

  let bounds(anchor, width, height, ascent) = {
    let dx = if anchor.ends-with("west") { 0pt } else if anchor.ends-with("east") { width } else { width / 2 }
    let dy = if anchor.starts-with("base") { ascent } else if anchor.starts-with("north") { 0pt } else if anchor.starts-with("south") { height } else { height / 2 }
    (x: -dx, y: -dy, width: width, height: height, ascent: ascent)
  }

  let label(body, anchor) = {
    let ascent = measure(text(top-edge: "bounds", bottom-edge: "baseline", body)).height
    let body = text(top-edge: "bounds", bottom-edge: "bounds", body)
    let (width, height) = measure(body)
    (..bounds(anchor, width, height, ascent), body: body)
  }

  let run-text(runs, font, size, opacity: 1, math-scope: none) = {
    let body = runs.map(r => {
      let body = if "math" in r {
        eval(r.math, mode: "math", scope: math-scope)
      } else {
        let content = [#(r.text)]
        if r.italic { content = text(style: "italic", content) }
        if r.bold { content = text(weight: "bold", content) }
        content
      }
      if "fill" in r {
        text(fill: rgb(..r.fill).transparentize((1 - opacity) * 100%), body)
      } else if opacity < 1 {
        text(fill: text.fill.transparentize((1 - opacity) * 100%), body)
      } else {
        body
      }
    }).join([])
    if font != none { body = text(font: font, body) }
    if size != none { body = text(size: size * 1pt, body) }
    body
  }

  let needs-math(runs) = runs.any(r => "math" in r)
  let load-mitex() = {
    import "@preview/mitex:0.2.7": mitex-scope
    mitex-scope
  }

  // the marker contains a drawable copy for clips and transforms that require SVG.
  let svg-label(id, runs, font, size, math-scope: none) = {
    let em = if size == none { text.size } else { size * 1pt }
    let entry = label(run-text(runs, font, size, math-scope: math-scope), "north-west")
    let family = if font == none { text.font } else { font }
    let family = if type(family) == array { family } else { (family,) }
    let family = family.map(f => repr(if type(f) == dictionary { f.name } else { f })).join(", ")
    let weights = (thin: 100, extralight: 200, light: 300, regular: 400, medium: 500,
      semibold: 600, bold: 700, extrabold: 800, black: 900)
    let weight = if type(text.weight) == str { weights.at(text.weight) } else { text.weight }
    let spans = runs.map(r => {
      let w = if r.bold { " font-weight=\"bold\"" } else { "" }
      let i = if r.italic { " font-style=\"italic\"" } else { "" }
      let c = if "fill" in r { " fill=\"" + rgb(..r.fill).to-hex() + "\"" } else { "" }
      let content = if "math" in r { r.math } else { r.text }
      "<tspan" + w + i + c + ">" + escape(content) + "</tspan>"
    }).join("")
    let body = ("<text data-panfig-label=\"" + id + "\" x=\"" + number(entry.x) + "\" y=\"" + number(entry.y + entry.ascent)
      + "\" font-family=\"" + escape(family) + "\" font-size=\"" + number(em)
      + "\" font-weight=\"" + str(weight) + "\" font-style=\"" + text.style + "\" fill=\"currentColor"
      + "\" xml:space=\"preserve\">" + spans + "</text>")
    (..entry, body: body)
  }

  let tex-engine() = plugin.transition(plugin("latex.wasm").initialize)
  let compile(job, math-scope: none) = {
    // measure only labels added since the previous TeX retry pass.
    let pending = job.labels.slice(job.measured)
    for (id, item) in pending {
      let macro = "\\expandafter\\def\\csname " + id + "\\endcsname"
      let size = item.at("size", default: none)
      let entry = svg-label(id, item.runs, item.at("font", default: none), size, math-scope: math-scope)
      let w = number(calc.max(0.001pt, entry.width))
      let h = number(calc.max(0.001pt, entry.height))
      let svg = ("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" + w + "pt\" height=\"" + h
        + "pt\" viewBox=\"0 0 " + w + " " + h + "\">" + entry.body + "</svg>")
      let file = id + ".svg"
      job.files.insert(file, bytes(svg))
      job.defs += macro + "{\\begingroup\\catcode37=14\\relax\\lower " + number(entry.height - entry.ascent) + "bp\\hbox{\\includegraphics{" + file + "}}\\endgroup}%\n"
    }
    job.measured = job.labels.len()
    let result = tex-engine().compile(bytes(job.defs + job.declarations + job.document), typwire.encode(job.files))
    (job, typwire.decode(result))
  }

  let canvas(entries, viewport: none, width: auto, height: auto, fit: "cover", warnings: ()) = {
    let (x, y, w, h) = if viewport != none { point(viewport) }
      else if entries.len() == 0 { (0pt, 0pt, 0pt, 0pt) }
      else {
        let x = calc.min(..entries.map(e => e.x))
        let y = calc.min(..entries.map(e => e.y))
        (x, y, calc.max(..entries.map(e => e.x + e.width)) - x, calc.max(..entries.map(e => e.y + e.height)) - y)
      }
    let frame = box(width: w, height: h, clip: viewport != none, {
      // surface missing TeX fonts as native Typst warnings without altering figure geometry.
      for font in warnings { place(hide(text(font: font)[a])) }
      for e in entries { place(top + left, dx: e.x - x, dy: e.y - y, e.body) }
    })
    // fractional heights participate in the surrounding vertical flow.
    let container = if type(height) == fraction {
      block.with(breakable: false)
    } else { box }
    container(width: width, height: height, layout(size => {
      if w == 0pt or h == 0pt { return frame }
      let (sx, sy) = (size.width / w, size.height / h)
      let proportional = calc.min(sx, sy)
      if width == auto and height == auto { proportional = calc.min(1, proportional) }
      if width == auto { sx = proportional }
      if height == auto { sy = proportional }
      let (target-w, target-h) = (w * sx, h * sy)
      let uniform = (cover: calc.max(sx, sy), contain: calc.min(sx, sy), stretch: none).at(fit)
      if uniform != none { (sx, sy) = (uniform, uniform) }
      box(width: target-w, height: target-h,
        clip: fit == "cover" and (w * sx > target-w or h * sy > target-h),
        place(top + left, dx: (target-w - w * sx) / 2, dy: (target-h - h * sy) / 2,
          scale(x: 100% * sx, y: 100% * sy, origin: top + left, frame)))
    }))
  }

  let place-box(layer, e) = {
    let (x, y) = point(layer.at)
    let (sx, sy) = layer.at("scale", default: (1, 1))
    let angle = layer.at("angle", default: 0) * 1deg
    let shear = layer.at("shear", default: 0)
    if (sx, sy, angle, shear) == (1, 1, 0deg, 0) { return (..e, x: x + e.x, y: y + e.y) }

    let frame = box(width: 0pt, height: 0pt, place(top + left, dx: e.x, dy: e.y, box(width: e.width, height: e.height, e.body)))
    let frame = scale(x: sx * 100%, y: sy * 100%, origin: top + left, frame)
    let frame = if shear == 0 { frame } else { skew(ax: calc.atan(shear), origin: top + left, frame) }
    let frame = rotate(angle, origin: top + left, frame)
    let xs = ()
    let ys = ()
    for u in (e.x, e.x + e.width) {
      for v in (e.y, e.y + e.height) {
        let (px, py) = (sx * u + shear * sy * v, sy * v)
        xs.push(px * calc.cos(angle) - py * calc.sin(angle))
        ys.push(px * calc.sin(angle) + py * calc.cos(angle))
      }
    }
    let (dx, dy) = (calc.min(..xs), calc.min(..ys))
    (x: x + dx, y: y + dy, width: calc.max(..xs) - dx, height: calc.max(..ys) - dy,
     body: place(top + left, dx: -dx, dy: -dy, frame))
  }

  let clip-entry(entry, rect) = {
    let (x, y, w, h) = point(rect)
    (x: x, y: y, width: w, height: h, body: box(width: w, height: h, clip: true,
      place(top + left, dx: entry.x - x, dy: entry.y - y, entry.body)))
  }

  let unpack-source(source) = {
    if type(source) == content {
      assert(source.func() == raw, message: "Pass a raw code block for inline drawing source.")
      return (source.text, source.at("lang", default: none), false)
    }
    let is-file = type(source) == str and not source.contains("\\") and (
      source.contains(regex("(?i)^[^\r\n]+[.](pgf|tikz|tex|svg|typ|cetz)$"))
      and not source.starts-with(regex("^\\s*(%|<)"))
    )
    (source, if is-file { lower(source.split(".").last()) }, is-file)
  }

  /// import a filename, path, raw block, string or bytes as a Typst figure.
  let import-figure(format: auto, resolve: none,
    width: auto, height: auto, fit: "cover", ..input) = context {
    let (source, lang, is-file) = unpack-source(..input)
    let format = format
    let resource-path = resolve
    if is-file {
      let filename = source
      // forwarding the original argument lets path resolve it at the document's call site.
      source = if resolve == none { path(..input) } else { resolve(filename) }
      let caller-path = if resolve != none { resolve } else { name => {
        assert(not filename.split("/").contains("..") and path(filename) == source,
          message: "For linked project files, pass resolve: p => path(p) at the document call site.")
        path(name)
      }}
      let dir = filename.replace(regex("[^/]*$"), "")
      resource-path = name => caller-path(if name.starts-with("/") { name } else { dir + name })
    }
    let resource(name) = {
      assert(resource-path != none, message: "To read " + repr(name) + ", pass resolve: p => path(p) at the document call site.")
      read(resource-path(name), encoding: none)
    }
    let inputs = (:)
    let input = if type(source) == path { read(source, encoding: none) } else { bytes(source) }
    if format == auto {
      format = if lang == "svg" or str(input).trim().starts-with("<") or str(input).trim().starts-with("\u{feff}<") { "svg" }
        else if lang in ("cetz","typ","typst") { "cetz" } else { "pgf" }
    }
    if format in ("tex", "latex", "tikz") { format = "pgf" }
    assert(format in ("pgf", "svg"), message: "Unsupported input format " + repr(format) + ". Import PGF, TikZ or SVG. Use CeTZ canvases directly as Typst content.")
    let math-scope = none
    let host-labels = (:)
    let warnings = ()
    let doc = if format == "svg" {
      json(wasm.read_svg(input, bytes("svg")))
    } else {
      let read-pgf(files) = typwire.decode(wasm.read_pgf(input, typwire.encode(files)))
      let result = read-pgf(inputs)
      while result.kind == "input" {
        let name = result.name
        assert(name not in inputs, message: "repeated PGF input request " + repr(name))
        inputs.insert(name, str(resource(name)))
        result = read-pgf(inputs)
      }
      result
    }
    if format == "pgf" and doc.kind == "tex" {
      let prepare(data, prefix) = {
        if not data.contains("\\pgftext") and not data.contains("\\node") and not data.contains(regex("[^\\x00-\\xFF]")) { return (data, (), "") }
        let result = json(wasm.labels(bytes(data), bytes(str(prefix))))
        (result.source, result.labels, result.declarations)
      }
      let (main, labels, declarations) = prepare(str(input), 0)
      let files = (:)
      for (name, data) in inputs {
        let (source, extra, decls) = prepare(data, files.len()+1)
        declarations += decls
        labels += extra
        files.insert(name, bytes(source))
      }
      let chemistry = if main.starts-with("%% Creator: Matplotlib, PGF backend") and main.contains("%%   \\usepackage[version=4]{mhchem}") {
        let code = main.replace(regex("(?m)^\\s*%[^\\n]*"), "")
        let other = code.replace(regex("\\\\ce\\s*\\{(?:\\^[0-9]+)?(?:[A-Z][a-z]?[0-9]*)+\\}"), "")
        assert(not other.contains(regex("\\\\(?:ce|cf|pu|mhchemoptions)\\b")),
          message: "This figure requests mhchem v4 syntax. The bundled mhchem is v3.11. Render the original with a v4 TeX installation.")
        "\\usepackage[version=3]{mhchem}\n"
      } else { "" }
      let document = "\\usepackage{amsmath}\n" + chemistry + "\n\\begin{document}\n" + main + "\n\\end{document}\n"
      if math-scope == none and labels.any(((_, item)) => needs-math(item.runs)) {
        math-scope = load-mitex()
      }
      let job = (document: document, declarations: declarations, defs: "", measured: 0, labels: labels, files: files)
      let (job, result) = compile(job, math-scope: math-scope)
      while result.kind == "error" {
        let pending = result.missing.filter(n => n not in job.files)
        if pending.len() == 0 { panic(result.error) }
        if pending.len() > 1 { panic(result.error + "\nSpecify the linked filename with its extension.") }
        let name = pending.first()
        let data = resource(name)
        if name.ends-with(".pgf") or name.ends-with(".tex") {
          let (source, extra, decls) = prepare(str(data), job.files.len()+1)
          if math-scope == none and extra.any(((_, item)) => needs-math(item.runs)) {
            math-scope = load-mitex()
          }
          job.declarations += decls
          job.labels += extra
          job.files.insert(name, bytes(source))
        } else { job.files.insert(name, data) }
        (job, result) = compile(job, math-scope: math-scope)
      }
      host-labels = job.labels.to-dict()
      warnings = result.at("warnings", default: ())
      doc = json(wasm.read_svg(bytes(result.svg), bytes("tex")))
    }

    let viewport = doc.at("viewport", default: none)
    let layers = doc.layers
    if math-scope == none and layers.any(l => l.kind == "text" and needs-math(l.runs)) {
      math-scope = load-mitex()
    }
    let entries = ()
    for layer in layers {
      let entry = if layer.kind == "bounds" {
        let (x, y, w, h) = point(layer.rect)
        (x: x, y: y, width: w, height: h, body: [])
      } else if layer.kind == "svg" {
        let (x, y, w, h) = point(layer.rect)
        (x: x, y: y, width: w, height: h, body: image(bytes(layer.svg), format: "svg", width: w, height: h))
      } else if layer.kind == "host-text" {
        let item = host-labels.at(layer.id)
        let body = run-text(item.runs, item.at("font", default: none), item.at("size", default: none), math-scope: math-scope)
        if layer.color != (0, 0, 0, 255) { body = text(fill: rgb(..layer.color), body) }
        place-box(layer, label(body, "base-west"))
      } else if layer.kind == "text" {
        let body = run-text(layer.runs, layer.font, layer.size, opacity: layer.at("opacity", default: 1), math-scope: math-scope)
        place-box(layer, label(body, layer.anchor))
      } else if layer.kind == "image" {
        let name = layer.file
        let data = resource(name)
        let (w, h) = json(wasm.image_size(data, bytes(name)))
        let width = layer.width
        let height = layer.height
        if width == none { width = if height == none { w } else { height * w / h } }
        if height == none { height = width * h / w }
        let e = bounds(layer.anchor, width * 1pt, height * 1pt, height * 1pt)
        if "slice" in layer {
          let (x, y, w, h) = point(layer.slice.rect)
          let mime = (png: "png", jpg: "jpeg", jpeg: "jpeg", svg: "svg+xml").at(lower(name.split(".").last()))
          let tag = ("<image x=\"" + number(e.x) + "\" y=\"" + number(e.y) + "\" width=\"" + number(e.width)
            + "\" height=\"" + number(e.height) + "\" preserveAspectRatio=\"none\" xlink:href=\"data:image/" + mime + ";base64," + str(wasm.pack(data)) + "\"/>")
          let svg = layer.slice.svg.replace("<!--image-->", tag)
          (x: x, y: y, width: w, height: h, body: image(bytes(svg), format: "svg", width: w, height: h))
        } else {
          let body = image(data, width: e.width, height: e.height, fit: "stretch")
          place-box(layer, (..e, body: body))
        }
      }
      entries.push(if "clip" in layer { clip-entry(entry, layer.clip) } else { entry })
    }
    canvas(entries, viewport: viewport, width: width, height: height, fit: fit, warnings: warnings)
  }
  import-figure
}
