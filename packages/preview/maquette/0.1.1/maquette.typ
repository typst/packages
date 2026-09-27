// maquette — render 3D models (STL, OBJ, PLY) as SVG or PNG images in Typst

#let maquette-plugin = plugin("maquette.wasm")

// Auto-detect output format: PNG starts with 0x89, SVG starts with '<' (0x3C).
#let _detect-format(data) = {
  if data.at(0) == 0x3C { "svg" } else { "png" }
}

#let _parse-args(args) = {
  // Extract display args (not part of render config)
  let named = args.named()
  let width = named.at("width", default: auto)
  let height = named.at("height", default: auto)
  let format = named.at("format", default: "png")

  // Build config: named params (minus display args) merged with positional dict if any
  let config = (:)
  if args.pos().len() > 0 {
    let first = args.pos().at(0)
    if type(first) == str {
      // Legacy: pre-encoded JSON string
      return (cfg: bytes(first), width: width, height: height, format: format)
    }
    if type(first) == dictionary {
      config = first
    }
  }
  for (k, v) in named {
    if k not in ("width", "height", "format") {
      config.insert(k, v)
    }
  }
  (
    cfg: bytes(json.encode(config)),
    width: width,
    height: height,
    format: format,
  )
}

#let _render(data, png-fn, svg-fn, args) = {
  let a = _parse-args(args)
  if a.format == "png" {
    let result = png-fn(data, a.cfg)
    image(result, format: _detect-format(result), width: a.width, height: a.height)
  } else {
    image(svg-fn(data, a.cfg), format: "svg", width: a.width, height: a.height)
  }
}

#let render-stl(stl-data, ..args) = {
  _render(stl-data, maquette-plugin.render_stl_png, maquette-plugin.render_stl, args)
}

#let render-obj(obj-data, ..args) = {
  let data = bytes(obj-data)
  _render(data, maquette-plugin.render_obj_png, maquette-plugin.render_obj, args)
}

#let render-ply(ply-data, ..args) = {
  _render(ply-data, maquette-plugin.render_ply_png, maquette-plugin.render_ply, args)
}

#let get-stl-info(stl-data, ..args) = {
  let a = _parse-args(args)
  json(maquette-plugin.get_stl_info(stl-data, a.cfg))
}

#let get-obj-info(obj-data, ..args) = {
  let a = _parse-args(args)
  json(maquette-plugin.get_obj_info(bytes(obj-data), a.cfg))
}

#let get-ply-info(ply-data, ..args) = {
  let a = _parse-args(args)
  json(maquette-plugin.get_ply_info(ply-data, a.cfg))
}
