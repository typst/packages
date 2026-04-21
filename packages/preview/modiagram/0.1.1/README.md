[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fjonathandip%2Fmodiagram%2Fmaster%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://typst.app/universe/package/modiagram)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Typsium/alchemist/blob/master/LICENSE)

# modiagram
Draw molecular orbital and energy pathway diagrams: a package inspired by the LaTeX [`modiagram`](https://ctan.org/pkg/modiagram) package by Clemens Niederberger plus additional features for plotting energy pathway diagrams.

Requires [`@preview/cetz:0.4.2`](https://typst.app/universe/package/cetz) and [`"@preview/zero:0.6.1"`](https://typst.app/universe/package/zero).

---
## Quick start

```typst
#import "@preview/modiagram:0.1.1" as mo

#figure({
  import mo: *
  modiagram(
    ao(name: "1s-L", x: -1, energy:    0, electrons: "pair", label: $1s$),
    ao(name: "1s-R", x:  1, energy:    0, electrons: "pair", label: $1s$),
    ao(name: "S",    x:  0, energy: -0.5, electrons: "pair", label: $sigma$),
    ao(name: "S*",   x:  0, energy:  0.5, electrons: "",     label: $sigma^*$),
    connect("1s-L & S", "1s-R & S", "1s-L & S*", "1s-R & S*"),
    energy-axis(title: [Energy]),
  )
})
```
![example-01](images/example-01.png)

---
## Import styles

The recommended method for importing is to use an alias: this prevents certain functions in modiagram (particularly those from cetz) from overwriting the standard Typst functions (such as the `grid` function).

```typst
// Recommended — through an alias

#import "@preview/modiagram:0.1.1" as mo

#figure({
  import mo: *
  modiagram(
	ao(name: "test", x: 0, energy: 0, electrons: "pair", label: $1s$),
  )
})

// Named module — explicit prefix

#import "@preview/modiagram:0.1.1" as mo

#figure(
  mo.modiagram(
	ao(name: "test", x: 0, energy: 0, electrons: "pair", label: $1s$),
  )
)
```

---
## Reference

### `modiagram(...)`

Renders the complete diagram. All elements are passed as positional arguments.

| Parameter | Type | Description                                                                              |
| --------- | ---- | ---------------------------------------------------------------------------------------- |
| `...`     | any  | `ao()`, `connect()`, `config()`, `energy-axis()`, `en-pathway()`, `legend()`, `raw()`, cetz wrappers |
| `config`  | dict | Diagram-level overrides — same keys as `modiagram-setup()`                               |

---
### `ao(...)` — atomic / molecular orbital

Draws one orbital bar with optional electrons and label.

| Parameter      | Default | Description                                             |
| -------------- | ------- | ------------------------------------------------------- |
| `name`         | auto    | String identifier used by `connect()`                   |
| `x`            | `0`     | Horizontal position (float = cm, or any Typst length)   |
| `energy`       | `0`     | Vertical position (energy level)                        |
| `electrons`    | `""`    | Space-separated spin tokens: `"up"`, `"down"`, `"pair"` |
| `label`        | `none`  | Content placed below the bar, e.g. `$1s$`               |
| `color`        | `black` | Base color for bar, electrons, and label                |
| `bar-color`    | `auto`  | Bar color only (overrides `color`)                      |
| `el-color`     | `auto`  | Electron arrow color (overrides `color`)                |
| `label-color`  | `auto`  | Label color (overrides `color`)                         |
| `style`        | `auto`  | Per-orbital style (see **Orbital styles** below)        |
| `label-size`   | `auto`  | Font size for the label                                 |
| `label-gap`    | `auto`  | Gap between bar and label (cm)                          |
| `el-stroke-w`  | `auto`  | Electron arrow stroke width                             |
| `bar-stroke-w` | `auto`  | Bar stroke width                                        |
| `ao-width`     | `auto`  | Bar width (cm)                                          |
| `up-el-pos`    | `auto`  | X offset from bar center for ↑ electron                 |
| `down-el-pos`  | `auto`  | X offset from bar center for ↓ electron                 |

```typst
#figure({
  import mo: *
  modiagram(
	ao(name: "sigma2s1", x: 1.00, energy: 0.00, electrons: "pair", label: $sigma_(2s)$),
	ao(name: "2s1", x: 0.00, energy: 0.50, electrons: "pair", label: $2s$, bar-stroke-w: 1pt, bar-color: purple, label-color: black),
	ao(name: "2s2", x: 2.00, energy: 0.50, electrons: "pair", label: $2s$, el-stroke-w: .8pt, el-color: purple),
	ao(name: "sigma2s2", x: 1.00, energy: 1.00, electrons: "pair", label: $sigma_(2s)^*$),

	ao(name: "s2pz", x: 1.00, energy: 2.00, electrons: "pair", label: $sigma_(2p_z)$, ao-width: 0.5),
	ao(name: "π1", x: 0.75, energy: 3.00, electrons: "pair", label: $pi_(2p_x)$, color: red, label-size: 6pt, label-gap: 0.2cm),
	ao(name: "π2", x: 1.25, energy: 3.00, electrons: "pair", label: $pi_(2p_y)$, color: red, label-size: 6pt, label-gap: 0.2cm),
	ao(name: "π3", x: 0.75, energy: 4.00, electrons: "up", label: $pi_(2p_x)^*$, el-color: blue),
	ao(name: "π4", x: 1.25, energy: 4.00, electrons: "up", label: $pi_(2p_y)^*$, el-color: blue),
	ao(name: "S2pz", x: 1.00, energy: 5.00, electrons: "", label: $sigma_(2p_z)^*$, label-color: purple, ao-width: 0.5),

	ao(name: "lp1", x: +0.00, energy: 3.50, electrons: "up", label: $2p_z$, up-el-pos: 2.5pt, el-color: green),
	ao(name: "lp2", x: -0.50, energy: 3.50, electrons: "up", label: $2p_y$, up-el-pos: 0pt),
	ao(name: "lp3", x: -1.00, energy: 3.50, electrons: "pair", label: $2p_x$),

	ao(name: "rp1", x: +2.00, energy: 3.5, electrons: "pair", label: $2p_x$),
	ao(name: "rp2", x: +2.50, energy: 3.5, electrons: "up", label: $2p_y$),
	ao(name: "rp3", x: +3.00, energy: 3.5, electrons: "up", label: $2p_z$),  
  )
})
```

This is an (exaggerated) example of how all these settings can be used to represent atomic orbitals.

![example-02](/images/example-02.png)

---
### `connect(...)` — connection lines

Draws lines between pairs of orbitals.

```typst
connect("1s-L & S", "1s-R & S", style: "dashed", color: blue)
```

| Parameter     | Default | Description                            |
| ------------- | ------- | -------------------------------------- |
| `..pairs`     | —       | One or more `"nameA & nameB"` strings  |
| `style`       | `auto`  | Line style (see **Connection styles**) |
| `color`       | `auto`  | Line color                             |
| `thickness`   | `auto`  | Stroke width                           |
| `gap`         | `auto`  | Dot/dash spacing                       |
| `dash-length` | `auto`  | Dash segment length                    |
Building on the previous example, it is possible to pair orbitals using their "name" identifiers.

```typst
#figure({
  import mo: *
  modiagram(
	ao(name: "sigma2s1", x: 1.00, energy: 0.00, electrons: "pair", label: $sigma_(2s)$),
	ao(name: "2s1", x: 0.00, energy: 0.50, electrons: "pair", label: $2s$, bar-stroke-w: 1pt, bar-color: purple, label-color: black),
	ao(name: "2s2", x: 2.00, energy: 0.50, electrons: "pair", label: $2s$, el-stroke-w: .8pt, el-color: purple),
	ao(name: "sigma2s2", x: 1.00, energy: 1.00, electrons: "pair", label: $sigma_(2s)^*$),

	connect("2s1 & sigma2s1", "sigma2s1 & 2s2", style: "gray"),
	connect("2s1 & sigma2s2", "sigma2s2 & 2s2", style: "solid", color: olive),

	ao(name: "s2pz", x: 1.00, energy: 2.00, electrons: "pair", label: $sigma_(2p_z)$, ao-width: 0.5),
	ao(name: "π1", x: 0.75, energy: 3.00, electrons: "pair", label: $pi_(2p_x)$, color: red, label-size: 6pt, label-gap: 0.2cm),
	ao(name: "π2", x: 1.25, energy: 3.00, electrons: "pair", label: $pi_(2p_y)$, color: red, label-size: 6pt, label-gap: 0.2cm),
	ao(name: "π3", x: 0.75, energy: 4.00, electrons: "up", label: $pi_(2p_x)^*$, el-color: blue),
	ao(name: "π4", x: 1.25, energy: 4.00, electrons: "up", label: $pi_(2p_y)^*$, el-color: blue),
	ao(name: "S2pz", x: 1.00, energy: 5.00, electrons: "", label: $sigma_(2p_z)^*$, label-color: purple, ao-width: 0.5),

	ao(name: "lp1", x: +0.00, energy: 3.50, electrons: "up", label: $2p_z$, up-el-pos: 2.5pt, el-color: green),
	ao(name: "lp2", x: -0.50, energy: 3.50, electrons: "up", label: $2p_y$, up-el-pos: 0pt),
	ao(name: "lp3", x: -1.00, energy: 3.50, electrons: "pair", label: $2p_x$),

	ao(name: "rp1", x: +2.00, energy: 3.5, electrons: "pair", label: $2p_x$),
	ao(name: "rp2", x: +2.50, energy: 3.5, electrons: "up", label: $2p_y$),
	ao(name: "rp3", x: +3.00, energy: 3.5, electrons: "up", label: $2p_z$),

	connect("rp3 & rp2","rp2 & rp1"),
	connect("lp3 & lp2", "lp2 & lp1"),
	connect("lp1 & π1", "π1 & π2", "π2 & rp1", color: red, style: "dashed", dash-length: 0.5mm),

	connect("lp1 & π3", "π3 & π4", "π4 & rp1"),
	connect("lp1 & S2pz", "S2pz & rp1"),
	connect("lp1 & s2pz", "s2pz & rp1"),
  )
})
```

![example-03](/images/example-03.png)

---

### `connect-label(...)` — label along a connection

Places content along the line between two orbitals.

```typst
connect-label("a", "σ", $Delta E$, ratio: 50%, pad: 0.15, anchor: "south")
```

| Parameter | Default | Description                                   |
| --------- | ------- | --------------------------------------------- |
| `a`, `b`  | —       | Orbital names (must match a `connect()` pair) |
| `body`    | —       | Any Typst content                             |
| `ratio`   | `50%`   | Position along the line                       |
| `pad`     | `0`     | Perpendicular offset (positive = above)       |
| `size`    | `auto`  | Font size (scales text and math)              |
Useful for quickly adding annotations to the connecting lines between orbitals. For example:

```typst
#figure({
  import mo: *
	modiagram(
	ao(name: "1s-L", x: -1, energy: 0, electrons: "pair", label: $1s$),
	ao(name: "1s-R", x: 1, energy: 0, electrons: "pair", label: $1s$),
	ao(name: "S", x: 0, energy: -0.5, electrons: "pair", label: $sigma$),
	ao(name: "S*", x: 0, energy: 0.5, electrons: "", label: $sigma^*$),
	connect("1s-L & S", "1s-R & S", "1s-L & S*", "1s-R & S*"),

	connect-label("S*", "1s-R", [Higher en.], size: 5pt, pad: 0.1, ratio: 30%),
	connect-label("1s-L", "S*", [Higher en.], size: 5pt, pad: 0.1, ratio: 70%),
	connect-label("1s-L", "S", [Lower en.], size: 5pt, pad: 0.1),
	connect-label("S", "1s-R", [Lower en.], size: 5pt, pad: 0.1),
  )
})
```

---

### `energy-axis(...)` — energy arrow

Draws a vertical (or horizontal) energy arrow at the left of the diagram.

```typst
energy-axis(title: "Energy", pad: 0.7cm, style: "horizontal")
```

| Parameter | Default      | Description                         |
| --------- | ------------ | ----------------------------------- |
| `title`   | `none`       | Content near the arrowhead          |
| `pad`	    | `0.5`        | Gap from leftmost orbital edge (cm) |
| `style`   | `"vertical"` | `"vertical"` or `"horizontal"`      |
Example of use:

```typst
#figure({
  import mo: *
  modiagram(
	ao(name: "1s-L", x: -1, energy: 0, electrons: "pair", label: $1s$),
	ao(name: "1s-R", x: 1, energy: 0, electrons: "pair", label: $1s$),
	ao(name: "S", x: 0, energy: -0.5, electrons: "pair", label: $sigma$),
	ao(name: "S*", x: 0, energy: 0.5, electrons: "", label: $sigma^*$),
	connect("1s-L & S", "1s-R & S", "1s-L & S*", "1s-R & S*"),

	energy-axis(title: [Energy], style: "horizontal", pad: 0.7),
  )
})
```

![example-04](/images/example-04.png)

---

### `x-axis(title, padding, style)`
 
Draws a horizontal axis below the diagram. When used together with `energy-axis()`, the two axes share an origin corner automatically.
 
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | `content` | `none` | Label near the arrowhead |
| `pad` | `float` or `length` | `0.5` | Vertical gap from the lowest orbital (cm) |
| `style` | `str` | `"below"` | `"below"` or `"above"` (label position relative to arrow) |
 
```typst
#figure({
  import mo: *
  modiagram(
    ao(name: "1", x: 0, energy: 0,   electrons: "pair"),
    ao(name: "2", x: 1, energy: 0.3, electrons: "up"),
    ao(name: "3", x: 2, energy: 0.8, electrons: ""),
    energy-axis(title: [Energy]),
    x-axis(title: [Reaction coordinate]),
  )
})
```
 
---

### `config(...)` — inline diagram override

Applies settings to all subsequent elements within the same `modiagram()` call. Pass `auto` to reset a key to the diagram default.

```typst
modiagram(
  config(color: red, style: "square"),
  ao(...),                           // red, square
  config(color: black),              // reset color
  ao(...),                           // black, square
)
```

Accepted keys: `color`, `bar-color`, `el-color`, `label-color`, `style`, `label-size`, `label-gap`, `el-stroke-w`, `bar-stroke-w`, `ao-width`, `conn-style`, `up-el-pos`, `down-el-pos`, `x-scale`, `energy-scale`.

The `x-scale` and `energy-scale` functions are extremely useful: they allow you to scale ALL x and y coordinates without having to manually re-enter all the values. This also applies to CeTZ primitives inserted into `modiagram`. Here is an example.

```typst
#figure({
  import mo: *
  modiagram(
	config(color: blue),

	ao(name: "sigma2s1", x: 1.00, energy: 0.00, electrons: "pair", label: $sigma_(2s)$),
	ao(name: "2s1", x: 0.00, energy: 0.50, electrons: "pair", label: $2s$),
	ao(name: "2s2", x: 2.00, energy: 0.50, electrons: "pair", label: $2s$),
	ao(name: "sigma2s2", x: 1.00, energy: 1.00, electrons: "pair", label: $sigma_(2s)^*$),

	connect("2s1 & sigma2s1", "sigma2s1 & 2s2",),
	connect("2s1 & sigma2s2", "sigma2s2 & 2s2",),

	config(el-color: red, bar-color: olive, label-color: maroon, label-size: 6pt, label-gap: 6pt, energy-scale: 0.7, up-el-pos: -1.5pt, down-el-pos: 1.5pt),

	ao(name: "s2pz", x: 1.00, energy: 2.00+1, electrons: "pair", label: $sigma_(2p_z)$),
	ao(name: "π1", x: 0.75, energy: 3.00+1, electrons: "pair", label: $pi_(2p_x)$),
	ao(name: "π2", x: 1.25, energy: 3.00+1, electrons: "pair", label: $pi_(2p_y)$),
	ao(name: "π3", x: 0.75, energy: 4.00+1, electrons: "up", label: $pi_(2p_x)^*$),
	ao(name: "π4", x: 1.25, energy: 4.00+1, electrons: "up", label: $pi_(2p_y)^*$),
	ao(name: "S2pz", x: 1.00, energy: 5.00+1, electrons: "", label: $sigma_(2p_z)^*$),

	ao(name: "lp1", x: +0.00, energy: 3.50+1, electrons: "up", label: $2p_z$),
	ao(name: "lp2", x: -0.50, energy: 3.50+1, electrons: "up", label: $2p_y$),
	ao(name: "lp3", x: -1.00, energy: 3.50+1, electrons: "pair", label: $2p_x$),

	ao(name: "rp1", x: +2.00, energy: 3.5+1, electrons: "pair", label: $2p_x$),
	ao(name: "rp2", x: +2.50, energy: 3.5+1, electrons: "up", label: $2p_y$),
	ao(name: "rp3", x: +3.00, energy: 3.5+1, electrons: "up", label: $2p_z$),

	connect("rp3 & rp2","rp2 & rp1"),
	connect("lp3 & lp2", "lp2 & lp1"),

	connect("lp1 & π1", "π1 & π2", "π2 & rp1"),
	connect("lp1 & π3", "π3 & π4", "π4 & rp1"),
	connect("lp1 & S2pz", "S2pz & rp1"),
	connect("lp1 & s2pz", "s2pz & rp1"),
  )
})
```

![example-05](/images/example-05.png)

---

### `en-pathway(...)` — evenly-spaced orbital sequence

Generates a sequence of orbitals at uniform horizontal spacing, connected by lines. Useful for energy level diagrams (reaction pathways).

```typst
en-pathway(0, 0.5, 1.0, skip, 1.5,
  color: blue, labels: ($1s$, $2s$, $2p$, $3s$),
  conn-style: "dashed", show-energies: true)
```

Use `skip` as an energy value to advance `x` without drawing an orbital.

| Parameter       | Default    | Description                                                      |
| --------------- | ---------- | ---------------------------------------------------------------- |
| `..energies`    | —          | Energy values (float, int, length, or numeric string), or `skip` |
| `color`         | `black`    | Color for bars, electrons, labels, connections                   |
| `x-step`        | `1.2`      | Horizontal distance between orbitals (cm)                        |
| `style`         | `auto`     | Orbital style                                                    |
| `conn-style`    | `"dashed"` | Connection style between adjacent orbitals (`none` to disable)   |
| `labels`        | `none`     | Array of content, one per orbital                                |
| `name-prefix`   | `"ep"`     | Prefix for auto-generated orbital names                          |
| `x-start`       | `0`        | Starting x position                                              |
| `show-energies` | `false`    | Show energy value above each orbital                             |
| `energy-format` | `auto`     | Function `v => content` for custom energy display                |
| `energy-size`   | `auto`     | Font size for energy labels                                      |
| `bar-stroke-w`  | `1.5pt`    | Stroke width for bars and electrons                              |
| `ao-width`      | `0.75`     | Bar width (cm)                                                   |
| `legend`        | `none`     | Content label shown in the diagram legend; display options are set via `legend()` |

This feature is extremely useful for computational chemists who wish to represent energy pathways in a very straightforward manner. All you need to do is specify the energy values and labels. If you also specify the name, a unique identifier is assigned, allowing you to add content positioned relative to the energy bar.

```typst
#figure({
  import mo: *
  modiagram(
  
	config(energy-scale: 0.3),
	
	en-pathway(
	  -4, 4, -1, 2, -8,
	  labels: ([SM], [TS$alpha$-1], [Key], [TS$beta$-1], [P]),
	  show-energies: true,
	  name-prefix: "black"
	),
	
	en-pathway(
	  -1, 2, -5, 5, -4,
	  labels: ([SM], [$gamma$], [Int], [Ex], [`code`]),
	  color: olive,
	  name-prefix: "olive"
	),

	energy-axis(title: "E")
  )
})
```
![example-06](/images/example-06.png)

---

### `en-difference(...)`
 
Draws a vertical double-headed arrow between two orbitals with an optional boxed ΔE label.
 
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `orb-a` | `str` | — | First orbital name |
| `orb-b` | `str` | — | Second orbital name |
| `body` | `content` or `auto` | `auto` | Label (`auto` computes `\|ΔE\|` from orbital energies) |
| `ratio` | `ratio` | `50%` | Label position along the arrow |
| `pad` | `float/length` | `0` | Extra offset from the orbital right edge |
| `color` | `color` | `black` | Shared color |
| `line-color` | `color` or `auto` | `auto` | Arrow/line color only |
| `label-color` | `color` or `auto` | `auto` | Label color only |
| `show-label` | `bool` | `true` | Whether to show the ΔE label box |
| `thickness` | `length` | `0.5pt` | Stroke width |
| `size` | `length` or `auto` | `8pt` | Label font size |
| `title` | `content` | `none` | Secondary text inside the label box |
| `title-gap` | `length` | `0.4em` | Space between value and title |

It can be used with both `ao()` and `en-pathway()`; the key is to specify the correct orbitals. It is extremely useful for showing the energy difference between two orbitals.
 
```typst
#figure({
  import mo: *
  modiagram(
    ao(name: "homo", x: 0, energy: -0.6, electrons: "pair",  label: [HOMO]),
    ao(name: "lumo", x: 0, energy:  0.6, electrons: "",      label: [LUMO]),
    en-difference("homo", "lumo", ratio: 50%, color: teal, title: [$Delta E_"gap"$]),
    energy-axis(title: [Energy]),
  )
})
```
 
---

### `ep-annotation(...)`
 
Draws a double-headed span arrow with a centered label below the diagram, connecting two `en-pathway` orbitals.
 
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `from` | `int` or `str` | — | Start orbital: index or full name |
| `to` | `int` or `str` | — | End orbital: index or full name |
| `body` | `content` | — | Label content |
| `name-prefix` | `str` | `"ep"` | Must match the `en-pathway()` prefix |
| `dy` | `float/length` | `0` | Vertical offset (negative = further down) |
| `pad` | `float/length` | `0` | Extra horizontal margin beyond orbital edges |
| `color` | `color` | `black` | Arrow and label color |
| `size` | `length` or `auto` | `auto` | Label font size |
 
```typst
#figure({
  import mo: *
  modiagram(
    en-pathway(0, 0.5, 1.1, 1.7),
    ep-annotation(0, 3, [Full pathway], dy: -0.5),
    ep-annotation(1, 2, $Delta G$, color: red, size: 8pt),
  )
})
```

---

### `legend(...)` — legend box for `en-pathway` diagrams

Controls how the legend is displayed when one or more `en-pathway()` calls carry a `legend:` label. Pass `legend()` as any element inside `modiagram()`. All parameters are optional.

| Parameter    | Default | Description                                                                   |
| ------------ | ------- | ----------------------------------------------------------------------------- |
| `pad`        | `0.35`  | Right-side clearance between the rightmost orbital and the legend block (canvas units or length). Increase this to move the legend clear of `en-difference` barriers. |
| `dx`         | `0`     | Additional x offset on top of `pad` (canvas units or length)                 |
| `dy`         | `0`     | y offset from the topmost orbital (canvas units or length)                    |
| `box`        | `false` | If `true`, wraps all entries in a white rounded box                           |
| `black-text` | `false` | If `true`, renders every label in black; the colored sample lines are unaffected |

```typst
#figure({
  import mo: *
  modiagram(
    config(energy-scale: 0.3),

    en-pathway(
      -4, 4, -1, 2, -8,
      color: red,
      labels: ([SM], [TS1], [Key], [TS2], [P]),
      name-prefix: "red",
      legend: [Pathway A],
    ),
    en-pathway(
      -1, 2, -5, 5, -4,
      color: olive,
      labels: ([SM], [Int1], [Int2], [Int3], [P]),
      name-prefix: "olive",
      legend: [Pathway B],
    ),

    legend(pad: 0.5, box: true, black-text: true),
    energy-axis(title: [E]),
  )
})
```

Each `en-pathway()` contributes one row to the legend (a short colored line followed by its label). The `legend()` element controls the position and appearance of the whole block. Omitting `legend()` uses the defaults.

To push the legend past an `en-difference` barrier on the right, increase `pad` or use `dx`:

```typst
legend(pad: 1.5)          // larger right clearance
legend(pad: 0.5, dx: 1)   // fine-tune with an extra offset
```

---

### `raw(closure)` — arbitrary cetz drawing

Executes raw cetz `draw.*` calls inside the diagram canvas.

```typst
raw((xs, ys, anchors) => {
  let p = at("σ", anchors, edge: "right")
  draw.content((p.at(0) + 0.2, p.at(1)), [bond], anchor: "west")
})
```

Closure signature: `(xs, ys, anchors) => { ... }`

- `xs`, `ys` — active x-scale and energy-scale
- `anchors` — dict of all orbital anchors; query with `at()`

A complex method for using CeTZ primitives within modiagram:

```typst
#figure({
  import mo: *
  modiagram(
  
	config(energy-scale: 0.3),
	
	en-pathway(
	  -4, 4, -1, 2, -8,
	  labels: ([SM], [TS$alpha$-1], [Key], [TS$beta$-1], [P]),
	  show-energies: true,
	  name-prefix: "black"
	),
	
	en-pathway(
	  -1, 2, -5, 5, -4,
	  labels: ([SM], [$gamma$], [Int], [Ex], [`code`]),
	  color: olive,
	  name-prefix: "olive"
	),

	energy-axis(title: "E")
	
	raw((xs, ys, anchors) => {
		let p = at("black-3", anchors, edge: "right")
		draw.content((p.at(0) + 0.2, p.at(1)), [#align(center, [BEST \ TS])], anchor: "west")
	})
  )
})
```

![example-07](/images/example-07.png)

---
## Position forms

All cetz wrappers accept these position forms:

| Form                 | Example           | Description                                            |
| -------------------- | ----------------- | ------------------------------------------------------ |
| `(x, y)`             | `(1.5, 0.3)`      | Numeric tuple, scaled by x-scale / energy-scale        |
| `"name"`             | `"σ"`             | Center of the named orbital                            |
| `"name.edge"`        | `"σ.right"`       | Named edge: `left`, `right`, `top`, `bottom`, `center` |
| `("a", ratio%, "b")` | `("a", 50%, "b")` | Linear interpolation between two positions             |
| `rel(dx, dy)`        | `rel(1, 0)`       | Relative offset from the previous point                |

Extra keyword arguments available on all wrappers: `pad`, `dx`, `dy`.

---
## Orbital styles

| Style      | Description                             | Default connection |
| ---------- | --------------------------------------- | ------------------ |
| `"plain"`  | Horizontal line only (default)          | dotted             |
| `"square"` | Square box                              | solid              |
| `"round"`  | Square box with rounded corners         | solid              |
| `"circle"` | Circle with side extensions             | solid              |
| `"fancy"`  | Rounded box with longer side extensions | dashed             |

![example-08](/images/example-08.png)

---

## Connection styles

| Style      | Appearance      |
| ---------- | --------------- |
| `"dotted"` | Dotted line     |
| `"dashed"` | Dashed line     |
| `"solid"`  | Solid line      |
| `"gray"`   | Solid gray line |

![example-09](/images/example-09.png)

---

## Global configuration

**`modiagram-setup(...)`** — set document-level defaults for all `modiagram()` calls:

```typst
#modiagram-setup(style: "square", scale: 1.2cm, label-size: 6pt)
```

**`en-pathway-setup(...)`** — set document-level defaults for all `en-pathway()` calls:

```typst
#en-pathway-setup(conn-style: "solid", show-energies: true, color: blue)
```

---

## Helper functions

|Function|Description|
|---|---|
|`at(name, anchors, edge: "center")`|Resolve a named orbital to `(x, y)` — use inside `raw()`|
|`sp(pt, xs, ys)`|Manually scale a `(x, y)` pair — use inside `raw()`|
|`rel(dx, dy)`|Relative offset sentinel for multi-point wrappers|
|`skip`|Skip sentinel for `en-pathway()`|

---

## Cetz wrappers

All standard cetz primitives are available as first-class diagram elements with automatic position resolution and `rel()` support:

`line` · `content` · `circle` · `rect` · `arc` · `grid` · `bezier` · `catmull` · `hobby` · `mark` · `merge-path` · `set-style` · `on-layer` · `group` · `hide` · `intersections` · `copy-anchors`

Collision-free aliases (for star imports): `mo-line`, `mo-circle`, `mo-rect`, `mo-arc`, `mo-grid`, `mo-content`.

---

## Priority chain

Settings are resolved in this order (first match wins):

```
per-element parameter
  → config() inline override
    → modiagram(config:) dict
      → modiagram-setup() global
        → built-in defaults
```

---
## Complete example with CeTZ functions

```typst
#figure({
  import mo: *
  modiagram(
    config(energy-scale: 0.3),
    line("olive-2", rel(0.9,3), stroke: 0.5pt+blue, mark:(end: ">>", fill: blue, scale: 0.5)),
    circle("olive-2", radius: 0.6, stroke: 0.5pt+blue, fill: yellow.lighten(80%)),
    content("olive-2", dx: 1.7, dy: 1.1, text(fill: blue)[example\ of content]),
    content("red-1.right", pad: 0.6, )[#align(center)[#text(size: 7pt)[Another\ way to\ include\ content]]],
    content("red-1.left", pad: 0.6)[#image("../images/Caffeine_structure.svg", width: 1.3cm)],

    legend(pad: 3, box: true),

    en-pathway(
      -4, 4, -1, 2, -8,
      labels: ([SM], [TS$alpha$-1], [Key], [TS$beta$-1], [P]),
      show-energies: true,
      color: red,
      name-prefix: "red",
      legend: [Triplet state]
      ),
    en-pathway(
      -1, 2, -5, 5.15, -4,
      labels: ([SM], [$gamma$], [Int], [Ex], [`code`]),
      color: olive,
      name-prefix: "olive",
      legend: [Singlet state]
    ),

    ao(x: 4.8, energy: 0, electrons: "pair"),
    ao(x: 2.4, energy: 1, electrons: "up", up-el-pos: 0),

    ep-annotation("red-0", "red-2", [Step 1]),
    ep-annotation("olive-3", "olive-4", [Step 2], color: blue),

    en-difference("olive-2", "red-1", ratio: 70%, color: red, pad: 5.7),
    en-difference("olive-3", "red-4", color: purple, pad: 1.3, title: [TS]),
    en-difference("olive-1", "olive-2", color: blue, pad: 3, ratio: 25%),

    energy-axis(title: "Energy in kcal/mol", style: "horizontal"),
    x-axis(title: "reaction coordinate", style: "below", pad: 1)

  )
})
```

![example-10](/images/example-10.png)

---

## License

MIT — see LICENSE for details.