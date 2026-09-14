# Mercator

Mercator is a typst package to render GeoJSON in typst documents.

# API 

The [render-map(code, config, ..args)](mercator.typ) function has 2+ arguments:

* code: GeoJSON data

* config: The config to modify how the map will be rendered

```json
{
  "stroke": "black",
  "stroke_width": 0.05,
  "fill": "red",
  "fill_opacity": 0.5,
  "viewbox": null,
  "label_color": "black",
  "label_font_size": 0.3,
  "label_font_family": "Arial",
  "show_labels": true
}
```

These are the default config values. 

* `viewbox`
* `label_color` 
* `label_font_size`
* `label_font_family`
* `show_labels` 

fields are Optional and can be omitted in the config.

NB: When `viewbox` is omitted or set to None, it is automatically computed via the GeoJSON coordinates to render the whole map in the canvas.

* ..args: Remaining arguments passed to [image.decode](https://typst.app/docs/reference/visualize/image/)

---

You can also use it as follows:

````typst 
#import "@preview/mercator:0.1.1"
#show raw.where(lang: "geojson"): it => mercator.render-map(it.text, config)

```geojson 
<your geojson code here>
```
````

# [examples](https://github.com/bernsteining/mercator/tree/main/mercator/examples)

```typst
#import "@preview/mercator:0.1.1"

#let sweden = read(
  "swedish_regions.json",
  encoding: "utf8",
)

#let config = json.encode((
  "stroke": "black",
  "stroke_width": 0.02,
  "fill": "green",
  "fill_opacity": 0.5,
  "viewbox": array((15.0, -73.4, 10.0, 10.0))))

#figure(mercator.render-map(sweden, config2, height:400pt), caption: "Swedish regions")
```

![swedish map](https://github.com/bernsteining/mercator/blob/main/mercator/examples/basic/swedish_regions.png)

````typst
#import "@preview/mercator:0.1.1"

#let france = read(
  "departements_fr.json",
  encoding: "utf8",
)

#let config3 = json.encode((
  "stroke": "red",
  "stroke_width": 0.005,
  "fill": "white",
  "fill_opacity": 0.5,
  show_labels: false))

#figure(mercator.render-map(france, config3, width:550pt, height: 400pt), caption: "Départements français")

````

![french map](https://github.com/bernsteining/mercator/blob/main/mercator/examples/basic/french_map.png)

Check the source of [examples/basic/example.typ](https://github.com/bernsteining/mercator/blob/main/mercator/examples/basic/example.typ) and its result [example.pdf](https://github.com/bernsteining/mercator/tree/main/mercator/examples/basic/example.pdf).

Another [example](https://github.com/bernsteining/mercator/tree/main/mercator/examples/france/all_france.pdf) showcases the rendering of 403 maps in one shot.

