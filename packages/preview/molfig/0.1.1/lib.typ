#import "@preview/maquette:0.1.0": render-obj, render-stl, render-ply, get-obj-info, get-stl-info, get-ply-info

#let _plugin = plugin("molfig.wasm")

#let v15-or-later() = {
  sys.version >= version(0, 15, 0)
}

#let _is-path(value) = {
  v15-or-later() and str(type(value)) == "path"
}

#let _normalize-data(data) = {
  if _is-path(data) {
    read(data, encoding: none)
  } else if type(data) == bytes {
    data
  } else if type(data) == str {
    bytes(data)
  } else {
    panic("molfig expects bytes, inline string data, or a Typst 0.15+ path. Use read(\"molecule.pdb\", encoding: none) for Typst 0.14-compatible files, or path(\"molecule.pdb\") on Typst 0.15 or later.")
  }
}

#let _merge-materials(config, generated) = {
  if type(config) != dictionary or type(generated) != dictionary {
    config
  } else {
    let user-materials = config.at("materials", default: (:))
    if type(user-materials) == dictionary {
      config + (materials: generated + user-materials)
    } else {
      config
    }
  }
}

#let _obj-bundle(bundle) = {
  let materials-len = int(str(bundle.slice(0, 8)))
  let obj-start = 8 + materials-len
  (
    mesh: bundle.slice(obj-start),
    materials: json(bundle.slice(8, obj-start)),
  )
}

#let _render-object-bundle(bundle) = {
  let materials-len = int(str(bundle.slice(0, 8)))
  let info-len = int(str(bundle.slice(8, 16)))
  let materials-start = 16
  let info-start = materials-start + materials-len
  let mesh-start = info-start + info-len
  (
    mesh: bundle.slice(mesh-start),
    materials: json(bundle.slice(materials-start, info-start)),
    info: json(bundle.slice(info-start, mesh-start)),
  )
}

#let _render-mesh(mesh, mesh-format, config, materials, width, height, output-format) = {
  let render-config = if mesh-format == "obj" {
    json.encode(_merge-materials(config, materials))
  } else {
    json.encode(config)
  }
  if mesh-format == "obj" {
    render-obj(mesh, render-config, width: width, height: height, format: output-format)
  } else if mesh-format == "stl" {
    render-stl(mesh, render-config, width: width, height: height, format: output-format)
  } else if mesh-format == "ply" {
    render-ply(mesh, render-config, width: width, height: height, format: output-format)
  } else {
    panic("mesh-format must be one of \"obj\", \"stl\", or \"ply\"")
  }
}

#let _mesh-options(format, representation, color-theme, theme, sphere-detail, radius-scale, atom-radius, bond-radius, infer-bonds, center, assembly, alt-loc, block-index, block-header, ribbon-radius, ribbon-width, helix-profile, round-cap, sheet-arrow-factor, tubular-helices, linear-segments, radial-segments, quality) = json.encode((
  format: format,
  representation: representation,
  color-theme: color-theme,
  theme: theme,
  sphere-detail: sphere-detail,
  radius-scale: radius-scale,
  atom-radius: atom-radius,
  bond-radius: bond-radius,
  infer-bonds: infer-bonds,
  center: center,
  assembly: assembly,
  alt-loc: alt-loc,
  block-index: block-index,
  block-header: block-header,
  ribbon-radius: ribbon-radius,
  ribbon-width: ribbon-width,
  helix-profile: helix-profile,
  round-cap: round-cap,
  sheet-arrow-factor: sheet-arrow-factor,
  tubular-helices: tubular-helices,
  linear-segments: linear-segments,
  radial-segments: radial-segments,
  quality: quality,
))

#let to-obj(
  data,
  format: "auto",
  representation: "default",
  color-theme: "chain-id",
  theme: (:),
  sphere-detail: 2,
  radius-scale: 1.0,
  atom-radius: 0.28,
  bond-radius: 0.12,
  infer-bonds: true,
  center: true,
  assembly: "1",
  alt-loc: "",
  block-index: none,
  block-header: "",
  ribbon-radius: 0.2,
  ribbon-width: 0.55,
  helix-profile: "elliptical",
  round-cap: false,
  sheet-arrow-factor: 1.5,
  tubular-helices: false,
  linear-segments: 8,
  radial-segments: 16,
  quality: "custom",
) = _plugin.to_obj(_normalize-data(data), bytes(_mesh-options(format, representation, color-theme, theme, sphere-detail, radius-scale, atom-radius, bond-radius, infer-bonds, center, assembly, alt-loc, block-index, block-header, ribbon-radius, ribbon-width, helix-profile, round-cap, sheet-arrow-factor, tubular-helices, linear-segments, radial-segments, quality)))

