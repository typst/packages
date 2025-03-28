// Leave a null margin here. It will be handled later in the grid.
// Horizontal A4 format, to be cut in half by hand.
#set page(paper: "a4", margin: 0pt, flipped: true)
// Set your language here.
#set text(lang: "it")

#let volantino_singolo = [
  // Place your logo if you wish.
  #place(
    bottom + right,
    dx: 0mm, dy: -10mm,
    image("fantasma.svg", height: 2.8cm))
  
  // Main heading
  #set text(font: "Bebas Neue", size: 48pt)
  #set par(leading: 10pt, spacing: 10pt)

  Non un euro per la loro guerra,
  No al riarmo UE
  
  // Body
  #set text(font: "Myriad Pro", size: 14pt)
  #set par(leading: 9pt, justify: true, spacing: 13pt)
  
  Ursula Von der Leyen ha presentato un piano di spesa per l’Unione Europea di *800 miliardi di euro*.
  Non per sanità, istruzione o salari.
  Non per il clima.
  Ma per una folle corsa agli armamenti.
  Questo disperato tentativo dell'UE di recuperare peso politico rispetto a USA e Russia
  allontana la pace e regala enormi profitti alle multinazionali delle armi.

  Questi fiumi di denaro pubblico andranno nelle tasche di Leonardo, Rheinmetall, BAE Systems, Thales e altre aziende che moltiplicano i fatturati quando Israele bombarda Gaza e quando giovani russi e ucraini si massacrano al fronte.

  In Italia, chi appoggia questo piano bellicista sono soprattutto il PD di Schlein e il partito di Giorgia Meloni.

  *Vergognosi* gli appelli del centrosinistra a un ipocrita europeismo che significa guerra e riarmo.

  *Vergognosa* la condotta del Governo Meloni che per obbedire a NATO e UE sacrifica le priorità dei cittadini.

  Per le nostre case minacciate dal *bradisismo* sono stati stanziati appena *50 milioni*, mentre per il *riarmo* il governo spenderà *65 miliardi* nei prossimi anni.

  #strong[
    Per i bisogni della gente: mai soldi.

    Per le armi e la guerra: miliardi.
  ]

  // Flush the rest to bottom.
  #v(1fr)
  
  // Footer
  #set text(font: "Bebas Neue", size: 24pt)
  #align(center)[
    Manifestazione nazionale \
    #text(size: 32pt)[Roma, 15 marzo 2025, ore 15]
  ]
]

#grid(
  columns: 2,
  inset: 12pt,
  volantino_singolo,
  grid.vline(stroke: (thickness: 0.1mm, dash: "dashed")),
  volantino_singolo
)
