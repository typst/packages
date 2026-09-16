= Introduzione
<cap:introduzione>
Questo documento ha una duplice funzione: da un lato mostra un esempio completo di tesi redatto in Typst~e conforme allo standard PDF/A, e dall'altro contiene suggerimenti e risposte a domande frequenti poste dagli studenti. Se ne raccomanda, pertanto, un'attenta lettura.

== Il template
<il-template>
Il template LaTeX è stato sviluppato, negli anni, dai membri del Laboratorio di Informatica Musicale (LIM) dell'Università degli Studi di Milano, in particolare da: Giorgio Presti, Luca Andrea Ludovico, Federico Avanzini, e Marco Tiraboschi. Questo template è un porting in Typst di quello LaTeX del LIM, la cui versione continuamente aggiornata è disponibile su Overleaf al seguente link:

#box(
  inset: 1.2em,
  link("https://www.overleaf.com/read/hmffzxzhhdqn"),
)

È stato principalmente inteso per gli elaborati finali del corso di laurea triennale in Informatica Musicale, e poi esteso anche agli altri CdL del Dipartimento di Informatica, ma può essere riadattato anche per altri corsi cambiando i metadati nel preambolo. Nel resto del documento, dove non specificato, useremo il termine #emph[tesi] nella sua accezione generica che include anche gli elaborati triennali.

=== Impostazioni

Per quanto riguarda Typst, è possibile impostare i seguenti parametri:
```typ
#show: progetto.with(
  university: "Università degli Studi di Milano",
  unilogo: "../template/img/unimi.svg",
  faculty: [Facoltà di Scienze e Tecnologie],
  department: [
    Dipartimento di Informatica \
    Giovanni degli Antoni
  ],
  cdl: [
    Corsi di Laurea Triennale in \
    Corso di Laurea
  ],
  printedtitle: "",
  title: "Un template meraviglioso",
  typeofthesis: "Elaborato Finale",
  author: (
    name: "Nome Cognome",
    serial_number: "123456",
  ),
  language: "it",
  supervisors: (
    "Prof. Enrico Fermi",
  ),
  cosupervisors: (
    "Prof. Ezio Auditore da Firenze",
    "Prof. Francesco Bianchi",
  ),
  academicyear: ""
)
```
(questi listati sono gli argomenti default). Tutti gli attributi sono sufficientemente chiari -- tranne `printedtitle`:
- Esso il titolo che appare _al frontespizio_, nel PDF
- `title` invece è quello che appare _nei metadata_ del file -- se `printedtitle` è vuoto, allora è uguale a `title`

== I contenuti
<sec:contenuti>
Alcune volte, le tesi possono avere forti connotazioni interdisciplinari. È però fondamentale ricordarsi che si tratta di lavori in area informatica, e questo aspetto deve emergere con chiarezza. Anche gli elaborati di contenuto più umanistico devono mostrare rigore scientifico e uno sforzo di formalizzazione nel loro svolgimento. In concreto, sono molto apprezzati schemi, tabelle, formalismi grafici e/o matematici, presenza di parti significative di codice (ove possibile).

Uno scritto di questa estensione parte sempre da un punto pregresso, tipicamente l'analisi dello stato dell'arte e della letteratura. È poi richiesto un contributo personale (e originale, nel caso delle tesi magistrali) per giungere a una conclusione formulata dall'autore, eventualmente anche in contrasto con il pensiero corrente o con quanto ci si prefigge all'inizio dell'opera.

Le tre fasi devono emergere con chiarezza:

- analisi dello stato dell'arte e/o della letteratura;

- contributo personale alla ricerca;

- conclusioni raggiunte, ed eventuali sviluppi futuri.

Nel loro complesso queste tre componenti devono rendere evidente la #emph[rilevanza] del lavoro, in termini di

- chiarezza nella definizione del problema, delle motivazioni e degli obiettivi della tesi;

- connessione con la letteratura (così da mostrare che la tematica oggetto della tesi è di interesse per la comunità scientifica);

- rilevanza della tematica nell'ambito delle discipline informatiche.

== Organizzazione della tesi
<sec:organizzazione>
La scelta di come strutturare un lavoro esteso, quale un elaborato finale o una tesi, non è semplice nè univoca, pertanto quelli sotto elencati vanno presi come suggerimenti generici e attualizzati alla propria situazione personale.

#figure(
  image(
    "../../src/img/unimi.svg",
    width: 25%,
  ),
  caption: [
    Il processo di trasformazione delle idee in testo~@hamalainen2019web.
  ],
)
<fig:ideas2text>

