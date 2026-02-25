// Markdown-like checklists
#import "@preview/cheq:0.3.0": checklist // https://typst.app/universe/package/cheq/

// locale
#import "locale.typ": DEGREE_PROGRAM, FACULTY_OF, MATRICULATION_NUMBER, SUBMITTED_BY, SUBMITTED_ON, SUBMITTED_TO

#let restriction-notice(
  title,
  company,
  confidentiality-period,
) = {
  [
    #text([Sperrvermerk (Deutsch/German)], size: 18pt, weight: 600)

    #v(2cm)

    Die vorliegende Abschlussarbeit mit dem Titel *#title* enthält interne und vertrauliche Daten des Unternehmens/der
    Einrichtung #company.

    Die Abschlussarbeit darf nur den Gutachtern (insbesondere Erst- und Zweitgutachtern), den Mitgliedern der
    Prüfungsorgane (einschließlich Beisitzer & Plagiatskontrolle) sowie den in einem eventuellen Rechtschutzverfahren
    Betrauten zugänglich gemacht werden.

    Im Übrigen ist eine Veröffentlichung und Vervielfältigungen der Abschlussarbeit - auch in Auszügen - nicht
    gestattet. Vorbehaltlich der Vorschriften zum Prüfungsverfahren und der Prüfung bedarf eine Einsichtnahme in die
    Arbeit durch Dritte einer ausdrücklichen Genehmigung der Verfasserin/des Verfassers sowie des o.a. Unternehmens/der
    o.a. Einrichtung. Diese Geheimhaltungsverpflichtung gilt bis zum Ablauf des #confidentiality-period.
    #pagebreak()
  ]
}

#let title-page(
  thesis-type,
  title,
  faculty,
  degree-program,
  submission-date,
  supervisor,
  author,
  language,
) = {
  align(right, [
    #image(
      "logo_hsmz.svg",
    )
  ])

  v(2.5cm)

  align(center, [

    #set text(size: 14pt)

    #text([#thesis-type\ ], size: 16pt, weight: 600)
    #DEGREE_PROGRAM.at(language) #degree-program

    #v(2cm)

    #text([#title], size: 16pt, weight: 600)

    #v(1.5cm)

    Hochschule Mainz\
    University of Applied Sciences\
    #FACULTY_OF.at(language) #faculty

    #v(2cm)

    #block(inset: (left: 2.5cm, right: 2.5cm), [
      #text(
        [
          #show: set par(leading: 0.5em)
          #table(
            inset: 8pt,
            columns: (1fr, 1fr),
            stroke: none,
            align: (right, left),
            [#SUBMITTED_BY.at(language):],
            [
              #author.name\
              #author.address.street\
              #author.address.zip, #author.address.city
            ],

            [#MATRICULATION_NUMBER.at(language):], author.matriculation-number,
            [#SUBMITTED_TO.at(language):], supervisor,
            [#SUBMITTED_ON.at(language):], submission-date,
          )],
        size: 11pt,
      )
    ])

  ])
  pagebreak()
}

#let declaration-of-originality(
  option,
  author,
  title,
  degree-program,
  supervisor,
  submission-date,
) = {
  [
    #text([Eigenständigkeitserklärung (Deutsch/German)], size: 18pt, weight: 600)

    #set text(size: 10pt)
    #set par(leading: 0.7em)

    Hiermit versichere ich, #author.name, dass ich die anliegende Arbeit

    #table(
      columns: 2,
      stroke: none,
      [*Titel der Arbeit*], [#underline(title)],
      [*Studienfach*], [#underline(degree-program)],
      [*Prüfer:in*], [#underline(supervisor)],
    )

    selbst angefertigt und alle für die Arbeit verwendeten Quellen und Hilfsmittel in der Arbeit vollständig angegeben
    habe.

    *Ich versichere außerdem,*

    #show: checklist
    - [#if option == 1 [x] else [ ]] *Option 1* Erlaubnis von KI-Tools mit geringfügiger Dokumentation
    _dass ich die Nutzung aller für die Erstellung dieser Arbeit erlaubten generativen KI-Tools im Anhang der
    vorliegenden Arbeit durch die Benennung des Tools und seines Einsatzzwecks tabellarisch dokumentiert habe. Alle
    wortwörtlich übernommenen oder paraphrasierten Inhalte von generativen KI-Tools wurden entsprechend gekennzeichnet.
    Mir ist bewusst, dass der Versuch einer nicht-dokumentierten Nutzung generativer KI-Tools als Täuschungsversuch
    entsprechend der Prüfungsordnung zu werten ist. Ich versichere, dass ich die mithilfe von KI-Tools generierten
    Inhalte nicht unreflektiert übernommen habe und ich als Autor:in die Verantwortung für Angaben und Aussagen in
    dieser Arbeit trage._

    - [#if option == 2 [x] else [ ]] *Option 2* Erlaubnis von KI-Tools mit umfangreicher Dokumentation
    _dass ich die Nutzung aller für die Erstellung dieser Arbeit erlaubten generativen KI-Tools im Anhang der
    vorliegenden Arbeit tabellarisch dokumentiert habe. Dazu gehört, welche generativen KI-Tools ich für welchen Zweck
    verwendet habe und auf welche Ausschnitte der Arbeit sich diese Nutzung bezieht. Ich habe zudem alle, von dem / der
    Prüfer:in angeforderten Quellen (Prompts & Outputs), die meinen Einsatz von generativer KI-Tools bei der Erstellung
    dieser Arbeit nachweisen, nach bestem Wissen im Anhang der Arbeit zur Verfügung gestellt. Alle wortwörtlich
    übernommenen oder paraphrasierten Inhalte von generativen KI-Tools wurden entsprechend gekennzeichnet. Mir ist
    bewusst, dass der Versuch einer nicht-dokumentierten Nutzung generativer KI-Tools als Täuschungsversuch entsprechend
    der Prüfungsordnung zu werten ist. Ich versichere, dass ich die mithilfe von KI-Tools generierten Inhalte nicht
    unreflektiert übernommen habe und ich als Autor:in die Verantwortung für Angaben und Aussagen in dieser Arbeit
    trage._

    - [#if option == 3 [x] else [ ]] *Option 3* Verbot von KI-Tools
    _dass ich *keine* auf Künstlicher Intelligenz (KI) basierenden Text- oder Bildgeneratoren (z.B. Chat-GPT) verwendet
    habe, da der Einsatz dieser Tools bei der Erstellung dieser Arbeit mir durch den / die Prüfer:in explizit verboten
    wurde. Mir ist bewusst, dass der Einsatz eines generativen KI-Tools eine Missachtung der Vorgabe ist und dies als
    Täuschungsversuch entsprechend der Prüfungsordnung gewertet wird._

    #table(
      columns: (1fr, 1fr),
      stroke: none,
      table.cell(
        underline([#author.address.zip #author.address.city, #submission-date]),
        align: bottom,
      ),
      table.cell(
        [
          #set image(height: 1.5cm)
          #author.signature-image
        ],
        align: bottom,
      ),
      "Ort, Datum",
      "Unterschrift",
    )
  ]
}
