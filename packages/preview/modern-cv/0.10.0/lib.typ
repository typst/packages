#import "@preview/fontawesome:0.6.0": *
#import "@preview/linguify:0.5.0": *

// const color
#let color-darknight = rgb("#131A28")
#let color-darkgray = rgb("#333333")
#let color-gray = rgb("#5d5d5d")
#let default-accent-color = rgb("#262F99")
#let default-location-color = rgb("#333333")

// const icons
#let linkedin-icon = box(fa-icon("linkedin", fill: color-darknight))
#let github-icon = box(fa-icon("github", fill: color-darknight))
#let gitlab-icon = box(fa-icon("gitlab", fill: color-darknight))
#let bitbucket-icon = box(fa-icon("bitbucket", fill: color-darknight))
#let twitter-icon = box(fa-icon("twitter", fill: color-darknight))
#let bluesky-icon = box(fa-icon("bluesky", fill: color-darknight))
#let mastodon-icon = box(fa-icon("mastodon", fill: color-darknight))
#let google-scholar-icon = box(fa-icon("google-scholar", fill: color-darknight))
#let orcid-icon = box(fa-icon("orcid", fill: color-darknight))
#let phone-icon = box(fa-icon("square-phone", fill: color-darknight))
#let email-icon = box(fa-icon("envelope", fill: color-darknight))
#let birth-icon = box(fa-icon("cake", fill: color-darknight))
#let homepage-icon = box(fa-icon("home", fill: color-darknight))
#let website-icon = box(fa-icon("globe", fill: color-darknight))
#let address-icon = box(fa-icon("location-crosshairs", fill: color-darknight))


/// Helpers

// Common helper functions
#let __format_author_name(author, language) = {
  if language == "zh" or language == "ja" {
    str(author.lastname) + str(author.firstname)
  } else {
    str(author.firstname) + " " + str(author.lastname)
  }
}

#let __apply_smallcaps(content, use-smallcaps) = {
  if use-smallcaps {
    smallcaps(content)
  } else {
    content
  }
}

// layout utility
#let __justify_align(left_body, right_body) = {
  block[
    #left_body
    #box(width: 1fr)[
      #align(right)[
        #right_body
      ]
    ]
  ]
}

#let __justify_align_3(left_body, mid_body, right_body) = {
  block[
    #box(width: 1fr)[
      #align(left)[
        #left_body
      ]
    ]
    #box(width: 1fr)[
      #align(center)[
        #mid_body
      ]
    ]
    #box(width: 1fr)[
      #align(right)[
        #right_body
      ]
    ]
  ]
}

#let __coverletter_footer(
  author,
  language,
  date,
  lang_data,
  use-smallcaps: true,
) = {
  set text(fill: gray, size: 8pt)
  __justify_align_3[
    #__apply_smallcaps(date, use-smallcaps)
  ][
    #__apply_smallcaps(
      {
        let name = __format_author_name(author, language)
        name + " · " + linguify("cover-letter", from: lang_data)
      },
      use-smallcaps,
    )
  ][
    #context {
      counter(page).display()
    }
  ]
}

#let __resume_footer(author, language, lang_data, date, use-smallcaps: true) = {
  set text(fill: gray, size: 8pt)
  __justify_align_3[
    #__apply_smallcaps(date, use-smallcaps)
  ][
    #__apply_smallcaps(
      {
        let name = __format_author_name(author, language)
        name + " · " + linguify("resume", from: lang_data)
      },
      use-smallcaps,
    )
  ][
    #context {
      counter(page).display()
    }
  ]
}

// Helper for contact items in the header.
// - item (dictionary): The contact item with the following fields: text (string, required), icon (box, optional), link (string, optional)
// - link-prefix (string): The prefix to use for the link (e.g. "mailto:")
// - inset (dictionary): Inset of each individual contact item
#let __contact_item(item, link-prefix: "", inset: (:)) = {
  box[
    #set align(bottom)
    #if ("icon" in item) {
      [#item.icon]
    }
    // Then modify the selection to use the constant:
    #box(inset: inset)[
      #if ("link" in item) {
        link(link-prefix + item.link)[#item.text]
      } else {
        item.text
      }
    ]
  ]
}

