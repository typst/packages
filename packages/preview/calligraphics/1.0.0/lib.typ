#import "@preview/voronay:0.1.0": *
#import "@preview/fontawesome:0.6.0": *
#import "@preview/linguify:0.5.0": *

#fa-version("7")

#let default-main-color = rgb("#a658b8");
#let linkedin-icon = box(baseline: -10%, fa-icon("linkedin"))
#let github-icon = box(baseline: -10%, fa-icon("github"))
#let gitlab-icon = box(baseline: -10%, fa-icon("gitlab"))
#let bitbucket-icon = box(baseline: -10%, fa-icon("bitbucket"))
#let twitter-icon = box(baseline: -10%, fa-icon("twitter"))
#let google-scholar-icon = box(baseline: -10%, fa-icon("google-scholar"))
#let orcid-icon = box(baseline: -10%, fa-icon("orcid"))
#let phone-icon = box(baseline: -10%, fa-icon("square-phone"))
#let email-icon = box(baseline: -10%, fa-icon("envelope"))
#let birth-icon = box(baseline: -10%, fa-icon("cake"))
#let homepage-icon = box(baseline: -10%, fa-icon("home"))
#let website-icon = box(baseline: -10%, fa-icon("globe"))
#let address-icon = box(baseline: 0%, fa-icon("location-dot"))

/// Show a link with an icon, specifically for Github projects
/// *Example*
/// #example(`resume.github-link("ptsouchlos/awesome-resume")`)
/// - github-path (string): The path to the Github project (e.g. "ptsouchlos/awesome-resume")
/// -> none
#let github-link(github-path) = {
  set box(height: 11pt)

  align(right + horizon)[
    #fa-icon("github") #link(
      "https://github.com/" + github-path,
      github-path,
    )
  ]
}

#let author-card(author, header-font,
  main-color,
  secondary-color,
  bland-color,
) = {
  let icon-color = secondary-color
  let name = {
    block[
      #set par(leading: 0.4em)
      #set text(size: 28pt, style: "normal", font: header-font)
      //#upper(text(secondary-color, tracking: -0.06em, weight: "light", author.lastname))
      #text(secondary-color, weight: "light", author.lastname)
      #text(main-color.darken(60%), weight: "light", author.firstname)
    ]
  }

  let positions = {
    set text(main-color, size: 9pt, weight: "regular")
    smallcaps(
      author.positions.join(text[#"  "#sym.dot.c#"  "]),
    )
  }

  let address = {
    set text(size: 8pt, weight: "regular")
    v(0pt)
    if ("address" in author) [
      #text(icon-color, address-icon)
      #box[#text(author.address)]
    ]
  }

  let contacts = {
    set box(height: 9pt)
    v(8pt)

    let separator = box(width: 5pt)

    set text(size: 8pt, weight: "regular", style: "normal")
    block[
      #align(horizon)[
        #if ("birth" in author) [
          #box[
            #text(icon-color, birth-icon)
            #box[#text(author.birth)]
          ]
          #separator
        ]
        #if ("phone" in author) [
          #box[
            #text(icon-color, phone-icon)
            #box[#link("tel:" + author.phone)[#author.phone]]
            #separator
          ]
        ]
        #if ("email" in author) [
          #box[
            #text(icon-color, email-icon)
            #box[#link("mailto:" + author.email)[#author.email]]
          ]
        ]
        #if ("homepage" in author) [
          #separator
          #box[
            #text(icon-color, homepage-icon)
            #box[#link(author.homepage)[#author.homepage]]
          ]
        ]
        #if ("github" in author) [
          #separator
          #box[
            #text(icon-color, github-icon)
            #box[#link("https://github.com/" + author.github)[#author.github]]

          ]
        ]
        #if ("gitlab" in author) [
          #separator
          #box[
            #text(icon-color, gitlab-icon)
            #box[#link("https://gitlab.com/" + author.gitlab)[#author.gitlab]]
          ]
        ]
        #if ("bitbucket" in author) [
          #separator
          #box[
            #text(icon-color, bitbucket-icon)
            #box[#link(
              "https://bitbucket.org/" + author.bitbucket,
            )[#author.bitbucket]]
          ]
        ]
        #if ("linkedin" in author) [
          #separator
          #box[
            #text(icon-color, linkedin-icon)
            #box[
              #link(
                "https://www.linkedin.com/in/" + author.linkedin,
              )[#author.firstname #author.lastname]
            ]
          ]
        ]
        #if ("twitter" in author) [
          #separator
          #box[
            #text(icon-color, twitter-icon)
            #box[#link(
              "https://twitter.com/" + author.twitter,
            )[\@#author.twitter]]
          ]
        ]
        #if ("scholar" in author) [
          #box[
            #let fullname = str(author.firstname + " " + author.lastname)
            #separator
            #text(icon-color, google-scholar-icon)
            #box[#link(
              "https://scholar.google.com/citations?user=" + author.scholar,
            )[#fullname]]
          ]
        ]
        #if ("orcid" in author) [
          #separator
          #box[
            #text(icon-color, orcid-icon)
            #box[#link("https://orcid.org/" + author.orcid)[#author.orcid]]
          ]
        ]
        #if ("website" in author) [
          #separator
          #box[
            #text(icon-color, website-icon)
            #box[#link(author.website)[#author.website]]
          ]
        ]
        #if ("custom" in author and type(author.custom) == array) [
          #for item in author.custom [
            #if ("text" in item) [
              #separator
              #if ("icon" in item) [
                #box(text(icon-color, fa-icon(item.icon)))
              ]
              #box[
                #if ("link" in item) [
                  #link(item.link)[#item.text]
                ] else [
                  #item.text
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  }
  name
  positions
  address
  contacts
}