Prima di cominciare a scrivere testo è fondamentale creare un indice dei contenuti organizzato in maniera gerarchica (tesi, capitoli, sezioni, sottosezioni, ecc.). Una volta ottenuto un indice soddisfacente, questo potrà essere riempito dal testo della tesi. Un approccio informatico alla questione è il seguente: scrivere una tesi significa partire da un grafo di idee~@hamalainen2019web e arrivare a creare un albero di contenuti testuali (un #emph[minimum spanning tree] del grafo delle idee!). L'albero rappresenta la struttura del testo, dove il nodo radice è la tesi stessa, i suoi figli sono i capitoli, ecc. Le foglie dell'albero rappresentano le sottosezioni di livello più fine. Idealmente l'albero dei contenuti dovrebbe avere le seguenti caratteristiche:

- essere bilanciato;

- avere un'altezza $h = 4$ o $5$;

- essere un albero $n$-ario con $2 lt.eq n lt.eq 7$

Anche i contenuti testuali di tutti i nodi allo stesso livello dell'albero dovrebbero essere il più possibile bilanciati (ad esempio, sarebbe sbagliato avere un capitolo di una pagina e un altro di $30$ pagine). È tollerato uno sbilanciamento a favore del capitolo che descrive il proprio lavoro specifico e i contributi innovativi.

Limitatamente al secondo livello dell'albero (capitoli), un esempio puramente indicativo di scaletta per una tesi di natura sperimentale è quello che segue:

- Indice

- Introduzione

- Capitolo sullo stato dell'arte

- Capitolo sulle tecnologie utilizzate#footnote[Questo capitolo si può omettere se le sole tecnologie utilizzate sono strumenti standard come Python, JavaScript, C++, Matlab, ecc.]

- Capitolo sul caso di studio o sul software realizzato

- Capitolo sui test effettuati

- Breve capitolo su conclusioni e sviluppi futuri

- Bibliografia ed eventuale Sitografia

- Eventuali appendici (ad esempio, listati completi di codice, manuale utente, dimostrazioni, ecc.)

Sarà dunque opportuno prevedere, nel capitolo introduttivo, un esplicito richiamo alla struttura del documento. Ad esempio: "Il presente lavoro è organizzato come segue: nel Capitolo 1 …".

== Stile e forma
<sec:forma>
Lo stile di una tesi scientifica deve essere esatto, chiaro, compatto, oggettivo~@strunk1999style.

#emph[Esatto] vuol dire che ogni parola utilizzata significa solo ciò che deve esprimere. È opportuno cercare di evitare sinonimi per riferirsi a concetti importanti. Ove possibile si definiscano variabili (la frequenza $f$, il tempo $n$, ecc.) e le si usino in maniera sistematica. Vanno evitate il più possibile espressioni vaghe e non quantitative ("abbastanza grande", "praticamente tutti", "molto pochi", …). Si usino i pronomi con parsimonia, meglio ripetere qualche sostantivo nel testo piuttosto che lasciare delle ambiguità.

#emph[Chiaro] significa che la struttura e la forma devono essere funzionali a trasmettere l'informazione nel modo più immediato e comprensibile. I titoli di capitoli e sezioni devono essere illustrativi dei contenuti (è anche utile avere un breve testo all'inizio di un capitolo o una sezione, prima di passare alle sottosezioni). Il testo deve essere diviso logicamente in frasi, paragrafi, capoversi: sono preferibili paragrafi brevi, diretti e dichiarativi, limitando le subordinate e gli incisi, e i capoversi devono essere coerenti con la logica del discorso. L'uso di termini tecnici va limitato solo ai casi necessari. Anche gli acronimi devono essere usati con parsimonia, e vanno spiegati la prima volta che vengono usati.

#emph[Compatto] significa che si deve scrivere solo ciò che è necessario scrivere. Bisogna evitare ripetizioni di concetti e osservazioni. Bisogna limitare descrizioni e dettagli che non siano necessari alla comprensione del discorso generale. In particolare vanno evitate osservazioni banali, che risultino ovvie al lettore. Tra una forma verbosa ("in considerazione del fatto che…") e una equivalente più sintetica ("perché…") si preferisca la seconda.

#emph[Oggettivo] significa che ciò che si scrive deve essere privo di elementi soggettivi e di elementi che possono influenzare la valutazione. Vanno accuratamente evitate considerazioni personali ("Questa idea mi è venuta per la prima volta in occasione…"), nonché affermazioni opinabili il cui giudizio sia lasciato al parere personale dell'autore. L'unico modo per supportare tali prese di posizione è fornire dati scientifici a riprova della propria tesi, o riferirsi in modo esplicito a un antecedente bibliografico ("ipse dixit") citandone la provenienza in bibliografia. Infine, l'elaborato deve essere steso in forma impersonale. Frasi quali "Durante la mia esperienza ho approfondito i temi…" sono facilmente sostituibili con locuzioni quali "Durante la fase di analisi sono stati approfonditi i temi…".

Un uso appropriato di figure e tabelle è essenziale per supportare i punti appena discussi. Figure e tabelle devono avere delle didascalie autoesplicative (che non richiedano di leggere il testo principale per capirne il significato). Il testo principale deve però sempre contenere un riferimento alla figura o alla tabella ("Come mostrato in Fig.1, …"). L'uso di schemi grafici (uno schema a blocchi di algoritmo di elaborazione audio, uno schema concettuale di progetto software, ecc.) è particolarmente utile a supportare la chiarezza e la compattezza dell'esposizione.
