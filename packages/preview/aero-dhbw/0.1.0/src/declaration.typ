#let declaration(
  title: [],
  author: [],
  project: [],
  project-type: [],
  place-of-authorship: [],
  date: [],
  lang: []
) = {
  set align(left)
  
  if lang == "en" {
    set text(lang: "en")
    [
    
      #heading("Declaration of Authorship", outlined: false)
      #set par(justify: true)

      In accordance with Section 1.1.14 of Appendix 1 to §§ 3, 4 and 5 of the Study and Examination Regulations for Bachelor’s Degree Programs in the Technical Field of the Baden-Württemberg Cooperative State University dated September 2017, as amended on July 24, 2023.

      #v(2em)
      I hereby declare that I have authored my #project-type #project on the topic: 

      #v(2em)
      #align(center,block(inset: (x: 3em), emph(title)))
      #v(2em)

      independently and have used no other sources or aids than those indicated. I also declare that the submitted electronic version corresponds to the printed version.

      #v(6em)

      #place-of-authorship, #datetime.display(date, "[month repr:long] [day], [year]")
      
      #v(4em)

      #line(length: 14em, stroke: 0.5pt)

      #v(2em)

      #author
    ]
  }
  else {
    set text(lang: "de")
    [
      #heading("Erklärung", outlined: false)
      #set par(justify: true)

      gemäß Ziffer 1.1.14 der Anlage 1 zu §§ 3, 4 und 5 der Studien- und Prüfungsordnung für die Bachelorstudiengänge im Studienbereich Technik der Dualen Hochschule Baden-Württemberg vom 29.09.2017 in der Fassung vom 24.07.2023.

      #v(2em)
      Ich versichere hiermit, dass ich meine #project-type #project mit dem Thema: 

      #v(2em)
      #align(center,block(inset: (x: 3em), emph(title)))
      #v(2em)

      selbstständig verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel benutzt habe. Ich versichere zudem, dass alle eingereichten Fassungen übereinstimmen.

      #v(6em)

      #place-of-authorship, den #datetime.display(date, "[day].[month].[year]")
      
      #v(4em)

      #line(length: 14em, stroke: 0.5pt)

      #v(2em)

      #author
    ]
  }
}