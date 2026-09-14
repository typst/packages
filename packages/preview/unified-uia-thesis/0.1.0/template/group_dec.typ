#set heading(outlined: false)
#show heading.where(depth: 1): set text(12pt)
#set text(lang: "no")

// set these to true or false
#let group-declaration = (
  main: (
    (
      "Vi erklærer herved at vår besvarelse er vårt eget arbeid, og at vi ikke har brukt andre kilder eller har mottatt annen hjelp enn det som er nevnt i besvarelsen.",
      true,
    ),
    (
      [
        *Vi erklærer videre at denne besvarelsen:*
        - Ikke har vært brukt til annen eksamen ved annen avdeling/universitet/høgskole innenlands eller utenlands.
        - Ikke refererer til andres arbeid uten at det er oppgitt.
        - Ikke refererer til eget tidligere arbeid uten at det er oppgitt.
        - Har alle referansene oppgitt i litteraturlisten.
        - Ikke er en kopi, duplikat eller avskrift av andres arbeid eller besvarelse.
      ],
      none,
    ),
    (
      "Vi er kjent med at brudd på ovennevnte er å betrakte som fusk og kan med- føre annullering av eksamen og utestengelse fra universiteter og høgskoler i Norge, jf. Universitets- og høgskoleloven §§4-7 og 4-8 og Forskrift om eksamen §§ 31.",
      none,
    ),
    (
      "Vi er kjent med at alle innleverte oppgaver kan bli plagiatkontrollert.",
      none,
    ),
    (
      "Vi er kjent med at Universitetet i Agder vil behandle alle saker hvor det forligger mistanke om fusk etter høgskolens retningslinjer for behandling av saker om fusk.",
      none,
    ),
    (
      "Vi har satt oss inn i regler og retningslinjer i bruk av kilder og referanser på biblioteket sine nettsider.",
      none,
    ),
    (
      "Vi har i flertall blitt enige om at innsatsen innad i gruppen er merkbart forskjellig og ønsker dermed å vurderes individuelt. Ordinært vurderes alle deltakere i prosjektet samlet.",
      false,
    ),
  ),
  pub: (
    (
      "Vi gir herved Universitetet i Agder en vederlagsfri rett til å gjøre oppgaven tilgjengelig for elektronisk publisering.",
      none,
    ),
    (
      "Er oppgaven båndlagt (konfidensiell)?",
      none,
    ),
    (
      "Er oppgaven unntatt offentlighet?",
      none,
    ),
  ),
)

#let check(checked) = {
  align(center + horizon, scale(150%, if checked == true { $checkmark.heavy$ } else if checked == false {
    $crossmark.heavy$
  } else { text(fill: red, $excl$) }))
}

= Obligatorisk egenerklæring

Den enkelte student er selv ansvarlig for å sette seg inn i hva som er lovlige hjelpemidler, retningslinjer for bruk av disse og regler om kildebruk. Erklæringen skal bevisstgjøre studentene på deres ansvar og hvilke konsekvenser fusk kan medføre. Manglende erklæring fritar ikke studentene fra sitt ansvar.
#table(
  columns: (auto, 1fr, 1cm),
  ..group-declaration
    .main
    .enumerate(start: 1)
    .map(((i, (description, checked))) => ([#i.], description, check(checked)))
    .flatten()
)

= Publiseringsavtale

Fullmakt til elektronisk publisering av oppgaven Forfatter(ne) har opphavsrett til oppgaven. Det betyr blant annet enerett til å gjøre verket tilgjengelig for allmennheten (Åndsverkloven. §2). Oppgaver som er unntatt offentlighet eller taushetsbelagt/konfidensiell vil ikke bli publisert.
#table(
  columns: (1fr, 1cm),
  ..group-declaration.pub.map(((description, checked)) => (description, check(checked))).flatten()
)
