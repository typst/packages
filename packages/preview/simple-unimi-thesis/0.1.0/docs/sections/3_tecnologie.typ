= Tecnologie utilizzate
<cap3>
In questo capitolo vengono presentati alcuni suggerimenti utili per un utente Typst~alle prime armi.

== Generalità
<generalità>
=== La scrittura WYSIWYG vs.~WYSIWYM
<la-scrittura-wysiwyg-vs.-wysiwym>
L'acronimo WYSIWYG sta per "What You See is What You Get", e si riferisce al concetto di ottenere sulla carta testo e immagini che abbiano una disposizione grafica equivalente a quella visualizzata a schermo dal software di videoscrittura. Un esempio classico di WYSIWYG è Microsoft Word, che mostra il testo impaginato e formattato come ci si aspetta di vederlo una volta stampato.

L'acronimo WYSIWYM sta per "What You See is What You Mean", ed è il paradigma per la creazione di testi strutturati. Typst~è un ambiente che supporta tale paradigma. In realtà, anche Microsoft Word avrebbe la possibilità di strutturare il testo, principalmente attraverso il meccanismo degli stili, ma pochissimi utenti sfruttano tale funzionalità (ovviamente se sceglierete di scrivere la tesi in Word raccomandiamo caldamente l'uso di tali funzioni, così come le funzioni di gestione automatica dei riferimenti e della bibliografia).

I principali svantaggi di un sistema WYSIWYM sono il tempo di apprendimento, dovuto a una minore intuitività degli strumenti software, e la necessità di invocare la compilazione del documento per vederne l'aspetto definitivo. Ad esempio, in Typst~l'intero documento viene scritto in testo semplice, che all'interno contiene ambienti e comandi con informazioni di layout, e solo la compilazione permette di scoprire eventuali errori di sintassi e giungere, infine, alla creazione del PDF.

Le difficoltà iniziali, però, sono ampiamente compensate dai vantaggi a medio e lungo termine. Infatti, il lavoro risulterà perfettamente impaginato e strutturato, e dunque avrà un aspetto professionale. Questo riguarda non solo gli stili, che vengono applicati al testo in modo coerente con il template prescelto, ma anche aspetti tipicamente spinosi di Word, quali il posizionamento delle immagini e delle tabelle, la creazione di una bibliografia con relative citazioni nel testo, la creazione di un sommario. Diventa automatico e molto semplice, ad esempio, aggiungere un indice delle figure o delle tabelle, oppure numerare le formule espresse nel testo. Un altro aspetto su cui Typst~è nettamente superiore a Word è proprio la scrittura di formule matematiche, come mostrato nell'esempio qui riportato: $ x_i (n) = a_(i 1) u_1 (n) + a_(i 2) u_2 (n) + dots.h.c + a_(i J) u_J (n) thin . $

=== Risorse e strumenti
<risorse-e-strumenti>
Esiste una vastissima gamma di risorse online per avvicinarsi a Typst. Un buon punto di partenza è navigare l'applicazione web di Typst,#footnote[#link("https://typst.app/");] che contiene una ricca documentazione su come funziona il linguaggio,#footnote[#link("https://typst.app/docs/");] un archivio di librerie e template #footnote()[#link("https://typst.app/universe/")] e anche un forum nel quale trovare le domande più frequenti.#footnote[#link("https://forum.typst.app/");]

In alternativa a un'installazione locale sul proprio pc, è possibile utilizzare un editor Typst~online, con il vantaggio di avere immediatamente a disposizione l'ambiente di sviluppo e tutti i package necessari, nonché di potere condividere il proprio progetto con il relatore di tesi. Il più diffuso editor online per questo linguaggio è l'app web fornita direttamente da Typst: una semplice iscrizione tramite mail permette di accedere all'editor.

Qualunque sia la risorsa utilizzata, ecco un elenco non esaustivo di argomenti di base nei quali con tutta probabilità ci si imbatterà durante la stesura della tesi.

- Formattazione del testo (grassetto, italics, dimensioni font, ecc.) e del documento (heading di vario livello, indici, ecc.).

- Elenchi: ambienti #emph[enum] e #emph[list].

- Riferimenti incrociati: comando `ref`, label ed etichette.

- Matematica: equazioni e modalità #emph[inline].

- Figure: formati grafici, ambiente #emph[figure] e #emph[image].

- Tabelle: ambienti #emph[table] e #emph[grid].

- Riferimenti e bibliografie (si veda più sotto la sezione~@sec:bibtex).