/// Format contact items with the respective Font Awesome icon and return them as list
///
/// - author (dictionary): The dictionary containing the contact item values
/// - item-inset (dictionary): Inset of each individual contact item
/// -> array (of content)
#let __format_contact_items(author, item-inset: (:)) = {
  let contact-item(item, link-prefix: "") = {
    __contact_item(item, link-prefix: link-prefix, inset: item-inset)
  }

  let items = ()

  if "birth" in author {
    items.push(
      contact-item(
        (text: author.birth, icon: birth-icon),
      ),
    )
  }
  if "phone" in author {
    items.push(
      contact-item(
        (text: author.phone, icon: phone-icon, link: author.phone),
        link-prefix: "tel:",
      ),
    )
  }
  if "email" in author {
    items.push(
      contact-item(
        (text: author.email, icon: email-icon, link: author.email),
        link-prefix: "mailto:",
      ),
    )
  }
  if "homepage" in author {
    items.push(
      contact-item(
        (text: author.homepage, icon: homepage-icon, link: author.homepage),
      ),
    )
  }
  if "github" in author {
    items.push(
      contact-item(
        (text: author.github, icon: github-icon, link: author.github),
        link-prefix: "https://github.com/",
      ),
    )
  }
  if "gitlab" in author {
    items.push(
      contact-item(
        (text: author.gitlab, icon: gitlab-icon, link: author.gitlab),
        link-prefix: "https://gitlab.com/",
      ),
    )
  }
  if "bitbucket" in author {
    items.push(
      contact-item(
        (text: author.bitbucket, icon: bitbucket-icon, link: author.bitbucket),
        link-prefix: "https://bitbucket.org/",
      ),
    )
  }
  if "linkedin" in author {
    items.push(
      contact-item(
        (
          text: author.firstname + " " + author.lastname,
          icon: linkedin-icon,
          link: author.linkedin,
        ),
        link-prefix: "https://www.linkedin.com/in/",
      ),
    )
  }
  if "twitter" in author {
    items.push(
      contact-item(
        (text: "@" + author.twitter, icon: twitter-icon, link: author.twitter),
        link-prefix: "https://twitter.com/",
      ),
    )
  }
  if "bluesky" in author {
    items.push(
      contact-item(
        (text: "@" + author.bluesky, icon: bluesky-icon, link: author.bluesky),
        link-prefix: "https://bsky.app/profile/",
      ),
    )
  }
  if "mastodon" in author {
    items.push(
      contact-item(
        (
          text: "@" + author.mastodon,
          icon: mastodon-icon,
          link: author.mastodon,
        ),
        link-prefix: "https://mastodon.social/@",
      ),
    )
  }
  if "scholar" in author {
    let fullname = str(author.firstname + " " + author.lastname)
    items.push(
      contact-item(
        (text: fullname, icon: google-scholar-icon, link: author.scholar),
        link-prefix: "https://scholar.google.com/citations?user=",
      ),
    )
  }
  if "orcid" in author {
    items.push(
      contact-item(
        (text: author.orcid, icon: orcid-icon, link: author.orcid),
        link-prefix: "https://orcid.org/",
      ),
    )
  }
  if "website" in author {
    items.push(
      contact-item(
        (text: author.website, icon: website-icon, link: author.website),
      ),
    )
  }
  if "custom" in author and type(author.custom) == array {
    for item in author.custom {
      if "text" in item {
        items.push(
          contact-item(
            (
              text: item.text,
              icon: if ("icon" in item) {
                box(fa-icon(item.icon, fill: color-darknight))
              } else {
                none
              },
              link: if ("link" in item) {
                item.link
              } else {
                none
              },
            ),
            link-prefix: "",
          ),
        )
      }
    }
  }

  items
}

