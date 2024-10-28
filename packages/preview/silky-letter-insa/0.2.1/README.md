# INSA - Typst Template
Typst Template for short documents and letters for the french engineering school INSA.

## Example
By default, the template initializes with the `insa-letter` show rule, with parameters that you must fill in by yourself.

Here is an example of filled template:
````typst
#import "@preview/silky-letter-insa:0.2.1": *
#show: doc => insa-letter(
  author: "Youenn LE JEUNE, Kelian NINET",
  insa: "rennes"
  doc)

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

To behave correctly on computers without those specific fonts installed, this template will automatically fallback to other similar fonts:
- **League Spartan** -> **Arial** (approved by INSA's graphic charter, by default in Windows) -> **Liberation Sans** (by default in most Linux)
- **Source Serif** -> **Source Serif 4** (downloadable for free) -> **Georgia** (approved by the graphic charter) -> **Linux Libertine** (default Typst font)

### Note on variable fonts
If you want to install those fonts on your computer, Typst might not recognize them if you install their _Variable_ versions. You should install the static versions (**League Spartan Bold** and most versions of **Source Serif**).

Keep an eye on [the issue in Typst bug tracker](https://github.com/typst/typst/issues/185) to see when variable fonts will be used!

## Notes
This template is being developed by Youenn LE JEUNE from the INSA de Rennes in [this repository](https://github.com/SkytAsul/INSA-Typst-Template).

For now it includes assets from the INSA de Rennes graphic charter, but users from other INSAs can open an issue on the repository with the correct assets for their INSA.

If you have any other feature request, open an issue on the repository as well.

## License
The typst template is licensed under the [MIT license](https://github.com/SkytAsul/INSA-Typst-Template/blob/main/LICENSE). This does *not* apply to the image assets. Those image files are property of Groupe INSA and INSA Rennes.

## Changelog
### 0.2.1
- Added `insa` option
- Added INSA HdF assets