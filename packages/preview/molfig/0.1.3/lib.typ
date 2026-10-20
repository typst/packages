/// Convert PDB, mmCIF, and BinaryCIF molecular structures into static meshes
/// and render them in Typst documents with `maquette`.
///
/// Public functions accept structure bytes, inline PDB or mmCIF text, and
/// Typst 0.15+ path values. File inputs on older Typst versions must be read
/// with `read(..., encoding: none)` before being passed to Molfig.
#import "@preview/maquette:0.1.1": render-obj, render-stl, render-ply, get-obj-info, get-stl-info, get-ply-info

#let _plugin = plugin("molfig.wasm")

#let _v15-or-later() = {
  sys.version >= version(0, 15, 0)
}

#let _is-path(value) = {
  _v15-or-later() and str(type(value)) == "path"
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

#let _is-number(value) = type(value) == int or type(value) == float

#let _semantic-decimate(decimate, config) = {
  if decimate != auto {
    decimate
  } else if type(config) == dictionary {
    let value = config.at("decimate", default: 0)
    if _is-number(value) { value } else { 0 }
  } else {
    0
  }
}

#let _strip-maquette-decimate(config, semantic-decimate) = {
  if type(config) != dictionary or not _is-number(semantic-decimate) or semantic-decimate <= 0 {
    config
  } else {
    let stripped = (:)
    for (key, value) in config {
      if key != "decimate" {
        stripped.insert(key, value)
      }
    }
    stripped
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

#let _mesh-options(format, representation, color-theme, theme, sphere-detail, radius-scale, atom-radius, bond-radius, infer-bonds, center, assembly, alt-loc, block-index, block-header, ribbon-radius, ribbon-width, helix-profile, round-cap, sheet-arrow-factor, tubular-helices, linear-segments, radial-segments, quality, decimate) = json.encode((
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
  decimate: decimate,
))

/// Export a molecular structure as a Wavefront OBJ mesh.
///
/// OBJ preserves Molfig face groups, operator metadata when requested, and
/// material identifiers for color themes.
///
/// - data (any): Structure bytes, inline PDB or mmCIF text, or a Typst 0.15+ path value.
/// - format (str): Input format: `"auto"`, `"pdb"`, `"cif"`, `"mmcif"`, or `"bcif"`.
/// - representation (str): Molecular representation, such as `"default"`, `"cartoon"`, `"spacefill"`, `"ball-and-stick"`, `"surface"`, `"ribbon"`, or `"backbone"`.
/// - color-theme (str): Mol\* color theme used to assign OBJ materials.
/// - theme (dictionary): Mol\* Viewer theme overrides, including `globalName`, `carbonColor`, and `symmetryColor`.
/// - sphere-detail (int): Icosphere subdivision detail used by sphere-based visuals.
/// - radius-scale (int, float): Global multiplier for molecular radii.
/// - atom-radius (int, float): Base atom radius used by ball-and-stick-style visuals.
/// - bond-radius (int, float): Base bond-cylinder radius.
/// - infer-bonds (bool): Whether missing covalent bonds are inferred from molecular geometry.
/// - center (bool): Whether the exported mesh is centered using the visible Mol\* bounding sphere.
/// - assembly (str): Biological assembly identifier, or `"asymmetric-unit"` to use the source asymmetric unit.
/// - alt-loc (str): Alternate-location selector; an empty string uses the default highest-occupancy policy.
/// - block-index (none, int): Zero-based CIF or BinaryCIF data-block index.
/// - block-header (str): CIF or BinaryCIF data-block header to select instead of `block-index`.
/// - ribbon-radius (int, float): Polymer tube radius for ribbon-derived geometry.
/// - ribbon-width (int, float): Polymer ribbon width.
/// - helix-profile (str): Helix cross-section profile: `"elliptical"`, `"rounded"`, or `"square"`.
/// - round-cap (bool): Whether polymer segment ends use rounded caps.
/// - sheet-arrow-factor (int, float): Width multiplier for beta-sheet arrow tips.
/// - tubular-helices (bool): Whether helices are emitted as tubes instead of ribbons.
/// - linear-segments (int): Longitudinal curve subdivisions.
/// - radial-segments (int): Radial profile subdivisions.
/// - quality (str): Geometry quality preset from `"lowest"` through `"highest"`, or `"auto"`/`"custom"`.
/// - decimate (int, float): Molfig semantic decimation strength in the range `0` to `1`.
/// -> bytes
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
  decimate: 0,
) = _plugin.to_obj(_normalize-data(data), bytes(_mesh-options(format, representation, color-theme, theme, sphere-detail, radius-scale, atom-radius, bond-radius, infer-bonds, center, assembly, alt-loc, block-index, block-header, ribbon-radius, ribbon-width, helix-profile, round-cap, sheet-arrow-factor, tubular-helices, linear-segments, radial-segments, quality, decimate)))

