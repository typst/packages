// maquette — render 3D models (STL, OBJ, PLY) as SVG or PNG images in Typst

#let maquette-plugin = plugin("maquette.wasm")

#let _parse-args(args, extra: (:)) = {
  // Extract display args (not part of render config)
  let named = args.named()
  let width = named.at("width", default: auto)
  let height = named.at("height", default: auto)
  let format = named.at("format", default: "png")

  // Build config: named params (minus display args) merged with positional dict if any
  let config = (:)
  if args.pos().len() > 0 {
    let first = args.pos().at(0)
    if type(first) == dictionary {
      config = first
    }
  }
  for (k, v) in named {
    if k not in ("width", "height", "format") {
      config.insert(k, v)
    }
  }
  // Wrapper-supplied config (e.g. auto-discovered `.mtl` text). An explicit
  // user value in `args` always wins over the auto-discovered one.
  for (k, v) in extra {
    if k not in config { config.insert(k, v) }
  }
  (
    cfg: bytes(json.encode(config)),
    config: config,
    width: width,
    height: height,
    format: format,
  )
}

#let _u32le(data, i) = data.at(i) + data.at(i + 1) * 256 + data.at(i + 2) * 65536 + data.at(i + 3) * 16777216

#let _raw-image(px, w, h, width, height) = image(
  px, format: (encoding: "rgba8", width: w, height: h), width: width, height: height,
)

// Resolve a requested dimension (auto / length / ratio / relative) to a
// concrete length against `base`. Needed because `place`d children can't carry
// relative sizes — they collapse to zero (see the 0x02 overlay path).
#let _resolve(dim, base) = {
  if dim == auto { auto }
  else if type(dim) == length { dim }
  else if type(dim) == ratio { dim * base }
  else { dim.ratio * base + dim.length } // relative = ratio + length
}

// Turn a raster-entry result (0x00 raw RGBA / 0x02 raster+overlay / 0x3C SVG)
// into displayable content at the requested size. Shared by every PNG path.
#let _present(result, a) = {
    let marker = result.at(0)
    if marker == 0x00 {
      // Raw RGBA: [0x00][w u32 LE][h u32 LE][rgba8…]. Embedding the pixels
      // directly skips PNG encode (plugin) and decode (Typst), and avoids
      // re-compressing for the PDF.
      _raw-image(result.slice(9), _u32le(result, 1), _u32le(result, 5), a.width, a.height)
    } else if marker == 0x02 {
      // Raster + vector overlay: [0x02][w][h][rgba8 w*h*4][svg]. Layer the
      // transparent SVG (labels / grid lines / annotations / debug text) over
      // the raw pixels — no PNG anywhere.
      let w = _u32le(result, 1)
      let h = _u32le(result, 5)
      let n = w * h * 4
      let raster = result.slice(9, 9 + n)
      let overlay = result.slice(9 + n)
      // `place` can NOT resolve a relative size (`100%`, `58%`, …) for its
      // child — it collapses to zero and the overlay silently vanishes — so
      // both layers must receive the *same concrete* lengths. Resolve the
      // requested size against the container (via `layout`), fill the width
      // when nothing is given (like a bare SVG image), and otherwise keep the
      // render's aspect ratio (viewBox w×h) for any auto axis.
      layout(size => {
        let dw = _resolve(a.width, size.width)
        let dh = _resolve(a.height, size.height)
        if dw == auto and dh == auto {
          dw = size.width
          dh = size.width * h / w
        } else if dw == auto {
          dw = dh * w / h
        } else if dh == auto {
          dh = dw * h / w
        }
        box({
          _raw-image(raster, w, h, dw, dh)
          place(top + left, image(overlay, format: "svg", width: dw, height: dh))
        })
      })
    } else {
      // 0x3C — a pure SVG (defensive; raster mode returns 0x00 or 0x02).
      image(result, format: "svg", width: a.width, height: a.height)
    }
}

#let _shared(data, prepare, config) = {
  if prepare == none or "materials" in config or "highlight" in config or "mtl" in config { data }
  else { prepare(data) }
}

