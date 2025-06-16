<h1 align="center">
  <img alt="Typst" src="https://github.com/vitto4/ttuile/blob/main/assets/ttuile-header.png?raw=true">
</h1>

<p align="center">
  <a href="https://typst.app">
    <img alt="typst" src="https://img.shields.io/badge/Typst-%232f90ba.svg?&logo=Typst&logoColor=white"
  /></a>
  <a href="https://github.com/vitto4/ttuile/blob/main/LICENSE">
    <img alt="MIT" src="https://img.shields.io/github/license/vitto4/ttuile"
  /></a>
  <a href="https://github.com/vitto4/ttuile/releases">
    <img alt="GitHub Release" src="https://img.shields.io/github/v/release/vitto4/ttuile"
  /></a>
</p>

<p align="center"><i>A <b>Typst</b> template for lab reports at <a href="https://en.wikipedia.org/wiki/Institut_national_des_sciences_appliqu%C3%A9es_de_Lyon"> INSA Lyon</a>.</i></p>

<p align="center">
  <a href="https://github.com/vitto4/ttuile/blob/main/template/main.pdf">
    <img alt="Example" src="https://github.com/vitto4/ttuile/blob/main/assets/ttuile-banner.png?raw=true">
  </a>
</p>

> **Note :** Voir aussi le [README.FR.md](https://github.com/vitto4/ttuile/blob/main/README.FR.md) en français.

## 🧭 Table of contents

1. [Usage](#-usage)
1. [Documentation](#-documentation)
1. [Notes](#-notes)
1. [Contributing](#-contributing)


## 📎 Usage

This template targets french students, thus labels will be in french, see [Notes](#-notes).

It is available on _Typst Universe_ : [`@preview/ttuile:0.1.0`](https://typst.app/universe/package/ttuile).

If you wish to use it in a fully local manner, you'll need to either manually include `ttuile.typ` and `logo-insa-lyon.png` in your project's root directory ; or upload them to the _Typst web app_ if that's what you use.

You'll find these files in the [releases](https://github.com/vitto4/ttuile/releases) section.

Your folder structure should then look something like this :

```
.
├── ttuile.typ
├── logo-insa-lyon.png
└── main.typ
```

The template is now ready to be used, and can be called supplying the following arguments.
`?` means the argument can be null if not applicable.


| Argument | Default value | Type | Description |
|:--------:|:-------------:|:----:|:------------|
| `titre` | `none` | `content?` | The title of your report. |
| `auteurs` | `none` | `array<str> \| content?` | One or multiple authors to be credited in the report. |
| `groupe` | `none` | `content?` | Your class number/letter/identifier. Will be displayed right after the author(s). |
| `numero-tp` | `none` | `content?` | The number/identifier of the lab work/practical you're writing this report for. |
| `numero-poste` | `none` | `content?` | Number of your lab bench. |
| `date` | `none` | `datetime \| content?` | Date at which the lab work/practical was carried out. |
| `sommaire` | `true` | `bool` | Display the table of contents ? |
| `logo` | `image("logo-insa-lyon.png")` | `image?` | University logo to use. |
| `point-legende` | `false` | `bool` | Enable automatic enforcement of full stops at the end of figures' captions. (still somewhat experimental). |

A single positional argument is accepted, being the report's body.

You can call the template using the following syntax :

```typ
// Local import
// #import "ttuile.typ": *

// Universe import
#import "@preview/ttuile:0.1.0": *

#show: ttuile.with(
  titre: [« #lorem(8) »],
  auteurs: (
      "Theresa Tungsten",
      "Jean Dupont",
      "Eugene Deklan",
  ),
  groupe: "TD0",
  numero-tp: 0,
  numero-poste: "0",
  date: datetime.today(),
  // sommaire: false,
  // logo: image("path_to/logo.png"),
  // point-legende: true,
)
```

## 📚 Documentation

The package `ttuile.typ` exposes multiple functions, find out more about them in the _documentation_.

<p align="center">
  <a href="https://github.com/vitto4/ttuile/blob/main/DOC.EN.md">
    To the documentation
  </a>
</p>

An example file is also available in [`template/main.typ`](https://github.com/vitto4/ttuile/blob/main/template/main.typ)


## 🔖 Notes

- Beware, all of the labels will be in french (authors != auteurs, appendix != annexe, ...)
- If you really want to use this template despite not being an INSA student, you can probably figure out what to change in the code (namely labels mentioned above). You can remove the INSA logo by setting `logo: none`

  Should you still need help, no worries, feel free to reach out !
  
- The code - variable names and comments - is all in french. That's on me, I didn't really think it through when first writing the template haha. I might consider translating sometime in the future.
- The MIT license doesn't apply to the file `logo-insa-lyon.png`, it was retrieved from [INSA Lyon - éléments graphiques](https://www.insa-lyon.fr/fr/elements-graphiques). It doesn't apply either to the "INSA" branding.


## 🧩 Contributing

Contributions are welcome ! Parts of the template are very much spaghetti code, especially where the spacing between different headings is handled (seriously, it's pretty bad).

If you know the proper way of doing this, an issue or PR would be greatly appreciated :)