/// Export the OBJ materials for a molecular structure as a Wavefront MTL file.
///
/// Material order and identifiers match the corresponding `to-obj` output.
///
/// - data (any): Structure bytes, inline PDB or mmCIF text, or a Typst 0.15+ path value.
/// - format (str): Input format: `"auto"`, `"pdb"`, `"cif"`, `"mmcif"`, or `"bcif"`.
/// - representation (str): Molecular representation used to generate material assignments.
/// - color-theme (str): Mol\* color theme used to assign materials.
/// - theme (dictionary): Mol\* Viewer theme overrides, including `globalName`, `carbonColor`, and `symmetryColor`.
/// - sphere-detail (int): Icosphere subdivision detail used by sphere-based visuals.
/// - radius-scale (int, float): Global multiplier for molecular radii.
/// - atom-radius (int, float): Base atom radius used by ball-and-stick-style visuals.
/// - bond-radius (int, float): Base bond-cylinder radius.
/// - infer-bonds (bool): Whether missing covalent bonds are inferred from molecular geometry.
/// - center (bool): Whether the associated mesh is centered.
/// - assembly (str): Biological assembly identifier, or `"asymmetric-unit"` to use the source asymmetric unit.
/// - alt-loc (str): Alternate-location selector; an empty string uses the default highest-occupancy policy.
/// - block-index (none, int): Zero-based CIF or BinaryCIF data-block index.
/// - block-header (str): CIF or BinaryCIF data-block header to select instead of `block-index`.
/// - ribbon-radius (int, float): Polymer tube radius for ribbon-derived geometry.
/// - ribbon-width (int, float): Polymer ribbon width.
/// - helix-profile (str): Helix cross-section profile: `"elliptical"`, `"rounded"`, or `"square"`.
/// - round-cap (bool): Whether polymer segment ends use rounded caps.
/// - sheet-arrow-factor (int, float): Width multiplier for beta-sheet arrow tips.
/// - tubular-helices (bool): Whether helices are emitted as tubes instead of ribbons.
/// - linear-segments (int): Longitudinal curve subdivisions.
/// - radial-segments (int): Radial profile subdivisions.
/// - quality (str): Geometry quality preset from `"lowest"` through `"highest"`, or `"auto"`/`"custom"`.
/// - decimate (int, float): Molfig semantic decimation strength in the range `0` to `1`.
/// -> bytes
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
  decimate: 0,
) = _plugin.to_mtl(_normalize-data(data), bytes(_mesh-options(format, representation, color-theme, theme, sphere-detail, radius-scale, atom-radius, bond-radius, infer-bonds, center, assembly, alt-loc, block-index, block-header, ribbon-radius, ribbon-width, helix-profile, round-cap, sheet-arrow-factor, tubular-helices, linear-segments, radial-segments, quality, decimate)))