/// Show a link with an icon, specifically for Github projects
/// *Example*
/// #example(`resume.github-link("ptsouchlos/awesome-resume")`)
/// - github-path (string): The path to the Github project (e.g. "ptsouchlos/awesome-resume")
/// -> none
#let github-link(github-path) = {
  set box(height: 11pt)

  align(right + horizon)[
    #fa-icon("github", fill: color-darkgray) #h(2pt) #link(
      "https://github.com/" + github-path,
      github-path,
    )
  ]
}

/// Right section for the justified headers
/// - body (content): The body of the right header
#let secondary-right-header(body) = {
  set text(size: 11pt, weight: "medium")
  body
}

/// Right section of a tertiaty headers.
/// - body (content): The body of the right header
#let tertiary-right-header(body) = {
  set text(weight: "light", size: 9pt)
  body
}

/// Justified header that takes a primary section and a secondary section. The primary section is on the left and the secondary section is on the right.
/// - primary (content): The primary section of the header
/// - secondary (content): The secondary section of the header
#let justified-header(primary, secondary) = {
  set block(above: 0.7em, below: 0.7em)
  pad[
    #__justify_align[
      == #primary
    ][
      #secondary-right-header[#secondary]
    ]
  ]
}

/// Justified header that takes a primary section and a secondary section. The primary section is on the left and the secondary section is on the right. This is a smaller header compared to the `justified-header`.
/// - primary (content): The primary section of the header
/// - secondary (content): The secondary section of the header
#let secondary-justified-header(primary, secondary) = {
  __justify_align[
    === #primary
  ][
    #tertiary-right-header[#secondary]
  ]
}
/// --- End of Helpers

/// ---- Resume Template ----

