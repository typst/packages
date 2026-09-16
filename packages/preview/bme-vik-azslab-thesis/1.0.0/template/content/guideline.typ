// -------------------------------------------------------------------------------
// Rövid formai és tartalmi tájékoztató
// ----------------------------------------------------------------------------

#let create-guideline() = {
  set enum(indent: 2em, spacing: 1em)
  set list(indent: 2em, spacing: 1em)
  set page(margin: 2.5cm)
  set par(
    justify: true,
    first-line-indent: (amount: 2em, all: true),
    leading: 0.5em,
    spacing: 0.5em
  )
  set text(font: "New Computer Modern", size: 10pt)

  show enum: set block(
    above: 1em,
    below: 1em
  )
  show list: set block(
    above: 1em,
    below: 1em
  )

  align(center)[
    #text(weight: "bold", size: 16pt)[Általános információk, a diplomaterv szerkezete]
  ]
  block(above: 2em)[
    A diplomaterv szerkezete a BME Villamosmérnöki és Informatikai Karán:

    1. Diplomaterv feladatkiírás
    2. Címoldal
    3. Tartalomjegyzék
    4. A diplomatervező nyilatkozata az önálló munkáról és az elektronikus adatok kezeléséről
    5. Tartalmi összefoglaló magyarul és angolul
    6. Bevezetés: a feladat értelmezése, a tervezés célja, a feladat indokoltsága, a diplomaterv felépítésének rövid összefoglalása
    7. A feladatkiírás pontosítása és részletes elemzése
    8. Előzmények (irodalomkutatás, hasonló alkotások), az ezekből levonható következtetések
    9. A tervezés részletes leírása, a döntési lehetőségek értékelése és a választott megoldások indoklása
    10. A megtervezett műszaki alkotás értékelése, kritikai elemzése, továbbfejlesztési lehetőségek
    11. Esetleges köszönetnyilvánítások
    12. Részletes és pontos irodalomjegyzék
    13. Függelék(ek)

    Felhasználható a következő oldaltól kezdődő \LaTeX diplomatervsablon dokumentum tartalma. 

    A diplomaterv szabványos méretű A4-es lapokra kerüljön. Az oldalak tükörmargóval készüljenek (mindenhol 2,5~cm, baloldalon 1~cm-es kötéssel). Az alapértelmezett betűkészlet a 12 pontos Times New Roman, másfeles sorközzel, de ettől kismértékben el lehet térni, ill. más betűtípus használata is megengedett.

    Minden oldalon -- az első négy szerkezeti elem kivételével -- szerepelnie kell az oldalszámnak.

    A fejezeteket decimális beosztással kell ellátni. Az ábrákat a megfelelő helyre be kell illeszteni, fejezetenként decimális számmal és kifejező címmel kell ellátni. A fejezeteket decimális aláosztással számozzuk, maximálisan 3 aláosztás mélységben (pl. 2.3.4.1.). Az ábrákat, táblázatokat és képleteket célszerű fejezetenként külön számozni (pl. 2.4. ábra, 4.2. táblázat vagy képletnél (3.2)). A fejezetcímeket igazítsuk balra, a normál szövegnél viszont használjunk sorkiegyenlítést. Az ábrákat, táblázatokat és a hozzájuk tartozó címet igazítsuk középre. A cím a jelölt rész alatt helyezkedjen el.

    A képeket lehetőleg rajzoló programmal készítsék el, az egyenleteket egyenlet-szerkesztő segítségével írják le (A LaTex/Typst~ehhez kézenfekvő megoldásokat nyújt).

    Az irodalomjegyzék szövegközi hivatkozása történhet sorszámozva (ez a preferált megoldás) vagy a Harvard-rendszerben (a szerző és az évszám megadásával). A teljes lista névsor szerinti sorrendben a szöveg végén szerepeljen (sorszámozott irodalmi hivatkozások esetén hivatkozási sorrendben). A szakirodalmi források címeit azonban mindig az eredeti nyelven kell megadni, esetleg zárójelben a fordítással. A listában szereplő valamennyi publikációra hivatkozni kell a szövegben (a Typst-sablon a BibTeX~segítségével mindezt automatikusan kezeli). Minden publikáció a szerzők után a következő adatok szerepelnek: folyóirat cikkeknél a pontos cím, a folyóirat címe, évfolyam, szám, oldalszám tól-ig. A folyóiratok címét csak akkor rövidítsük, ha azok nagyon közismertek vagy nagyon hosszúak. Internetes hivatkozások megadásakor fontos, hogy az elérési út előtt megadjuk az oldal tulajdonosát és tartalmát (mivel a link egy idő után akár elérhetetlenné is válhat), valamint az elérés időpontját.

    #block(above: 5mm, below: 5mm)[
      Fontos:

      - A szakdolgozatkészítő / diplomatervező nyilatkozata (a jelen sablonban szereplő szövegtartalommal) kötelező előírás, Karunkon ennek hiányában a szakdolgozat/diplomaterv nem bírálható és nem védhető!
      - Mind a dolgozat, mind a melléklet maximálisan 15~MB méretű lehet!
    ]

    #align(center)[Jó munkát, sikeres szakdolgozatkészítést, ill. diplomatervezést kívánunk!]
  ]

  pagebreak(weak: true)
}

#create-guideline()