/// Export a molecular structure as a binary STL triangle mesh.
///
/// STL contains geometry only; color themes and face groups cannot be
/// represented by the format.
///
/// - data (any): Structure bytes, inline PDB or mmCIF text, or a Typst 0.15+ path value.
/// - format (str): Input format: `"auto"`, `"pdb"`, `"cif"`, `"mmcif"`, or `"bcif"`.
/// - representation (str): Molecular representation used to construct the mesh.
/// - color-theme (str): Color theme used during semantic construction; STL does not store its colors.
/// - theme (dictionary): Mol\* Viewer theme overrides used during semantic construction.
/// - sphere-detail (int): Icosphere subdivision detail used by sphere-based visuals.
/// - radius-scale (int, float): Global multiplier for molecular radii.
/// - atom-radius (int, float): Base atom radius used by ball-and-stick-style visuals.
/// - bond-radius (int, float): Base bond-cylinder radius.
/// - infer-bonds (bool): Whether missing covalent bonds are inferred from molecular geometry.
/// - center (bool): Whether the exported mesh is centered using the visible Mol\* bounding sphere.
/// - assembly (str): Biological assembly identifier, or `"asymmetric-unit"` to use the source asymmetric unit.
/// - alt-loc (str): Alternate-location selector; an empty string uses the default highest-occupancy policy.
/// - block-index (none, int): Zero-based CIF or BinaryCIF data-block index.
/// - block-header (str): CIF or BinaryCIF data-block header to select instead of `block-index`.
/// - ribbon-radius (int, float): Polymer tube radius for ribbon-derived geometry.
/// - ribbon-width (int, float): Polymer ribbon width.
/// - helix-profile (str): Helix cross-section profile: `"elliptical"`, `"rounded"`, or `"square"`.
/// - round-cap (bool): Whether polymer segment ends use rounded caps.
/// - sheet-arrow-factor (int, float): Width multiplier for beta-sheet arrow tips.
/// - tubular-helices (bool): Whether helices are emitted as tubes instead of ribbons.
/// - linear-segments (int): Longitudinal curve subdivisions.
/// - radial-segments (int): Radial profile subdivisions.
/// - quality (str): Geometry quality preset from `"lowest"` through `"highest"`, or `"auto"`/`"custom"`.
/// - decimate (int, float): Molfig semantic decimation strength in the range `0` to `1`.
/// -> bytes
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
  decimate: 0,
) = _plugin.to_stl(_normalize-data(data), bytes(_mesh-options(format, representation, color-theme, theme, sphere-detail, radius-scale, atom-radius, bond-radius, infer-bonds, center, assembly, alt-loc, block-index, block-header, ribbon-radius, ribbon-width, helix-profile, round-cap, sheet-arrow-factor, tubular-helices, linear-segments, radial-segments, quality, decimate)))

/// Export a molecular structure as an ASCII PLY triangle mesh.
///
/// PLY preserves Molfig face-group values but does not carry OBJ materials.
///
/// - data (any): Structure bytes, inline PDB or mmCIF text, or a Typst 0.15+ path value.
/// - format (str): Input format: `"auto"`, `"pdb"`, `"cif"`, `"mmcif"`, or `"bcif"`.
/// - representation (str): Molecular representation used to construct the mesh.
/// - color-theme (str): Color theme used during semantic construction; PLY does not store its colors.
/// - theme (dictionary): Mol\* Viewer theme overrides used during semantic construction.
/// - sphere-detail (int): Icosphere subdivision detail used by sphere-based visuals.
/// - radius-scale (int, float): Global multiplier for molecular radii.
/// - atom-radius (int, float): Base atom radius used by ball-and-stick-style visuals.
/// - bond-radius (int, float): Base bond-cylinder radius.
/// - infer-bonds (bool): Whether missing covalent bonds are inferred from molecular geometry.
/// - center (bool): Whether the exported mesh is centered using the visible Mol\* bounding sphere.
/// - assembly (str): Biological assembly identifier, or `"asymmetric-unit"` to use the source asymmetric unit.
/// - alt-loc (str): Alternate-location selector; an empty string uses the default highest-occupancy policy.
/// - block-index (none, int): Zero-based CIF or BinaryCIF data-block index.
/// - block-header (str): CIF or BinaryCIF data-block header to select instead of `block-index`.
/// - ribbon-radius (int, float): Polymer tube radius for ribbon-derived geometry.
/// - ribbon-width (int, float): Polymer ribbon width.
/// - helix-profile (str): Helix cross-section profile: `"elliptical"`, `"rounded"`, or `"square"`.
/// - round-cap (bool): Whether polymer segment ends use rounded caps.
/// - sheet-arrow-factor (int, float): Width multiplier for beta-sheet arrow tips.
/// - tubular-helices (bool): Whether helices are emitted as tubes instead of ribbons.
/// - linear-segments (int): Longitudinal curve subdivisions.
/// - radial-segments (int): Radial profile subdivisions.
/// - quality (str): Geometry quality preset from `"lowest"` through `"highest"`, or `"auto"`/`"custom"`.
/// - decimate (int, float): Molfig semantic decimation strength in the range `0` to `1`.
/// -> bytes
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
  decimate: 0,
) = _plugin.to_ply(_normalize-data(data), bytes(_mesh-options(format, representation, color-theme, theme, sphere-detail, radius-scale, atom-radius, bond-radius, infer-bonds, center, assembly, alt-loc, block-index, block-header, ribbon-radius, ribbon-width, helix-profile, round-cap, sheet-arrow-factor, tubular-helices, linear-segments, radial-segments, quality, decimate)))

