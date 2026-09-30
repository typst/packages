#import "i18n.typ": i18n, i18n-date-month-year
#import "constants.typ": WORK_TYPES
#import "utils.typ": apply-sans-font

/// Displays the title page of the thesis. Returns a formatted title page as a grid layout. Fonts, spacing, and margins are set for title page aesthetics.
///
/// - course-of-study (str): The name of the study course (e.g., "Software Engineering").
/// - mentor-name (str): Name of the mentor or supervisor.
/// - degree (str): Name of the degree to be shown. If not provided, it is selected based on work-type.
/// - submission-date (date | auto): Date of submission. Uses the document date if not provided.
/// - work-type (WORK_TYPES): Type of thesis. Defaults to `WORK_TYPES.bachelor-thesis`.
/// - study-program (str | auto): Study program display name. If not provided, shown based on work-type.
/// - place-of-study (str | auto): Location of study. Defaults to "Hagenberg".
#let titlepage(
  course-of-study, // Studiengang
  mentor-name,
  degree: auto,
  submission-date: auto,
  work-type: WORK_TYPES.bachelor-thesis,
  study-program: auto,
  place-of-study: auto,
) = context [
  #let place-of-study = if place-of-study == auto { "Hagenberg" } else {
    place-of-study
  }
  #let study-program = if study-program == auto {
    if work-type == WORK_TYPES.bachelor-thesis {
      i18n("fh-bachelor-study-program")
    } else {
      i18n("fh-master-study-program")
    }
  } else {
    study-program
  }
  #let degree = if degree == auto {
    if work-type == WORK_TYPES.bachelor-thesis {
      i18n("degree-bachelor")
    } else {
      i18n("degree-master")
    }
  } else {
    degree
  }
  #let submission-date = if submission-date == auto {
    if document.date == auto { datetime.today() } else { document.date }
  } else { submission-date }

  #set text(size: 10pt)
  #show: apply-sans-font.with(other-fonts: ("Verdana",))
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
      #study-program\
      #{
        show: strong
        set text(size: 11pt)
        course-of-study
      }\
      #i18n("hagenberg-address")
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
    if degree != none {
      v(1.5em)
      [#i18n("degree-goal-prefix")\ #degree]
    }
  }

  #v(1.5cm)
  #i18n("submitted-by")

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
  #place-of-study, #i18n-date-month-year(submission-date)

  #v(1em)
]
