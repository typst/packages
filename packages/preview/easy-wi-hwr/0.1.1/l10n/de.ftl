# HWR Berlin — Deutsche Lokalisierung
## Alle Keys müssen identisch in en.ftl vorhanden sein.

## Verzeichnis-Überschriften

toc-title = Inhaltsverzeichnis
abbreviations-title = Abkürzungsverzeichnis
figures-title = Abbildungsverzeichnis
tables-title = Tabellenverzeichnis
appendix-toc-title = Anhangsverzeichnis
appendix-section-title = Anhang
glossary-title = Glossar
bibliography-title = Literaturverzeichnis

## Abschnitt-Label im Anhang

appendix-label = Anhang

## Präfixe für Abbildungs-/Tabellenverzeichnis

figure-prefix = Abb.
table-prefix = Tab.

## Spaltenüberschriften in Abbildungs-/Tabellenverzeichnis

index-col-title = Titel
index-col-page = Seite
index-col-number = Nr.

## Abstract

abstract-title = Abstract

## KI-Verzeichnis

ai-tools-title = KI-Verzeichnis
ai-col-tool = KI-Hilfsmittel
ai-col-usage = Einsatzform
ai-col-chapters = Betroffene Teile der Arbeit
ai-col-remarks = Bemerkung

## Sperrvermerk

confidential-title = S P E R R V E R M E R K

confidential-intro-chapters =
    Folgende/s Kapitel/Passagen unterliegt/unterliegen aufgrund der Verwendung
    vertraulicher Daten einem Sperrvermerk und sind/ist ausschließlich für die
    zuständige Fachleiterin oder den zuständigen Fachleiter und betreuende
    Prüferin/Gutachterin oder betreuenden Prüfer/Gutachter einsichtig zu machen:

confidential-short-version =
    Eine Kurzfassung der Arbeit, die ausschließlich die nicht gesperrten Kapitel
    bzw. Unterkapitel enthält, wird unter der Bezeichnung { $filename } auf
    beigefügtem Datenträger zusätzlich zur Verfügung gestellt.

confidential-text-all =
    Alle folgenden Kapitel unterliegen aufgrund der Verwendung vertraulicher
    Daten einem Sperrvermerk und sind ausschließlich für die zuständige
    Fachleiterin oder den zuständigen Fachleiter und betreuende
    Prüferin/Gutachterin oder betreuenden Prüfer/Gutachter einsichtig zu machen.

## Ehrenwörtliche Erklärung

declaration-title = Ehrenwörtliche Erklärung
declaration-date-label = den
declaration-place-date = Ort, Datum
declaration-signature = Unterschrift

group-signature-note =
    Hinweis: Diese Arbeit hat mehrere Autoren. Es wurde nur ein Unterschriftsfeld
    eingefügt (group-signature: false). Bitte klären Sie vorab mit Ihrer betreuenden
    Prüferin / Ihrem betreuenden Prüfer, ob eine stellvertretende Unterschrift für
    die Gruppe akzeptiert wird.

# Pflichttext §3.11 — wörtlich aus den HWR-Richtlinien (Stand Januar 2025)
# Pluralisierung: [one] = Einzelperson, *[other] = Gruppe
# Continuation lines MÜSSEN mit mindestens 4 Leerzeichen beginnen (Fluent-Syntax).
declaration-text =
    { $author-count ->
        [one] Ich erkläre ehrenwörtlich:

            dass ich die vorliegende Arbeit in allen Teilen selbstständig angefertigt
            und keine anderen als die in der Arbeit angegebenen Quellen und Hilfsmittel
            benutzt habe, und dass die Arbeit in gleicher oder ähnlicher Form in noch
            keiner anderen Prüfung vorgelegen hat. Sämtliche wörtlichen oder
            sinngemäßen Übernahmen und Zitate, sowie alle Abschnitte, die mithilfe von
            KI-basierten Tools entworfen, verfasst und/oder bearbeitet wurden, sind
            kenntlich gemacht und nachgewiesen. Im Anhang meiner Arbeit habe ich
            sämtliche KI-basierte Hilfsmittel angegeben. Diese sind mit Produktnamen
            und formulierten Eingaben (Prompts) in einem KI-Verzeichnis ausgewiesen.

            Ich bin mir bewusst, dass die Verwendung von Texten oder anderen Inhalten
            und Produkten, die durch KI-basierten Tools generiert wurden, keine Garantie
            für deren Qualität darstellt. Ich verantworte die Übernahme jeglicher von
            mir verwendeter maschinell generierter Passagen vollumfänglich selbst und
            trage die Verantwortung für eventuell durch die KI generierte fehlerhafte
            oder verzerrte Inhalte, fehlerhafte Referenzen, Verstöße gegen das
            Datenschutz- und Urheberrecht oder Plagiate.
       *[other] Wir erklären ehrenwörtlich:

            dass wir die vorliegende Arbeit in allen Teilen selbstständig angefertigt
            und keine anderen als die in der Arbeit angegebenen Quellen und Hilfsmittel
            benutzt haben, und dass die Arbeit in gleicher oder ähnlicher Form in noch
            keiner anderen Prüfung vorgelegen hat. Sämtliche wörtlichen oder
            sinngemäßen Übernahmen und Zitate, sowie alle Abschnitte, die mithilfe von
            KI-basierten Tools entworfen, verfasst und/oder bearbeitet wurden, sind
            kenntlich gemacht und nachgewiesen. Im Anhang unserer Arbeit haben wir
            sämtliche KI-basierte Hilfsmittel angegeben. Diese sind mit Produktnamen
            und formulierten Eingaben (Prompts) in einem KI-Verzeichnis ausgewiesen.

            Wir sind uns bewusst, dass die Verwendung von Texten oder anderen Inhalten
            und Produkten, die durch KI-basierten Tools generiert wurden, keine Garantie
            für deren Qualität darstellt. Wir verantworten die Übernahme jeglicher von
            uns verwendeter maschinell generierter Passagen vollumfänglich selbst und
            tragen die Verantwortung für eventuell durch die KI generierte fehlerhafte
            oder verzerrte Inhalte, fehlerhafte Referenzen, Verstöße gegen das
            Datenschutz- und Urheberrecht oder Plagiate.
    }
