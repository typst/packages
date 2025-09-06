# nasin lipu penpo

[![en](https://img.shields.io/badge/lang-en-red.svg)](README.md)

o pona e lipu sina a!

o lukin e [lipu pi pana sona (toki Inli)](docs/main.pdf).

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="logo/penpo-dark.svg">
  <img alt="penpo" src="logo/penpo-light.svg">
</picture>

---

nimi "penpo" li sama "toki pona taso."

## nasin penpo li seme?

nasin lipu penpo li ilo sitelen.
kepeken lipu konwe "Typst" /taɪpst/ la ona li ken pali e lipu
pi pona lukin sama lipu "sama-ni/lipu.pdf".

kepeken "penpo", la...
- sina ken sitelen e lipu wan taso, li kama jo e lipu pi
  sitelen Lasina en sitelen pona lon poka.
- sina ken alasa e pakala lili ale kepeken wawa lili.
- nanpa wan la nimi jan li kama sitelen ale,
  taso nanpa tu en mute la sitelen lili nanpa wan taso
  li kama sitelen. sama lipu su.

sina wile sona e nasin pi kepeken "penpo",
la o lukin e lipu "sama-ni/lipu.typ" en
lipu mute lon "sama-ni/" kin.

## wile tan nasin penpo

- sina wile jo e nasin sitelen
  ["sitelen seli kiwen"](https://www.kreativekorp.com/software/fonts/sitelenselikiwen/).
  ona li ken sitelen pona.
  o pana e lipu ".ttf" lon poka pi lipu sina.

## o lukin

lipu ni li wan taso, li ken kama sitelen kepeken sitelen Lasina anu sitelen pona
kepeken wawa lili: o pana e `#show: penpo.pona.sitelen` anu `#show: penpo.lasina.sitelen`.

```typ
// lipu: toki.typ
#import "@preview/penpo:0.1.0"

#show link: set text(fill: blue.darken(20%))
#set figure(numbering: none)

// o sitelen e pakala ale. nimi "penpo" en "namako" en ante li pakala ala.
#penpo.pakala.open()
#penpo.o-oke-e-nimi("penpo", "namako", "soko", "n", "jasima", "majuna", "lanpan", "oko")

// nimi ni li kepeken sitelen ni lon nasin sitelen pona.
#penpo.nimisin("Newen", "namako en weka en namako", _lili: "namako namako")
#penpo.nimisin("Lasina", "linja ale sona insa ni a", _lili: "linja sona")

// sitelen lili li ni:
#penpo.o-ante-e-sitelen-lili("la", (
  ".": [~#sym.dot],
  "!": [~!],
  ":": [~:],
))
#penpo.o-ante-e-sitelen-lili("sp", (
  ".": h(1cm),
  ",": h(1mm),
))

toki a!
mi jan Newen.

// `penpo.only` la, toki li lon nasin sitelen wan taso.
mi pali e lipu ni kepeken
#penpo.only("sp")[sitelen pona]#penpo.only("la")[sitelen Lasina]
tan ni: /sp/
mi wile pana e sona pi kepeken penpo tawa jan mute.

#penpo.nimisin("Inli", "insa n li ijo", _lili: none)
#penpo.nimisin("Masi", "mun alasa sinpin ijo", _lili: 1)
#penpo.nimisin("Wikipesija", "wile ilo kon ilo pona esun sona ilo jan ale", _lili: 1)
#penpo.nimisin-mute(
  _lili: none,
  Sola: "suno o lukin ala",
  Mekuliju: "majuna e kule uta li insa jasima uta",
  Tela: "toki e lon ala",
  Olinpu: "o lukin insa nena pona unpa",
  Mon: "ma open nena",
  Mewika: "moku esun weka ilo kalama awen",
  Elopa: "esun lawa olin pona awen",
  Losi: "lanpan oko sewi insa",
  Nijon: "nasin ijo jan olin n",
  Loma: "lawa olin mi awen",
  Imalasi: "insa ma ala lon akesi suno ilo",
  Sonko: "soko open ni kiwen o",
  Insanjuwisi: "ilo nasin sona awen nena jo uta wile ilo sona ilo",
  Popo: "pi o pi o",
  Temo: "tawa e mi o",
)

== mun Masi

toki ni li tan #link("https://wikipesija.org/wiki/mun_Masi")[lipu Wikipesija]

#table(columns: (60%, 40%), stroke: none)[
  #set par(justify: true)
  suno mi la, mun Masi (toki Inli: "#penpo.esc[Mars]") /sp/
  li mun nanpa tu tu lon weka suno Sola. /sp/
  ona li lili nanpa tu. mun Masi la mun Mekuliju taso li lili. /sp/
  ma Tela la, ona li lili. ma pi mun Masi li jo e kiwen mute. /sp/
  ona li lete li jo e kon lili. /sp/
  ona li loje lukin la, nimi ante ona li "mun loje". /sp/
  telo li lon ala ma Masi. taso, kiwen telo lete li lon. /sp/
  ona li jo e nena ma suli. /sp/
  nena ma Olinpu Mon li nena ma nanpa wan lon /sp/
  ma Masi lon kulupu mun suno. /sp/
  nimi pi mun Masi li sama e jan sewi tan nasin sewi Loma. /sp/
  jan sewi ni li jan sewi utala. /sp/

  jan li tawa mun Masi ala. taso, ilo mun mute li tawa mun Masi. /sp/
  ma Mewika en ma Elopa /sp/
  en ma Losi en ma Nijon /sp/
  en ma Imalasi en ma Sonko /sp/
  li tawa e ilo tawa mun Masi. /sp/
  ilo li awen lon selo. ilo ante li ken tawa lon selo. /sp/
  ilo Insanjuwisi /sp/
  (toki Inli: "#penpo.esc[Ingenuity]") li ken tawa lon kon. /sp/
  ilo ante li tawa sike e mun Masi li pali e sitelen pi selo ona. /sp/

  mun lili tu li sike e mun Masi. /sp/
  nimi ona li mun Popo li mun Temo. /sp/
  ona li kiwen li sike lukin ala. /sp/
][
  #figure(
    image("assets/mun-Masi.jpg"),
    caption: "sitelen pi mun Masi",
  )
  #figure(
    image("assets/mun-Popo-en-Temo.jpg"),
    caption: "sitelen pi mun Popo en mun Temo",
  )
]
```
```typ
// lipu: main-sl.typ
#import "@preview/penpo:0.1.0"

#show: penpo.lasina.sitelen

#include "toki.typ"
```
```typ
// lipu: main-sp.typ
#import "@preview/penpo:0.1.0"

#show: penpo.pona.sitelen

#include "toki.typ"
```
![lipu ni li kepeken e sitelen Lasina](sama-ni/main-sl.svg)
![lipu ni li kepeken e sitelen pona](sama-ni/main-sp.svg)

