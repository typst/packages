<h1 align="center">
  <picture><img alt="Typst" src="https://github.com/vitto4/ttuile/blob/main/docs/ttuile-header.png?raw=true"></picture>
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

<p align="center"><i>A <b>Typst</b> template for students' lab reports at <a href="https://en.wikipedia.org/wiki/Institut_national_des_sciences_appliqu%C3%A9es_de_Lyon">INSA Lyon</a>.</i></p>

<p align="center">
  <a href="https://github.com/vitto4/ttuile/blob/main/template/main.pdf">
    <img alt="Banner" src="https://github.com/vitto4/ttuile/blob/main/docs/ttuile-banner.png?raw=true">
  </a>
</p>

> **Note**
> 
> This template targets French students, so you may see French words here and there.
> Should you want to write your report in another language, there's a workaround, see [Notes](#-notes).

## 🧭 Table of contents

1. [Usage](#-usage)
1. [Documentation](#-documentation)
1. [Notes](#-notes)
1. [Contributing](#-contributing)


## 📎 Usage

Colorful lab report template more or less aligned with guidelines guidelines issued in 1st year at INSA Lyon.
It is available on _Typst Universe_ : [`@preview/ttuile:0.2.0`](https://typst.app/universe/package/ttuile).

If you wish to use it locally, you'll need to either manually include `ttuile.typ` and folder `internal/` in your project's root directory ; or upload them to the _Typst web app_ if that's what you use.

You'll find these files in the [releases](https://github.com/vitto4/ttuile/releases) section.

Your folder structure should then look something like this :

```
.
├── ttuile.typ
├── internal/
│    ├── defaults.typ
│    ├── helpers.typ
│    └── logo-insa-lyon.png
└── main.typ
```

The template is now ready to be used, and can be called supplying the following arguments.
`?` means the argument can be null if not applicable.


| Argument | Default value | Type | Description |
|:--------:|:-------------:|:----:|:------------|
| `headline` | `none` | `dictionary<str, content> \| content?` | Title of the report |
| `authors` | `none` | `array<str \| content> \| content?` | One or multiple authors to be credited in the report |
| `group` | `none` | `content?` | Your class (or group) number/letter/identifier to be displayed right after the author(s) |
| `footer-left` | `none` | `content?` | Usually your lab bench number |
| `footer-right` | `none` | `content?` | Usually the date at which the lab work/practical was carried out |
| `outlined` | `true` | `bool` | Display the table of contents ? |
| `logo` | `image("internal/logo-insa-lyon.png")` | `image \| content?` | University logo to display |

A single positional argument is accepted, being the report's body.

You can call the template using the following syntax :

```typ
// Local import
// #import "ttuile.typ": *

// Universe import
#import "@preview/ttuile:0.2.0": *

#show: ttuile.with(
  // This is one way to set the headline, but the following also works :
  //  * headline: [You may supply just the title],
  //  * headline: text(fill: blue, weight: "regular")[And even style it\ however you wish],
  headline: (
    lead: [Compte rendu de TP n°1 :],
    title: [« #lorem(8) »],
  ),
  // Same as above :
  //  * authors: [You may also supply whatever you want],
  authors: (
    "Theresa Tungsten",
    "Jean Dupont",
    "Eugene Deklan",
  ),
  group: "TD0",
  footer-left: [Poste n°0],
  footer-right: datetime.today().display("[day]/[month]/[year]"),
  outlined: true,
  // Also remove the uni logo or insert your own :
  //  * logo: image("your-logo.png"),
  //  * logo: none,
)
```

## 📚 Documentation

The package `ttuile.typ` exposes multiple functions, find out more about them in the _documentation_.

<p align="center">
  <a href="https://github.com/vitto4/ttuile/blob/main/docs/DOCS.md">
    To the documentation
  </a>
</p>

An example file is also available in [`template/main.typ`](https://github.com/vitto4/ttuile/blob/main/template/main.typ)


## 🔖 Notes

- As mentioned previously, the template targets French students, so you'll get things like `Auteurs != Authors`, `Annexe != Appendix` and such. Thankfully I didn't cut corners there hehe, all of that can be tweaked :
  ```typ
  #show: ttuile.with(
    headline: [Yay, the French's all gone !],
    authors: [*Authors:* Theresa Tungsten, Jean Dupont and Eugene Deklan],
    group: "Group 1",
    // This is supposed to be the lab bench number, but you may as well put whatever in there
    footer-left: [Hello, world!],
    footer-right: datetime.today().display("[day]/[month]/[year]"),
    // You can use your own university's logotype
    logo: image("path_to/logo.png"),
  )
  
  // This will fix tables and figures
  #set text(lang: "en")

  // And this the appendices section
  #appendices-section(
    ...,
    headline: "Appendices",
    supplement: "Appendix",
    outline-title: "List of appendices",
  )
  ```
- You may also tweak heading spacing : `#show heading: set block(above: 18pt, below: 5pt)`.
- The MIT license doesn't apply to the file `logo-insa-lyon.png`, it was retrieved from [INSA Lyon - éléments graphiques](https://www.insa-lyon.fr/fr/elements-graphiques). It doesn't apply either to the "INSA" branding.


## 🧩 Contributing

Contributions are welcome ! Parts of the template are very much spaghetti code, so if you know the proper way of achieving what I'm going for, an issue or PR would be greatly appreciated :)