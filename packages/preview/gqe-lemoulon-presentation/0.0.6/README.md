# gqe-presentation

template [Typst web app](https://typst.app/?template=gqe-lemoulon-presentation&version=0.0.6) to generate GQE slides


## 🧑‍💻 Usage

- Directly from [Typst web app](https://typst.app/) by clicking "Start from template" on the dashboard and searching for `gqe-lemoulon-presentation`.

- With CLI:

```
typst init @preview/gqe-lemoulon-presentation:{version}
```

## Documentation

Here [gqe-lemoulon-presentation-doc](docs/gqe-lemoulon-presentation-doc.pdf) you have the reference documentation that describes the functions and parameters used in this package. (_Generated with [tidy](https://github.com/Mc-Zen/tidy)_)

gqe-lemoulon-presentation is based on [touying](https://touying-typ.github.io/) package. The documentation is available [here](https://touying-typ.github.io/docs/intro).

It extends Touying with builtin functions [pave](#pave), [tableau](#tableau), [tableaum](#tableaum), [image-legende](#image-legende).

You can configure your own [colors](#config-colors) to modify the theme.

The theme comes with [predefined logo](#predefined-logo), but you can change it using the config-info dictionnary entry logo and use your own [image](https://typst.app/docs/reference/visualize/image/).

### pave

uses [showybox](https://typst.app/universe/package/showybox/) to display boxes using your touying config-colors settings.

```
#pave("Scientific projects and hardware")[
- High throughput
- Metaproteomics
- Instrument improvements
]
```


### tableau

uses customized typst [table function](https://typst.app/docs/reference/model/table) to display tables using your touying config-colors settings.

```
#tableau(columns: 3,
  [Hydrochloric Acid],
  [12.0], [92.1],
  [Sodium Myreth Sulfate],
  [16.6], [104],
  [Potassium Hydroxide],
  table.cell(colspan: 2)[24.7],
  )
```

### tableaum

uses [tablem](https://typst.app/universe/package/tablem/) typst to display tables from a markdown syntax, using your touying config-colors settings.

```
#tableaum(columns: 3)[
  | *Hydrochloric Acid* | *Sodium Myreth Sulfate* | *Potassium Hydroxide* |
  | ------ | ---------- | ---------- |
  | 12.0 | 16.6 | 24.7 |
  | 92.1 | 104 | 24.7 |
]
```
### image-legende

display a block stacking together an [image](https://typst.app/docs/reference/visualize/image/) and a legend

```
#image-legende(image: image("./fig/gqe/06_human_height.png"), width: 85%, [Distribution of student's height in a brittish university])
```


### config-colors

gqe-lemoulon-presentation comes with predefined colors, but you can use the touying config-colors dictionnary to define your own.
See the typst [color]("https://typst.app/docs/reference/visualize/color/") documentation to select a color.

The code below will use "blue" as dominant color and "red" when using touying alert function. The dictionnary must be placed as an argument to start a new document, see below.
```
config-colors(
  primary: blue
  alert: red
)
```

### predefined logo

Common used logos of institutions in our lab are predefined in typst variables.

| Typst variable | Institution |
| -------- | ------------ |
| logo-agroparistech | [AgroParisTech](https://www.agroparistech.fr/) |
| logo-cnrs | [CNRS](https://www.cnrs.fr) |
| logo-cnrs-biologie | [CNRS - Biologie](https://www.insb.cnrs.fr/fr) |
| logo-ideev | [IDEEV](https://www.ideev.universite-paris-saclay.fr/) |
| logo-inrae | [INRAE](https://www.inrae.fr/) |
| logo-pappso | [PAPPSO](http://pappso.inra.fr/) |
| logo-gqe | [GQE - Le Moulon](https://moulon.inrae.fr/umr/) |
| logo-upsay | [Université Paris Saclay](https://www.universite-paris-saclay.fr/) |
| logo-upsay-fac-sciences | [Université Paris Saclay - Faculté des Sciences]() |



## Local installation

## Install Rust and Typst (Linux)

```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```
and then install [Typst](https://github.com/typst/typst#installation)

```
cargo install typst-cli
```

## Start a new document

```

#import "@preview/gqe-lemoulon-presentation:0.0.5":*
#import themes.gqe: *

#show: gqe-lemoulon-presentation-theme.with(
  aspect-ratio: "4-3",
  config-info(
    title: [your presentation title],
    subtitle: [your subtitle],
    author: [John Doe],
    date: [20 decembre 2024],
    logo: logo-pappso,
    logo2: logo-ideev,
    brochette: grid(columns: (30%, 25%,20%,20%),{
		set align(horizon + center)
		set image(height: 25pt)
		logo-upsay
		},{
		set align(horizon + center)
		set image(height: 20pt)
		logo-inrae
		},{
		set align(horizon + center)
		set image(height: 30pt)
		logo-cnrs-biologie
		}),
  ),
  config-colors(
    primary: blue
  )
)

#set text(font: "PT Sans", weight: "light", size: 24pt)



#title-slide()


```

## 📝 License

This is GPLv3 licensed.
