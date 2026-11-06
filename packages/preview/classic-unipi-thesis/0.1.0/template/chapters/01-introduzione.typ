// Ogni capitolo è un file a sé, incluso da main.typ. Un titolo di livello 1 (`=`) inizia un nuovo capitolo.
// L'etichetta tra < > permette di richiamare il titolo nel testo con @intro.

= Introduzione <intro>

#lorem(80)

#lorem(60)

// Un paragrafo si separa dal successivo con una riga vuota; il rientro della prima riga è automatico.

== Titoli e sezioni <sec:titoli>

I titoli si scrivono con `=` ripetuto: `=` capitolo, `==` sezione, `===` sottosezione, `====` titolo senza numero.
Un titolo si cita nel testo con la sua etichetta, ad esempio `@sec:titoli`: vedi la @sec:titoli.

#lorem(50)

=== Una sottosezione

#lorem(70)

==== Un titolo di quarto livello (non numerato)

#lorem(40)

== Formattazione del testo

#lorem(30) Il testo può essere *in grassetto*, _in corsivo_ o `a larghezza fissa`, e può contenere un
#link("https://typst.app/docs")[collegamento ipertestuale] oppure una nota a piè di pagina.#footnote[
  Una nota a piè di pagina: #lorem(12)
]

=== Elenchi

// Elenco puntato (-) e numerato (+); l'indentazione crea i livelli annidati.
- Primo elemento: #lorem(8)
- Secondo elemento: #lorem(10)
  - Un sotto-elemento
  - Un altro sotto-elemento
- Terzo elemento

+ Primo passo
+ Secondo passo
+ Terzo passo

/ Termine: la descrizione di un termine, utile per glossari e definizioni.
/ Altro termine: #lorem(10)

=== Citazioni bibliografiche

Le voci bibliografiche si aggiungono in `utils/Bibliografia.bib` e si citano con `@chiave`: Knuth ha scritto un libro fondamentale
sulla programmazione @knuth1997art, mentre @lamport1994latex descrive un celebre sistema di composizione tipografica.
Più riferimenti si possono citare insieme: @knuth1997art @lamport1994latex, e anche articoli di rivista, come @vaswani2017attention. L'elenco completo compare in fondo alla tesi.

#lorem(60)
