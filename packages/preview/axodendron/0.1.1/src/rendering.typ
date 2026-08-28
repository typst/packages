// Physical and topological render composition.

#import "protocol.typ": _plugin, _request, _positive, _node-id-array, _unique, _unwrap, _require-payload
#import "analysis.typ": _resolved-view, _selection
#import "cetz.typ": _projected-anchor, cetz-annotate

#let _color(color-by, colormap, minimum, maximum) = {
  if color-by == "type" {
    (mode: "by-type")
  } else if type(color-by) == str {
    (mode: "uniform", color: color-by)
  } else {
    let is-metric-result = type(color-by) == dictionary and "data" in color-by
    let field = if is-metric-result {
      let data = color-by.at("data")
      if data.at("kind") != "node-field" {
        panic("Axodendron: `color-by` accepts MetricResult only after explicit conversion to NodeField")
      }
      data.at("value")
    } else {
      color-by
    }
    (
      mode: "scalar",
      node_ids: field.at("node_ids"),
      values: field.at("values"),
      minimum: minimum,
      maximum: maximum,
      colormap: colormap,
      fingerprint: if is-metric-result {
        color-by.at("source").at("morphology_fingerprint")
      } else {
        field.at("fingerprint", default: none)
      },
    )
  }
}

#let _display-unit(unit) = if unit == "um" { "µm" } else { unit }

#let _format-overlay-number(value) = {
  let magnitude = calc.abs(value)
  str(if magnitude >= 100 {
    calc.round(value, digits: 0)
  } else if magnitude >= 10 {
    calc.round(value, digits: 1)
  } else if magnitude >= 1 {
    calc.round(value, digits: 2)
  } else if magnitude >= 0.1 {
    calc.round(value, digits: 3)
  } else {
    calc.round(value, digits: 4)
  })
}

#let _overlay-dx(position, inset) = {
  if position == left or position == top + left or position == bottom + left {
    inset
  } else {
    -inset
  }
}

#let _overlay-dy(position, inset) = {
  if position == bottom or position == bottom + left or position == bottom + right {
    -inset
  } else {
    inset
  }
}

#let _palette-stops(name) = if name == "magma" {
  ("#000004", "#51127c", "#b73779", "#fc8961", "#fcfdbf")
} else {
  ("#440154", "#3b528b", "#21918c", "#5ec962", "#fde725")
}

