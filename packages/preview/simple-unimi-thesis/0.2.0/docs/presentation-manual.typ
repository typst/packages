#import "@preview/simple-unimi-thesis:0.2.0": *
#import "@preview/touying:0.7.4": *
#import "@preview/zebraw:0.6.3": *

#show: zebraw.with(numbering: false, inset: (left: 1.25em))
#show: unimi-presentation.with(
  config-info(
    title: [Manuale di `unimi-presentation`],
    author: [Vittorio Robecchi],
    serial-number: "10851734",
    date: datetime.today(),
  ),
)

#set text(lang: "it")

#title-slide()

= Introduzione

== Titolo

- È necessario compilare le seguenti informazioni in ```typ #config-info()``` all'inizio della presentazione:
  ```typ
  #show: unimi-presentation.with(
    config-info(
      title: [Titolo della Presentazione],
      course: [Corso di Laurea],
      author: [Nome Cognome],
      serial-number: [123456],
      date: datetime(...),
    ),
  )
  ```

---

- Impostare la lingua:
  ```typ
  #set text(lang: "it")
  ```
  #pause

- Sia la diapositiva del titolo che quelle normali faranno riferimento a quei dati #pause

- Essa è chiamabile mediante ```typ #title-slide()``` e generalmente si piazza appena dopo la precedente funzione

== Comandi generali

- La presentazione si può dividere in sezioni e diapositive, rispettivamente utilizzando i titoli di livello 1 (```typ =```) e 2 (```typ ==```) #pause

  - *Attenzione*: i numeri in basso a sinistra fanno riferimento rispettivamente al numero di diapositive _adesso_ (#context utils.slide-counter.display()) e al numero di diapositive _totali_ (#context utils.last-slide-number) -- *NON* al numero di pagine #pause

- Nell'intestazione apparianno sempre il titolo della diapositiva corrente e, al di sotto, quello della sezione #pause

- Ogni volta che si cambia sezione, viene invocato l'indice con il titolo corrispondente evidenziato, mentre gli altri leggermente sbiaditi (vedasi prossima diapositiva)

= Realizzazione della presentazione

== Punti a elenco

- Una tipica diapositiva è costituita da punti a elenco che vengono mostrati uno per volta #pause

- I punti a elenco si scrivono come segue:
  ```typ
  - Primo
  - Secondo
  ``` #pause

- Per farli apparire uno per diapositiva, Touying offre la funzione ```typ #pause```:
  ```typ
  - Primo #pause
  - Secondo #pause
  ``` #pause

- Si noti come il numero della diapositiva sia rimasto il medesimo (ossia #context utils.slide-counter.display())

== Colonne

#columns[
  - Spesso è utile disporre il contenuto in un certo numero di colonne in base alla necessità #pause

  - Typst offre la funzione ```typ #columns(n)```, che distruibuisce il contenuto su più colonne in base al `n`umero specificato #pause

  #colbreak()

  - Inoltre è utile utilizzare anche ```typ #colbreak()``` per l'interruzione di colonna #pause

  - Touying invece offre ```typ #components.adaptive-columns()```, che distruibuisce il contenuto  su diverse colonne in base alle dimensioni (come nell'indice)
]

== Dividere le diapositive

- Alla volte è utile passare alla prossima diapositiva prima, senza aspettare che il contenuto la riempia #pause

- Un altro modo di vederlo è mostrare prima una certo contenuto...

---

- ...e solo dopo il resto; tuttavia "rimuovendo" la parte prima, come se la schermata venisse aggiornata #pause

- Questo è possibile farlo utilizzando il separatore ```typ ---```, che chiama la funzione ```typ #pagebreak()```

== Conclusione

- Generalmente le presentazioni terminano con una singola dispositiva che scrive "Grazie per l'attenzione" o auguri affini #pause

- La funzione standard per questo scopo è ```typ #focus-slide(content)```, dove `content` è la frase di chiusura #pause

- Il codice della prossima -- e ultima -- diapositiva infatti è

  ```typ
  #focus-slide("Grazie per l'attenzione.")
  ```

#focus-slide("Grazie per l'attenzione.")