== Suggerimenti sull'uso di Typst
<sec:consigli_latex>
Fatte salve le indicazioni generali fornite nella sezione precedente, di seguito si riportano alcune osservazioni puntuali sulle domande e gli errori più tipici degli studenti alle prime armi con Typst.

=== Riferimenti incrociati
<riferimenti-incrociati>
Uno dei principali vantaggi di Typst~è la possibilità di impostare riferimenti automatici a molti elementi del documento, tra cui headings, tabelle, figure, equazioni, riferimenti bibliografici, e via dicendo.

Quindi il modo corretto per riferirsi, ad esempio, alla seconda sezione non è scrivere "Sezione 2" bensì "@chap:stato_arte". Il risultato apparente (nel PDF) è lo stesso, mentre ci sono differenze sostanziali a livello di codice. Il vantaggio è che, se il secondo capitolo diventasse il terzo, il riferimento incrociato continuerebbe a puntare alla posizione corretta. Si pensi, per estensione, alla numerazione delle immagini, o ai riferimenti alla bibliografia.

Sintatticamente, questo richiede di inserire delle label `<mia_label>` dopo una #emph[figure] che contiene gli elementi cui ci si vuole riferire, e dei comandi `#ref(<mia_label>)` o `@mia_label` dove si vuole creare il riferimento. La sintassi con `@` si utilizza anche per riferirsi agli elementi della bibliografia (si veda più sotto la sezione~@sec:bibtex per la generazione di una bibliografia completa).

=== Ritorni a capo
<ritorni-a-capo>
I ritorni a capo in Typst~possono essere effettuati in due modi: con la sintassi `\` o con una doppia pressione del tasto di ritorno a capo. In generale, la soluzione corretta è la seconda, che equivale a usare il tasto Enter in Word. Il Backslash, che corrisponde a Shift+Enter in Word, crea una nuova riga senza interruzione del paragrafo. Questo va usato solo in casi molto specifici, come nella frase seguente.

Il sito web ufficiale dell'Università degli Studi di Milano è:
#align(center, link("https://www.unimi.it"))

In questo template, un nuovo paragrafo (dopo un doppio a capo) crea un rientro della prima riga. Questo viene fatto impostando il parametro `first-line-indent` di `par` al valore `1.2em`. Non c'è nulla di male nel rientro, ma se proprio lo si vuole evitare la soluzione è rimuovere il parametro appena citato.

=== Spazi tra parole
<spazi-tra-parole>
Riguardo la gestione della spaziatura tra parole, Typst~adotta una strategia molto elegante, che lascia uno spazio maggiorato dopo il punto di fine periodo. Un potenziale problema è che questo spazio extra viene introdotto dopo qualsiasi occorrenza del punto, indipendentemente dalla funzione sintattica, e dunque anche dopo i nomi puntati, quali "R. Schumann", o dopo le formule "ad es.", "Fig. n", "ecc." e via dicendo. Per evitarlo, questi spazi da non aumentare vanno sostituiti con alternative, quali un Backslash seguito da uno spazio (che immette un #emph[control space];) o una tilde `~` (che introduce un #emph[unbreakable space];, utile a impedire ritorni a capo intermedi).

=== Ambienti per scrivere codice
<ambienti-per-scrivere-codice>
Il codice all'interno dell'elaborato va scritto con carattere monospaziato e rispettando, nell'ambito del possibile, le originali regole (o buone pratiche) di indentazione.

Per farlo, esistono all'interno del Typst universe una serie di librerie per la scrittura di codice, come `lovelace` o `algo`.

Una soluzione che non attinge ai repository Typst è aprire e chiudere un blocco con il triplice accento #raw("`") e inserire al suo interno il codice da renderizzare.

Un esempio, relativo al calcolo del massimo comun divisore attraverso l'algoritmo di Euclide in Python, è:

```
def MCD(a,b):
  while b != 0:
    a, b = b, a % b
  return a
```

Se dopo l'apertura del blocco si specifica il linguaggio adottato, ad esempio con la sintassi #raw("```python"), si ottiene automaticamente l'evidenziazione del codice:

```python
def MCD(a,b):
  while b != 0:
    a, b = b, a % b
  return a
```

L'elenco dei linguaggi ufficialmente supportati non è disponibile, ma è presente una lista #footnote[#link("https://github.com/typst/typst/issues/1511#issuecomment-1822459773")] non ufficiale creata da un utente grazie all'autocompletamento dell'editor della web app.