#let to-mtl(
  data,
  format: "auto",
  representation: "default",
  color-theme: "chain-id",
  theme: (:),
  sphere-detail: 2,
  radius-scale: 1.0,
  atom-radius: 0.28,
  bond-radius: 0.12,
  infer-bonds: true,
  center: true,
  assembly: "1",
  alt-loc: "",
  block-index: none,
  block-header: "",
  ribbon-radius: 0.2,
  ribbon-width: 0.55,
  helix-profile: "elliptical",
  round-cap: false,
  sheet-arrow-factor: 1.5,
  tubular-helices: false,
  linear-segments: 8,
  radial-segments: 16,
  quality: "custom",
) = _plugin.to_mtl(_normalize-data(data), bytes(_mesh-options(format, representation, color-theme, theme, sphere-detail, radius-scale, atom-radius, bond-radius, infer-bonds, center, assembly, alt-loc, block-index, block-header, ribbon-radius, ribbon-width, helix-profile, round-cap, sheet-arrow-factor, tubular-helices, linear-segments, radial-segments, quality)))

#let to-stl(
  data,
  format: "auto",
  representation: "default",
  color-theme: "chain-id",
  theme: (:),
  sphere-detail: 2,
  radius-scale: 1.0,
  atom-radius: 0.28,
  bond-radius: 0.12,
  infer-bonds: true,
  center: true,
  assembly: "1",
  alt-loc: "",
  block-index: none,
  block-header: "",
  ribbon-radius: 0.2,
  ribbon-width: 0.55,
  helix-profile: "elliptical",
  round-cap: false,
  sheet-arrow-factor: 1.5,
  tubular-helices: false,
  linear-segments: 8,
  radial-segments: 16,
  quality: "custom",
) = _plugin.to_stl(_normalize-data(data), bytes(_mesh-options(format, representation, color-theme, theme, sphere-detail, radius-scale, atom-radius, bond-radius, infer-bonds, center, assembly, alt-loc, block-index, block-header, ribbon-radius, ribbon-width, helix-profile, round-cap, sheet-arrow-factor, tubular-helices, linear-segments, radial-segments, quality)))

#let to-ply(
  data,
  format: "auto",
  representation: "default",
  color-theme: "chain-id",
  theme: (:),
  sphere-detail: 2,
  radius-scale: 1.0,
  atom-radius: 0.28,
  bond-radius: 0.12,
  infer-bonds: true,
  center: true,
  assembly: "1",
  alt-loc: "",
  block-index: none,
  block-header: "",
  ribbon-radius: 0.2,
  ribbon-width: 0.55,
  helix-profile: "elliptical",
  round-cap: false,
  sheet-arrow-factor: 1.5,
  tubular-helices: false,
  linear-segments: 8,
  radial-segments: 16,
  quality: "custom",
) = _plugin.to_ply(_normalize-data(data), bytes(_mesh-options(format, representation, color-theme, theme, sphere-detail, radius-scale, atom-radius, bond-radius, infer-bonds, center, assembly, alt-loc, block-index, block-header, ribbon-radius, ribbon-width, helix-profile, round-cap, sheet-arrow-factor, tubular-helices, linear-segments, radial-segments, quality)))

#let info(
  data,
  format: "auto",
  representation: "default",
  color-theme: "chain-id",
  theme: (:),
  sphere-detail: 2,
  radius-scale: 1.0,
  atom-radius: 0.28,
  bond-radius: 0.12,
  infer-bonds: true,
  center: true,
  assembly: "1",
  alt-loc: "",
  block-index: none,
  block-header: "",
  ribbon-radius: 0.2,
  ribbon-width: 0.55,
  helix-profile: "elliptical",
  round-cap: false,
  sheet-arrow-factor: 1.5,
  tubular-helices: false,
  linear-segments: 8,
  radial-segments: 16,
  quality: "custom",
) = json(_plugin.info(_normalize-data(data), bytes(_mesh-options(format, representation, color-theme, theme, sphere-detail, radius-scale, atom-radius, bond-radius, infer-bonds, center, assembly, alt-loc, block-index, block-header, ribbon-radius, ribbon-width, helix-profile, round-cap, sheet-arrow-factor, tubular-helices, linear-segments, radial-segments, quality))))

