# mercator

![logo](https://raw.githubusercontent.com/bernsteining/mercator/refs/heads/main/examples/data/logo.png)

Mercator is a Typst plugin to render GeoJSON and TopoJSON as SVG maps.

## usage

```typst
#import "@preview/mercator:0.1.2": *

#let world = read("examples/data/world.json", encoding: "utf8")

#render-map(world, json.encode((
  projection: (
    type: "orthographic",
    center_lat: 45,
    center_lon: 10,
  ),
  graticule: (step: 15),
)), width: 100%)
```

## documentation

Check the [documentation](https://github.com/bernsteining/mercator/raw/refs/heads/main/examples/documentation.pdf), it covers all the features with examples.

## config options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `stroke` | string | `"black"` | Stroke color. Supports `{property_name}` interpolation. |
| `stroke_width` | float | `0.05` | Stroke width |
| `fill` | string | `"white"` | Fill color. Supports `{property_name}` interpolation. |
| `fill_opacity` | float | `1.0` | Fill opacity |
| `fill_pattern` | string | none | `"hatched"`, `"crosshatched"`, or `"dotted"`. Supports `{property_name}`. |
| `point_radius` | float | `stroke_width * 5` | Radius for Point/MultiPoint geometries |
| `point_color` | string | same as `fill` | Point fill color. `"none"` hides points. Supports `{property_name}`. |
| `viewbox` | array | auto | Manual viewbox as `(x, y, width, height)` |
| `viewbox_padding` | float | `0.15` | Padding fraction around auto-computed viewbox |
| `label` | string or array | none | Label template: `"{name}"` or array of `{text, font_size, color, font_family}` objects |
| `label_color` | string | `"black"` | Default label color |
| `label_font_size` | float | `0.3` | Default label font size |
| `label_font_family` | string | `"Arial"` | Default label font family |
| `projection` | object | equirectangular | Projection config (see below) |
| `graticule` | object | none | Graticule overlay config (see below) |
| `tissot` | object | none | Tissot's indicatrix overlay config (see below) |

### projections

| Type | Category | Parameters |
|------|----------|------------|
| `equirectangular` | Cylindrical | `central_meridian` |
| `mercator` | Cylindrical | `central_meridian` |
| `cassini` | Cylindrical | `central_meridian` |
| `lambert_conformal_conic` | Conic | `standard_parallel_1`, `standard_parallel_2`, `central_meridian`, `latitude_of_origin` |
| `albers_equal_area` | Conic | `standard_parallel_1`, `standard_parallel_2`, `central_meridian`, `latitude_of_origin` |
| `bonne` | Pseudo-conic | `standard_parallel`, `central_meridian` |
| `polyconic` | Pseudo-conic | `central_meridian` |
| `robinson` | Pseudo-cylindrical | `central_meridian` |
| `natural_earth` | Pseudo-cylindrical | `central_meridian` |
| `hammer` | Pseudo-cylindrical | `central_meridian` |
| `winkel_tripel` | Pseudo-cylindrical | `central_meridian` |
| `orthographic` | Azimuthal | `center_lat`, `center_lon` |
| `gnomonic` | Azimuthal | `center_lat`, `center_lon` |
| `lambert_azimuthal_equal_area` | Azimuthal | `center_lat`, `center_lon` |
| `azimuthal_equidistant` | Azimuthal | `center_lat`, `center_lon` |
| `wiechel` | Pseudo-azimuthal | `center_lat`, `center_lon` |
| `peirce_quincuncial` | Other | `center_lon` |
| `authagraph` | Other | _(no parameters)_ |

### graticule

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `step` | float | `15.0` | Degrees between grid lines |
| `color` | string | `"#ccc"` | Line color |
| `width` | float | `0.5` | Line width |
| `opacity` | float | `0.6` | Line opacity |

### tissot

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `step` | float | `30.0` | Degrees between indicator circles |
| `radius` | float | `5.0` | Circle radius in degrees |
| `fill` | string | `"red"` | Fill color |
| `fill_opacity` | float | `0.3` | Fill opacity |
| `stroke` | string | `"red"` | Stroke color |
| `stroke_width` | float | `0.5` | Stroke width |
| `max_lat` | float | `60.0` | Maximum latitude for indicators |