/// Resume template that is inspired by the Awesome CV Latex template by posquit0. This template can loosely be considered a port of the original Latex template.
///
/// The original template: https://github.com/posquit0/Awesome-CV
///
/// - author (dictionary): Structure that takes in all the author's information
/// - profile-picture (image): The profile picture of the author. This will be cropped to a circle and should be square in nature.
/// - contact-items-separator (content): Separator to use between the "contact" items in the header of the resume. This includes items like your email, website, Github account, phone number and so on. The default is blank spacing.
/// - contact-items-inset (dictionary): Gap between contact item icon and contact item text.
/// - date (string): The date the resume was created
/// - accent-color (color): The accent color of the resume
/// - colored-headers (boolean): Whether the headers should be colored or not
/// - language (string): The language of the resume, defaults to "en". See lang.toml for available languages
/// - use-smallcaps (boolean): Whether to use small caps formatting throughout the template
/// - show-address-icon (boolean): Whether to show the address icon
/// - description (str | none): The PDF description
/// - keywords (array | str): The PDF keywords
/// - body (content): The body of the resume
/// -> none
#let resume(
  author: (:),
  profile-picture: image,
  contact-items-separator: h(10pt),
  contact-items-inset: (left: 4pt),
  date: datetime.today().display("[month repr:long] [day], [year]"),
  accent-color: default-accent-color,
  colored-headers: true,
  show-footer: true,
  language: "en",
  font: ("Source Sans 3", "Source Sans Pro"),
  header-font: "Roboto",
  paper-size: "a4",
  use-smallcaps: true,
  show-address-icon: false,
  description: none,
  keywords: (),
  body,
) = {
  if type(accent-color) == str {
    accent-color = rgb(accent-color)
  }

  let lang_data = toml("lang.toml")

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

  show: body => context {
    set document(
      author: author.firstname + " " + author.lastname,
      title: lflib._linguify("resume", lang: language, from: lang_data).ok,
      description: desc,
      keywords: keywords,
    )
    body
  }

  set text(
    font: font,
    lang: language,
    size: 11pt,
    fill: color-darkgray,
    fallback: true,
  )

  set page(
    paper: paper-size,
    margin: (
      left: 15mm,
      right: 15mm,
      top: 10mm,
      bottom: if show-footer { 20mm } else { 10mm },
    ),
    footer: if show-footer [#__resume_footer(
      author,
      language,
      lang_data,
      date,
      use-smallcaps: use-smallcaps,
    )] else [],
    footer-descent: 35%,
  )

  // set paragraph spacing
  set par(spacing: 0.75em, justify: true)

  set heading(numbering: none, outlined: false)

  show heading.where(level: 1): it => block(sticky: true)[
    #set text(size: 16pt, weight: "regular")
    #set align(left)
    #set block(above: 1em)
    #let color = if colored-headers {
      accent-color
    } else {
      color-darkgray
    }
    #text[#strong[#text(color)[#it.body]]]
    #box(width: 1fr, line(length: 100%))
  ]

  show heading.where(level: 2): it => {
    set text(color-darkgray, size: 12pt, style: "normal", weight: "bold")
    it.body
  }

  show heading.where(level: 3): it => {
    set text(size: 10pt, weight: "regular")
    __apply_smallcaps(it.body, use-smallcaps)
  }

  let name = {
    align(center)[
      #pad(bottom: 5pt)[
        #block[
          #set text(size: 32pt, style: "normal", font: header-font)
          #if language == "zh" or language == "ja" [
            #text(accent-color, weight: "bold")[#author.lastname]#text(
              weight: "thin",
            )[#author.firstname]
          ] else [
            #text(accent-color, weight: "thin")[#author.firstname]
            #text(weight: "bold")[#author.lastname]
          ]
        ]
      ]
    ]
  }

  let positions = {
    set text(accent-color, size: 9pt, weight: "regular")
    align(center)[
      #__apply_smallcaps(
        author.positions.join(text[#"  "#sym.dot.c#"  "]),
        use-smallcaps,
      )
    ]
  }

  let address = {
    set text(size: 9pt, weight: "regular")
    align(center)[
      #if ("address" in author) [
        #if show-address-icon [
          #__contact_item(
            (
              icon: address-icon,
              text: text(author.address),
            ),
            inset: contact-items-inset,
          )
        ] else [
          #text(author.address)
        ]
      ]
    ]
  }

  // Contact section
  let contacts = {
    set box(height: 9pt)
    set text(size: 9pt, weight: "regular", style: "normal")

    let items = __format_contact_items(author, item-inset: contact-items-inset)
    align(center, items.join(contact-items-separator))
  }

  if profile-picture != none {
    grid(
      columns: (100% - 4cm, 4cm),
      rows: 100pt,
      gutter: 10pt,
      [
        #name
        #positions
        #address
        #contacts
      ],
      align(left + horizon)[
        #block(
          clip: true,
          stroke: 0pt,
          radius: 2cm,
          width: 4cm,
          height: 4cm,
          profile-picture,
        )
      ],
    )
  } else {
    name
    positions
    address
    contacts
  }

  body
}

/// The base item for resume entries.
/// This formats the item for the resume entries. Typically your body would be a bullet list of items. Could be your responsibilities at a company or your academic achievements in an educational background section.
/// - body (content): The body of the resume entry
#let resume-item(body) = {
  set text(size: 10pt, style: "normal", weight: "light", fill: color-darknight)
  set block(above: 0.75em, below: 1.25em)
  set par(leading: 0.65em)
  block(above: 0.5em)[
    #body
  ]
}

/// The base item for resume entries. This formats the item for the resume entries. Typically your body would be a bullet list of items. Could be your responsibilities at a company or your academic achievements in an educational background section.
/// - title (string): The title of the resume entry
/// - location (string): The location of the resume entry
/// - date (string): The date of the resume entry, this can be a range (e.g. "Jan 2020 - Dec 2020")
/// - description (content): The body of the resume entry
/// - title-link (string): The link to use for the title (can be none)
/// - accent-color (color): Override the accent color of the resume-entry
/// - location-color (color): Override the default color of the "location" for a resume entry.
#let resume-entry(
  title: none,
  location: "",
  date: "",
  description: "",
  title-link: none,
  accent-color: default-accent-color,
  location-color: default-location-color,
) = {
  let title-content
  if type(title-link) == str {
    title-content = link(title-link)[#title]
  } else {
    title-content = title
  }
  block(above: 1em, below: 0.65em, sticky: true)[
    #pad[
      #justified-header(title-content, location)
      #if description != "" or date != "" [
        #secondary-justified-header(description, date)
      ]
    ]
  ]
}

