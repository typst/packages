#import "utils.typ": *

#let frontispieces = (
  "alternate": (
    university,
    faculty,
    department,
    unilogo,
    course,
    title,
    subtitle,
    supervisor,
    cosupervisor,
    thesis-type,
    author,
    serial-number,
    academic-year,
  ) => page(
    margin: (top: 2cm),
    footer: none,
    {
      set align(center + top)

      unilogo
      text(
        size: 2em,
        weight: 500,
        upper("Università degli Studi di Milano"),
      )
      {
        set par(spacing: 0cm)

        set text(size: 1.7em, font: "Liberation Serif")
        if faculty != none {
          upper(faculty)
        }
      }

      v(4.5cm)

      block(
        width: 100%,
        stroke: (bottom: black),
        inset: (bottom: 2em),
        text(
          size: 3.5em,
          weight: 450,
          smallcaps(title),
        ),
      )

      if subtitle != none {
        align(
          right,
          block(
            width: 70%,
            text(
              size: 1.6em,
              style: "italic",
              subtitle,
            ),
          ),
        )
      }

      v(4em)

      {
        set text(size: 1.3em)
        set align(left)

        set text(size: 1.1em)
        parbreak()
        smallcaps(author)
        if serial-number != none {
          parbreak()
          context _localization.at(text.lang).serial-number + serial-number
        }

        if course != none {
          parbreak()
          course
        }

        set align(right)
        if supervisor != none {
          v(2em)
          _show-starvisor(supervisor, "supervisor")
        }
        if cosupervisor != none {
          _show-starvisor(cosupervisor, "cosupervisor")
        }

        if department != none {
          parbreak()
          department
        }
      }

      set align(bottom + center)

      text(
        size: 1.2em,
        smallcaps(context {
          _localization.at(text.lang).academic-year
          if type(academic-year) == datetime {
            let current-year = academic-year.year()
            str(current-year - 1) + [ --- ] + str(current-year)
          } else {
            " " + academic-year
          }
        }),
      )
    },
  ),
  "lim": (
    university,
    faculty,
    department,
    unilogo,
    course,
    title,
    subtitle,
    supervisors,
    cosupervisors,
    thesis-type,
    author,
    serial-number,
    academic-year,
  ) => page(
    footer: none,
    {
      align(
        center,
        context {
          text(size: _sizes.LARGE, university) + linebreak()
          upper(faculty)
          v(0.0135 * page.height)
          upper(department)
          v(0.02 * page.height)
          unilogo
          v(0.0135 * page.height)
          upper(course)
        },
      )

      // v(0.0168 * page.height)
      v(1fr)

      align(
        center,
        text(size: _sizes.Large, upper(title)),
      )

      v(0.5cm)

      if (subtitle != none) {
        align(
          center,
          subtitle,
        )
      }

      // v(0.0673 * page.height)
      v(1fr)

      set text(size: _sizes.large)

      align(
        left,
        {
          _show-starvisor(supervisors, "supervisor")
          _show-starvisor(cosupervisors, "cosupervisor")
        },
      )

      context { v(0.0168 * page.height) }
      // v(1fr)

      align(
        right,
        box({
          context {
            set align(left)
            if author != none {
              thesis-type + " "
              _localization.at(text.lang).type-of-thesis
              ":" + linebreak()
              author + linebreak()
            }
            if serial-number != none {
              _localization.at(text.lang).serial-number + " "
              serial-number
            }
          }
        }),
      )

      // v(0.0337 * paper.height)
      v(1fr)

      align(
        center,
        context {
          smallcaps({
            _localization.at(text.lang).academic-year
            " "
            academic-year
          })
        },
      )
    },
  ),
)

