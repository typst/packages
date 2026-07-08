# INSA - Typst Template
Typst Template for short documents and letters for the french engineering school INSA.

## Example
By default, the template initializes with the `insa-letter` show rule, with parameters that you must fill in by yourself.

Here is an example of filled template:
````typst
#import "@preview/silky-letter-insa:0.2.3": *
#show: doc => insa-letter(
  author: "Youenn LE JEUNE, Kelian NINET",
  insa: "rennes",
  doc,
)

#v(15pt)
#align(center, text(size: 22pt, weight: "bold", smallcaps("Probabilités - Annale 2022 (V1)")))
#v(5pt)

#set heading(numbering: "1.")
#show heading.where(level: 2): it => [
  #counter(heading).display()
  #text(weight: "medium", style: "italic", size: 13pt, it.body)

]

= Intervalle de confiance
== Calculer sur l’échantillon une estimation de la moyenne.
$ overline(x_n) = 1/n sum_(i=1)^n x_i = 1885 $

== Calculer sur l’échantillon une estimation de la variance.
$
"Variance biaisée :" s^2 &= 1/n sum_(i=1)^n (x_i - overline(x_n))^2 = 218^2\
"Variance corrigée :" s'^2 &=  n/(n-1) s^2 = 231^2
$

Le bon estimateur est le second.

== Écrire le code R permettant d’évaluer les deux bornes de l’intervalle de confiance du temps d’exécution avec une confiance de 92%.
Nous sommes dans le cas d'une recherche de moyenne avec variance inconnue, l'intervalle sera donc
$ [overline(X) + t_(n-1)(alpha/2) S'/sqrt(n), quad overline(X) + t_(n-1)(1 - alpha/2) S'/sqrt(n)] $
En R, avec l'échantillon nommé `data`, ça donne
```R
data = c(1653, 2059, 2281, 1813, 2180, 1721, 1857, 1677, 1728)
moyenne = mean(data)
s_prime = sqrt(var(data)) # car la variance de R est déjà corrigée
n = 9
alpha = 0.08

IC_min = moyenne + qt(alpha / 2, df = n - 1) * s_prime / sqrt(n)
IC_max = moyenne + qt(1 - alpha / 2, df = n - 1) * s_prime / sqrt(n)
```

Ici on a $[1730, 2040]$.
````

## Fonts
The graphic charter recommends the fonts **League Spartan** for headings and **Source Serif** for regular text. To have the best look, you should install those fonts.

To behave correctly on computers lacking those specific fonts, this template will automatically fallback to similar ones:
- Headings: [**League Spartan**](https://fonts.google.com/specimen/League+Spartan) -> **Arial** (approved by INSA's graphic charter, by default in Windows) -> **Liberation Sans** (by default in most Linux)
- Body: **Source Serif** -> [**Source Serif 4**](https://fonts.google.com/specimen/Source+Serif+4) -> **Georgia** (approved by the graphic charter) -> _default Typst font_

> You can download the fonts from [here](https://github.com/SkytAsul/INSA-Typst-Template/tree/letter-0.2.3/fonts).

## Notes
This template is being developed by Youenn LE JEUNE from the INSA de Rennes in [this repository](https://github.com/SkytAsul/INSA-Typst-Template) with contributions by other people.

For now it includes assets from the graphic charters of those INSAs:
- Rennes (`rennes`)
- Hauts de France (`hdf`)
- Centre Val de Loire (`cvl`)
Users from other INSAs can open a pull request on the repository with the assets for their INSA.

If you have any other feature request, open an issue on the repository as well.

## License
The typst template is licensed under the MIT license. This does *not* apply to the image assets. Those image files are property of Groupe INSA.

## Changelog
### 0.2.3
- CVL assets are now vector graphics

### 0.2.2
- Added INSA CVL assets

### 0.2.1
- Added `insa` option
- Added INSA HdF assets
