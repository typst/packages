#import "@preview/silky-letter-insa:0.2.1": *
#show: doc => insa-letter(
  author: [
    NOM Prénom\
    Rôle / Département
  ],
  date: datetime.today(), // peut être remplacé par une date, par ex. "23/03/2024"
  doc
)

// gros titre en haut au centre
#v(15pt)
#align(center, text(size: 22pt, font: heading-fonts, weight: "bold", upper("Probabilités - Annale X")))
#v(5pt)

#set heading(numbering: "1.") // numérotation des titres

= Gros titre
== Sous section
Équation sur une ligne : $overline(x_n) = 1/n sum_(i=1)^n x_i$

== Autre sous section
Grosse équation :
$
"Variance biaisée :" s^2 &= 1/n sum_(i=1)^n (x_i - overline(x_n))^2\
"Variance corrigée :" s'^2 &=  n/(n-1) s^2
$

=== Petite section
Code R :
```R
data = c(1653, 2059, 2281, 1813, 2180, 1721, 1857, 1677, 1728)
moyenne = mean(data)
s_prime = sqrt(var(data)) # car la variance de R est déjà corrigée
n = 9
alpha = 0.08

IC_min = moyenne + qt(alpha / 2, df = n - 1) * s_prime / sqrt(n)
IC_max = moyenne + qt(1 - alpha / 2, df = n - 1) * s_prime / sqrt(n)
```