=== Figure
<figure>
In tutti i casi in cui sia possibile (schemi a blocchi, plot di dati, ecc.), è opportuno che le figure siano in formato vettoriale (svg) per aumentarne la leggibilità. Nel caso di figure prodotte da software esterno (ad esempio, grafici esportati in eps o pdf da Matlab), è consigliabile conservare tutti i sorgenti e i dati utilizzati per generarle: in questo modo sarà possibile ricreare le figure quando necessario.

Le figure devono sempre avere riferimenti nel testo, realizzati come visto nella @riferimenti-incrociati. Il medesimo discorso vale anche per Tabelle ed Equazioni.

Si evitino espressioni del tipo "come visibile nella figura seguente" in favore di riferimenti esatti del tipo "come visibile in Fig~@fig:ideas2text" in quanto Typst posiziona le immagini sulla pagina seguendo regole tipografiche, che non corrispondono necessariamente alla posizione di inserimento nel sorgente del documento.

== Bibliografia
<sec:bibtex>
=== Generalità
<generalità-1>
Esistono più modi per inserire una bibliografia in Typst: o quello di BibLaTeX @biblatex oppure Hayagriva @hayagriva. Entrambi consentono di aggiungere, rimuovere e modificare voci di bibliografia in maniera efficiente, di formattarle, di riordinarle a piacere e aggiornare automaticamente i corrispondenti riferimenti nel testo, ecc.

La differenza è che il primo è lo standard che arriva da LaTeX -- e quindi tutto ciò che ne consegue: ampio supporto, letto ed esportato ovunque -- mentre il secondo è l'approccio alla Typst, quindi molto più agile, intuitivo; ma in quanto più moderno non si aspetti lo stesso supporto.

/ Per BibLaTeX : Una guida introduttiva e completa è "Tame the BeaST".#footnote[Accessibile da #link("http://www.tug.org/interest.html");] In estrema sintesi, i passi per gestire una bibliografia tramite sono essenzialmente tre.

+ Salvare i riferimenti bibliografici come entry di uno o più file con l'estensione `.bib` (si veda ad esempio il file `bibliografia.bib`, parte di questo template). Gli entry sono scritti in un formato specifico, in particolare ogni entry ha una propria etichetta testuale che lo identifica univocamente

+ Creare la bibliografia alla fine del documento o dove desiderato, usando il comando `#bibliography("file.bib")`. È possibile inoltre specificare uno stile bibliografico modificando il campo `style` del comando precedente.

+ All'interno del testo, riferirsi a una voce di bibliografia tramite il comando `@etichetta_entry`. Si noti che una voce bibliografica non viene inclusa in bibliografia in assenza di una citazione all'interno del testo (coerentemente con quanto discusso nella sezione~@sec:biblio).

Tutte queste considerazioni si applicano anche ad Hayagriva.

La scelta del sistema ricade sulla fonte della bibliografia: se è principalmente da scrivere _a mano_, allora conviene sicuramente Hayagriva perché è molto più semplice; altrimenti, se la bibliografia viene recuperata (o generata) da fonti online è meglio BibLaTeX perché è un formato standard e supportato da qualsiasi software.

È consigliabile infine cominciare a costruire la propria bibliografia a mano a mano che si analizza lo stato dell'arte, invece che rimandare alla stesura finale della tesi.

=== Strumenti
<strumenti>
Un file .bib è un file di testo e può quindi essere gestito con un qualsiasi text editor. Esistono comunque molti tool più evoluti per gestire bibliografie in formato bib. Un'applicazione installabile localmente sul proprio pc è JabRef.#footnote[#link("http://www.jabref.org");];. Oppure esistono tool online, come Zotero,#footnote[#link("http://www.zotero.org");] che forniscono molte funzionalità tra cui l'esportazione di bibliografie in formato bib.

Peraltro, anche Google Scholar esporta automaticamente citazioni in formato bib cliccando sul link Cita (icona con doppie virgolette) e scegliendo l'opzione nella parte bassa della finestra che si apre. #strong[Attenzione] però: spesso i bib esportati da Scholar sono incompleti o sporchi, è sempre consigliabile controllarne la correttezza.

Infatti, si preferiscono, in generale, i metadati raccolti dalla sorgente primaria della risorsa (es. sito ufficiale della pubblicazione) rispetto a quelli presentati dai motori di ricerca. Nel caso in cui i siti ufficiali non propongano il formato , esistono convertitori, facilmente reperibili e utilizzabili via web, per convertire in la maggior parte dei formati (es. RIS). Nei rari casi in cui non siano disponibili i dati in alcun formato machine readable, potete compilare manualmente l'entry voi stessi.