/// Show cumulative GPA.
/// *Example:*
/// #example(`resume.resume-gpa("3.5", "4.0")`)
#let resume-gpa(numerator, denominator) = {
  set text(size: 12pt, style: "italic", weight: "light")
  text[Cumulative GPA: #box[#strong[#numerator] / #denominator]]
}

/// Show a certification in the resume.
/// *Example:*
/// #example(`resume.resume-certification("AWS Certified Solutions Architect - Associate", "Jan 2020")`)
/// - certification (content): The certification
/// - date (content): The date the certification was achieved
#let resume-certification(certification, date) = {
  justified-header(certification, date)
}

/// Styling for resume skill categories.
/// - category (string): The category
#let resume-skill-category(category) = {
  set text(size: 11pt, style: "normal", weight: "bold", hyphenate: false)
  category
}

/// Styling for resume skill values/items
/// - values (array): The skills to display
#let resume-skill-values(values) = {
  set text(size: 11pt, style: "normal", weight: "light")
  // This is a list so join by comma (,)
  values.join(", ")
}

/// Show a list of skills in the resume under a given category.
/// - category (string): The category of the skills
/// - items (list): The list of skills. This can be a list of strings but you can also emphasize certain skills by using the `strong` function.
#let resume-skill-item(category, items) = {
  set block(below: 0.65em)
  set pad(top: 2pt)

  pad[
    #grid(
      columns: (3fr, 8fr),
      gutter: 10pt,
      align: left + top,
      resume-skill-category(category), resume-skill-values(items),
    )
  ]
}

/// Show a grid of skill lists with each row corresponding to a category of skills, followed by the skills themselves. The dictionary given to this function should have the skill categories as the dictionary keys and the values should be an array of values for the corresponding key.
/// - categories-with-values (dictionary): key value pairs of skill categories and it's corresponding values (skills)
#let resume-skill-grid(categories-with-values: (:)) = {
  set block(below: 1.25em)
  set pad(top: 2pt)

  pad[
    #grid(
      columns: (auto, auto),
      gutter: 10pt,
      align: left + top,
      ..categories-with-values
        .pairs()
        .map(((key, value)) => (
          resume-skill-category(key),
          resume-skill-values(value),
        ))
        .flatten()
    )
  ]
}

/// ---- End of Resume Template ----

/// ---- Coverletter ----

/// Default signature for the cover letter template.
/// - lang-data (dictionary): Structure that contains all the language data. Used with `linguify`
/// - language (string): The language of the cover letter.
/// - author (string): The author of the cover letter.
/// - alignment (alignment): Alignment of the signature.
/// - padding (dictionary): Padding of the signature.
#let default-signature(lang-data, language, author, alignment, padding) = {
  align(alignment, pad(..padding)[
    #text(weight: "light")[#linguify("sincerely", from: lang-data)#if (
        language != "de"
      ) [#sym.comma]] \
    #if ("signature" in author) {
      author.signature
    } \
    #text(weight: "bold")[#author.firstname #author.lastname]
  ])
}

#let default-closing(lang-data) = {
  align(bottom)[
    #text(weight: "light", style: "italic")[
      #linguify("attached", from: lang-data)#sym.colon #linguify(
        "curriculum-vitae",
        from: lang-data,
      )]
  ]
}

#let default-par = (spacing: 0.75em, justify: true)