#let _render(data, png-fn, svg-fn, args, prepare: none) = {
  let a = _parse-args(args)
  if a.format != "png" {
    image(svg-fn(_shared(data, prepare, a.config), a.cfg), format: "svg", width: a.width, height: a.height)
  } else {
    layout(_ => _present(png-fn(_shared(data, prepare, a.config), a.cfg), a))
  }
}

// ── OBJ material / texture sidecar discovery ───────────────────────────────
//
// Little-endian encoders + bundle packer, shared wire format with
// `maquette_core::bundle` (identical to the glTF wrapper's packer).
#let _u16-bytes(n) = bytes((calc.rem(n, 256), calc.rem(calc.quo(n, 256), 256)))
#let _u32-bytes(n) = bytes((
  calc.rem(n, 256),
  calc.rem(calc.quo(n, 256), 256),
  calc.rem(calc.quo(n, 65536), 256),
  calc.rem(calc.quo(n, 16777216), 256),
))

// Pack `filename -> bytes` into the sidecar bundle the plugin unpacks. Empty
// input → empty bytes (plugin treats this as "no textures").
#let _pack-bundle(files) = {
  let names = files.keys()
  let n = names.len()
  if n == 0 { return bytes(()) }
  let header-size = 4
  for name in names { header-size += 2 + bytes(name).len() + 4 + 4 }
  let entries = ()
  let cursor = header-size
  for name in names {
    let data = files.at(name)
    entries.push((name: name, offset: cursor, length: data.len()))
    cursor += data.len()
  }
  let out = _u32-bytes(n)
  for e in entries {
    let name-bytes = bytes(e.name)
    out += _u16-bytes(name-bytes.len())
    out += name-bytes
    out += _u32-bytes(e.offset)
    out += _u32-bytes(e.length)
  }
  for e in entries { out += files.at(e.name) }
  out
}

// Directory prefix of a path (keeps the trailing slash; "" for a bare name).
#let _dir-of(path) = {
  let i = path.len()
  while i > 0 {
    let c = path.at(i - 1)
    if c == "/" or c == "\\" { break }
    i -= 1
  }
  path.slice(0, i)
}

// Every `mtllib` filename referenced by an OBJ (one line may list several).
#let _obj-mtllibs(text) = {
  let out = ()
  for line in text.split("\n") {
    let l = line.trim()
    if l.starts-with("mtllib ") or l.starts-with("mtllib\t") {
      for tok in l.slice(6).split(regex("\\s+")) {
        let t = tok.trim().replace("\\", "/")
        if t != "" and t not in out { out.push(t) }
      }
    }
  }
  out
}

// Every `map_Kd` texture filename referenced by concatenated MTL text. The
// filename is the last whitespace token (after any `-o`/`-s`/… options).
#let _mtl-map-kd(text) = {
  let out = ()
  for line in text.split("\n") {
    let l = line.trim()
    if l.starts-with("map_Kd ") or l.starts-with("map_Kd\t") {
      let toks = l.split(regex("\\s+")).filter(t => t.trim() != "")
      if toks.len() >= 2 {
        let f = toks.at(toks.len() - 1).replace("\\", "/")
        if f not in out { out.push(f) }
      }
    }
  }
  out
}

/// Render an STL model to an image (PNG raster by default, `format: "svg"` for vector).
///
/// 🔗 *Dial in the camera, lighting and materials visually in the live web demo, then
/// copy the generated code:* https://bernsteining.github.io/maquette/
///
/// - stl-data (bytes): STL file contents — read with `encoding: none` (binary STL).
/// - ..args (arguments): render config, as named arguments or a single dictionary
///   (camera, lights, material, shading, post-processing, …).
/// -> content
#let render-stl(stl-data, ..args) = {
  _render(stl-data, maquette-plugin.render_stl_png, maquette-plugin.render_stl, args, prepare: maquette-plugin.prepare_stl)
}

