# Mercator

[Mercator](https://github.com/bernsteining/mercator/tree/main) is a typst package to render GeoJSON as SVG in typst.

## Usage

````typst
#import "@preview/mercator:0.1.0"

#show raw.where(lang: "geojson"): it => mercator.render-map(it.text, config, width: 400pt)

// inline

#let config = json.encode((
  "stroke": "black",
  "stroke_width": 0.02,
  "fill": "green",
  "fill_opacity": 0.5,
  "viewbox": array((10.0, -70.0, 15.0, 15.0))))

```geojson
<GeoJSON>
```

// from file

#let france = read(
  "departements_fr.json",
  encoding: "utf8",
)

#let config3 = json.encode((
  "stroke": "red",
  "stroke_width": 0.005,
  "fill": "white",
  "fill_opacity": 0.5,
  "viewbox": array((-5.0, -54.0, 15.0, 14.6))))

#figure(mercator.render-map(france, config3, width:550pt, height: 400pt), caption: "Départements français")
````

# [example](https://github.com/bernsteining/mercator/blob/main/mercator/example/example.typ)

![](https://raw.githubusercontent.com/bernsteining/mercator/refs/heads/main/mercator/example/french_map.png)