/// Cover letter template that is inspired by the Awesome CV Latex template by posquit0. This template can loosely be considered a port of the original Latex template.
/// This coverletter template is designed to be used with the resume template.
/// - author (dictionary): Structure that takes in all the author's information. The following fields are required: firstname, lastname, positions. The following fields are used if available: email, phone, github, linkedin, orcid, address, website, custom. The `custom` field is an array of additional entries with the following fields: text (string, required), icon (string, optional Font Awesome icon name), link (string, optional).
/// - profile-picture (image): The profile picture of the author. This will be cropped to a circle and should be square in nature.
/// - contact-items-separator (content): Separator to use between the "contact" items in the header of the coverletter. This includes items like your email, website, Github account, phone number and so on. The default is blank spacing.
/// - contact-items-inset (dictionary): Gap between contact item icon and contact item text.
/// - heading-padding (dictionary): Padding of the salutation line.
/// - signature-padding (dictionary): Padding of the signature.
/// - signature-alignment (alignment): Alignment of the signature.
/// - par-spacing (length): Spacing between paragraphs of the letter content.
/// - date (datetime): The date the cover letter was created. This will default to the current date.
/// - accent-color (color): The accent color of the cover letter
/// - language (string): The language of the cover letter, defaults to "en". See lang.toml for available languages
/// - font (array): The font families of the cover letter
/// - header-font (array): The font families of the cover letter header
/// - show-footer (boolean): Whether to show the footer or not
/// - signaure (content): The signature of the cover letter. You can set this to `none` to show the default signature or remove it completely.
/// - closing (content): The closing of the cover letter. This defaults to "Attached Curriculum Vitae". You can set this to `none` to show the default closing or remove it completely.
/// - use-smallcaps (boolean): Whether to use small caps formatting throughout the template
/// - show-address-icon (boolean): Whether to show the address icon
/// - description (str | none): The PDF description
/// - keywords (array | str): The PDF keywords
/// - body (content): The body of the cover letter
#let coverletter(
  author: (:),
  profile-picture: image,
  contact-items-separator: box(width: 6pt, align(center, sym.bar.v)),
  contact-items-inset: (:),
  heading-padding: (above: 2em, below: 1em),
  signature-padding: (top: 1em),
  signature-alignment: left,
  par-spacing: 1.5em,
  date: datetime.today().display("[month repr:long] [day], [year]"),
  accent-color: default-accent-color,
  language: "en",
  font: ("Source Sans 3", "Source Sans Pro"),
  header-font: "Roboto",
  show-footer: true,
  signature: none,
  closing: none,
  paper-size: "a4",
  use-smallcaps: true,
  show-address-icon: false,
  description: none,
  keywords: (),
  body,
) = {
  if type(accent-color) == str {
    accent-color = rgb(accent-color)
  }

  // language data
  let lang_data = toml("lang.toml")

  if signature == none {
    signature = default-signature(
      lang_data,
      language,
      author,
      signature-alignment,
      signature-padding,
    )
  }

  if closing == none {
    closing = default-closing(lang_data)
  }

  let desc = if description == none {
    (
      lflib._linguify("cover-letter", lang: language, from: lang_data).ok
        + " "
        + author.firstname
        + " "
        + author.lastname
    )
  } else {
    description
  }

  show: body => context {
    set document(
      author: author.firstname + " " + author.lastname,
      title: lflib
        ._linguify("cover-letter", lang: language, from: lang_data)
        .ok,
      description: desc,
      keywords: keywords,
    )
    body
  }

  set text(
    font: font,
    lang: language,
    size: 11pt,
    fill: color-darkgray,
    fallback: true,
  )

  set page(
    paper: paper-size,
    margin: (
      left: 15mm,
      right: 15mm,
      top: 10mm,
      bottom: if show-footer { 20mm } else { 10mm },
    ),
    footer: if show-footer [#__coverletter_footer(
      author,
      language,
      date,
      lang_data,
      use-smallcaps: use-smallcaps,
    )] else [],
    footer-descent: 35%,
  )

  // set paragraph spacing
  set par(..default-par)

  set heading(numbering: none, outlined: false)

  show heading: it => block(..heading-padding)[
    #set text(size: 16pt, weight: "regular")

    #align(left)[
      #text[#strong[#text(accent-color)[#it.body]]]
      #box(width: 1fr, line(length: 100%))
    ]
  ]

  let name = {
    align(right)[
      #pad(bottom: 5pt)[
        #block[
          #set text(size: 32pt, style: "normal", font: header-font)
          #if language == "zh" or language == "ja" [
            #text(accent-color, weight: "bold")[#author.lastname]#text(
              weight: "bold",
            )[#author.firstname]
          ] else [
            #text(accent-color, weight: "thin")[#author.firstname]
            #text(weight: "bold")[#author.lastname]
          ]

        ]
      ]
    ]
  }

  let positions = {
    set text(accent-color, size: 9pt, weight: "regular")
    align(right)[
      #__apply_smallcaps(
        author.positions.join(text[#"  "#sym.dot.c#"  "]),
        use-smallcaps,
      )
    ]
  }

  let address = {
    set text(size: 9pt, weight: "bold", fill: color-gray)
    align(right)[
      #if ("address" in author) [
        #if show-address-icon [
          #__contact_item(
            (
              icon: address-icon,
              text: text(author.address),
            ),
            inset: contact-items-inset,
          )
        ] else [
          #text(author.address)
        ]
      ]
    ]
  }

  let contacts = {
    set text(size: 8pt, weight: "light", style: "normal")

    let items = __format_contact_items(author)
    align(right, items.join(contact-items-separator))
  }

  let letter-heading = {
    grid(
      columns: (1fr, 2fr),
      rows: 100pt,
      align(left + horizon)[
        #block(
          clip: true,
          stroke: 0pt,
          radius: 2cm,
          width: 4cm,
          height: 4cm,
          profile-picture,
        )
      ],
      [
        #name
        #positions
        #address
        #contacts
      ],
    )
  }

  // actual content
  letter-heading
  {
    set par(spacing: par-spacing)
    set text(weight: "light")
    body
  }
  signature
  closing
}

