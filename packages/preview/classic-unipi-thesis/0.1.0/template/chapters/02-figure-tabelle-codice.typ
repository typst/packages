= Figure, tabelle e codice <cap:float>

Figure, tabelle e listati sono numerati automaticamente per capitolo (1.1, 1.2, …). Basta assegnare un'etichetta
`<nome>` alla `#figure(...)` e richiamarla con il prefisso corrispondente:

/ Figura: `<nome>` $arrow.r$ `@fig:nome`
/ Tabella: `<nome>` $arrow.r$ `@tbl:nome`
/ Listato: `<nome>` $arrow.r$ `@lst:nome`

#lorem(40)

== Immagini <sec:immagini>

// image() accetta PNG, JPG, SVG, PDF… Il percorso è relativo a questo file.
// Il testo tra [ ] in `caption` è la didascalia: l'elenco delle figure usa solo la sua prima frase.
La @fig:esempio mostra come inserire un'immagine con didascalia. #lorem(25)

#figure(
  image("../assets/images/piazza-dei-miracoli.svg"),
  caption: [Un'immagine caricata da file. Dopo il primo punto, il resto della didascalia compare solo sotto la figura e non nell'elenco delle figure],
) <esempio>

Si possono anche disegnare figure direttamente in Typst, senza file esterni, oppure affiancare più immagini con una griglia
(@fig:affiancate).

#figure(
  grid(
    columns: 2,
    gutter: 1em,
    image("../assets/images/torre-progetto.svg"), image("../assets/images/torre-oggi.svg"),
  ),
  caption: [Due immagini affiancate. Ciascuna potrebbe essere una sotto-figura (a) e (b).],
) <affiancate>
#lorem(40)

== Tabelle <sec:tabelle>

// table() definisce colonne e celle; con `stroke: none` e `table.hline` si ottiene lo stile "a tre linee".
La @tbl:risultati è una tabella con intestazione e didascalia. #lorem(20)

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    align: (left, center, center),
    stroke: none,
    table.header([*Metodo*], [*Accuratezza*], [*Tempo (s)*]),
    table.hline(stroke: 0.5pt),
    [Metodo A], [0.91], [12.4],
    [Metodo B], [0.93], [18.9],
    [Metodo C], [0.95], [25.1],
  ),
  caption: [Confronto tra tre metodi. Dati inventati a scopo dimostrativo.],
) <risultati>

#lorem(40)

== Codice sorgente <sec:codice>

// Codice inline: `...`. Blocchi di codice: tre apici inversi seguiti dal nome del linguaggio.
Il codice si può scrivere nel testo, come ```python print("ciao")```, oppure in un blocco. Il @lst:fibonacci è un listato
con didascalia e numerazione, citabile come qualsiasi figura.

#figure(
  ```python
  def fibonacci(n: int) -> int:
      """Restituisce l'n-esimo numero di Fibonacci."""
      a, b = 0, 1
      for _ in range(n):
          a, b = b, a + b
      return a

  print(fibonacci(10))  # 55
  ```,
  caption: [Calcolo iterativo dei numeri di Fibonacci in Python.],
) <fibonacci>

Oppure normalmente:
  ```python
  x = 5
  print(fibonacci(x))
  ```

Per includere un file di codice esistente si può usare `raw(read("script.py"), lang: "python")`.

== Grafici
Per i grafici bellini si può usare lilaq (ne ha diversi)
#import "@preview/lilaq:0.6.0" as lq

#let xs = (0, 1, 2, 3, 4)

#lq.diagram(
  title: [Precious data],
  xlabel: $x$, 
  ylabel: $y$,

  lq.plot(xs, (3, 5, 4, 2, 3), mark: "s", label: [A]),
  lq.plot(
    xs, x => 2*calc.cos(x) + 3, 
    mark: "o", label: [B]
  )
)

#let weierstrass(x, k: 8) = {
  range(k).map(k => calc.pow(0.5, k) * calc.cos(calc.pow(5, k) * x)).sum()
}

#let xs = lq.linspace(-0.5, .5, num: 1000)
#let xs-fine = lq.linspace(-0.05, 0, num: 1000)

#show: lq.set-grid(stroke: none)

#lq.diagram(
  width: 14cm, 
  height: 7cm,
  ylim: (0, 2),
  margin: (x: 2%),

  lq.plot(xs, weierstrass, mark: none),

  lq.rect(-0.05, 1.5, width: .05, height: .3),

  lq.place(
    60%, 100% - 1.2em, 
    align: bottom,
    lq.diagram(
      width: 5.4cm, height: 2cm, 
      margin: 0%,
      ylim: (1.5, 1.8),
      fill: white,
      lq.plot(xs-fine, weierstrass, mark: none),
    )
  )
)

Vedi #link("https://typst.app/universe/package/lilaq/")[documentazione]