// Detailed description below a resume entry.
#let resume-item(body) = {
  set text(size: 10pt, style: "normal")
  set block(above: 0.75em, below: 1.25em)
  set par(leading: 0.65em)
  block(above: 0.5em)[
    #body
  ]
}

/// Base item for resume entries.
/// - title (string): The title of the resume entry
/// - location (content): The location of the resume entry
/// - date (string): The date of the resume entry, this can be a range (e.g. "Jan 2020 - Dec 2020")
/// - description (content): Short description of the resume entry
/// - title-link (string): The link to use for the title (can be none)
/// - accent-color (color): Override the accent color of the resume-entry
/// - location-color (color): Override the default color of the "location" for a resume entry.
#let resume-entry(
  title: none,
  location: "",
  date: "",
  description: "",
  title-link: none,
  above-pad: 1.5em,
  bottom-pad: 0.65em,
) = {
  block(above: above-pad, below: bottom-pad)[
    #block(above: 0.7em, below: 0.45em, width: 100%)[
      #let title-content = if title-link != none {
        link(title-link)[#title]
      } else {
        title
      }
      == #title-content
      #place(bottom + right)[
        ==== #location
      ]
    ]

    #if description != "" or date != "" {
      block(width: 100%)[
        === #description
        #place(bottom + right)[
          ===== #date
        ]
      ]
    }
  ]
}

/// Show a list of skills in the resume under a given category.
/// - category (string): The category of the skills
/// - items (list): The list of skills. This can be a list of strings but you can also emphasize certain skills by using the `strong` function.
#let aside-skill-item(category, items) = {
  block(below: 1.25em, {
    block[
      #set text(hyphenate: false)
      == #category
    ]
    block[
      #set text(size: 11pt, style: "normal", weight: "light")
      #items.join(" • ")
    ]
  })
}

