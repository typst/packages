#import "@preview/unofficial-uninsubria-thesis:0.1.0": gls, sourcecode
= Spiegazione

Di seguito vengono illustrati alcuni elementi e funzioni utili per creare documenti Typst con questo template.

== Espressioni e abbreviazioni

Usa la funzione `gls` per inserire espressioni dal glossario, che verranno quindi collegate lì. Un esempio è:

In questo capitolo viene descritta una #gls("Softwareschnittstelle"). In questo contesto si parla anche di #gls("API"). L'interfaccia utilizza tecnologie come #gls("HTTP").

Il template utilizza il pacchetto `glossarium` per tali riferimenti al glossario. Nella #link("https://typst.app/universe/package/glossarium/", "documentazione") associata vengono mostrate altre varianti per tali riferimenti incrociati. Lì viene anche spiegato in dettaglio come può essere strutturato il glossario.


== Elenchi

Ci sono elenchi puntati o numerati:

- Questo
- è un
- elenco puntato

+ E
+ qui viene
- tutto numerato.

== Figure e tabelle

Figure e tabelle (con le relative didascalie) vengono create come segue.

=== Figure

#figure(caption: "Una figura", image(width: 4cm, "/images/ts.svg"))

=== Tabelle

#figure(
  caption: "Una tabella",
  table(
    columns: (1fr, 50%, auto),
    inset: 10pt,
    align: horizon,
    table.header(
      [],
      [*Area*],
      [*Parameters*],
    ),

    text("cylinder.svg"),
    $ pi h (D^2 - d^2) / 4 $,
    [
      $h$: height \
      $D$: outer radius \
      $d$: inner radius
    ],

    text("tetrahedron.svg"), $ sqrt(2) / 12 a^3 $, [$a$: edge length],
  ),
)<table>

== Codice sorgente

Il codice sorgente con la relativa formattazione viene inserito come segue:

#figure(
  caption: "Un pezzo di codice sorgente",
  sourcecode[```ts
    const ReactComponent = () => {
      return (
        <div>
          <h1>Hello World</h1>
        </div>
      );
    };

    export default ReactComponent;
    ```],
)


== Riferimenti

Per i riferimenti bibliografici si utilizza la funzione `cite` o la scorciatoia con il simbolo \@:
- `#cite(form: "prose", <iso18004>)` produce: \ #cite(form: "prose", <iso18004>)
- Con `@iso18004` si ottiene: @iso18004

Tabelle, figure e altri elementi possono essere contrassegnati con un'etichetta tra parentesi angolari (la tabella sopra ha ad esempio l'etichetta `<table>`). Essa può quindi essere referenziata con `@table`. Nel caso specifico si ottiene: @table