/// Render a Wavefront OBJ model to an image (PNG raster by default, `format: "svg"` for vector).
///
/// 🔗 *Dial in the camera, lighting and materials visually in the live web demo, then
/// copy the generated code:* https://bernsteining.github.io/maquette/
///
/// - obj-data (bytes, str): OBJ file contents (reading with `encoding: none` is
///   recommended), or — when `read:` is given — a *path* to the `.obj`.
/// - read (function, none): an inline reader, `p => read(p, encoding: none)`.
///   When present, `obj-data` is treated as a path: the wrapper reads it, then
///   auto-discovers its `mtllib` material libraries and every `map_Kd` diffuse
///   texture (resolved relative to the `.obj`), decodes them, and renders the
///   model *textured* (PNG only). Without it, behaviour is unchanged — pass
///   OBJ bytes and, optionally, `mtl:`/`materials:` in the config yourself.
/// - ..args (arguments): render config, as named arguments or a single dictionary
///   (camera, lights, material, shading, post-processing, …).
/// -> content
#let render-obj(obj-data, read: none, ..args) = {
  if read == none {
    // Classic path: bytes in, colours via `mtl:`/`materials:` config if any.
    let data = bytes(obj-data)
    return _render(data, maquette-plugin.render_obj_png, maquette-plugin.render_obj, args, prepare: maquette-plugin.prepare_obj)
  }
  // Path + reader: discover material libraries and diffuse textures.
  let obj-bytes = bytes(read(obj-data))
  let base = _dir-of(obj-data)
  let obj-text = str(obj-bytes)
  let mtl-text = ""
  for f in _obj-mtllibs(obj-text) { mtl-text += str(read(base + f)) + "\n" }
  let tex-files = (:)
  for f in _mtl-map-kd(mtl-text) {
    if f not in tex-files { tex-files.insert(f, bytes(read(base + f))) }
  }
  let a = _parse-args(args, extra: (mtl: mtl-text))
  if a.format != "png" {
    // SVG output can't carry raster textures; still applies `.mtl` Kd colours.
    image(maquette-plugin.render_obj(obj-bytes, a.cfg), format: "svg", width: a.width, height: a.height)
  } else {
    layout(_ => _present(maquette-plugin.render_obj_png_tex(obj-bytes, a.cfg, _pack-bundle(tex-files)), a))
  }
}

/// Render a PLY model or point cloud to an image (PNG raster by default, `format: "svg"` for vector).
///
/// 🔗 *Dial in the camera, lighting and materials visually in the live web demo, then
/// copy the generated code:* https://bernsteining.github.io/maquette/
///
/// - ply-data (bytes): PLY file contents — read with `encoding: none`.
/// - ..args (arguments): render config, as named arguments or a single dictionary
///   (camera, lights, material, point-cloud reconstruction, …).
/// -> content
#let render-ply(ply-data, ..args) = {
  _render(ply-data, maquette-plugin.render_ply_png, maquette-plugin.render_ply, args)
}

/// STL model metadata (triangles, vertices, bounding box, resolved camera) as a dictionary.
///
/// 🔗 *Explore models interactively in the live web demo:* https://bernsteining.github.io/maquette/
///
/// - stl-data (bytes): STL file contents — read with `encoding: none`.
/// - ..args (arguments): optional config affecting the resolved camera/projection.
/// -> dictionary
#let get-stl-info(stl-data, ..args) = {
  let a = _parse-args(args)
  json(maquette-plugin.get_stl_info(_shared(stl-data, maquette-plugin.prepare_stl, a.config), a.cfg))
}

/// OBJ model metadata (triangles, vertices, bounding box, groups, resolved camera) as a dictionary.
///
/// 🔗 *Explore models interactively in the live web demo:* https://bernsteining.github.io/maquette/
///
/// - obj-data (bytes, str): OBJ file contents.
/// - ..args (arguments): optional config affecting the resolved camera/projection.
/// -> dictionary
#let get-obj-info(obj-data, ..args) = {
  let a = _parse-args(args)
  json(maquette-plugin.get_obj_info(_shared(bytes(obj-data), maquette-plugin.prepare_obj, a.config), a.cfg))
}

/// PLY model metadata (triangles, vertices, bounding box, resolved camera) as a dictionary.
///
/// 🔗 *Explore models interactively in the live web demo:* https://bernsteining.github.io/maquette/
///
/// - ply-data (bytes): PLY file contents — read with `encoding: none`.
/// - ..args (arguments): optional config affecting the resolved camera/projection.
/// -> dictionary
#let get-ply-info(ply-data, ..args) = {
  let a = _parse-args(args)
  json(maquette-plugin.get_ply_info(ply-data, a.cfg))
}
