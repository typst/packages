#import "@preview/hsrm-internship-report:0.0.1": *
#import "data.typ": *

#show: project.with(
  // update values in data.typ
  title: title,
  subtitle: subtitle,
  authors: authors,
  company-name: company-name,
  company-logo: company-logo,
  company-supervisor: company-supervisor,
  uni-name: uni-name,
  uni-logo: uni-logo,
  uni-supervisor: uni-supervisor,

  line-spacing: line-spacing,
  legend-on-outline: legend-on-outline,
  heading-font: heading-font,
  text-font: text-font,
)

#author("FR")[
  = Template
  == Einsatz des Templates

  === Zweck
  Dieses Template wurde speziell für Praxisberichte mit mehreren Autorinnen und Autoren entwickelt.
]

#author("RZ")[
  == Autorenkennzeichnung

  === Syntax
  Das Template ermöglicht die eindeutige Kennzeichnung von Textpassagen, um den jeweiligen Autor klar zuzuordnen.
  Dies erleichtert die Nachverfolgung der inhaltlichen Beiträge und die Zusammenarbeit mehrerer Verfasser.
  Die Anwendung erfolgt über folgenden Befehl:
  \
  \
  ```Typst #author("authorsShort")[Hier der Text]```

  === Legende
  Eine Legende zur Autorenkennzeichnung kann im Inhaltsverzeichnis ein- oder ausgeblendet werden.
  Eine zusätzliche Option, die Legende im Fußbereich der Seiten anzuzeigen, um die Autorenzuordnung auch während des Lesens zu erleichtern, ist in Planung.

  === Fonts
  Aktuell unterstützt die Typst-App standardmäßig weder die Schriftart "Times New Roman" noch "Arial". Dennoch können beide Schriftarten als `.ttf`, `.ttc`, `.otf` oder `.otc` Dateien importiert und im Dokument eingebunden werden. Alternativ besteht die Möglichkeit, die Typst-CLI zu verwenden, um die gewünschten Schriftarten systemweit verfügbar zu machen und anschließend im Projekt zu nutzen.

  == Disclaimer
  Die Vorlage orientiert sich an den Vorgaben für Praxisberichte im Studiengang Angewandte Informatik an der HSRM, erhebt jedoch keinen Anspruch auf Vollständigkeit, Aktualität oder Fehlerfreiheit.
]

#author("RZ")[
  = Ein Beispiel
  Die Abschnitte sind mit unterschiedlichen Autorenkennzeichnungen versehen, um die Funktion zu verdeutlichen.
  #lorem(50)

  == Text von verschiedenen Autoren
  === Text von Autor 1
  Beispieltext, verfasst von Autor 1, zur Illustration der Kennzeichnung.
  #lorem(80)
]

#author("FR")[
  === Text von Autor 2
  Beispieltext, verfasst von Autor 2, zur Demonstration der Mehrfachautoren-Unterstützung.
  #lorem(280)
]
