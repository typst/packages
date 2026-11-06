/*
 * ==========================================================
 * Project: Typst Academic Thesis Template (KZN)
 * File: appendix.typ
 * Description:
 *   A comprehensive Typst template for academic theses and
 *   dissertations. Provides functions for title pages, headers,
 *   footers, table of contents, list of figures/tables, figure
 *   and table formatting with subfigures, and full document
 *   layout management. Supports multilingual documents (DE/EN/FR)
 *   with customizable fonts, spacing, and numbering schemes.
 *
 * Authors: Christian Prim and Lukas Zuberbühler
 * License: MIT License
 * ==========================================================
 *
 * Copyright (c) 2026 Christian Prim and Lukas Zuberbühler
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
 
#import "@preview/kzn-ma:0.1.0": *
#import "@preview/unify:0.7.1": unit, qty, num
#import "@preview/codly:1.3.0": codly, codly-init
#import "@preview/codly-languages:0.1.10": *
#import "@preview/typsium:0.3.1": ce

#show: codly-init.with()
#codly(languages: codly-languages)
#codly(number-format: none, zebra-fill: none, lang-format: none)

#let KZN = "Kantonsschule Zürich Nord (KZN)"


// ============================================================
// Anhang A: Formelsatz
// ============================================================

= Formelsatz <anhang1>

Der Formelsatz in Typst ist eng an #LaTeX angelehnt, aber mit einfacherer Syntax. Freistehende Formeln werden mit ```typst $ ... $``` (mit Leerzeichen vor und nach den Dollarzeichen) gesetzt, Inline-Formeln ohne Leerzeichen.

== Grundlegende Mathematik

```typst
// Inline: Pythagoras
Der Satz des Pythagoras lautet $a^2 + b^2 = c^2$.

// Freistehend: Quadratische Formel
$ x_(1,2) = (-b plus.minus sqrt(b^2 - 4 a c)) / (2a) $

// Griechische Buchstaben und Operatoren
$ alpha + beta = gamma, quad Delta omega = 2 pi f $

// Summen und Produkte
$ sum_(k=1)^n k = (n(n+1))/2, quad product_(i=1)^n i = n! $

// Integrale
$ integral_a^b f(x) dif x = F(b) - F(a) $

// Partielle Ableitungen
$ (partial f)/(partial x) = lim_(h -> 0) (f(x+h,y) - f(x,y))/h $

// Vektoren und Spaltenvektor
$ arrow(F) = m arrow(a), quad arrow(v) = mat(v_x; v_y; v_z) $

// Matrix
$ bold(A) = mat(
  a_(11), a_(12), a_(13);
  a_(21), a_(22), a_(23);
  a_(31), a_(32), a_(33)
) $
```

Die Ausgabe der freistehenden Formeln:

$ x_(1,2) = (-b plus.minus sqrt(b^2 - 4 a c)) / (2a) $

$ alpha + beta = gamma, quad Delta omega = 2 pi f $

$ sum_(k=1)^n k = (n(n+1))/2, quad product_(i=1)^n i = n! $

$ integral_a^b f(x) dif x = F(b) - F(a) $

$ (partial f)/(partial x) = lim_(h -> 0) (f(x+h,y) - f(x,y))/h $

$ arrow(F) = m arrow(a), quad arrow(v) = mat(v_x; v_y; v_z) $

$ bold(A) = mat(
  a_(11), a_(12), a_(13);
  a_(21), a_(22), a_(23);
  a_(31), a_(32), a_(33)
) $

== Physikalische Formeln

```typst
// Tsiolkowski-Gleichung (Raketengrundgleichung)
$ Delta v = v_g dot.c ln(m_0 / m_1) $

// Maxwell-Gleichungen (differentielle Form)
$ nabla dot.c arrow(E) = rho / epsilon_0, quad
  nabla dot.c arrow(B) = 0 $

$ nabla times arrow(E) = - (partial arrow(B))/(partial t), quad
  nabla times arrow(B) = mu_0 arrow(J) + mu_0 epsilon_0 (partial arrow(E))/(partial t) $

// Energiebilanz Looping
$ 1/2 m v_0^2 = 1/2 m v_"top"^2 + m g (2r) $

// Doppler-Effekt
$ f = f_0 / (1 - v/c) $
```

$ Delta v = v_g dot.c ln(m_0 / m_1) $

$ nabla dot.c arrow(E) = rho / epsilon_0, quad nabla dot.c arrow(B) = 0 $

$ nabla times arrow(E) = - (partial arrow(B))/(partial t), quad
  nabla times arrow(B) = mu_0 arrow(J) + mu_0 epsilon_0 (partial arrow(E))/(partial t) $

$ f = f_0 / (1 - v/c) $

== Einheiten mit ```typst unify```

```typst
#import "@preview/unify:0.7.1": unit, qty, num

// Masszahlen mit Einheit
Die Lichtgeschwindigkeit beträgt #qty("2.998e8", "m/s").
Ein Parsec entspricht #qty("3.086e16", "m") oder #qty("3.262", "ly").

// Einheit ohne Masszahl
Gib das Ergebnis in #unit("kilo gram meter per second squared") an.

// Einheiten innerhalb von Formeln
$ a = F/m = qty("15.0", "kN") / qty("1230", "kg")
       = qty("12.2", "m/s^2") $

// SI-Präfixe: ausgeschrieben und als Symbol sind gleichwertig
#qty("100", "mega pascal")
#qty("100", "MPa")
```


// ============================================================
// Anhang B: Chemische Formeln und Reaktionsgleichungen
// ============================================================

#pagebreak(weak: true)

= Chemische Formeln und Reaktionsgleichungen <app:chemie>

Für den Chemiesatz steht das Paket `typsium` (#link("https://typst.app/universe/package/typsium")) zur Verfügung. Es wird analog zu `mhchem` in #LaTeX über die Funktion ```typst #ce[...]``` bedient und muss zu Beginn des Dokuments importiert werden:

```typst
#import "@preview/typsium:0.3.1": ce
```

*Achtung:* Das Paket `typsium` ist teilweise nicht kompatibel mit dem Paket `unify`. Daher nur die Funktionen einbinden, die auch wirklich benötigt werden — hier z.B. nur `ce`.

== Summenformeln und Ionen

Summenformeln werden direkt in ```typst #ce[...]``` eingegeben. Indizes, Ladungen und Oxidationszahlen werden automatisch korrekt gesetzt:

```typst
// Einfache Summenformeln
#ce[H2O] #h(1em) #ce[CO2] #h(1em) #ce[H2SO4]

// Ionen mit Ladung
#ce[Na+] #h(1em) #ce[Cl-] #h(1em) #ce[SO4^2-] #h(1em) #ce[NH4+] #h(1em) #ce[Fe^3+]

// Aggregatzustände
#ce[NaCl(s)] #h(1em) #ce[HCl(g)] #h(1em) #ce[NaOH(aq)]
```

#ce[H2O] #h(1em) #ce[CO2] #h(1em) #ce[H2SO4]

#ce[Na+] #h(1em) #ce[Cl-] #h(1em) #ce[SO4^2-] #h(1em) #ce[NH4+] #h(1em) #ce[Fe^3+]

#ce[NaCl(s)] #h(1em) #ce[HCl(g)] #h(1em) #ce[NaOH(aq)]

== Reaktionsgleichungen

Reaktionspfeile werden direkt als ASCII-Sequenzen geschrieben:

```typst
// Synthese von Wasser
#ce[2H2 + O2 -> 2H2O]

// Gleichgewichtsreaktion: Haber-Bosch-Verfahren
#ce[N2 + 3H2 <=> 2NH3]

// Säure-Base-Reaktion: Neutralisation
#ce[HCl(aq) + NaOH(aq) -> NaCl(aq) + H2O(l)]

// Fällungsreaktion
#ce[AgNO3(aq) + NaCl(aq) -> AgCl(s) + NaNO3(aq)]

// Redoxreaktion: Korrosion von Eisen
#ce[4Fe + 3O2 -> 2Fe2O3]
```

#ce[2H2 + O2 -> 2H2O]

#ce[N2 + 3H2 <=> 2NH3]

#ce[HCl(aq) + NaOH(aq) -> NaCl(aq) + H2O(l)]

#ce[AgNO3(aq) + NaCl(aq) -> AgCl(s) + NaNO3(aq)]

#ce[4Fe + 3O2 -> 2Fe2O3]

== Reaktionsgleichung als freistehender Block

Für längere Reaktionsgleichungen oder wenn eine Nummerierung gewünscht wird, kann ```typst #ce``` in eine ```typst figure```-Umgebung eingebettet werden:

```typst
#figure(
  $ ce("2SO2(g) + O2(g) <->[V2O5][450°C] 2SO3(g)") $,
  caption: [Katalytische Oxidation von Schwefeldioxid im Kontaktverfahren.],
  kind: "equation",
  supplement: [Gl.],
)<gl:kontaktverfahren>

Wie in @gl:kontaktverfahren dargestellt...
```

#figure(
  $ ce("2SO2(g) + O2(g) <->[V2O5][450°C] 2SO3(g)") $,
  caption: [Katalytische Oxidation von Schwefeldioxid im Kontaktverfahren.],
  kind: "equation",
  supplement: [Gl.],
)<gl:kontaktverfahren>

Strukturformeln (Lewis-Strukturen, Skelettformeln) sind mit `typsium` nicht darstellbar. Dafür steht das Paket `alchemist` (#link("https://typst.app/universe/package/alchemist")) zur Verfügung, das auf `cetz` aufbaut und eine ähnliche Syntax wie `chemfig` in #LaTeX bietet.


// ============================================================
// Anhang C: Diakritische Zeichen und nicht-lateinische Schriften
// ============================================================

#pagebreak(weak: true)

= Diakritische Zeichen und nicht-lateinische Schriften <app:zeichen>

Typst verarbeitet Text als Unicode (UTF-8). Alle Sonderzeichen können direkt im Quelltext eingegeben werden – eine besondere Deklaration ist nicht nötig, solange die verwendete Schriftart die entsprechenden Zeichen enthält.

== Romanische Sprachen

Akzente und Sonderzeichen romanischer Sprachen werden direkt eingegeben:

```typst
// Französisch
Liberté, égalité, fraternité.
L'œuvre de Molière est représentative du théâtre classique français.
Jean-François a étudié à l'école à Genève.

// Spanisch
La investigación científica requiere método y paciencia.
El niño pequeño aprendió el español con facilidad.
¿Cómo están ustedes? — Muy bien, gracias.

// Portugiesisch
A investigação científica exige rigor metodológico.
São Paulo é a maior cidade do Brasil.
A língua portuguesa tem muita variação regional.

// Italienisch
La ricerca scientifica richiede metodo e pazienza.
Il caffè e la piazza sono elementi centrali della vita italiana.
```

Liberté, égalité, fraternité. L'œuvre de Molière est représentative du théâtre classique français.

La investigación científica requiere método y paciencia. ¿Cómo están ustedes?

A língua portuguesa tem muita variação regional.

La ricerca scientifica richiede metodo e pazienza. Il caffè e la piazza sono elementi centrali della vita italiana.

== Latein

Lateinische Texte benötigen keine Sonderzeichen, ausser bei mittelalterlichem Latein mit Ligaturen:

```typst
// Klassisches Latein
Gallia est omnis divisa in partes tres, quarum unam incolunt Belgae,
aliam Aquitani, tertiam qui ipsorum lingua Celtae, nostra Galli appellantur.

// Mittelalterliches Latein mit Ligaturen (direkt als Unicode)
Æneas, filius Veneris, ex Troia fugit.
Cœlum, non animum, mutant qui trans mare currunt.

// Makrons für Vokalquantitäten (Aussprache)
// In EB Garamond und ähnlichen Fonts vorhanden:
Rōma aeterna. Amō, amās, amat.
```

Gallia est omnis divisa in partes tres, quarum unam incolunt Belgae, aliam Aquitani, tertiam qui ipsorum lingua Celtae, nostra Galli appellantur.

Æneas, filius Veneris, ex Troia fugit. Cœlum, non animum, mutant qui trans mare currunt.

Rōma aeterna. Amō, amās, amat.

== Griechisch

Für griechische Textpassagen (nicht Formeln) muss die Textsprache temporär gesetzt werden, damit Silbentrennung und Typografie korrekt funktionieren:

```typst
// Kurze Einbettung im deutschen Text
Der Begriff #text(lang: "el")[φιλοσοφία] (philosophía) bedeutet wörtlich
«Liebe zur Weisheit».

// Altgriechisch
#text(lang: "el")[
  — Χαῖρε, ὦ φίλε. πῶς ἔχεις;
  — Εὖ ἔχω, ὦ Σώκρατες. καὶ σύ;
  — Καὶ ἐγὼ εὖ. τί πράττεις σήμερον;
]

// Modernes Griechisch
#text(lang: "el")[
  — Γεια σου! Πώς είσαι;
  — Καλά, ευχαριστώ. Εσύ;
  — Πολύ καλά. Τι κάνεις σήμερα;
  — Πηγαίνω στην αγορά. Τα λέμε αργότερα!
]
```

Der Begriff #text(lang: "el")[φιλοσοφία] (philosophía) bedeutet wörtlich «Liebe zur Weisheit».

#text(lang: "el")[
  — Χαῖρε, ὦ φίλε. πῶς ἔχεις;
  — Εὖ ἔχω, ὦ Σώκρατες. καὶ σύ;
  — Καὶ ἐγὼ εὖ. τί πράττεις σήμερον;
]

#text(lang: "el")[
  — Γεια σου! Πώς είσαι;
  — Καλά, ευχαριστώ. Εσύ;
  — Πολύ καλά. Τι κάνεις σήμερα;
  — Πηγαίνω στην αγορά. Τα λέμε αργότερα!
]

== Arabisch

Arabisch wird von rechts nach links geschrieben (_right-to-left_, RTL). Typst behandelt die Textrichtung automatisch, wenn die Sprache korrekt gesetzt ist:

```typst
// Eingebettetes Wort im deutschen Text
Das arabische Wort #text(lang: "ar")[مرحبا] (marḥaban) bedeutet «Hallo».

// Alltagskommunikation auf Arabisch (vokalisiert)
// Textrichtung wird automatisch umgeschaltet
#text(lang: "ar")[
  — مَرْحباً! كَيْفَ حَالَكَ؟
  — بِخَيْرً، شُكْراً. وَأَنْتَ؟
]
```

Das arabische Wort #text(lang: "ar")[مرحبا] (marḥaban) bedeutet «Hallo».

#text(lang: "ar")[
  — مَرْحباً! كَيْفَ حَالَكَ؟
  — بِخَيْرً، شُكْراً. وَأَنْتَ؟
]

*Hinweis zur Schriftart:* Die Standardschrift _EB Garamond_ unterstützt Griechisch und Lateinisch mit Ligaturen vollständig. Für Arabisch empfiehlt sich eine dedizierte arabische Schriftart wie _Noto Naskh Arabic_, die separat geladen werden kann:

```typst
// Schriftart nur für diesen Block wechseln
#text(font: "Noto Naskh Arabic", lang: "ar")[مَرْحباً! كَيْفَ حَالَكَ؟]
```

#text(font: "Noto Naskh Arabic", lang: "ar")[مَرْحباً! كَيْفَ حَالَكَ؟]


// ============================================================
// Anhang D: Abbildungsbeispiele
// ============================================================

#pagebreak(weak: true)

= Abbildungsbeispiele <app:abbildungen>

== Einfache Abbildung

Eine einzelne Abbildung wird mit ```typst #figure()``` und ```typst kind: figure``` eingebunden. Die Legende erscheint automatisch unterhalb der Abbildung und wird im Abbildungsverzeichnis aufgeführt.

```typst
#figure(
  image("img/image.jpeg", width: 80%),
  caption: [Kantonsschule Zürich Nord, Ansicht von der Birchstrasse.],
  kind: figure,
)<fig:kzn-gebaeude>

Wie in @fig:kzn-gebaeude zu sehen ist, ...
```

== Abbildung als Grid (mehrere Teilabbildungen)

Für mehrere zusammengehörige Abbildungen steht die ```typst kind: "subfigure"```-Erweiterung des Templates zur Verfügung. Die Teilabbildungen werden in einem ```typst #grid()``` angeordnet und erhalten eigene Legenden mit Buchstabenkennung (a), (b), ...

```typst
#figure(
  align(center)[
    #grid(
      columns: (0.5fr, 0.5fr), // Zwei gleich breite Spalten
      gutter: 7mm,              // Abstand zwischen den Teilabbildungen
      align: bottom,
      [
        #figure(
          image("img/bild_a.jpeg", width: 100%),
          caption: [Zustand vor dem Versuch],
          kind: "subfigure",
        )<fig:versuch-a>
      ],
      [
        #figure(
          image("img/bild_b.jpeg", width: 100%),
          caption: [Zustand nach dem Versuch],
          kind: "subfigure",
        )<fig:versuch-b>
      ],
    )
  ],
  caption: [Vergleich des Zustands vor und nach dem Versuch.],
  kind: figure,
)<fig:versuch>
```

Die Teilabbildungen können einzeln referenziert werden:

```typst
In @fig:versuch sind beide Zustände gegenübergestellt.
Der Ausgangszustand ist in @fig:versuch-a,
das Ergebnis in @fig:versuch-b zu sehen.
```

Für ein 2×2-Raster mit vier Teilabbildungen:

```typst
#figure(
  align(center)[
    #grid(
      columns: (0.5fr, 0.5fr),
      gutter: 7mm,
      align: bottom,
      [
        #figure(
          image("img/a.jpeg", width: 100%),
          caption: [Variante A],
          kind: "subfigure",
        )<fig:var-a>
      ],
      [
        #figure(
          image("img/b.jpeg", width: 100%),
          caption: [Variante B],
          kind: "subfigure",
        )<fig:var-b>
      ],
      [
        #figure(
          image("img/c.jpeg", width: 100%),
          caption: [Variante C],
          kind: "subfigure",
        )<fig:var-c>
      ],
      [
        #figure(
          image("img/d.jpeg", width: 100%),
          caption: [Variante D],
          kind: "subfigure",
        )<fig:var-d>
      ],
    )
  ],
  caption: [Vier Varianten im Vergleich.],
  kind: figure,
)<fig:varianten>
```


// ============================================================
// Anhang E: Tabellenbeispiele
// ============================================================

#pagebreak(weak: true)

= Tabellenbeispiele <app:tabellen>

== Einfache Tabelle

```typst
#figure(
  table(
    columns: 4,
    align: (left, center, right, right),
    fill: (_, y) => if y == 0 { blue.transparentize(80%) },
    stroke: (_, y) => (
      x: none,
      top: if y == 0 { 1pt } else { if y == 1 { 0.5pt } else { 0pt } },
      bottom: 1pt,
    ),
    table.header(
      [*Messung*], [*Bedingung*], [*Wert in m/s*], [*Unsicherheit*],
    ),
    [M1], [Raumtemperatur], [343.2],  [±0.5],
    [M2], [0 °C],           [331.5],  [±0.4],
    [M3], [100 °C],         [386.0],  [±0.6],
  ),
  caption: [Schallgeschwindigkeit unter verschiedenen Bedingungen.],
  kind: table,
)<tab:schall>
```

#figure(
  table(
    columns: 4,
    align: (left, center, right, right),
    fill: (_, y) => if y == 0 { blue.transparentize(80%) },
    stroke: (_, y) => (
      x: none,
      top: if y == 0 { 1pt } else { if y == 1 { 0.5pt } else { 0pt } },
      bottom: 1pt,
    ),
    table.header(
      [*Messung*], [*Bedingung*], [*Wert in m/s*], [*Unsicherheit*],
    ),
    [M1], [Raumtemperatur], [343.2],  [±0.5],
    [M2], [0 °C],           [331.5],  [±0.4],
    [M3], [100 °C],         [386.0],  [±0.6],
  ),
  caption: [Schallgeschwindigkeit unter verschiedenen Bedingungen.],
  kind: table,
)<tab:schall>

== Mehrere Tabellen nebeneinander (Grid)

Analog zu den Abbildungen können auch Tabellen nebeneinander gesetzt werden, indem die ```typst kind: "subfigure"```-Umgebung verwendet wird. Dies ist nützlich, um kompakte Vergleiche darzustellen.

```typst
#figure(
  align(center)[
    #grid(
      columns: (0.48fr, 0.48fr),
      gutter: 10mm,
      align: bottom,
      [
        #figure(
          table(
            columns: 3,
            align: (left, right, right),
            fill: (_, y) => if y == 0 { blue.transparentize(80%) },
            stroke: (_, y) => (
              x: none,
              top: if y == 0 { 1pt } else { if y == 1 { 0.5pt } else { 0pt } },
              bottom: 1pt,
            ),
            table.header([*Planet*], [*Masse (kg)*], [*Radius (km)*]),
            [Merkur], [$3.30 times 10^23$], [2440],
            [Venus],  [$4.87 times 10^24$], [6052],
            [Erde],   [$5.97 times 10^24$], [6371],
            [Mars],   [$6.42 times 10^23$], [3390],
          ),
          caption: [Innere Planeten],
          kind: "subfigure",
        )<tab:innere-planeten>
      ],
      [
        #figure(
          table(
            columns: 3,
            align: (left, right, right),
            fill: (_, y) => if y == 0 { blue.transparentize(80%) },
            stroke: (_, y) => (
              x: none,
              top: if y == 0 { 1pt } else { if y == 1 { 0.5pt } else { 0pt } },
              bottom: 1pt,
            ),
            table.header([*Planet*], [*Masse (kg)*], [*Radius (km)*]),
            [Jupiter], [$1.90 times 10^27$], [71492],
            [Saturn],  [$5.68 times 10^26$], [60268],
            [Uranus],  [$8.68 times 10^25$], [25559],
            [Neptun],  [$1.02 times 10^26$], [24764],
          ),
          caption: [Äussere Planeten],
          kind: "subfigure",
        )<tab:aeussere-planeten>
      ],
    )
  ],
  caption: [Physikalische Eigenschaften der Planeten des Sonnensystems.],
  kind: table,
)<tab:planeten>
```

Die gesetzte Tabelle:

#figure(
  align(center)[
    #grid(
      columns: (0.48fr, 0.48fr),
      gutter: 10mm,
      align: bottom,
      [
        #figure(
          table(
            columns: 3,
            align: (left, right, right),
            fill: (_, y) => if y == 0 { blue.transparentize(80%) },
            stroke: (_, y) => (
              x: none,
              top: if y == 0 { 1pt } else { if y == 1 { 0.5pt } else { 0pt } },
              bottom: 1pt,
            ),
            table.header([*Planet*], [*Masse (kg)*], [*Radius (km)*]),
            [Merkur], [$3.30 times 10^23$], [2440],
            [Venus],  [$4.87 times 10^24$], [6052],
            [Erde],   [$5.97 times 10^24$], [6371],
            [Mars],   [$6.42 times 10^23$], [3390],
          ),
          caption: [Innere Planeten],
          kind: "subfigure",
        )<tab:innere-planeten>
      ],
      [
        #figure(
          table(
            columns: 3,
            align: (left, right, right),
            fill: (_, y) => if y == 0 { blue.transparentize(80%) },
            stroke: (_, y) => (
              x: none,
              top: if y == 0 { 1pt } else { if y == 1 { 0.5pt } else { 0pt } },
              bottom: 1pt,
            ),
            table.header([*Planet*], [*Masse (kg)*], [*Radius (km)*]),
            [Jupiter], [$1.90 times 10^27$], [71492],
            [Saturn],  [$5.68 times 10^26$], [60268],
            [Uranus],  [$8.68 times 10^25$], [25559],
            [Neptun],  [$1.02 times 10^26$], [24764],
          ),
          caption: [Äussere Planeten],
          kind: "subfigure",
        )<tab:aeussere-planeten>
      ],
    )
  ],
  caption: [Physikalische Eigenschaften der Planeten des Sonnensystems.],
  kind: table,
)<tab:planeten>

Die Referenzierung funktioniert analog zu Abbildungen. Mit ```typst @tab:planeten``` wird die gesamte Tabelle referenziert, mit ```typst @tab:innere-planeten``` und ```typst @tab:aeussere-planeten``` die jeweiligen Teiltabellen.

#pagebreak(weak: true)
