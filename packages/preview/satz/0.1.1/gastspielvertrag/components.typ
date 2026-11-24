// Gastspielvertrag components — contract-specific rendering blocks.

/// A blank field to fill in.
///
/// Bold label on top, line below — fill it by hand.
///
/// - label (str): what goes above the line
#let fillin(label) = {
  v(0.5em)
  text(weight: "bold", size: 10pt)[#label:]
  v(0.1em)
  line(length: 100%, stroke: 0.25pt + black)
}

/// The top of the contract — who plays, where, when.
///
/// Blank lines for the venue to fill in, then your artist info
/// and a table with the gig details.
///
/// - g (dictionary): your gig config
/// - zeilenabstand (length): line spacing
#let contract_header(g, zeilenabstand) = {
  // Veranstalter (venue) — fill-in fields
  fillin("Name / Firma")
  fillin("Anschrift (Straße, PLZ Ort)")
  fillin("Rechnungsadresse (falls abweichend)")
  fillin("Vertreten durch")

  v(2 * zeilenabstand)

  // Künstler (artist) — fixed
  text(weight: "bold", size: 11pt)[Künstler:]
  v(0.3em)
  text(size: 10pt)[#g.kuenstler — vertreten durch #g.kuenstler_vertreter]
  v(0.2em)
  text(size: 10pt)[#g.kuenstler_anschrift]

  v(2 * zeilenabstand)

  // Gig-Daten table
  text(weight: "bold", size: 10pt)[Veranstaltung:]
  v(0.3em)
  table(
    columns: (auto, 1fr),
    inset: 4pt,
    stroke: none,
    [*Veranstaltung:*], [#g.veranstaltung],
    [*Veranstaltungsort:*], [#g.location],
    [*Datum:*], [#g.datum],
    [*Auftrittszeit:*], [#g.auftrittszeit],
    [*Auftrittsdauer:*], [#g.auftrittsdauer],
    [*Einlass:*], [#g.einlass],
    [*Curfew:*], [#g.curfew],
  )

  // Personal
  let gesamt = g.musiker + (if g.techniker { 1 } else { 0 }) + (if g.fotograf { 1 } else { 0 })
  v(0.5em)
  text(size: 10pt)[Besetzung: #g.musiker Musiker #if g.techniker [ + Techniker ] #if g.fotograf [ + Fotograf ] → #gesamt Personen]
}

/// §1 — What this contract is about.
#let paragraph_1(g) = {
  text(weight: "bold", size: 11pt)[§ 1 Gegenstand des Vertrages]
  v(0.3em)
  text(size: 10pt)[
    Der Veranstalter engagiert den Künstler für das oben genannte Gastspiel.
    \
    Der Veranstalter verpflichtet sich, spätestens zwei Wochen vor dem
    Veranstaltungstag folgende Informationen per E-Mail zu übermitteln:
  ]
  list(
    [Name und Mobilnummer der verantwortlichen Ansprechpartner vor Ort],
    [Zeiten für Get-In, Soundcheck, Stagetime und Curfew],
    [Informationen zu kostenfreien und sicheren Parkmöglichkeiten],
  )
}

/// §2 — Pay and terms.
#let paragraph_2(g, zeilenabstand) = {
  text(weight: "bold", size: 11pt)[§ 2 Gage und Konditionen]
  v(0.3em)

  if g.gage_typ == "fest" {
    text(size: 10pt)[Der Künstler erhält für die Darbietung eine feste Gage in Höhe von #g.festgage €.]
  } else {
    text(size: 10pt)[
      Der Künstler erhält eine prozentuale Beteiligung an den Netto-Ticketeinnahmen
      in Höhe von #g.prozentsatz %. Eine Mindestgage von #g.mindestgage € wird garantiert.
    ]
  }

  v(0.5em)
  text(size: 10pt)[
    *Zahlungsziel:* 14 Tage nach der Veranstaltung per Überweisung.
    \
    *Verzug:* Bei Überschreitung des Zahlungsziels werden Verzugszinsen in Höhe
    von 9 Prozentpunkten über dem Basiszinssatz (§ 288 Abs. 2 BGB) sowie eine
    Verzugspauschale von 40,00 € fällig. Der Veranstalter kommt spätestens 30 Tage
    nach Rechnungszugang in Verzug (§ 286 Abs. 3 BGB).
  ]

  if g.kleinunternehmer {
    v(0.5em)
    text(size: 9pt, style: "italic")[
      Als Kleinunternehmer im Sinne des § 19 Abs. 1 UStG wird keine Umsatzsteuer berechnet.
    ]
  }
}

/// §3 — What the venue has to do.
#let paragraph_3() = {
  text(weight: "bold", size: 11pt)[§ 3 Pflichten des Veranstalters]
  v(0.3em)
  enum(
    numbering: "1.",
    [Der Veranstalter verpflichtet sich zur Erfüllung des beigefügten Technical Rider. Sollte benötigtes Equipment nicht bereitstellbar sein, ist der Künstler zeitnah zu benachrichtigen.],
    [Der Veranstalter ist für die ordnungsgemäße Anmeldung und Abführung aller anfallenden Gebühren für die GEMA verantwortlich und trägt die Kosten hierfür.],
    [Der Veranstalter stellt eine der Lokalität angepasste PA- und Lichtanlage zur Verfügung. Ein kompetenter Haustechniker ist während der gesamten Anwesenheit des Künstlers anwesend und erreichbar.],
    [Der Veranstalter übernimmt die Haftung für die Sicherheit des Künstlers, seiner Musiker und Hilfskräfte sowie für die vom Künstler in den Veranstaltungsort eingebrachten Anlagen und Instrumente.],
  )
}

/// §4 — What if someone cancels.
#let paragraph_4() = {
  text(weight: "bold", size: 11pt)[§ 4 Rücktritt und Ausfall]
  v(0.3em)
  enum(
    numbering: "1.",
    text(size: 10pt)[
      *Absage durch den Veranstalter:* Bei Absage der Veranstaltung durch den
      Veranstalter aus Gründen, die der Künstler nicht zu vertreten hat, wird
      eine Ausfallgage fällig:
    ],
  )
  list(
    [Absage 14 bis 8 Tage vor der Show: 50 % der vereinbarten Gage],
    [Absage 7 Tage oder weniger vor der Show: 100 % der vereinbarten Gage],
  )
  enum(
    start: 2,
    text(size: 10pt)[
      *Absage durch den Künstler:* Sollte der Künstler aus wichtigem Grund
      (z. B. nachweisliche Krankheit, Unfall) nicht auftreten können, entfällt
      der Anspruch auf die Gage. Der Veranstalter wird unverzüglich informiert.
    ],
  )
}

/// §5 — Hospitality — food, drinks, backstage.
#let paragraph_5(g) = {
  let gesamt = g.musiker + (if g.techniker { 1 } else { 0 }) + (if g.fotograf { 1 } else { 0 })
  let buyout_total = gesamt * g.buyout_pro_person

  text(weight: "bold", size: 11pt)[§ 5 Hospitality]
  v(0.3em)
  text(size: 10pt)[
    Personen: #gesamt (Musiker: #g.musiker #if g.techniker [ + Techniker ] #if g.fotograf [ + Fotograf ])
  ]
  v(0.5em)
  text(size: 10pt)[
    *Verpflegung:* Unser gesamtes Team ernährt sich vegetarisch, eine Person davon vegan.
    Wir benötigen vor oder nach dem Konzert eine vollwertige Mahlzeit. Falls dies nicht
    möglich ist, bitten wir um ein Buy-Out von #g.buyout_pro_person € pro Person
    (Gesamt: #buyout_total €), auszuzahlen bei Ankunft in bar. Getränke und Snacks
    sind davon unabhängig.
  ]
  v(0.5em)
  text(size: 10pt)[
    *Backstage:* Bequeme Sitzgelegenheiten, großer Spiegel, mindestens drei
    Steckdosen, WLAN-Zugang, Mülleimer. 1 Kiste stilles Wasser, Kaffee + Hafermilch,
    Tee, gekühlte Getränke (Mate, Cola/Zero, Apfelschorle), Obst, Nüsse, Schokolade (auch vegan).
  ]
}

/// §6 — Extra costs (travel, tech, hotel …).
#let paragraph_6(g) = {
  text(weight: "bold", size: 11pt)[§ 6 Zusatzkosten]
  v(0.3em)
  text(size: 10pt)[
    Vorab vereinbarte Kosten, die der Veranstalter zusätzlich zur Gage erstattet:
  ]
  v(0.5em)

  let posten = ()
  let transport_betrag = g.transport_km * g.transport_satz * 2

  if transport_betrag > 0 {
    posten.push(("Transportpauschale (" + str(g.transport_km) + " km × " + str(g.transport_satz) + " €/km × 2)", 1, transport_betrag))
  }
  if g.techniker_honorar > 0 {
    posten.push(("Techniker-Honorar", 1, g.techniker_honorar))
  }
  if g.uebernachtung > 0 {
    posten.push(("Übernachtungskosten", 1, g.uebernachtung))
  }
  if g.sonstiges_betrag > 0 and g.sonstiges_text != "" {
    posten.push((g.sonstiges_text, 1, g.sonstiges_betrag))
  }

  if posten.len() > 0 {
    let total = posten.map(p => p.at(1) * p.at(2)).sum()
    table(
      columns: (1fr, auto, auto, auto),
      inset: 4pt,
      align: (left, center, right, right),
      stroke: none,
      table.hline(stroke: 0.5pt),
      [*Posten*], [*Anzahl*], [*Einzelpreis*], [*Gesamt*],
      table.hline(stroke: 0.25pt),
      ..posten.map(p => (
        [#p.at(0)],
        [#p.at(1)],
        [#p.at(2) €],
        [#(p.at(1) * p.at(2)) €]
      )).flatten(),
      table.hline(stroke: 0.5pt),
      [], [], [*Gesamt:*], [*#total €*],
      table.hline(stroke: 0.5pt),
    )
  } else {
    text(size: 10pt, style: "italic")[Keine Zusatzkosten vereinbart.]
  }
}

/// §7 — Merch, respect, access.
#let paragraph_7() = {
  text(weight: "bold", size: 11pt)[§ 7 Merchandise, Awareness, Sonstiges]
  v(0.3em)
  enum(
    numbering: "1.",
    [*Merchandise:* Der Künstler ist berechtigt, am Veranstaltungsort Merchandise-Artikel zu verkaufen. Der Veranstalter stellt hierfür einen geeigneten Platz zur Verfügung und erhält keine Provision.],
    [*Respektvoller Umgang:* Wir erwarten einen respektvollen Umgang mit allen Beteiligten. Jegliche Form von Diskriminierung wird nicht toleriert. Wir bitten die Veranstaltenden, ein Awareness-Konzept bereitzuhalten und Anlaufstellen für Betroffene sichtbar zu machen.],
    [*Barrierefreiheit:* Ein barrierefreier Zugang zu den Räumlichkeiten ist sicherzustellen. Eine geschlechterinklusive Beschilderung der sanitären Anlagen ist ausdrücklich erwünscht.],
  )
}

/// §8 — Final clauses.
#let paragraph_8() = {
  text(weight: "bold", size: 11pt)[§ 8 Schlussbestimmungen]
  v(0.3em)
  text(size: 10pt)[
    Änderungen oder Ergänzungen dieses Vertrages bedürfen der Schriftform.
    Sollten einzelne Bestimmungen dieses Vertrages unwirksam sein oder werden,
    bleiben die übrigen Bestimmungen wirksam. An die Stelle der unwirksamen
    Bestimmung tritt eine Regelung, die dem wirtschaftlichen Zweck der
    unwirksamen Bestimmung am nächsten kommt.
  ]
}

/// Two lines to sign — venue and artist.
#let signature_lines(kuenstler_vertreter) = {
  v(3em)
  grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      #line(length: 100%, stroke: 0.5pt)
      #v(0.2em)
      #text(size: 9pt)[Unterschrift Veranstalter]
    ],
    [
      #line(length: 100%, stroke: 0.5pt)
      #v(0.2em)
      #text(size: 9pt)[#kuenstler_vertreter]
    ],
  )
}
