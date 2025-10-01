This template implements a typst version of the [TUD math thesis](https://tu-dresden.de/mn/math/studium/pruefungsaemter/abschlussarbeiten?set_language=en) LaTeX-template. It provides things like
- Bachelor thesis template
- Master thesis template
- theorem environments (threw [great-theorems 0.1.2](https://typst.app/universe/package/great-theorems/0.1.2/))
- show rule for only numbering Equation with label

# Remark: Fonts
You need additional fonts for the template to function and look properly. The original LaTeX template uses Latin-Modern font family. You could download the otf-files from [here](https://www.1001fonts.com/latin-modern-roman-font.html).

If you use this template locally you have to install this font on your system.
If you use this template on the webapp you have to create a font-folder and put the otf-files in there.


# Usage
You could create a document threw
```
typst init @preview/classic-tud-math-thesis:0.1.0
```
or with the following import at the beginning of your document
```typst
#import "@preview/classic-tud-math-thesis:0.1.0" : *
```

The beginning Show-Rule to initialize your document is:
```typst
#show: classic-tud-math-thesis.with(
  name: [Ihr Familienname],
  vorname: [Ihr Vorname],
  gebdatum: [Ihr Geburtsdatum],
  ort: [Ihr Geburtsort],
  betreuer: [Vollständiger akad. Titel (z.B. Prof. Dr. rer. nat. habil.) Vorname Familienname Ihres Betreuers / Ihrer Betreuerin],
  betreuer-kurz: [Kurzer akad. Titel (z.B. Prof. Dr.) Vorname Familienname Ihres Betreuers / Ihrer Betreuerin],
  institut: [Institut ihres Betreuers],
  thema: [Titel ihrer Arbeit],
  datum: [tt. mm. jjjj],
  abschluss: "bsc",
  studiengang: [Mathematik oder Technomathematik oder Wirtschaftsmathematik],
  use_default_math_env: true,
)
```
The arguments of the `abschluss`-parameter could be `"bsc"` if you want to write a Bachelor thesis or `"msc"` if you want to write a Master thesis.

As default for the theorem-environments we use [great-theorems 0.1.2](https://typst.app/universe/package/great-theorems/0.1.2/). But you could of course also define the theorem environments by yourself. In this case set the `use_default_math_env` parameter to `false` and use instead this import statement
```typst
#import "@preview/classic-tud-math-thesis:0.1.0" : classic-tud-math-thesis
```
at the beginning. 

# Default Theorem environmet
We use for the theorems [great-theorems 0.1.2](https://typst.app/universe/package/great-theorems/0.1.2/) and [rich-counter 0.2.2](https://typst.app/universe/package/rich-counters/0.2.2/) for the counters. You could give your theorems an addidtional title with the `title:[content]` parameter.

## numbered theorems
Our numbered theorems are numbered in the format 
_{name} {chapter-number}.{theorem-counter}_ 
We provide the following environments:
- `#definition[body]`
- `#theorem[body]`
- `#lemma[body]`
- `#korollar[body]`
- `#beispiel[body]`

## unnumbered theorems
We also provide an unnumbered version with
- `#_definition[body]`
- `#_theorem[body]`
- `#_lemma[body]`
- `#_korollar[body]`
- `#_beispiel[body]`

## proof environment
- `#beweis[body]`

# Numbering of equations
We use for the behaviour and the numbering of the equations the [equate 0.3.2](https://typst.app/universe/package/equate/0.3.2/) package. If you want to use equate with our presets, then write this command in the beginning of your document:
```typ
#show: setup-equate.with()
```
If you want to change the behaviour of equate, then you could pass them threw `setup-equate.with()`directly to equate. For more information look directly in the [equate](https://typst.app/universe/package/equate/0.3.2/) package.