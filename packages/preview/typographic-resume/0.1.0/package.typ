#let default-theme = (
  margin: 26pt,
  font: "Libre Baskerville",
  font-size: 8pt,
  font-secondary: "Roboto",
  font-tertiary: "Montserrat",
  text-color: rgb("#3f454d"),
  gutter-size: 4em,
  main-width: 6fr,
  aside-width: 3fr,
  profile-picture-width: 55%,
)


#let resume(
  first-name: "",
  last-name: "",
  profession: "",
  bio: "",
  profile-picture: none,
  theme: (),
  aside: [],
  main,
) = {
  // Function to pick a key from the theme, or a default if not provided.
  let th(key, default: none) = {
    return if key in theme and theme.at(key) != none {
      theme.at(key)
    } else if default != none and default in theme and theme.at(default) != none {
      theme.at(default)
    } else if default != none {
      default-theme.at(default)
    } else {
      default-theme.at(key)
    }
  }

  set page(
    margin: (
      top: th("margin"),
      bottom: th("margin"),
      left: th("margin"),
      right: th("margin"),
    ),
  )

  // Fix for https://github.com/typst/typst/discussions/2919
  show heading.where(level: 1): set text(size: th("font-size"))
  show heading.where(level: 2): set text(size: th("font-size"))
  show heading.where(level: 3): set text(size: th("font-size"))

  show heading.where(level: 1): set text(font: th("font-tertiary"), weight: "light")

  set text(font: th("font"), size: th("font-size"), fill: th("text-color"))

  set block(above: 10pt, below: 8pt, spacing: 10pt)

  set grid(columns: (th("gutter-size"), 1fr))

  grid(
    columns: (th("aside-width"), th("margin"), th("main-width")),

    // Aside.
    {
      {
        {
          show heading: set block(above: 0pt, below: 0pt)
          show heading: set text(size: 12pt, weight: "regular", font: th("font"), fill: th("text-color"))
          heading(level: 2, first-name)
        }
        {
          show heading: set block(above: 3pt, below: 0pt)
          show heading: set text(size: 26pt, weight: "regular", font: th("font"), fill: th("text-color"))

          heading(level: 1, last-name)
        }
        {
          show heading: set block(above: 10pt, below: 0pt)
          show heading: set text(weight: "light", font: th("font-tertiary"))
          heading(level: 3, upper(profession))
        }

        if profile-picture != none {
          set block(radius: 100%, clip: true, above: 1fr, below: 1fr)
          set align(center)
          set image(width: th("profile-picture-width"))
          profile-picture
        } else {
          v(1fr)
        }


        set text(weight: "light", style: "italic", hyphenate: true)
        set par(leading: 1.0em)
        bio
      }

      aside
    },

    // Empty space.
    { },

    // Content.
    main
  )
}


#let section(
  theme: (),
  title,
  body,
) = {
  show heading.where(level: 1): set align(theme.align-title) if "align-title" in theme
  show heading.where(level: 1): set align(end) if not "align-title" in theme

  if "space-above" not in theme {
    v(1fr)
  } else {
    v(theme.space-above)
  }


  heading(level: 1, upper(title))
  {
    set block(above: 2pt, below: 14pt)
    line(stroke: 1pt, length: 100%)
  }
  body
}

#let contact-entry(
  theme: (),
  gutter,
  right,
) = {
  set grid(columns: (theme.gutter-size, 1fr)) if "gutter-size" in theme
  set text(font: theme.font-secondary) if "font-secondary" in theme
  set text(font: default-theme.font-secondary) if "font-secondary" not in theme
  set text(size: theme.font-size) if "font-size" in theme

  grid(
    {
      context {
        set align(center) if not "align-gutter" in theme
        set align(theme.align-gutter) if "align-gutter" in theme
        gutter
      }
    },
    {
      right
    }
  )
}

#let language-entry(
  theme: (),
  language,
  level,
) = {
  set text(font: theme.font) if "font-secondary" in theme
  set text(font: default-theme.font-secondary) if "font-secondary" not in theme
  set text(size: theme.font-size) if "font-size" in theme

  stack(
    dir: ltr,
    language,
    {
      set align(end)
      level
    },
  )
}

#let work-entry(
  theme: (),
  timeframe: "",
  title: "",
  organization: "",
  location: "",
  body,
) = {
  set text(size: theme.font-size) if "font-size" in theme

  if "space-above" not in theme {
    v(1fr)
  } else {
    v(theme.space-above)
  }
  {
    set text(font: theme.font-secondary) if "font-secondary" in theme
    set text(font: default-theme.font-secondary) if "font-secondary" not in theme
    set block(above: 0pt, below: 0pt)
    stack(
      dir: ltr,
      spacing: 1fr,
      stack(
        spacing: 5pt,
        context {
          set text(weight: "light", fill: text.fill.lighten(30%))
          timeframe
        },
        {
          {
            set text(weight: "bold")
            upper(title)
          }
          " – "
          organization
        },
      ),
      context {
        set align(horizon)
        set text(weight: "light", fill: text.fill.lighten(30%))
        location
      },
    )
  }
  {
    set block(above: 6pt, below: 8pt)
    line(stroke: 0.1pt, length: 100%)
  }
  context {
    set text(fill: text.fill.lighten(30%))
    set par(leading: 1em)
    body
  }
}

#let education-entry(
  theme: (),
  timeframe: "",
  title: "",
  institution: "",
  location: "",
  body,
) = {
  set text(size: theme.font-size) if "font-size" in theme

  {
    set text(font: theme.font-secondary) if "font-secondary" in theme
    set text(font: default-theme.font-secondary) if "font-secondary" not in theme
    stack(
      spacing: 5pt,
      {
        set text(weight: "bold")
        upper(title)
      },
      institution,
    )

    {
      set block(above: 6pt, below: 8pt)
      line(stroke: 0.1pt, length: 100%)
    }
  }


  context {
    set text(weight: "light", fill: text.fill.lighten(30%))
    stack(
      spacing: 8pt,
      {
        set text(font: theme.font) if "font" in theme
        body
      },
      {
        set text(font: theme.font-secondary) if "font-secondary" in theme
        set text(font: default-theme.font-secondary) if "font-secondary" not in theme
        timeframe
      },
    )
  }
}

#let github-icon = image("images/github-brands.svg")
#let phone-icon = image("images/phone-solid.svg")
#let email-icon = image("images/envelope-solid.svg")
