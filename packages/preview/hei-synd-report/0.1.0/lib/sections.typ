//
// Description: Some recurrent section elements mainly for exams
// Author     : Silvan Zahno
//
#import "constants.typ": *
#import "boxes.typ": *

#let part(
  title: [],
  number: 1,
  size: huge,
) = {
  pagebreak()
  v(1fr)
  align(center, smallcaps(text(size, [Part #number])))
  v(2em)
  align(center, smallcaps(text(size, title)))
  v(1fr)
  pagebreak()
}


#let titlebox(
  width: 100%,
  radius: 10pt,
  border: 1pt,
  inset: 20pt,
  outset: -10pt,
  linecolor: box-border,
  titlesize: huge,
  subtitlesize: larger,
  title: [],
  subtitle: none,
) = {
    if title != [] {
    align(center,
      rect(
        stroke: (left:linecolor+border, top:linecolor+border, rest:linecolor+(border+1pt)),
        radius: radius,
        outset: (left:outset, right:outset),
        inset: (left:inset*2, top:inset, right:inset*2, bottom:inset),
        width: width)[
          #align(center,
            [
              #if subtitle != none {
                [#text(titlesize, title) \ \ #text(subtitlesize, subtitle)]
              } else {
                text(titlesize, title)
              }
            ]
          )
        ]
      )
    }
}

#let exam_header(
  nbrEx: 5+1,
  pts: 10,
  lang: "en" // "de" "fr"
) = {
  if nbrEx == 0 {
    table(
      columns: (2cm, 90%),
      align: center + top,
      stroke: none,
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
    )
  } else if nbrEx == 1 {
    table(
      columns: (2cm, 90%-1.3cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
    )
  } else if nbrEx == 2 {
    table(
      columns: (2cm, 90%-2.3cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  } else if nbrEx == 3 {
    table(
      columns: (2cm, 90%-3.3cm, 1cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], [#v(-0.4cm)#text(small, "2")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  } else if nbrEx == 4 {
    table(
      columns: (2cm, 90%-4.3cm, 1cm, 1cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], [#v(-0.4cm)#text(small, "2")], [#v(-0.4cm)#text(small, "3")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  } else if nbrEx == 5 {
    table(
      columns: (2cm, 90%-5.3cm, 1cm, 1cm, 1cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], [#v(-0.4cm)#text(small, "2")], [#v(-0.4cm)#text(small, "3")], [#v(-0.4cm)#text(small, "4")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  } else if nbrEx == 6 {
    table(
      columns: (2cm, 90%-6.3cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], [#v(-0.4cm)#text(small, "2")], [#v(-0.4cm)#text(small, "3")], [#v(-0.4cm)#text(small, "4")], [#v(-0.4cm)#text(small, "5")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  } else if nbrEx == 7 {
    table(
      columns: (2cm, 90%-7.3cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], [#v(-0.4cm)#text(small, "2")], [#v(-0.4cm)#text(small, "3")], [#v(-0.4cm)#text(small, "4")], [#v(-0.4cm)#text(small, "5")], [#v(-0.4cm)#text(small, "6")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  } else if nbrEx == 8 {
    table(
      columns: (2cm, 90%-8.3cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], [#v(-0.4cm)#text(small, "2")], [#v(-0.4cm)#text(small, "3")], [#v(-0.4cm)#text(small, "4")], [#v(-0.4cm)#text(small, "5")], [#v(-0.4cm)#text(small, "6")], [#v(-0.4cm)#text(small, "7")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  } else if nbrEx == 9 {
    table(
      columns: (2cm, 90%-9.3cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], [#v(-0.4cm)#text(small, "2")], [#v(-0.4cm)#text(small, "3")], [#v(-0.4cm)#text(small, "4")], [#v(-0.4cm)#text(small, "5")], [#v(-0.4cm)#text(small, "6")], [#v(-0.4cm)#text(small, "7")], [#v(-0.4cm)#text(small, "8")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  } else if nbrEx == 10 {
    table(
      columns: (2cm, 90%-10.3cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1cm, 1.3cm),
      align: center + top,
      stroke: none,
      [], [], [#v(-0.4cm)#text(small, "1")], [#v(-0.4cm)#text(small, "2")], [#v(-0.4cm)#text(small, "3")], [#v(-0.4cm)#text(small, "4")], [#v(-0.4cm)#text(small, "5")], [#v(-0.4cm)#text(small, "6")], [#v(-0.4cm)#text(small, "7")], [#v(-0.4cm)#text(small, "8")], [#v(-0.4cm)#text(small, "9")], if lang == "en" {[#v(-0.4cm)#text(small, "Grade")]} else {[#v(-0.4cm)#text(small, "Note")]},
      if lang == "en" or lang == "de" {[#text(large, "Name:")]} else {[#text(large, "Nom:")]
      },
      [#line(start: (0cm, 0.7cm), length:(100%), stroke:(dash:"loosely-dashed"))],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#square(size:1cm, stroke:1pt)],
      [#v(-0.3cm)#rect(height:1cm, width:1.2cm, stroke:2pt)],
      [], [], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [#v(-0.2cm)#text(small, [(#pts)])], [],
    )
  }
  /*if lang == "en" {
    [#text(large, "Name:")]
  } else if lang == "fr" {
    [#text(large, "Nom:")]
  } else if lang == "de" {
    [#text(large, "Name:")]
  }
  line(start: (2cm, 0cm), length:(80%-nbrEx*5%), stroke:(dash:"loosely-dashed"))
  if nbrEx != 0 {
    let i = 0
    while i <= nbrEx {
      if i == nbrEx {
        square(size:1.3cm, stroke:2pt)
      } else {
        square(size:1cm, stroke:1pt)
      }
      i = i + 1
    }
  }*/
}

#let exam_reminder_did(
  lang: "en" // "de" "fr",
) = {
  if lang == "en" {
    infobox[
      *Exam Reminder:* \
      You can only use the following items:
      - a laptop without internet connection
      - a pocketcalculator
      - all paper documents you want
      It is forbidden to use generative AI.
      \
      *Good Luck!*
    ]
  } else if lang == "fr" {
    infobox[
      *Rappel d'examen :* \
      Vous ne pouvez utiliser que les éléments suivants :
      - un ordinateur portable sans connexion internet
      - une calculatrice de poche
      - tous les documents papier que vous souhaitez
      Il est interdit d'utiliser l'IA générative.
      \
      *Bonne chance!*
    ]
  } else if lang == "de" {
    infobox[
      *Prüfungserinnerung:* \
      Sie können nur die folgenden Gegenstände verwenden:
      - ein Laptop ohne Internetanschluss
      - einen Taschenrechner
      - alle Papierdokumente
      Es ist verboten, generative KI zu verwenden.
      \
      *Viel Glück!*
    ]
  }
}

#let exam_reminder_car(
  lang: "en" // "de" "fr",
) = {
  if lang == "en" {
    infobox[
      *Exam Reminder:*
      \ \
      You can only use the following items:
      - the two-page summary you created.
      - a pocketcalculator
      In addition, properly comment all high-level and assembler code to explain its purpose and how it fits into the program structure.
      \ \
      *Good Luck!*
    ]
  } else if lang == "fr" {
    infobox[
      *Rappel d'examen :*
      \ \
      Vous ne pouvez utiliser que les éléments suivants :
      - le résumé de deux pages que vous avez créé.
      - une calculatrice de poche
      Commenter également tout le code de haut niveau et le code assembleur de manière appropriée afin d'expliquer son but et son intégration dans la structure du programme.
      \ \
      *Bonne chance!*
    ]
  } else if lang == "de" {
    infobox[
      *Prüfungserinnerung:*
      \ \
      Sie können nur die folgenden Elemente verwenden:
      - die zweiseitige Zusammenfassung, die Sie erstellt haben.
      - einen Taschenrechner
      Kommentieren Sie ausserdem den gesamten High-Level- und Assembler-Code ordnungsgemäss aus, um seinen Zweck und seine Einbindung in die Programmstruktur zu erklären.
      \ \
      *Viel Glück!*
    ]
  }
}

#let exam_reminder_syd(
  lang: "en" // "de" "fr",
) = {
  if lang == "en" {
    infobox[
      *Exam Reminder:*
      \
      You can only use the following items:
      - your personal notes
      - the couse slides
      //- A one-page summary (front and back) prepared by you.
      It is forbidden to use generative AI.
      \
      *Good Luck!*
    ]
  } else if lang == "fr" {
    infobox[
      *Rappel d'examen :*
      \
      Vous ne pouvez utiliser que les éléments suivants :
      - vos notes personnelles
      - les diapositives du cours
      Il est interdit d'utiliser l'IA générative.
      \
      *Bonne chance!*
    ]
  } else if lang == "de" {
    infobox[
      *Prüfungserinnerung:*
      \
      Sie können nur die folgenden Elemente verwenden:
      - Ihre persönlichen Notizen
      - die Vorlesungsfolien
      Es ist verboten, generative KI zu verwenden.
      \
      *Viel Glück!*
    ]
  }
}

#let exercises_solution_hints(
  lang: "en" // "de" "fr",
) = {
  if lang == "en" {
    infobox[
      *Solution vs. Hints:*
      \
      While not every response provided herein constitutes a comprehensive solution, some serve as helpful hints intended to guide you toward discovering the solution independently. In certain instances, only a portion of the solution is presented.
    ]
  } else if lang == "fr" {
    infobox[
      *Solution vs. Hints:*
      \
      Toutes les réponses fournies ici ne sont pas des solutions complètes. Certaines ne sont que des indices pour vous aider à trouver la solution vous-même. Dans d'autres cas, seule une partie de la solution est fournie.
    ]
  } else if lang == "de" {
    infobox[
      *Lösung vs. Hinweise:*
      \
      Nicht alle hier gegebenen Antworten sind vollständige Lösungen. Einige dienen lediglich als Hinweise, um Ihnen bei der eigenständigen Lösungsfindung zu helfen. In anderen Fällen wird nur ein Teil der Lösung präsentiert.
    ]
  }
}
