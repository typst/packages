= Test
<chap:test>
Ogni lavoro scientifico richiede una validazione dei risultati ottenuti. Questo si può fare confrontando in modo sistematico il proprio lavoro con lavori concorrenti o misurando l'efficacia del lavoro mediante test con gli utenti. È fondamentale che questi test siano ripetibili, dovrete dunque fornire tutti i dettagli necessari nel testo per permettere a chi legge la tesi di replicare l'esperimento.

Progettare e condurre un test soggettivo con utenti è un lavoro complesso e lungo, che richiede pianificazione e competenza. Il bel libro di Lazar #emph[et al.];~@lazar2017methods illustra in dettaglio i concetti principali della ricerca sperimentale e le metodologie correlate: ipotesi di ricerca, design sperimentale, analisi dei risultati sperimentali. Quelli che seguono sono alcuni consigli specifici sugli aspetti più importanti.

== Protocollo
<protocollo>
Uno degli errori più comuni è sottovalutare lo studio di un #emph[protocollo] sperimentale. Affinché i risultati dei test siano significativi è necessario non trascurare i seguenti aspetti:

- eliminare distorsioni sistematiche involontarie;

- isolare le variabili oggetto dello studio;

- garantire una numerosità sufficiente del campione;

- confrontare gli effetti con un gruppo di controllo.

== Risultati
<risultati>
I risultati dei test vanno presentati in modo chiaro e completo, possibilmente indicando la significatività statistica di quanto ottenuto.

È buona norma fornire sia i dati numerici (un esempio di come si fanno le tabelle in Typst~è visibile in Tab.~@tab:sample), sia una rappresentazione grafica (a barre, a scatole e baffi, a violino, di dispersione, ecc.).

È inoltre consigliato riportare in appendice i dati grezzi completi, in modo da permettere al lettore di ripetere eventuali test statistici.

#figure(
  align(center)[#table(
      columns: 3,
      align: (col, row) => (left, left, left).at(col),
      inset: 6pt,
      [Colonna 1], [Colonna 2], [Colonna 3],
      [5], [8], [1],
      [6], [9], [2],
      [7], [0], [3],
    )],
  caption: [Tabella di esempio.],
)<tab:sample>
== Osservazioni
<osservazioni>
Quando si traggono conclusioni dai dati bisogna prestare attenzione a non confondere la correlazione con un rapporto di causalità. Molto spesso accade che un test suggerisca la presenza di un fenomeno, ma non dica nulla sulla causa. In questo caso bisogna formulare delle ipotesi, calcolare le implicazioni, ed eseguire un test che valuti se e quali di queste implicazioni si verifichino. Se il nuovo test falsifica la teoria, non importa quanto questa sia elegante: è falsa. Se invece il nuovo test non falsifica la teoria, allora la si può dare per "vera fino a prova contraria".

Per queste ragioni è necessario esporre le proprie osservazioni in maniera cauta, senza andare oltre ciò che suggeriscono i dati. È certamente possibile speculare sulle cause, ma va esplicitato chiaramente, e tali speculazioni vanno supportate dalla bibliografia.