#let render(
  data,
  format: "auto",
  mesh-format: "obj",
  representation: "default",
  color-theme: "chain-id",
  theme: (:),
  sphere-detail: 2,
  radius-scale: 1.0,
  atom-radius: 0.28,
  bond-radius: 0.12,
  infer-bonds: true,
  center: true,
  assembly: "1",
  alt-loc: "",
  block-index: none,
  block-header: "",
  ribbon-radius: 0.2,
  ribbon-width: 0.55,
  helix-profile: "elliptical",
  round-cap: false,
  sheet-arrow-factor: 1.5,
  tubular-helices: false,
  linear-segments: 8,
  radial-segments: 16,
  quality: "custom",
  config: (:),
  width: auto,
  height: auto,
  output-format: "png",
) = {
  let mesh-config = _mesh-options(format, representation, color-theme, theme, sphere-detail, radius-scale, atom-radius, bond-radius, infer-bonds, center, assembly, alt-loc, block-index, block-header, ribbon-radius, ribbon-width, helix-profile, round-cap, sheet-arrow-factor, tubular-helices, linear-segments, radial-segments, quality)
  let source = _normalize-data(data)
  let object = if mesh-format == "obj" {
    _obj-bundle(_plugin.to_obj_bundle(source, bytes(mesh-config)))
  } else if mesh-format == "stl" {
    (mesh: _plugin.to_stl(source, bytes(mesh-config)), materials: (:))
  } else if mesh-format == "ply" {
    (mesh: _plugin.to_ply(source, bytes(mesh-config)), materials: (:))
  } else {
    panic("mesh-format must be one of \"obj\", \"stl\", or \"ply\"")
  }
  _render-mesh(object.mesh, mesh-format, config, object.materials, width, height, output-format)
}

#let render-object(
  data,
  format: "auto",
  mesh-format: "obj",
  representation: "default",
  color-theme: "chain-id",
  theme: (:),
  sphere-detail: 2,
  radius-scale: 1.0,
  atom-radius: 0.28,
  bond-radius: 0.12,
  infer-bonds: true,
  center: true,
  assembly: "1",
  alt-loc: "",
  block-index: none,
  block-header: "",
  ribbon-radius: 0.2,
  ribbon-width: 0.55,
  helix-profile: "elliptical",
  round-cap: false,
  sheet-arrow-factor: 1.5,
  tubular-helices: false,
  linear-segments: 8,
  radial-segments: 16,
  quality: "custom",
  config: (:),
  width: auto,
  height: auto,
  output-format: "png",
) = {
  let options = (
    format: format,
    representation: representation,
    color-theme: color-theme,
    theme: theme,
    sphere-detail: sphere-detail,
    radius-scale: radius-scale,
    atom-radius: atom-radius,
    bond-radius: bond-radius,
    infer-bonds: infer-bonds,
    center: center,
    assembly: assembly,
    alt-loc: alt-loc,
    block-index: block-index,
    block-header: block-header,
    ribbon-radius: ribbon-radius,
    ribbon-width: ribbon-width,
    helix-profile: helix-profile,
    round-cap: round-cap,
    sheet-arrow-factor: sheet-arrow-factor,
    tubular-helices: tubular-helices,
    linear-segments: linear-segments,
    radial-segments: radial-segments,
    quality: quality,
  )
  let source = _normalize-data(data)
  let render-object-config = json.encode(options + (mesh-format: mesh-format))
  let object = _render-object-bundle(_plugin.render_object_bundle(source, bytes(render-object-config)))
  (
    kind: "render-object",
    format: mesh-format,
    mesh_format: mesh-format,
    mesh: object.mesh,
    materials: object.materials,
    info: object.info,
    content: _render-mesh(object.mesh, mesh-format, config, object.materials, width, height, output-format),
  )
}

#let mesh-info(data, format: "auto", mesh-format: "obj", config: (:), ..mesh-args) = {
  let options = mesh-args.named()
  let raw = if mesh-format == "obj" {
    to-obj(data, format: format, ..options)
  } else if mesh-format == "stl" {
    to-stl(data, format: format, ..options)
  } else if mesh-format == "ply" {
    to-ply(data, format: format, ..options)
  } else {
    panic("mesh-format must be one of \"obj\", \"stl\", or \"ply\"")
  }

  let info = if mesh-format == "obj" {
    get-obj-info(raw, json.encode(config))
  } else if mesh-format == "stl" {
    get-stl-info(raw, json.encode(config))
  } else {
    get-ply-info(raw, json.encode(config))
  }

  if type(info) == dictionary {
    info
  } else {
    json(info)
  }
}
