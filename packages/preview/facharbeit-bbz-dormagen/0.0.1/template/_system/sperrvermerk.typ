// =======================================================================
// DATEI: sperrvermerk.typ
// ZWECK: Sperrvermerk: Rendert die optionale Geheimhaltungserklärung auf einer eigenen Seite, falls aktiviert.
// =======================================================================

#let render_sperrvermerk(userdata) = [

// ==========================================
// SPERRVERMERK (VERTRAULICHKEIT)
// ==========================================
#v(3cm)
#heading(numbering: none, outlined: false)[Sperrvermerk]

#v(1em)
Diese Facharbeit enthält unternehmensinterne und vertrauliche Informationen des Unternehmens #userdata.ausbildungsbetrieb. Veröffentlichung, Duplizierung und Weitergabe der Arbeit, auch in Auszügen, ist grundsätzlich nicht gestattet. Sie ist nur zur Vorlage bei der Fachschule sowie den Begutachtern der Arbeit bestimmt und darf weder der Öffentlichkeit noch dritten Personen zugänglich gemacht werden.

#v(4cm)
Dormagen, #userdata.abgabedatum

#v(2cm)
#line(length: 8cm, stroke: 0.5pt)
#text(size: 10pt)[Unterschrift (#userdata.vorname #userdata.nachname)]
]