/// Resume template
/// - author (dictionary): Structure that takes in all the author's information. The following fields are required: firstname, lastname, positions. The following fields are used if available: email, phone, github, linkedin, orcid, address, website, custom. The `custom` field is an array of additional entries with the following fields: text (string, required), icon (string, optional Font Awesome icon name), link (string, optional).
/// - header-font (array): The font families of the cover letter headers
/// - font (array): The font families of the cover letter
/// - main-color (color): The main color of the cover letter
/// - secondary-color (color): The secondary color of the cover letter
/// - language (string): The language of the cover letter, defaults to "en". See lang.toml for available languages
/// - description (str | none): The PDF description
/// - keywords (array | str): The PDF keywords
#let resume(
  author: (:),
  header-font: "inria sans",
  font: ("Source Sans Pro", "Source Sans 3"),
  language: "en",
  main-color: default-main-color,
  secondary-color: none,
  description: none,
  keywords: (),
  rand-seed: 2000,
  left-col,
  right-col
) = {
  //let secondary-color = rgb("#131A28")
  let secondary-color = if secondary-color == none {
    main-color.rotate(60deg).darken(70%)
  } else {
    secondary-color
  }
  let bland-color = rgb("#333333")
  let lang_data = toml("lang.toml")
  let col-inset = 0.5cm

  let desc = if description == none {
    (
      lflib._linguify("resume", lang: language, from: lang_data).ok
      + " "
      + author.firstname
      + " "
      + author.lastname
    )
  } else {
    description
  }

  let to-string(it) = {
    if type(it) == str {
      it
    } else if type(it) != content {
      str(it)
    } else if it.has("text") {
      it.text
    } else if it.has("children") {
      it.children.map(to-string).join()
    } else if it.has("body") {
      to-string(it.body)
    } else if it == [ ] {
      " "
    }
  }

  let base-seed = rand-seed + (author.firstname + " " + author.lastname).len() * 2000;

  set document(
    author: author.firstname + " " + author.lastname,
    title: lflib._linguify("resume", lang: language, from: lang_data).ok,
    description: desc,
    keywords: keywords,
  )
  set page(
    margin: 0mm,
    footer-descent: 0pt,
  )

  set text(
    font: font,
    lang: language,
    size: 11pt,
    fill: bland-color,
    fallback: true,
  )
  set par(
    spacing: 0.75em, justify: true,
    justification-limits: (tracking: (min: -0.01em, max: 0.02em))
  )
  show strong: set text(main-color.darken(20%))
  show emph: set text(weight: "light")

  set heading(numbering: none, outlined: false)


  show heading.where(level: 1): it => [
    #set text(size: 12pt, tracking: 0.04em,  font: header-font, weight: "regular")
    #set align(left)
    #block(above: 2em, below: 1em)[
      #upper(strong(text(main-color.darken(40%), it.body)))
      #box(width: 1fr, line(length: 100% + col-inset, stroke: main-color))
    ]
  ]

  show heading.where(level: 2): it => {
    set text(bland-color.lighten(10%), size: 12pt, style: "normal", weight: "bold", font: header-font)
    it.body
  }

  show heading.where(level: 3): it => {
    set text(secondary-color, size: 9pt, weight: 500)
    set par(leading: 0.5em)
    smallcaps(it.body)
  }
  show heading.where(level: 4): set text(main-color.lighten(10%), size: 9pt, weight: "regular", font: header-font)

  show heading.where(level: 5): set text(weight: "light", size: 9pt, font: header-font)

  let back-color = main-color.lighten(75%)
  grid(
    fill: (back-color, none),
    align: top,
    columns: (4fr, 7fr),
    rows: 1fr,
    inset: col-inset,
  )[
    #place(top, box(width: 100%, height: 100%, outset: col-inset, clip: true)[
      #layout(size => {
        let width = 1.2 * (size.width + 2 * col-inset)
        let ratio = 1.2 * (size.height + 2 * col-inset) / width
        let points = hilbert-point-sort(
          range(1600)
          .map(i => halton-2-3(i + base-seed))
          .map(((x, y)) => (x, y * ratio ))
        )
        let faces = delaunay-triangulate(points)
        let new_p = get-circumcenters(points, faces)
        for (i, (f1, f2, f3)) in faces.enumerate() {
          let (v1x, v1y) = points.at(f1)
          let (v2x, v2y) = points.at(f2)
          let (v3x, v3y) = points.at(f3)
          let (noise_x, noise_y) = r2-sequence(i)
          let t = calc.abs((noise_x - 0.5) * 0.1 + calc.max(v1y, v2y, v3y) / ratio)
          let v = calc.abs(calc.fract((noise_y - 0.5) * 0.1 + calc.max(v1x, v2x, v3x)))
          let w = calc.pow(t, 1.5) * calc.pow((1. - v), 0.5)
          let c = color.mix(
            (main-color.rotate(0deg).lighten(20%), 100% * w),
            (back-color, 100% * (1. - w)),
          )
          place(top + left,
            dx: - 2. * col-inset,
            dy: - 2. * col-inset,
            polygon(
              (v1x * width, v1y * width),
              (v2x * width, v2y * width),
              (v3x * width, v3y * width),
              stroke: c + 0.1pt,
              fill : c,
            ))
        }
      })
    ])

    #pad(top: 35pt, align(center, author-card(author, header-font, main-color, secondary-color, bland-color)))
    #set text(size: 10pt, style: "normal", fill: secondary-color.lighten(10%))
    #set block(above: 0.75em, below: 1.25em)
    #set list(spacing: 1.25em)
    #set par(leading: 0.65em)

    #left-col
  ][
    #set text(size: 10pt, style: "normal", fill: secondary-color.lighten(30%))
    #show heading.where(level: 1): it => [
      #set text(size: 14pt, weight: "regular", font: header-font)
      #set align(left)
      #set block(above: 1em)
      #let back-color = main-color.darken(20%)
      #box(
        fill: back-color,
        inset: (top: 4pt),
        outset: (x: col-inset, bottom: 6pt),
        width: 100%,
        height: 1em + 4pt,
        clip: true,
      )[
        #set align(horizon)
        #layout( size => {
          let width = 1.15 * (size.width + 2 * col-inset)
          let ratio = 1.15 * (size.height + 10pt) / width

          let n_points = 180

          let seed = to-string(it.body).len() * n_points
          let generator(i) = halton-2-3(i + seed + base-seed)

          let points = hilbert-point-sort(
            range(n_points).map(generator).map(
              ((x, y)) => (x, y * ratio )))
          let faces = delaunay-triangulate(points)
          for (i, (f1, f2, f3)) in faces.enumerate() {
            let (v1x, v1y) = points.at(f1)
            let (v2x, v2y) = points.at(f2)
            let (v3x, v3y) = points.at(f3)
            let (noise_x, noise_y) = r2-sequence(i + seed)
            let t = calc.abs((noise_x - 0.5) * 0.1 + calc.max(v1y, v2y, v3y) / ratio)
            let v = calc.abs(calc.fract((noise_y - 0.5) * 0.1 + calc.max(v1x, v2x, v3x)))
            let w = calc.pow(t, 1.5) * calc.pow(v, 0.5)
            let c = color.mix(
              (main-color.rotate(0deg).lighten(20%), 100% * w),
              (back-color, 100% * (1. - w)),
            )
            place(top + left,
              dx: - 2. * col-inset,
              dy: - 5pt,
              polygon(
                (v1x * width, v1y * width),
                (v2x * width, v2y * width),
                (v3x * width, v3y * width),
                stroke: c + 0.1pt,
                fill : c,
              ))
          }
          let color = main-color.lighten(100%)
          upper(strong(text(color, tracking: 3pt, it.body)))
        })
      ]
    ]

    #show heading.where(level: 4): set text(main-color.lighten(30%), size: 9pt, weight: "regular", font: header-font)
    #right-col
  ]
}


