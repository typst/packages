/*
* Functions for the CV template
*/

#import "@preview/fontawesome:0.2.1": *
#import "./utils/injection.typ": inject
#import "./utils/styles.typ": latinFontList, latinHeaderFont, awesomeColors, regularColors, setAccentColor, hBar
#import "./utils/lang.typ": isNonLatin, defaultDateWidth

/// Insert the header section of the CV.
///
/// - metadata (array): the metadata read from the TOML file.
/// - headerFont (array): the font of the header.
/// - regularColors (array): the regular colors of the CV.
/// - awesomeColors (array): the awesome colors of the CV.
/// -> content
#let _cvHeader(
  metadata,
  profilePhoto,
  headerFont,
  regularColors,
  awesomeColors,
) = {
  // Parameters
  let hasPhoto = metadata.layout.header.display_profile_photo
  let align = eval(metadata.layout.header.header_align)
  let if_inject_ai_prompt = metadata.inject.inject_ai_prompt
  let if_inject_keywords = metadata.inject.inject_keywords
  let keywords_list = metadata.inject.injected_keywords_list
  let personalInfo = metadata.personal.info
  let firstName = metadata.personal.first_name
  let lastName = metadata.personal.last_name
  let headerQuote = metadata.lang.at(metadata.language).at("header_quote", default: none)
  let displayProfilePhoto = metadata.layout.header.display_profile_photo
  let headerInfoFontSize = eval(metadata.layout.header.at("info_font_size", default: "10pt"))
  let accentColor = setAccentColor(awesomeColors, metadata)
  let nonLatinName = ""
  let nonLatin = isNonLatin(metadata.language)
  if nonLatin {
    nonLatinName = metadata.lang.non_latin.name
  }

  // Injection
  inject(
    if_inject_ai_prompt: if_inject_ai_prompt,
    if_inject_keywords: if_inject_keywords,
    keywords_list: keywords_list,
  )

  // Styles
  let headerFirstNameStyle(str) = {
    text(
      font: headerFont,
      size: 32pt,
      weight: "light",
      fill: regularColors.darkgray,
      str,
    )
  }
  let headerLastNameStyle(str) = {
    text(font: headerFont, size: 32pt, weight: "bold", str)
  }
  let headerInfoStyle(str) = {
    text(size: headerInfoFontSize, fill: accentColor, str)
  }
  let headerQuoteStyle(str) = {
    text(size: 10pt, weight: "medium", style: "italic", fill: accentColor, str)
  }

  // Components
  let makeHeaderInfo() = {
    let personalInfoIcons = (
      phone: fa-phone(),
      email: fa-envelope(),
      linkedin: fa-linkedin(),
      homepage: fa-pager(),
      github: fa-square-github(),
      gitlab: fa-gitlab(),
      orcid: fa-orcid(),
      researchgate: fa-researchgate(),
      location: fa-location-dot(),
      extraInfo: "",
    )
    let n = 1
    for (k, v) in personalInfo {
      // A dirty trick to add linebreaks with "linebreak" as key in personalInfo
      if k == "linebreak" {
        n = 0
        linebreak()
        continue
      }
      if k.contains("custom") {
        let img = v.at("image", default: "")
        let awesomeIcon = v.at("awesomeIcon", default: "")
        let text = v.at("text", default: "")
        let link_value = v.at("link", default: "")
        let icon = ""
        if img != "" {
          icon = img.with(width: 10pt)
        } else {
          icon = fa-icon(awesomeIcon)
        }
        box({
          icon
          h(5pt)
          link(link_value)[#text]
        })
      } else if v != "" {
        box({
          // Adds icons
          personalInfoIcons.at(k)
          h(5pt)
          // Adds hyperlinks
          if k == "email" {
            link("mailto:" + v)[#v]
          } else if k == "linkedin" {
            link("https://www.linkedin.com/in/" + v)[#v]
          } else if k == "github" {
            link("https://github.com/" + v)[#v]
          } else if k == "gitlab" {
            link("https://gitlab.com/" + v)[#v]
          } else if k == "homepage" {
            link("https://" + v)[#v]
          } else if k == "orcid" {
            link("https://orcid.org/" + v)[#v]
          } else if k == "researchgate" {
            link("https://www.researchgate.net/profile/" + v)[#v]
          } else {
            v
          }
        })
      }
      // Adds hBar
      if n != personalInfo.len() {
        hBar()
      }
      n = n + 1
    }
  }

  let makeHeaderNameSection() = table(
    columns: 1fr,
    inset: 0pt,
    stroke: none,
    row-gutter: 6mm,
    if nonLatin {
      headerFirstNameStyle(nonLatinName)
    } else [#headerFirstNameStyle(firstName) #h(5pt) #headerLastNameStyle(lastName)],
    [#headerInfoStyle(makeHeaderInfo())],
    .. if headerQuote != none { ([#headerQuoteStyle(headerQuote)],) },
  )

  let makeHeaderPhotoSection() = {
    set image(height: 3.6cm)
    if displayProfilePhoto {
      box(profilePhoto, radius: 50%, clip: true)
    } else {
      v(3.6cm)
    }
  }

  let makeHeader(leftComp, rightComp, columns, align) = table(
    columns: columns,
    inset: 0pt,
    stroke: none,
    column-gutter: 15pt,
    align: align + horizon,
    {
      leftComp
    },
    {
      rightComp
    },
  )

  if hasPhoto {
    makeHeader(
      makeHeaderNameSection(),
      makeHeaderPhotoSection(),
      (auto, 20%),
      align,
    )
  } else {
    makeHeader(
      makeHeaderNameSection(),
      makeHeaderPhotoSection(),
      (auto, 0%),
      align,
    )
  }
}

/// Insert the footer section of the CV.
///
/// - metadata (array): the metadata read from the TOML file.
/// -> content
#let _cvFooter(metadata) = {
  // Parameters
  let firstName = metadata.personal.first_name
  let lastName = metadata.personal.last_name
  let footerText = metadata.lang.at(metadata.language).cv_footer

  // Styles
  let footerStyle(str) = {
    text(size: 8pt, fill: rgb("#999999"), smallcaps(str))
  }

  return table(
    columns: (1fr, auto),
    inset: -5pt,
    stroke: none,
    footerStyle([#firstName #lastName]), footerStyle(footerText),
  )

}

/// Add the title of a section.
///
/// NOTE: If the language is non-Latin, the title highlight will not be sliced.
///
/// - title (str): The title of the section.
/// - highlighted (bool): Whether the first n letters will be highlighted in accent color.
/// - letters (int): The number of first letters of the title to highlight.
/// - metadata (array): (optional) the metadata read from the TOML file.
/// - awesomeColors (array): (optional) the awesome colors of the CV.
/// -> content
#let cvSection(
  title,
  highlighted: true,
  letters: 3,
  metadata: metadata,
  awesomeColors: awesomeColors,
) = {
  let lang = metadata.language
  let nonLatin = isNonLatin(lang)
  let beforeSectionSkip = eval(
    metadata.layout.at("before_section_skip", default: 1pt),
  )
  let accentColor = setAccentColor(awesomeColors, metadata)
  let highlightText = title.slice(0, letters)
  let normalText = title.slice(letters)
  let sectionTitleStyle(str, color: black) = {
    text(size: 16pt, weight: "bold", fill: color, str)
  }

  v(beforeSectionSkip)
  if nonLatin {
    sectionTitleStyle(title, color: accentColor)
  } else {
    if highlighted {
      sectionTitleStyle(highlightText, color: accentColor)
      sectionTitleStyle(normalText, color: black)
    } else {
      sectionTitleStyle(title, color: black)
    }
  }
  h(2pt)
  box(width: 1fr, line(stroke: 0.9pt, length: 100%))
}

/// Add an entry to the CV.
///
/// - title (str): The title of the entry.
/// - society (str): The society of the entry (company, university, etc.).
/// - date (str | content): The date(s) of the entry.
/// - location (str): The location of the entry.
/// - description (array): The description of the entry. It can be a string or an array of strings.
/// - logo (image): The logo of the society. If empty, no logo will be displayed.
/// - tags (array): The tags of the entry.
/// - metadata (array): (optional) the metadata read from the TOML file.
/// - awesomeColors (array): (optional) the awesome colors of the CV.
/// -> content
#let cvEntry(
  title: "Title",
  society: "Society",
  date: "Date",
  location: "Location",
  description: "Description",
  logo: "",
  tags: (),
  metadata: metadata,
  awesomeColors: awesomeColors,
) = {
  let accentColor = setAccentColor(awesomeColors, metadata)
  let beforeEntrySkip = eval(
    metadata.layout.at("before_entry_skip", default: 1pt),
  )
  let beforeEntryDescriptionSkip = eval(
    metadata.layout.at("before_entry_description_skip", default: 1pt),
  )
  let dateWidth = metadata.layout.at("date_width", default: none)
  let dateWidth = if dateWidth == none {
    defaultDateWidth(metadata.language)
  } else {
    eval(dateWidth)
  }

  let entryA1Style(str) = {
    text(size: 10pt, weight: "bold", str)
  }
  let entryA2Style(str) = {
    align(
      right,
      text(weight: "medium", fill: accentColor, style: "oblique", str),
    )
  }
  let entryB1Style(str) = {
    text(size: 8pt, fill: accentColor, weight: "medium", smallcaps(str))
  }
  let entryB2Style(str) = {
    align(
      right,
      text(size: 8pt, weight: "medium", fill: gray, style: "oblique", str),
    )
  }
  let entryDatesStyle(dates) = {
    [
      #set list(marker: [])
      #dates
    ]
  }
  let entryDescriptionStyle(str) = {
    text(
      fill: regularColors.lightgray,
      {
        v(beforeEntryDescriptionSkip)
        str
      },
    )
  }
  let entryTagStyle(str) = {
    align(center, text(size: 8pt, weight: "regular", str))
  }
  let entryTagListStyle(tags) = {
    for tag in tags {
      box(
        inset: (x: 0.25em),
        outset: (y: 0.25em),
        fill: regularColors.subtlegray,
        radius: 3pt,
        entryTagStyle(tag),
      )
      h(5pt)
    }
  }

  let ifSocietyFirst(condition, field1, field2) = {
    return if condition {
      field1
    } else {
      field2
    }
  }
  let ifLogo(path, ifTrue, ifFalse) = {
    return if metadata.layout.entry.display_logo {
      if path == "" {
        ifFalse
      } else {
        ifTrue
      }
    } else {
      ifFalse
    }
  }
  let setLogoContent(path) = {
    return if logo == "" [] else {
      set image(width: 100%)
      logo
    }
  }

  v(beforeEntrySkip)
  table(
    columns: (1fr, dateWidth),
    inset: 0pt,
    stroke: none,
    gutter: 6pt,
    align: (x, y) => if x == 1 { right } else { auto },
    {
      table(
        columns: (ifLogo(logo, 4%, 0%), 1fr),
        inset: 0pt,
        stroke: none,
        align: horizon,
        column-gutter: ifLogo(logo, 4pt, 0pt),
        setLogoContent(logo),
        table(
          columns: auto,
          inset: 0pt,
          stroke: none,
          row-gutter: 6pt,
          align: auto,
          {
            entryA1Style(
              ifSocietyFirst(
                metadata.layout.entry.display_entry_society_first,
                society,
                title,
              ),
            )
          },

          {
            entryB1Style(
              ifSocietyFirst(
                metadata.layout.entry.display_entry_society_first,
                title,
                society,
              ),
            )
          },
        ),
      )
      entryDescriptionStyle(description)
      entryTagListStyle(tags)
    },
    table(
      columns: auto,
      inset: 0pt,
      stroke: none,
      row-gutter: 6pt,
      align: auto,
      entryA2Style(
        ifSocietyFirst(
          metadata.layout.entry.display_entry_society_first,
          location,
          entryDatesStyle(date),
        ),
      ),
      entryB2Style(
        ifSocietyFirst(
          metadata.layout.entry.display_entry_society_first,
          entryDatesStyle(date),
          location,
        ),
      ),
    ),
  )
}

/// Add the start of an entry to the CV.
///
/// - society (str): The society of the entry (company, university, etc.).
/// - location (str): The location of the entry.
/// - logo (image): The logo of the society. If empty, no logo will be displayed.
/// - metadata (array): (optional) the metadata read from the TOML file.
/// - awesomeColors (array): (optional) the awesome colors of the CV.
/// -> content
#let cvEntryStart(
  society: "Society",
  location: "Location",
  logo: "",
  metadata: metadata,
  awesomeColors: awesomeColors,
) = {
  // To use cvEntryStart, you need to set display_entry_society_first to true in the metadata.toml file.
  if not metadata.layout.entry.display_entry_society_first {
    panic("display_entry_society_first must be true to use cvEntryStart")
  }

  let accentColor = setAccentColor(awesomeColors, metadata)
  let beforeEntrySkip = eval(
    metadata.layout.at("before_entry_skip", default: 1pt),
  )
  let beforeEntryDescriptionSkip = eval(
    metadata.layout.at("before_entry_description_skip", default: 1pt),
  )
  let dateWidth = metadata.layout.at("date_width", default: none)
  let dateWidth = if dateWidth == none {
    defaultDateWidth(metadata.language)
  } else {
    eval(dateWidth)
  }
  
  let entryA1Style(str) = {
    text(size: 10pt, weight: "bold", str)
  }
  let entryA2Style(str) = {
    align(
      right,
      text(weight: "medium", fill: accentColor, style: "oblique", str),
    )
  }
  let entryDatesStyle(dates) = {
    [
      #set list(marker: [])
      #dates
    ]
  }
  let entryDescriptionStyle(str) = {
    text(
      fill: regularColors.lightgray,
      {
        v(beforeEntryDescriptionSkip)
        str
      },
    )
  }
  let entryTagStyle(str) = {
    align(center, text(size: 8pt, weight: "regular", str))
  }
  let entryTagListStyle(tags) = {
    for tag in tags {
      box(
        inset: (x: 0.25em),
        outset: (y: 0.25em),
        fill: regularColors.subtlegray,
        radius: 3pt,
        entryTagStyle(tag),
      )
      h(5pt)
    }
  }

  let ifSocietyFirst(condition, field1, field2) = {
    return if condition {
      field1
    } else {
      field2
    }
  }
  let ifLogo(path, ifTrue, ifFalse) = {
    return if metadata.layout.entry.display_logo {
      if path == "" {
        ifFalse
      } else {
        ifTrue
      }
    } else {
      ifFalse
    }
  }
  let setLogoContent(path) = {
    return if logo == "" [] else {
      set image(width: 100%)
      logo
    }
  }

  v(beforeEntrySkip)
  table(
    columns: (ifLogo(logo, 4%, 0%), 1fr, dateWidth),
    inset: 0pt,
    stroke: none,
    gutter: 6pt,
    align: horizon,
    setLogoContent(logo),
    entryA1Style(society),
    entryA2Style(location),
  )
  v(-10pt)
}

/// Add a continued entry to the CV.
///
/// - title (str): The title of the entry.
/// - date (str | content): The date(s) of the entry.
/// - description (array): The description of the entry. It can be a string or an array of strings.
/// - tags (array): The tags of the entry.
/// - metadata (array): (optional) the metadata read from the TOML file.
/// - awesomeColors (array): (optional) the awesome colors of the CV.
/// -> content
#let cvEntryContinued(
  title: "Title",
  date: "Date",
  description: "Description",
  tags: (),
  metadata: metadata,
  awesomeColors: awesomeColors,
) = {
  // To use cvEntryContinued, you need to set display_entry_society_first to true in the metadata.toml file.
  if not metadata.layout.entry.display_entry_society_first {
    panic("display_entry_society_first must be true to use cvEntryContinued")
  }
  
  let accentColor = setAccentColor(awesomeColors, metadata)
  let beforeEntrySkip = eval(
    metadata.layout.at("before_entry_skip", default: 1pt),
  )
  let beforeEntryDescriptionSkip = eval(
    metadata.layout.at("before_entry_description_skip", default: 1pt),
  )
  let dateWidth = metadata.layout.at("date_width", default: none)
  let dateWidth = if dateWidth == none {
    defaultDateWidth(metadata.language)
  } else {
    eval(dateWidth)
  }

  let entryB1Style(str) = {
    text(size: 8pt, fill: accentColor, weight: "medium", smallcaps(str))
  }
  let entryB2Style(str) = {
    align(
      right,
      text(size: 8pt, weight: "medium", fill: gray, style: "oblique", str),
    )
  }
  let entryDatesStyle(dates) = {
    [
      #set list(marker: [])
      #dates
    ]
  }
  let entryDescriptionStyle(str) = {
    text(
      fill: regularColors.lightgray,
      {
        v(beforeEntryDescriptionSkip)
        str
      },
    )
  }
  let entryTagStyle(str) = {
    align(center, text(size: 8pt, weight: "regular", str))
  }
  let entryTagListStyle(tags) = {
    for tag in tags {
      box(
        inset: (x: 0.25em),
        outset: (y: 0.25em),
        fill: regularColors.subtlegray,
        radius: 3pt,
        entryTagStyle(tag),
      )
      h(5pt)
    }
  }

  v(beforeEntrySkip)
  table(
    columns: (1fr, dateWidth),
    inset: 0pt,
    stroke: none,
    gutter: 6pt,
    align: auto,
    {
      entryB1Style(title)
      entryDescriptionStyle(description)
      entryTagListStyle(tags)
    },
    entryB2Style(entryDatesStyle(date)),
  )
}

/// Add a skill to the CV.
///
/// - type (str): The type of the skill. It is displayed on the left side.
/// - info (str | content): The information about the skill. It is displayed on the right side. Items can be separated by `#hbar()`.
/// -> content
#let cvSkill(type: "Type", info: "Info") = {
  let skillTypeStyle(str) = {
    align(right, text(size: 10pt, weight: "bold", str))
  }
  let skillInfoStyle(str) = {
    text(str)
  }

  table(
    columns: (17%, 1fr),
    inset: 0pt,
    column-gutter: 10pt,
    stroke: none,
    skillTypeStyle(type), skillInfoStyle(info),
  )
  v(-6pt)
}

/// Add a skill with a level to the CV.
///
/// - type (str): The type of the skill. It is displayed on the left side.
/// - level (int): The level of the skill. It is displayed in as circles in the middle. The minimum level is 0 and the maximum level is 5.
/// - info (str | content): The information about the skill. It is displayed on the right side.
/// -> content
#let cvSkillWithLevel(
  type: "Type",
  level: 3,
  info: "Info"
) = {
  let skillTypeStyle(str) = {
    align(right, text(size: 10pt, weight: "bold", str))
  }
  let skillInfoStyle(str) = {
    text(str)
  }
  let skillLevelStyle(str) = {
    set text(size: 10pt, fill: regularColors.darkgray)
    for x in range(0, level) {
      [#fa-icon("circle", solid: true) ]
    }
    for x in range(level, 5) {
      [#fa-icon("circle") ]
    }
  }

  table(
    columns: (17%, auto, 1fr),
    inset: 0pt,
    column-gutter: 10pt,
    stroke: none,
    skillTypeStyle(type), skillLevelStyle(level), skillInfoStyle(info),
  )
  v(-6pt)
}

/// Add a skill tag to the CV.
/// 
/// - skill (str | content): The skill to be displayed.
/// -> content
#let cvSkillTag(skill) = {
  let entryTagStyle(str) = {
    align(center, text(size: 10pt, weight: "regular", str))
  }
  box(
    inset: (x: 0.5em, y: 0.5em),
    fill: regularColors.subtlegray,
    radius: 3pt,
    entryTagStyle(skill),
  )
  h(5pt)
}

/// Add a Honor to the CV.
///
/// - date (str): The date of the honor.
/// - title (str): The title of the honor.
/// - issuer (str): The issuer of the honor.
/// - url (str): The URL of the honor.
/// - location (str): The location of the honor.
/// - awesomeColors (array): (optional) The awesome colors of the CV.
/// - metadata (array): (optional) The metadata read from the TOML file.
/// -> content
#let cvHonor(
  date: "1990",
  title: "Title",
  issuer: "",
  url: "",
  location: "",
  awesomeColors: awesomeColors,
  metadata: metadata,
) = {
  let accentColor = setAccentColor(awesomeColors, metadata)

  let honorDateStyle(str) = {
    align(right, text(str))
  }
  let honorTitleStyle(str) = {
    text(weight: "bold", str)
  }
  let honorIssuerStyle(str) = {
    text(str)
  }
  let honorLocationStyle(str) = {
    align(
      right,
      text(weight: "medium", fill: accentColor, style: "oblique", str),
    )
  }

  table(
    columns: (16%, 1fr, 15%),
    inset: 0pt,
    column-gutter: 10pt,
    align: horizon,
    stroke: none,
    honorDateStyle(date),
    if issuer == "" {
      honorTitleStyle(title)
    } else if url != "" {
      [
        #honorTitleStyle(link(url)[#title]), #honorIssuerStyle(issuer)
      ]
    } else {
      [
        #honorTitleStyle(title), #honorIssuerStyle(issuer)
      ]
    },
    honorLocationStyle(location),
  )
  v(-6pt)
}

/// Add the publications to the CV by reading a bib file.
///
/// - bib (bibliography): The `bibliography` object with the path to the bib file.
/// - keyList (list): The list of keys to include in the publication list.
/// - refStyle (str): The reference style of the publication list.
/// - refFull (bool): Whether to show the full reference or not.
/// -> content
#let cvPublication(bib: "", keyList: list(), refStyle: "apa", refFull: true) = {
  let publicationStyle(str) = {
    text(str)
  }
  show bibliography: it => publicationStyle(it)
  set bibliography(title: none, style: refStyle, full: refFull)
  bib
}
