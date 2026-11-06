#import "i18n.typ": i18n, i18n-date-short
#import "constants.typ": WORK_TYPES

#let titlepage(
  course-of-study, // Studiengang
  mentor-name,
  submission-date: datetime.today(),
  work-type: WORK_TYPES.bachelor-thesis,
) = context [
  #set text(font: ("Verdana", "Arial", text.font), size: 10pt)
  #set page(margin: (
    top: 2cm,
    left: 2.5cm,
    bottom: 2cm,
    right: 2.27cm,
  ))
  #set par(leading: 0.5em, spacing: 0.5em, justify: false)

  #grid(
    columns: (auto, 1fr),
    align: left + horizon,
    gutter: 1em,
    image("../assets/logo-cropped.svg", height: 1.25cm),
    [
      #{
        if work-type == WORK_TYPES.bachelor-thesis [
          #i18n("fh-bachelor-study-program")
        ] else [
          #i18n("fh-master-study-program")
        ]
      }\
      #{
        show: strong
        set text(size: 11pt)
        course-of-study
      }\
      #{
        i18n("hagenberg-address")
      }
    ],
  )

  #set align(center)
  #v(6.5cm)

  #{
    set text(size: 18pt)
    show: strong
    document.title
  }

  #v(2.5cm)
  #{
    set text(size: 14pt)
    if work-type == WORK_TYPES.bachelor-thesis {
      i18n("bachelor-thesis")
    } else {
      i18n("master-thesis")
    }
  }

  #v(1.5em)
  #{
    i18n("degree-goal-declaration")
  }

  #v(1.5cm)
  #{
    i18n("submitted-by")
  }

  #v(1em)
  #{
    set text(size: 14pt)
    show: strong
    document.author.join("\n")
  }

  #v(1fr)

  #{
    set text(size: 11pt)
    i18n("reviewed-by")
    sym.space
    mentor-name
  }

  #v(1cm)
  Hagenberg, #{
    import "@preview/datify:1.3.0": display-date

    display-date(submission-date, pattern: "MMMM yyyy")
  }

  #v(1em)
]