/// Cover letter template designed to be used with the resume template.
/// - author (dictionary): Structure that takes in all the author's information. The following fields are required: firstname, lastname, positions. The following fields are used if available: email, phone, github, linkedin, orcid, address, website, custom. The `custom` field is an array of additional entries with the following fields: text (string, required), icon (string, optional Font Awesome icon name), link (string, optional).
/// - profile-picture (image): The profile picture of the author. This will be cropped to a circle and should be square in nature.
/// - date (datetime): The date the cover letter was created. This will default to the current date.
/// - main-color (color): The main color of the cover letter
/// - secondary-color (color): The secondary color of the cover letter
/// - language (string): The language of the cover letter, defaults to "en". See lang.toml for available languages
/// - font (array): The font families of the cover letter
/// - header-font (array): The font families of the cover letter headers
/// - show-footer (boolean): Whether to show the footer or not
/// - closing (content): The closing of the cover letter. This defaults to "Attached Curriculum Vitae". You can set this to `none` to show the default closing or remove it completely.
/// - description (str | none): The PDF description
/// - keywords (array | str): The PDF keywords
/// - body (content): The body of the cover letter
/// - entity-info (content): The information of the hiring entity including the company name, the target (who's attention to), street address, and city
/// - job-position (string): The job position you are applying for
/// - addressee (string): The person you are addressing the letter to
/// - dear (string): optional field for redefining the "dear" variable
#let coverletter(
  author: (:),
  profile-picture: none,
  date: datetime.today().display("[month repr:long] [day], [year]"),
  main-color: default-main-color,
  secondary-color: none,
  language: "en",
  font: ("Source Sans Pro", "Source Sans 3"),
  header-font: "Inria sans",
  show-footer: true,
  closing: none,
  description: none,
  keywords: (),
  entity-info: (:),
  job-position: "",
  addressee: "",
  dear: "",
  body,
) = {
  if type(main-color) == str {
    main-color = rgb(main-color)
  }
  let secondary-color = if secondary-color == none {
    main-color.rotate(60deg).darken(70%)
  } else {
    secondary-color
  }
  let bland-color = rgb("#333333")

  // language data
  let lang-data = toml("lang.toml")

  if closing == none {
    closing = text(weight: "light", style: "italic")[
      #linguify("attached", from: lang-data)#sym.colon #linguify(
        "curriculum-vitae",
        from: lang-data,
      )]
  }

  let desc = if description == none {
    (
      lflib._linguify("cover-letter", lang: language, from: lang-data).ok
      + " "
      + author.firstname
      + " "
      + author.lastname
    )
  } else {
    description
  }

  set document(
    author: author.firstname + " " + author.lastname,
    title: lflib
    ._linguify("cover-letter", lang: language, from: lang-data)
    .ok,
    description: desc,
    keywords: keywords,
  )

  set text(
    font: font,
    lang: language,
    size: 12pt,
    fill: secondary-color.lighten(20%),
    fallback: true,
  )

  let margin-x = 15mm
  let margin-y = 10mm
  let bleed-right = 10pt
  let bleed-left = 10pt
  let back-color = main-color.lighten(75%)
  let back-color-dark = main-color.lighten(20%)
  let dark-back-color = main-color.darken(20%)

  set page(
    margin: (x: margin-x, y: margin-y),
    footer: if show-footer [
      #set text(fill: bland-color.lighten(60%), size: 8pt)
      #grid(columns: (1fr, 1fr, 1fr), align: (left, center, right))[
        #smallcaps(date)
      ][
        #smallcaps(
          {
            linguify("cover-letter", from: lang-data)
          },
        )
      ][
        #if language == "zh" or language == "ja" {
          str(author.lastname) + str(author.firstname)
        } else {
          str(author.firstname) + " " + str(author.lastname)
        }
      ]
    ] else [],
    footer-descent: 2mm,
    background: context {
      let thickness = 1pt
      let pos = locate(<letter-heading>).position()
      place(polygon(
        (100% + bleed-right - margin-x - thickness / 2., 0%),
        (100% + bleed-right - margin-x - thickness / 2., pos.y),
        stroke: back-color + thickness,
      ))
      place(polygon(
        ( - bleed-left + margin-x + thickness / 2., pos.y),
        ( - bleed-left + margin-x + thickness / 2., 100%),
        stroke: dark-back-color + thickness,
      ))
    },
  )

  // set paragraph spacing
  set par(
    spacing: 0.75em, justify: true,
    justification-limits: (tracking: (min: -0.01em, max: 0.02em))
  )

  set heading(numbering: none, outlined: false)

  show heading: it => [
    #set block(above: 1em, below: 1em)
    #set text(size: 16pt, weight: "regular")

    #align(left)[
      #text[#strong[#text(main-color)[#it.body]]]
      #box(width: 1fr, line(length: 100%))
    ]
  ]

  let letter-heading = context {
    let header-content = grid(
      columns: (1fr, 2fr),
      rows: 100pt,
      align(left + horizon)[
        #block(
          clip: true,
          stroke: 0pt,
          radius: 2cm,
          width: 4cm,
          height: auto,
          profile-picture,
        )
      ],
      [
        #pad(right: 20pt, align(right, author-card(author, header-font, main-color, secondary-color, bland-color)))
      ],
    )
    let m = measure(header-content)
    place(top, dx: - margin-x, dy: - margin-y, box(width: 100% + margin-x + bleed-right, height: m.height + margin-y, clip: true)[
      #layout(size => {
        let width = 1.2 * (size.width)
        let ratio = 1.2 * (size.height) / width
        let points = hilbert-point-sort(
          range(800)
          .map(halton-2-3)
          .map(((x, y)) => (x, y * ratio ))
        )
        let faces = delaunay-triangulate(points)
        for (i, (f1, f2, f3)) in faces.enumerate() {
          let (v1x, v1y) = points.at(f1)
          let (v2x, v2y) = points.at(f2)
          let (v3x, v3y) = points.at(f3)
          let (noise_x, noise_y) = r2-sequence(i)
          let t = calc.abs((noise_x - 0.5) * 0.1 + calc.max(v1y, v2y, v3y) / ratio)
          let v = calc.abs(calc.fract((noise_y - 0.5) * 0.1 + calc.max(v1x, v2x, v3x)))
          let w = calc.pow(t, 0.5) * calc.pow((1. - v), 1.)
          let c = color.mix(
            (main-color.rotate(0deg).lighten(20%), 100% * w),
            (back-color, 100% * (1. - w)),
          )
          place(top + left,
            polygon(
              (v1x * width, v1y * width),
              (v2x * width, v2y * width),
              (v3x * width, v3y * width),
              stroke: c + 0.1pt,
              fill : c,
            ))
        }
      })
    ])
    header-content
    pad(top: 1.5em, bottom: 1.5em)[
      #text(secondary-color.lighten(10%), weight: "bold", size: 12pt, entity-info.target)
      #h(1fr)
      #text(main-color.lighten(30%), size: 9pt, weight: "regular", font: header-font, date) \
      #text(weight: "regular", fill: secondary-color, size: 9pt)[
        #smallcaps(entity-info.name) \
        #entity-info.street-address \
        #entity-info.city \
      ]
    ]
    {
      set text(size: 14pt, weight: "regular", font: header-font)
      let back-color = main-color.darken(20%)
      block(
        fill: back-color,
        inset: (top: 10pt),
        outset: (left: bleed-left, bottom: 6pt),
        width: 100% + 15mm + bleed-left,
        height: 1em + 6pt,
        clip: true,
        below: 2.5em,
      )[
        #layout( size => {
          let width = 1.15 * (size.width)
          let ratio = 1.15 * (size.height + 10pt) / width

          let n_points = 180

          let seed = 0
          let generator(i) = halton-2-3(i + seed)

          let points = hilbert-point-sort(
            range(n_points).map(generator).map(
              ((x, y)) => (x, y * ratio )))
          let faces = delaunay-triangulate(points)
          for (i, (f1, f2, f3)) in faces.enumerate() {
            let (v1x, v1y) = points.at(f1)
            let (v2x, v2y) = points.at(f2)
            let (v3x, v3y) = points.at(f3)
            let (noise_x, noise_y) = r2-sequence(i + seed)
            let t = calc.abs((noise_x - 0.5) * 0.1 + calc.max(v1y, v2y, v3y) / ratio)
            let v = calc.abs(calc.fract((noise_y - 0.5) * 0.1 + calc.max(v1x, v2x, v3x)))
            let w = calc.pow(t, 1.5) * calc.pow(v, 0.5)
            let c = color.mix(
              (main-color.rotate(0deg).lighten(20%), 100% * w),
              (back-color, 100% * (1. - w)),
            )
            place(top + left,
              dy: - 5pt,
              polygon(
                (v1x * width, v1y * width),
                (v2x * width, v2y * width),
                (v3x * width, v3y * width),
                stroke: c + 0.1pt,
                fill : c,
              ))
          }
          let color = main-color.lighten(100%)

          strong(text(color)[
            #h(0.5em)
            #linguify(
              "letter-position-pretext",
              from: lang-data,
            ) #job-position
            <letter-heading>
          ])
        })
      ]
    }
    text(weight: "light", fill: secondary-color)[
      #if dear == "" [
        #linguify("dear", from: lang-data)
      ] else [
        #dear
      ]
      #addressee,
    ]
  }

  let signature = [
    #text(weight: "light", fill: secondary-color)[#linguify("sincerely", from: lang-data)#if (
      language != "de"
    ) [#sym.comma]] \
    #block(above: 1.5em, below: 1em)[
      #text(main-color, weight: "bold")[#author.firstname #author.lastname]
      #box(width: 1fr, line(length: 100%, stroke: main-color))
    ]
  ]

  letter-heading
  {
    set text(weight: 300)
    set par(spacing: 2em)
    body
  }
  signature
  closing
}