/// Inspect molecular, Model/Structure/Unit, representation, and mesh-planning metadata.
///
/// This performs Molfig's parsing and semantic representation work without
/// sending a mesh to `maquette` for document rendering.
///
/// - data (any): Structure bytes, inline PDB or mmCIF text, or a Typst 0.15+ path value.
/// - format (str): Input format: `"auto"`, `"pdb"`, `"cif"`, `"mmcif"`, or `"bcif"`.
/// - representation (str): Molecular representation whose semantic metadata is inspected.
/// - color-theme (str): Mol\* color theme used during semantic construction.
/// - theme (dictionary): Mol\* Viewer theme overrides, including `globalName`, `carbonColor`, and `symmetryColor`.
/// - sphere-detail (int): Icosphere subdivision detail used by sphere-based visuals.
/// - radius-scale (int, float): Global multiplier for molecular radii.
/// - atom-radius (int, float): Base atom radius used by ball-and-stick-style visuals.
/// - bond-radius (int, float): Base bond-cylinder radius.
/// - infer-bonds (bool): Whether missing covalent bonds are inferred from molecular geometry.
/// - center (bool): Whether geometry bounds and export planning use centered coordinates.
/// - assembly (str): Biological assembly identifier, or `"asymmetric-unit"` to use the source asymmetric unit.
/// - alt-loc (str): Alternate-location selector; an empty string uses the default highest-occupancy policy.
/// - block-index (none, int): Zero-based CIF or BinaryCIF data-block index.
/// - block-header (str): CIF or BinaryCIF data-block header to select instead of `block-index`.
/// - ribbon-radius (int, float): Polymer tube radius for ribbon-derived geometry.
/// - ribbon-width (int, float): Polymer ribbon width.
/// - helix-profile (str): Helix cross-section profile: `"elliptical"`, `"rounded"`, or `"square"`.
/// - round-cap (bool): Whether polymer segment ends use rounded caps.
/// - sheet-arrow-factor (int, float): Width multiplier for beta-sheet arrow tips.
/// - tubular-helices (bool): Whether helices are emitted as tubes instead of ribbons.
/// - linear-segments (int): Longitudinal curve subdivisions.
/// - radial-segments (int): Radial profile subdivisions.
/// - quality (str): Geometry quality preset from `"lowest"` through `"highest"`, or `"auto"`/`"custom"`.
/// - decimate (int, float): Molfig semantic decimation strength in the range `0` to `1`.
/// -> dictionary
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
  decimate: 0,
) = json(_plugin.info(_normalize-data(data), bytes(_mesh-options(format, representation, color-theme, theme, sphere-detail, radius-scale, atom-radius, bond-radius, infer-bonds, center, assembly, alt-loc, block-index, block-header, ribbon-radius, ribbon-width, helix-profile, round-cap, sheet-arrow-factor, tubular-helices, linear-segments, radial-segments, quality, decimate))))