/// Render a radius-aware morphology as one WASM-generated SVG, then add labels
/// and a scale bar as native Typst content. `width` and `height` are page units;
/// all canvas and morphology values are unitless numbers.
///
/// - cell (dictionary): The morphology to render.
/// - projection (str, dictionary): Named or custom orthographic projection.
/// - color-by (str, dictionary): Compartment coloring, a uniform color, or scalar node data.
/// - colormap (str): Named scalar palette, either `"viridis"` or `"magma"`.
/// - minimum (none, int, float): Optional lower bound for scalar coloring.
/// - maximum (none, int, float): Optional upper bound for scalar coloring.
/// - width (length): Positive Typst width of the render block.
/// - height (length): Positive Typst height of the render block.
/// - canvas-width (int): Positive SVG viewport width in unitless pixels.
/// - canvas-height (int): Positive SVG viewport height in unitless pixels.
/// - padding (int, float): Non-negative SVG viewport padding.
/// - geometry (str): Segment geometry mode, such as `"tapered"` or `"skeleton"`.
/// - radius-mode (str): Radius display policy applied to neurites.
/// - soma-mode (str): Soma display policy.
/// - stroke-width (int, float): Skeleton or centerline width in SVG pixels.
/// - minimum-radius (int, float): Lower display-radius clamp in SVG pixels.
/// - maximum-radius (int, float): Upper neurite display-radius clamp in SVG pixels.
/// - maximum-soma-radius (int, float): Upper soma display-radius clamp in SVG pixels.
/// - radius-scale (int, float): Positive multiplier applied to neurite radii.
/// - radius-exponent (int, float): Positive exponent applied to neurite radii.
/// - soma-scale (int, float): Positive multiplier applied to soma radii.
/// - background (none, str): Optional SVG background color.
/// - outline-color (none, str): Optional segment-outline color.
/// - outline-width (int, float): Non-negative segment-outline width in SVG pixels.
/// - display-tolerance (none, int, float): Optional display-only simplification tolerance in `cell.units`.
/// - include-nodes (bool): Whether the generated SVG should include node elements.
/// - anchor-nodes (array): Additional integer node IDs whose projected positions are returned.
/// - labels (array): Typst-native annotations returned by `label`.
/// - markers (array): Typst-native annotations returned by `marker`.
/// - cetz (none, module): Imported CeTZ module required by `cetz-labels`.
/// - cetz-labels (array): Leader annotations returned by `cetz-label`.
/// - legend (none, dictionary): Optional categorical legend returned by `legend`.
/// - color-bar (none, dictionary): Optional scalar color bar returned by `color-bar`.
/// - scale-bar (none, dictionary): Optional physical scale bar returned by `scale-bar`.
/// - strict-node-ids (bool): Whether missing annotation and anchor node IDs should stop evaluation.
/// - return-report (bool): Whether to return geometry metadata with the rendered content.
/// -> content, dictionary
#let render(
  cell,
  projection: "xy",
  color-by: "type",
  colormap: "viridis",
  minimum: none,
  maximum: none,
  width: 120mm,
  height: 90mm,
  canvas-width: 800,
  canvas-height: 600,
  padding: 24,
  geometry: "tapered",
  radius-mode: "readable",
  soma-mode: "equivalent-sphere",
  stroke-width: 2,
  minimum-radius: 1,
  maximum-radius: 18,
  maximum-soma-radius: 96,
  radius-scale: 1,
  radius-exponent: 0.5,
  soma-scale: 1,
  background: none,
  outline-color: none,
  outline-width: 1,
  display-tolerance: none,
  include-nodes: false,
  anchor-nodes: (),
  labels: (),
  markers: (),
  cetz: none,
  cetz-labels: (),
  legend: none,
  color-bar: none,
  scale-bar: none,
  strict-node-ids: true,
  return-report: false,
) = {
  if width <= 0pt or height <= 0pt {
    panic("Axodendron: render width and height must be positive lengths")
  }
  if calc.abs(width / height - canvas-width / canvas-height) > 0.000001 {
    panic("Axodendron: page and SVG canvas aspect ratios must match")
  }
  let anchor-nodes = _node-id-array("anchor-nodes", anchor-nodes)
  if type(labels) != array or type(markers) != array or type(cetz-labels) != array {
    panic("Axodendron: labels, markers, and cetz-labels must be arrays")
  }
  if not cetz-labels.all(annotation => {
    type(annotation) == dictionary and annotation.at("kind", default: none) == "cetz-label"
  }) {
    panic("Axodendron: `cetz-labels` accepts only values returned by `cetz-label`")
  }
  if cetz-labels != () and cetz == none {
    panic("Axodendron: pass the imported CeTZ module as `cetz` when using `cetz-labels`")
  }
  let overlay-node-ids = _unique(
    (labels + markers + cetz-labels).map(annotation => annotation.at("node")) + anchor-nodes,
  )
  let options = (
    width: canvas-width,
    height: canvas-height,
    padding: padding,
    stroke_width: stroke-width,
    geometry: geometry,
    radius_mode: radius-mode,
    soma_mode: soma-mode,
    minimum_radius: minimum-radius,
    maximum_radius: maximum-radius,
    maximum_soma_radius: maximum-soma-radius,
    radius_scale: radius-scale,
    radius_exponent: radius-exponent,
    soma_scale: soma-scale,
    background: background,
    outline_color: outline-color,
    outline_width: outline-width,
    view: _resolved-view(cell, projection),
    color: _color(color-by, colormap, minimum, maximum),
    display_tolerance: display-tolerance,
    include_nodes: include-nodes,
    overlay_node_ids: overlay-node-ids,
    strict_overlay_ids: strict-node-ids,
  )
  let document = _unwrap(_plugin.render(_require-payload(cell), _request(options)))
  let projected = document.at("nodes")
  let node-anchors = projected.map(node => _projected-anchor(
    node,
    width,
    height,
    canvas-width,
    canvas-height,
  ))

  let native-body = block(width: width, height: height, clip: true)[
    #image(bytes(document.at("svg")), format: "svg", width: 100%, height: 100%, fit: "stretch")

    #for annotation in labels {
      let node = projected.find(item => item.at("node_id") == annotation.at("node"))
      if node == none {
        if strict-node-ids {
          panic("Axodendron: label node " + str(annotation.at("node")) + " was not rendered")
        }
      } else {
        let offset = annotation.at("offset")
        place(
          top + left,
          dx: width * node.at("x") / canvas-width + offset.at("x"),
          dy: height * node.at("y") / canvas-height + offset.at("y"),
          annotation.at("body"),
        )
      }
    }

    #for annotation in markers {
      let node = projected.find(item => item.at("node_id") == annotation.at("node"))
      if node == none {
        if strict-node-ids {
          panic("Axodendron: marker node " + str(annotation.at("node")) + " was not rendered")
        }
      } else {
        let offset = annotation.at("offset")
        let body = annotation.at("body")
        place(
          top + left,
          dx: width * node.at("x") / canvas-width + offset.at("x") - annotation.at("size") / 2,
          dy: height * node.at("y") / canvas-height + offset.at("y") - annotation.at("size") / 2,
          if body == none {
            circle(
              radius: annotation.at("size") / 2,
              fill: annotation.at("fill"),
              stroke: annotation.at("stroke"),
            )
          } else {
            box(
              width: annotation.at("size"),
              height: annotation.at("size"),
              align(center + horizon, body),
            )
          },
        )
      }
    }

    #if legend != none {
      place(
        legend.at("position"),
        dx: _overlay-dx(legend.at("position"), legend.at("inset")),
        dy: _overlay-dy(legend.at("position"), legend.at("inset")),
        block(
          inset: 4pt,
          fill: white.transparentize(8%),
          stroke: 0.4pt + luma(70%),
          radius: 2pt,
          stack(
            dir: ttb,
            spacing: 2pt,
            ..legend.at("entries").map(entry => grid(
              columns: (7pt, auto),
              column-gutter: 4pt,
              rect(width: 7pt, height: 7pt, fill: rgb(entry.at("color"))),
              text(size: 8pt, entry.at("label")),
            )),
          ),
        ),
      )
    }

    #if color-bar != none {
      let stops = _palette-stops(color-bar.at("colormap"))
      let bar-width = 70pt
      let stop-width = bar-width / stops.len()
      let palette = grid(
        columns: stops.map(_ => stop-width),
        ..stops.map(color => rect(width: stop-width, height: 6pt, fill: rgb(color))),
      )
      let labeled-palette = if color-bar.at("label") == none {
        palette
      } else {
        stack(
          dir: ttb,
          spacing: color-bar.at("label-gap", default: 4pt),
          text(size: 8pt, color-bar.at("label")),
          palette,
        )
      }
      place(
        color-bar.at("position"),
        dx: _overlay-dx(color-bar.at("position"), color-bar.at("inset")),
        dy: _overlay-dy(color-bar.at("position"), color-bar.at("inset")),
        block(
          inset: 4pt,
          fill: white.transparentize(8%),
          stroke: 0.4pt + luma(70%),
          radius: 2pt,
          stack(
            dir: ttb,
            spacing: 2pt,
            labeled-palette,
            grid(
              columns: (bar-width / 2, bar-width / 2),
              align(left, text(size: 7pt, _format-overlay-number(color-bar.at("min")))),
              align(right, text(size: 7pt, _format-overlay-number(color-bar.at("max")))),
            ),
          ),
        ),
      )
    }

    #if scale-bar != none {
      let value = _positive("scale-bar.value", scale-bar.at("value"))
      let bar-width = width * value * document.at("pixels_per_unit") / canvas-width
      let bar-label = if scale-bar.at("label") == none {
        str(value) + " " + _display-unit(cell.at("units"))
      } else {
        scale-bar.at("label")
      }
      place(
        bottom + left,
        dx: scale-bar.at("inset"),
        dy: -scale-bar.at("inset"),
        stack(
          dir: ttb,
          spacing: 2pt,
          line(length: bar-width, stroke: scale-bar.at("stroke")),
          align(center, text(size: 8pt, bar-label)),
        ),
      )
    }
  ]
  let render-result = (
    body: native-body,
    width: width,
    height: height,
    canvas-width: canvas-width,
    canvas-height: canvas-height,
    node-anchors: node-anchors,
    report: document.at("report"),
    pixels-per-unit: document.at("pixels_per_unit"),
    source-node-count: document.at("source_node_count"),
    rendered-node-count: document.at("rendered_node_count"),
  )
  let body = if cetz-labels == () {
    native-body
  } else {
    cetz-annotate(
      render-result,
      cetz: cetz,
      labels: cetz-labels,
      strict: strict-node-ids,
    )
  }
  if return-report { render-result + (body: body,) } else { body }
}