/// Cover letter heading that takes in the information for the hiring company and formats it properly.
/// - entity-info (content): The information of the hiring entity including the company name, the target (who's attention to), street address, and city
/// - date (date): The date the letter was written (defaults to the current date)
#let hiring-entity-info(
  entity-info: (:),
  date: datetime.today().display("[month repr:long] [day], [year]"),
  use-smallcaps: true,
) = {
  set par(leading: 1em, ..default-par)
  pad(top: 1.5em, bottom: 1.5em)[
    #__justify_align[
      #text(weight: "bold", size: 12pt)[#entity-info.target]
    ][
      #text(weight: "light", style: "italic", size: 9pt)[#date]
    ]

    #pad(top: 0.65em, bottom: 0.65em)[
      #text(weight: "regular", fill: color-gray, size: 9pt)[
        #__apply_smallcaps(entity-info.name, use-smallcaps) \
        #entity-info.street-address \
        #entity-info.city \
      ]
    ]
  ]
}

/// Letter heading for a given job position and addressee.
/// - job-position (string): The job position you are applying for
/// - addressee (string): The person you are addressing the letter to
/// - dear (string): optional field for redefining the "dear" variable
/// - padding (dictionary): Padding of the heading line
#let letter-heading(
  job-position: "",
  addressee: "",
  dear: "",
  padding: (top: 1em, bottom: 1em),
) = {
  set par(..default-par)
  let lang_data = toml("lang.toml")

  // TODO: Make this adaptable to content
  underline(evade: false, stroke: 0.5pt, offset: 0.3em)[
    #text(weight: "bold", size: 12pt)[#linguify(
        "letter-position-pretext",
        from: lang_data,
      ) #job-position]
  ]
  pad(..padding)[
    #text(weight: "light", fill: color-gray)[
      #if dear == "" [
        #linguify("dear", from: lang_data)
      ] else [
        #dear
      ]
      #addressee,
    ]
  ]
}

/// ---- End of Coverletter ----
