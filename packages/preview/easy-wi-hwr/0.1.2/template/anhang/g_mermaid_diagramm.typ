// anhang/g_mermaid_diagramm.typ — Beispiel: Mermaid-Diagramm im Anhang
// Nutzt das mmdr-Package um Mermaid-Syntax direkt in Typst zu rendern.
// Voraussetzung: #import "@preview/mmdr:0.2.1": mermaid (einmalig oben in der Datei)
// Details: https://typst.app/universe/package/mmdr

#import "@preview/mmdr:0.2.1": mermaid

#figure(
  mermaid("graph TD
    A[Literaturrecherche] --> B[Hypothesenbildung]
    B --> C{Quantitativ?}
    C -->|Ja| D[Fragebogen]
    C -->|Nein| E[Interview]
    D --> F[Auswertung]
    E --> F
  "),
  caption: [Forschungsprozess der vorliegenden Arbeit (erstellt mit Mermaid).],
)

// Weitere Beispiele:

// Sequenzdiagramm
#figure(
  mermaid("sequenceDiagram
    participant N as Nutzer
    participant S as System
    participant DB as Datenbank
    N->>S: Login-Anfrage
    S->>DB: Credentials prüfen
    DB-->>S: Ergebnis
    S-->>N: Zugang gewährt/verweigert
  "),
  caption: [Sequenzdiagramm des Login-Prozesses.],
)
