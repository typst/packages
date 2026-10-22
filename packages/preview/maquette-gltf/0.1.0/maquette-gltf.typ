// maquette-gltf — render glTF 2.0 assets in Typst.
//
// Two input shapes, both handled transparently:
//
//   1. `.glb`, or `.gltf` with everything embedded in `data:` URIs:
//        #render-gltf(read("model.glb", encoding: none))
//
//   2. `.gltf` split across multiple files (external `.bin`, textures):
//        #render-gltf("scene.gltf", read: p => read(p, encoding: none))
//
// For (2) the wrapper reads the `.gltf`, walks its JSON, discovers every
// external `buffer.uri` / `image.uri`, reads each one via the reader you
// passed in, and packs them into a sidecar bundle the wasm side unpacks.
// You write zero filenames — they're all in the `.gltf` JSON already.
//
// Why the `read: p => read(p, ...)` handshake?
// Typst packages can't read files from your project directory — `read()`
// inside a package resolves relative to the package itself. Passing an
// *inline lambda* wrapping your file's `read` gives us a filesystem handle
// scoped to your project (bare function references don't work: they stay
// bound to the package's path context — Typst resolves `read()` paths
// against the source location where the call is textually written).

#let gltf-plugin = plugin("maquette-gltf.wasm")

#let _u32le(data, i) = data.at(i) + data.at(i + 1) * 256 + data.at(i + 2) * 65536 + data.at(i + 3) * 16777216

// Little-endian encoders as byte arrays. Kept tiny — invoked once per header
// field, so we don't need a general-purpose bit-twiddler.
#let _u16-bytes(n) = bytes((calc.rem(n, 256), calc.rem(calc.quo(n, 256), 256)))
#let _u32-bytes(n) = bytes((
  calc.rem(n, 256),
  calc.rem(calc.quo(n, 256), 256),
  calc.rem(calc.quo(n, 65536), 256),
  calc.rem(calc.quo(n, 16777216), 256),
))

// Pack a dict of `uri -> bytes` into the sidecar bundle the plugin expects.
// Layout (matches `gltf_loader::parse_sidecar_bundle` on the Rust side):
//   [n u32 LE]
//   for i in 0..n:
//     [name_len u16 LE][name utf-8][data_offset u32 LE][data_length u32 LE]
//   [concatenated file bodies at their offsets]
// Empty input → empty bytes (plugin treats this as "no sidecars", identical
// to calling the non-split entry point).
#let _pack-bundle(files) = {
  let names = files.keys()
  let n = names.len()
  if n == 0 { return bytes(()) }

  // Header size = 4 + Σ (2 + name_len + 4 + 4). Compute up-front so we can
  // assign data offsets before serialising anything.
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

// Strip the last path component so we can join sidecar filenames against the
// glTF's directory. Handles `/` and `\` — Typst normalises to forward slashes
// but we accept both defensively.
#let _dir-of(path) = {
  let i = path.len()
  while i > 0 {
    let c = path.at(i - 1)
    if c == "/" or c == "\\" { break }
    i -= 1
  }
  path.slice(0, i)
}

// Walk the glTF JSON and read every external sidecar URI (any `buffer.uri`
// or `image.uri` that isn't a `data:` URI). Filenames are resolved relative
// to `base` (the .gltf's directory) via the caller-supplied `reader`.
// Data URIs are handled by the wasm side, not here.
//
// Typst forbids mutating outer bindings from a nested closure, so we insert
// inline (`files.insert(...)` is a statement in the containing block).
#let _discover-sidecars(json-obj, base, reader) = {
  let files = (:)
  let uris = ()
  for b in json-obj.at("buffers", default: ()) {
    let u = b.at("uri", default: none)
    if u != none and not u.starts-with("data:") { uris.push(u) }
  }
  for img in json-obj.at("images", default: ()) {
    let u = img.at("uri", default: none)
    if u != none and not u.starts-with("data:") { uris.push(u) }
  }
  for u in uris {
    if u not in files { files.insert(u, reader(base + u)) }
  }
  files
}