/// Render an abstract rooted forest independently of physical projection.
///
/// Continuous vertical depth is restricted to topological depth, path length,
/// or radial distance. Branch and Strahler orders are discrete attributes and
/// should be supplied through `color-by`, not used as a continuous depth axis.
///
/// - cell (dictionary): Morphology to render.
/// - depth (str): `"topological"`, `"path-length"`, or `"radial-distance"`.
/// - color-by (str, dictionary): Compartment color, uniform color, or NodeField.
/// - colormap (str): Scalar color map.
/// - minimum (none, int, float): Optional scalar minimum.
/// - maximum (none, int, float): Optional scalar maximum.
/// - domain (str): Selection domain.
/// - kinds (array): Optional SWC kind filter.
/// - roots (array): Optional subtree roots.
/// - nodes (array): Optional explicit node IDs.
/// - width (length): Typst output width.
/// - height (length): Typst output height.
/// - canvas-width (int): SVG canvas width.
/// - canvas-height (int): SVG canvas height.
/// - padding (int, float): SVG padding.
/// - stroke-width (int, float): Edge width.
/// - node-radius (int, float): Node radius when `include-nodes` is true.
/// - background (none, str): Optional SVG background.
/// - include-nodes (bool): Draw topology nodes.
/// - anchor-nodes (array): Node IDs for returned projected anchors.
/// - cetz (none, module): Optional caller-injected CeTZ module.
/// - cetz-labels (array): Leader annotations returned by `cetz-label`.
/// - strict-node-ids (bool): Whether missing anchor/annotation nodes are errors.
/// - return-report (bool): Return body, anchors, and layout provenance.
/// -> content, dictionary
#let render-tree(
  cell,
  depth: "topological",
  color-by: "type",
  colormap: "viridis",
  minimum: none,
  maximum: none,
  domain: "neurites",
  kinds: (),
  roots: (),
  nodes: (),
  width: 120mm,
  height: 90mm,
  canvas-width: 800,
  canvas-height: 600,
  padding: 24,
  stroke-width: 2,
  node-radius: 2.5,
  background: none,
  include-nodes: false,
  anchor-nodes: (),
  cetz: none,
  cetz-labels: (),
  strict-node-ids: true,
  return-report: false,
) = {
  if width <= 0pt or height <= 0pt {
    panic("Axodendron: render-tree width and height must be positive lengths")
  }
  if calc.abs(width / height - canvas-width / canvas-height) > 0.000001 {
    panic("Axodendron: page and SVG tree canvas aspect ratios must match")
  }
  let anchor-nodes = _node-id-array("anchor-nodes", anchor-nodes)
  if type(cetz-labels) != array {
    panic("Axodendron: `cetz-labels` must be an array")
  }
  if cetz-labels != () and cetz == none {
    panic("Axodendron: pass the imported CeTZ module as `cetz` when using `cetz-labels`")
  }
  let overlay-node-ids = _unique(
    anchor-nodes + cetz-labels.map(annotation => annotation.at("node")),
  )
  let document = _unwrap(_plugin.render_tree(
    _require-payload(cell),
    _request((
      width: canvas-width,
      height: canvas-height,
      padding: padding,
      stroke_width: stroke-width,
      node_radius: node-radius,
      depth: depth,
      selection: _selection(domain: domain, kinds: kinds, roots: roots, nodes: nodes),
      color: _color(color-by, colormap, minimum, maximum),
      background: background,
      include_nodes: include-nodes,
      overlay_node_ids: overlay-node-ids,
      strict_overlay_ids: strict-node-ids,
    )),
  ))
  let native-body = block(width: width, height: height, clip: true)[
    #image(bytes(document.at("svg")), format: "svg", width: 100%, height: 100%, fit: "stretch")
  ]
  let node-anchors = document.at("nodes").map(node => _projected-anchor(
    node,
    width,
    height,
    canvas-width,
    canvas-height,
  ))
  let result = (
    body: native-body,
    width: width,
    height: height,
    canvas-width: canvas-width,
    canvas-height: canvas-height,
    node-anchors: node-anchors,
    report: document.at("report"),
    source-node-count: document.at("source_node_count"),
    rendered-node-count: document.at("rendered_node_count"),
  )
  let body = if cetz-labels == () {
    native-body
  } else {
    cetz-annotate(result, cetz: cetz, labels: cetz-labels, strict: strict-node-ids)
  }
  if return-report { result + (body: body,) } else { body }
}