/// Convert a molecular structure and render it as Typst content with `maquette`.
///
/// OBJ materials generated from the selected color theme are merged into
/// `config.materials`; user-provided entries take precedence.
///
/// - data (any): Structure bytes, inline PDB or mmCIF text, or a Typst 0.15+ path value.
/// - format (str): Input format: `"auto"`, `"pdb"`, `"cif"`, `"mmcif"`, or `"bcif"`.
/// - mesh-format (str): Intermediate mesh format: `"obj"`, `"stl"`, or `"ply"`.
/// - representation (str): Molecular representation, such as `"default"`, `"cartoon"`, `"spacefill"`, `"ball-and-stick"`, `"surface"`, `"ribbon"`, or `"backbone"`.
/// - color-theme (str): Mol\* color theme used to assign OBJ materials.
/// - theme (dictionary): Mol\* Viewer theme overrides, including `globalName`, `carbonColor`, and `symmetryColor`.
/// - sphere-detail (int): Icosphere subdivision detail used by sphere-based visuals.
/// - radius-scale (int, float): Global multiplier for molecular radii.
/// - atom-radius (int, float): Base atom radius used by ball-and-stick-style visuals.
/// - bond-radius (int, float): Base bond-cylinder radius.
/// - infer-bonds (bool): Whether missing covalent bonds are inferred from molecular geometry.
/// - center (bool): Whether the mesh is centered using the visible Mol\* bounding sphere.
/// - assembly (str): Biological assembly identifier, or `"asymmetric-unit"` to use the source asymmetric unit.
/// - alt-loc (str): Alternate-location selector; an empty string uses the default highest-occupancy policy.
/// - block-index (none, int): Zero-based CIF or BinaryCIF data-block index.
/// - block-header (str): CIF or BinaryCIF data-block header to select instead of `block-index`.
/// - ribbon-radius (int, float): Polymer tube radius for ribbon-derived geometry.
/// - ribbon-width (int, float): Polymer ribbon width.
/// - helix-profile (str): Helix cross-section profile: `"elliptical"`, `"rounded"`, or `"square"`.
/// - round-cap (bool): Whether polymer segment ends use rounded caps.
/// - sheet-arrow-factor (int, float): Width multiplier for beta-sheet arrow tips.
/// - tubular-helices (bool): Whether helices are emitted as tubes instead of ribbons.
/// - linear-segments (int): Longitudinal curve subdivisions.
/// - radial-segments (int): Radial profile subdivisions.
/// - quality (str): Geometry quality preset from `"lowest"` through `"highest"`, or `"auto"`/`"custom"`.
/// - decimate (auto, int, float): Molfig semantic decimation strength; `auto` consumes numeric `config.decimate`.
/// - config (dictionary): Configuration forwarded to the selected `maquette` renderer after Molfig-specific normalization.
/// - width (auto, relative): Requested output width.
/// - height (auto, relative): Requested output height.
/// - output-format (str): Rendered image format, normally `"png"` or `"svg"`.
/// -> content
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
  decimate: auto,
  config: (:),
  width: auto,
  height: auto,
  output-format: "png",
) = {
  let semantic-decimate = _semantic-decimate(decimate, config)
  let mesh-config = _mesh-options(format, representation, color-theme, theme, sphere-detail, radius-scale, atom-radius, bond-radius, infer-bonds, center, assembly, alt-loc, block-index, block-header, ribbon-radius, ribbon-width, helix-profile, round-cap, sheet-arrow-factor, tubular-helices, linear-segments, radial-segments, quality, semantic-decimate)
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
  _render-mesh(object.mesh, mesh-format, _strip-maquette-decimate(config, semantic-decimate), object.materials, width, height, output-format)
}

