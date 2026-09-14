#import "./utils.typ": omit-dict-none, content-to-html

// what has humanity done to deserve this structure and its pervasiveness?

#let serialize-org(school, dept) = {
  let org = omit-dict-none(("L1": school, "L2": dept))

  if org.len() > 0 {
    org
  } else {
    none
  }
}

#let serialize-person(person) = {
  omit-dict-none((
    "Last name": person.at("last-names"),
    "First name": person.at("first-name"),
    "Local User Id": person.at("user-id", default: none),
    "E-mail": person.at("email", default: none),
    "organisation": serialize-org(
      person.at("school", default: none),
      person.at("department", default: none),
    ),
    "Other organisation": person.at("external-org", default: none),
  ))
}

#let serialize-degree(degree) = {
  (
    "Educational program": degree.at("name"),
    "programcode": degree.at("code"),
    "Degree": degree.at("kind"),
    "subjectArea": degree.at("subject-area"),
  )
}

#let serialize-lang(lang) = {
  if lang.len() == 3 {
    lang
  } else if lang == "en" {
    "eng"
  } else if lang == "sv" {
    "swe"
  } else {
    panic("Cannot serialize to alpha-3 language " + lang)
  }
}

#let serialize-title(lang, info) = {
  (
    "Main title": info.at("title"),
    "Subtitle": info.at("subtitle", default: ""),
    "Language": info.at("alpha-3", default: serialize-lang(lang)),
  )
}

#let serialize-cooperation(host-company, host-org) = {
  if host-company != none {
    ("Partner_name": host-company)
  } else if host-org != none {
    ("Partner_name": host-org)
  } else {
    none
  }
}

#let serialize-opponents(opponents) = {
  if opponents != none and opponents.len() > 0 {
    ("Name": opponents.join(" & "))
  } else {
    none
  }
}

#let serialize-presentation(presentation) = {
  if presentation != none {
    let location = presentation.at(
      "location",
      default: (
        room: none,
        address: none,
        city: none,
      ),
    )

    let online = presentation.at("online", default: none)
    let online-room = if online != none {
      "via " + online.at("service") + ": " + online.at("link")
    } else {
      none
    }

    omit-dict-none((
      "Date": presentation.at("slot").display("[year]-[month]-[day] [hour]:[minute]"),
      "Language": serialize-lang(presentation.at("language")),
      "Room": location.at("room", default: online-room),
      "Address": location.at("address", default: none),
      "City": location.at("city", default: none),
    ))
  } else {
    none
  }
}

#let serialize-global(
  primary-lang: "en",
  alt-lang: "sv",
  localized-info: (:),
  authors: (),
  supervisors: (),
  examiner: (:),
  course: (:),
  degree: (:),
  host-company: none,
  host-org: none,
  national-subject-categories: (),
  trita-series: "TRITA-EECS-EX",
  trita-number: "2025:0000",
  opponents: none,
  presentation: none,
  doc-date: datetime.today(),
  page-series-counts: (),
) = {
  let struct = (:)

  for (n, author) in authors.enumerate(start: 1) {
    struct.insert("Author" + str(n), serialize-person(author))
    // note: n > 2 might be ignored by consuming automation scripts
  }

  struct.insert("Cycle", str(degree.at("cycle")))
  struct.insert("Course code", str(course.at("code")))
  struct.insert("Credits", str(course.at("credits")))

  struct.insert("Degree1", serialize-degree(degree))
  // TODO: support for multiple degrees (including Same/Both mechanism)

  let primary-info = localized-info.at(primary-lang)
  let alt-info = localized-info.at(alt-lang)

  struct.insert("Title", serialize-title(primary-lang, primary-info))
  struct.insert("Alternative title", serialize-title(alt-lang, alt-info))

  for (n, supervisor) in supervisors.enumerate(start: 1) {
    struct.insert("Supervisor" + str(n), serialize-person(supervisor))
    // note: n > 3 might be ignored by consuming automation scripts
  }

  struct.insert("Examiner1", serialize-person(examiner))
  struct.insert("Cooperation", serialize-cooperation(host-company, host-org))
  struct.insert(
    "National Subject Categories",
    national-subject-categories.join(", "),
  )
  struct.insert(
    "Other information",
    (
      "Year": str(doc-date.year()),
      "Number of pages": page-series-counts.join(","),
    ),
  )
  struct.insert("Copyrightleft", "copyright") // TODO: support copyleft
  struct.insert(
    "Series",
    (
      "Title of series": "TRITA-" + trita-series,
      "No. in series": trita-number,
    ),
  )
  struct.insert("Opponents", serialize-opponents(opponents))
  struct.insert("Presentation", serialize-presentation(presentation))
  struct.insert("Number of lang instances", str(localized-info.len()))

  for (lang, info) in localized-info.pairs() {
    let tag = serialize-lang(info.at("alpha-3", default: lang))
    struct.insert(
      "Abstract[" + tag + "]",
      content-to-html(info.at("abstract")),
    )
    struct.insert("Keywords[" + tag + "]", info.at("keywords").join(", "))
  }

  omit-dict-none(struct)
}

#let for-diva-json(..args) = {
  let struct = serialize-global(..args)

  set text(font: "DejaVu Sans Mono", size: 10pt, ligatures: false)

  heading(outlined: false, level: 1, "€€€€ For DIVA €€€€")

  json.encode(struct)
}
