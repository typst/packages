#let titlepage()=[
  #set page(
    paper: "a4",
    margin: (top: 3cm, left: 3cm, right: 3cm, bottom: 3cm),
  )
  
  #set text(weight: "bold",font: "TeX Gyre Heros", size: 20pt, lang: "de", hyphenate: false)

  #set par(justify: false)

  
  #place(top + center, text(size:1.3em, [Your Title]))
  #v(1.1fr)
  
  #align(center + horizon, [
    #text([Bachelorarbeit der Mathematisch-Naturwissenschaftlichen Fakultät])
    #v(0.1em) 
    der  #smallcaps[Eberhard Karls Universität Tübingen]//kapitälchen
    #v(0.1em)
    #text([im Fach X])
  
  #v(1fr)
  
  vorgelegt von#str("\n\n") Surname, Name#str("\n") Tübingen, November 2025])
  #pagebreak()
]


// declaration of independence
#let declaration() = [
   #set page(
    paper: "a4",
    margin: (top: 3cm, left: 3cm, right: 3cm, bottom: 3cm),
  )
  
  #set text(size: 12pt, font: "TeX Gyre Heros", 
            lang: "de", hyphenate: false)
  #set list(marker: "-")
  #set par(justify: true)
  
  #strong("Erklärung:")
  
Hiermit erkläre ich,

- dass ich diese Arbeit selbst verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel benutzt habe, alle wörtlich oder sinngemäß aus anderen Werken übernommenen Aussagen als solche gekennzeichnet habe, die Arbeit weder vollständig noch in wesentlichen Teilen Gegenstand eines anderen Prüfungsverfahrens gewesen ist und die Arbeit weder vollständig noch in wesentlichen Teilen bereits veröffentlicht ist sowie dass das in Dateiform eingereichte Exemplar mit eingereichten gebundenen Exemplaren übereinstimmt.

- dass ich die Richtlinien zur Sicherung guter wissenschaftlicher Praxis und zum Umgang mit wissenschaftlichem Fehlverhalten an der Eberhard-Karls-Universität beachtet habe.
#v(2.5em) 

Tübingen, den #datetime.today().display("[day].[month].[year]")
//#image("../pictures/Unterschrift.png", width: 25%)

Your name
]