/// Build a rendered molecular object together with its mesh and semantic metadata.
///
/// The returned dictionary contains `kind`, `format`, `mesh_format`, `mesh`,
/// `materials`, `info`, and rendered `content` fields.
///
/// - data (any): Structure bytes, inline PDB or mmCIF text, or a Typst 0.15+ path value.
/// - format (str): Input format: `"auto"`, `"pdb"`, `"cif"`, `"mmcif"`, or `"bcif"`.
/// - mesh-format (str): Intermediate mesh format: `"obj"`, `"stl"`, or `"ply"`.
/// - representation (str): Molecular representation, such as `"default"`, `"cartoon"`, `"spacefill"`, `"ball-and-stick"`, `"surface"`, `"ribbon"`, or `"backbone"`.
/// - color-theme (str): Mol\* color theme used to assign OBJ materials.
/// - theme (dictionary): Mol\* Viewer theme overrides, including `globalName`, `carbonColor`, and `symmetryColor`.
/// - sphere-detail (int): Icosphere subdivision detail used by sphere-based visuals.
/// - radius-scale (int, float): Global multiplier for molecular radii.
/// - atom-radius (int, float): Base atom radius used by ball-and-stick-style visuals.
/// - bond-radius (int, float): Base bond-cylinder radius.
/// - infer-bonds (bool): Whether missing covalent bonds are inferred from molecular geometry.
/// - center (bool): Whether the mesh is centered using the visible Mol\* bounding sphere.
/// - assembly (str): Biological assembly identifier, or `"asymmetric-unit"` to use the source asymmetric unit.
/// - alt-loc (str): Alternate-location selector; an empty string uses the default highest-occupancy policy.
/// - block-index (none, int): Zero-based CIF or BinaryCIF data-block index.
/// - block-header (str): CIF or BinaryCIF data-block header to select instead of `block-index`.
/// - ribbon-radius (int, float): Polymer tube radius for ribbon-derived geometry.
/// - ribbon-width (int, float): Polymer ribbon width.
/// - helix-profile (str): Helix cross-section profile: `"elliptical"`, `"rounded"`, or `"square"`.
/// - round-cap (bool): Whether polymer segment ends use rounded caps.
/// - sheet-arrow-factor (int, float): Width multiplier for beta-sheet arrow tips.
/// - tubular-helices (bool): Whether helices are emitted as tubes instead of ribbons.
/// - linear-segments (int): Longitudinal curve subdivisions.
/// - radial-segments (int): Radial profile subdivisions.
/// - quality (str): Geometry quality preset from `"lowest"` through `"highest"`, or `"auto"`/`"custom"`.
/// - decimate (auto, int, float): Molfig semantic decimation strength; `auto` consumes numeric `config.decimate`.
/// - config (dictionary): Configuration forwarded to the selected `maquette` renderer after Molfig-specific normalization.
/// - width (auto, relative): Requested output width.
/// - height (auto, relative): Requested output height.
/// - output-format (str): Rendered image format, normally `"png"` or `"svg"`.
/// -> dictionary
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
  decimate: auto,
  config: (:),
  width: auto,
  height: auto,
  output-format: "png",
) = {
  let semantic-decimate = _semantic-decimate(decimate, config)
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
    decimate: semantic-decimate,
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
    content: _render-mesh(object.mesh, mesh-format, _strip-maquette-decimate(config, semantic-decimate), object.materials, width, height, output-format),
  )
}

/// Generate a mesh and inspect it with `maquette`'s format-specific metadata helper.
///
/// - data (any): Structure bytes, inline PDB or mmCIF text, or a Typst 0.15+ path value.
/// - format (str): Input format: `"auto"`, `"pdb"`, `"cif"`, `"mmcif"`, or `"bcif"`.
/// - mesh-format (str): Mesh format inspected by `maquette`: `"obj"`, `"stl"`, or `"ply"`.
/// - config (dictionary): Camera and projection configuration used by `maquette` while computing mesh metadata.
/// - mesh-args (arguments): Additional named Molfig mesh options accepted by the selected export function.
/// -> dictionary
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
