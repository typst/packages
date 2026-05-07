#let _validate-algemein-inputs(  
  abstand-oben, 
  abstand-unten,
  abstand-links, 
  abstand-rechts, 
  schriftart
  ) = {
    assert(
      type(abstand-links) == length and abstand-links >= 20mm and abstand-links <= 30mm,
      message: "Linker Abstand soll zwischen 20mm und 30mm sein"
    )
    assert(
      type(abstand-rechts) == length and abstand-rechts >= 20mm and abstand-rechts <= 30mm,
      message: "Rechter Abstand soll zwischen 20mm und 30mm sein"
    )
    assert(
      type(abstand-oben) == length and abstand-oben >= 20mm and abstand-oben <= 25mm,
      message: "Der obere Abstand soll zwischen 20mm und 25mm sein"
    )
    assert(
      type(abstand-unten) == length and abstand-unten >= 20mm and abstand-unten <= 25mm,
      message: "Der untere Abstand soll zwischen 20mm und 25mm sein"
    )

    assert(
      schriftart in ("Arial", "Times New Roman", "Verdana"),
      message: "Die Schriftart kann nur Arial(11pt), Verdana(11pt) oder Times New Roman(12pt) sein"
    )
  }

#let _validate-deckblatt-inputs(  
  leitfrage,
  name,
  referenzfach,
  bezugsfach,
  pruefer,
  vorgelegt-am,
  abgabetermin-am,
  stadt
  ) = {
    assert(type(leitfrage) == str, message:"Die Leitfrage soll ein string sein")
    assert(type(name) == str, message:"Name soll ein string sein")
    assert(type(referenzfach) == str, message: "Referenzfach soll ein string sein")
    assert(type(bezugsfach) == str, message: "Bezugsfach soll ein string sein")
    // check if pruefer follows this format ((name: "name"), (name: "name"))
    assert(type(pruefer) == array and pruefer.all(p => type(p) == dictionary and "name" in p), message: "Prüfer muss dem Format ((name: \"name\"), ...) entsprechen")
    assert(type(stadt) == str, message: "Stadt muss ein string sein")
    assert(
      type(vorgelegt-am) == datetime, 
      message: "vorgelegt-am soll ein datetime-Objekt sein"
    )
    assert(
      type(abgabetermin-am) == datetime,
      message: "abgabetermin-am soll ein datetime-Objekt sein"
    )
    assert(
      vorgelegt-am <= abgabetermin-am,
      message: "vorgelegt-am soll vor oder am selben Tag sein wie abgabetermin-am"
    )
  }