// Resolve the caller's argument to `(bytes, sidecars-bundle)`. If they passed
// a path (string) with a `reader` callback, we do the JSON walk and sidecar
// packing here so the plugin only ever sees packed bytes. If they passed
// bytes, sidecars are empty and the plugin uses its non-split entry points.
#let _resolve-input(model, reader) = {
  if type(model) == str {
    if reader == none {
      panic(
        "render-gltf: got a path string but no `read:` callback. Typst " +
        "packages can't read files from your project directly, so pass an " +
        "*inline lambda* wrapping your file's read:\n\n" +
        "  #render-gltf(\"scene.gltf\", read: p => read(p, encoding: none))\n\n" +
        "OR pass bytes directly for a .glb / fully-embedded .gltf:\n\n" +
        "  #render-gltf(read(\"model.glb\", encoding: none))"
      )
    }
    let data = reader(model)
    // GLB magic (`glTF` in ASCII) → fast path, no JSON walk. External URIs
    // are illegal in GLB anyway.
    if data.len() >= 4 and data.slice(0, 4) == bytes("glTF") {
      return (data: data, sidecars: bytes(()))
    }
    // JSON `.gltf` — walk it for external URIs. `json()` accepts bytes and
    // parses them as JSON (avoids the intermediate str allocation).
    let doc = json(data)
    let base = _dir-of(model)
    let files = _discover-sidecars(doc, base, reader)
    (data: data, sidecars: _pack-bundle(files))
  } else {
    (data: model, sidecars: bytes(()))
  }
}

#let _parse-args(args) = {
  let named = args.named()
  let width = named.at("width", default: auto)
  let height = named.at("height", default: auto)

  let config = (:)
  if args.pos().len() > 0 {
    let first = args.pos().at(0)
    if type(first) == dictionary { config = first }
  }
  for (k, v) in named {
    if k not in ("width", "height", "read") {
      config.insert(k, v)
    }
  }
  (
    cfg: bytes(json.encode(config)),
    width: width,
    height: height,
  )
}

#let _raw-image(px, w, h, width, height) = image(
  px, format: (encoding: "rgba8", width: w, height: h), width: width, height: height,
)

/// Render a glTF or GLB model to a raster image.
///
/// 🔗 *Frame the camera, lighting and animation visually in the live web demo,
/// then copy the generated code:* https://bernsteining.github.io/maquette/?model=tokyo.glb
///
/// `model` accepts either a path string or bytes:
///   - `"assets/scene.gltf"` (with `read: p => read(p, encoding: none)`) —
///     the wrapper reads the file, discovers external `.bin`/image sidecars
///     from the JSON, reads each one via your lambda, and hands the whole
///     set to the plugin.
///   - `read("model.glb", encoding: none)` — bytes; passed straight through.
///
/// - model (str, bytes): the glTF/GLB asset (see above).
/// - read (function, none): inline lambda wrapping your file's `read`.
///     Only needed for split `.gltf`. Must be a lambda, not a bare function
///     reference — see the module header for why.
/// - ..args (arguments): render config as named parameters. Recognised keys:
///     `width`, `height`, `background`, `camera`, `lights`, `ibl`, `shadows`,
///     `ssao`, `antialias`, `tone_mapping`, `ground`, `time`, `variant`, …
///     See `crates/maquette-gltf/src/config.rs` for the full list.
/// -> content
#let render-gltf(model, read: none, ..args) = {
  let input = _resolve-input(model, read)
  let a = _parse-args(args)
  layout(_ => {
    let result = if input.sidecars.len() == 0 {
      gltf-plugin.render_gltf(input.data, a.cfg)
    } else {
      gltf-plugin.render_gltf_split(input.data, a.cfg, input.sidecars)
    }
    _raw-image(result.slice(9), _u32le(result, 1), _u32le(result, 5), a.width, a.height)
  })
}

/// Return scene metadata (triangle count, bounding box, center, radius,
/// `max_animation_time`) as a dictionary. Useful for computing camera
/// framing or driving an animation slider.
///
/// 🔗 *Explore models interactively in the live web demo:*
/// https://bernsteining.github.io/maquette/?model=tokyo.glb
///
/// Same `model` polymorphism and `read:` handshake as `render-gltf`.
/// -> dictionary
#let get-gltf-info(model, read: none, ..args) = {
  let input = _resolve-input(model, read)
  let a = _parse-args(args)
  let result = if input.sidecars.len() == 0 {
    gltf-plugin.get_gltf_info(input.data, a.cfg)
  } else {
    gltf-plugin.get_gltf_info_split(input.data, a.cfg, input.sidecars)
  }
  json(result)
}
