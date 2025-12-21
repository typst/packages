// ---- nastavení -----
#let jmeno = "Jan Novák"
#let username = "novakja2"

#let fakulta = "Fakulta elektrotechnická ČVUT v Praze"
#let obor = "Obor Softwarové inženýrství a technologie"

#let nadpis = "Semestrální práce"
#let podnadpis = "Dokumentace"

#let datum = "Květen, " + str(datetime.today().year())


// ---- samotná titulní strana -----
#set page(numbering: none)
#[
  #set page(margin: 0in)
  #set align(center)

  #v(7em)

  #stack(dir: ltr, spacing: 1.3em)[
    #image("assets/cvut.svg", width: 7.1em)
  ][
    #v(1.5em)
    #set align(left)
    #stack(dir: ttb, spacing: 12pt)[
      #text(fakulta, size: 20pt, weight: "bold")
    ][
      #text(obor, size: 16pt)
    ]
  ]

  #v(20em)

  #text(nadpis, size: 26pt, weight: "bold")\
  #text(podnadpis, size: 18pt)

  #v(19em)

  #text(jmeno, 18pt)\
  #text(username, 12pt)
  #v(1.5em)
  #text(datum)
]
