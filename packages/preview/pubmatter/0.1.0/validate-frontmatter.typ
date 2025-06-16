
#let validateContent(raw, name, alias: none) = {
  if (name in raw) {
    assert(type(raw.at(name)) == str or type(raw.at(name)) == content, message: name + " must be a string or content")
    return raw.at(name)
  }
  if (type(alias) != array) { return }
  for a in alias { if (a in raw) { validateContent(raw, a) } }
}

#let validateString(raw, name, alias: none) = {
  if (name in raw) {
    assert(type(raw.at(name)) == str, message: name + " must be a string")
    return raw.at(name)
  }
  if (type(alias) != array) { return }
  for a in alias { if (a in raw) { validateString(raw, a) } }
}

#let validateBoolean(raw, name, alias: none) = {
  if (name in raw) {
    assert(type(raw.at(name)) == bool, message: name + " must be a boolean")
    return raw.at(name)
  }
  if (type(alias) != array) { return }
  for a in alias { if (a in raw) { validateBoolean(raw, a) } }
}

#let validateArray(raw, name, alias: none) = {
  if (name in raw) {
    assert(type(raw.at(name)) == array, message: name + " must be an array")
    return raw.at(name)
  }
  if (type(alias) != array) { return }
  for a in alias { if (a in raw) { validateArray(raw, a) } }
}

#let validateDate(raw, name, alias: none) = {
  if (name in raw) {
    let rawDate = raw.at(name)
    if (type(rawDate) == datetime) { return rawDate }
    if (type(rawDate) == int) {
      // assume this is the year
      assert(rawDate > 1000 and rawDate < 3000, message: "The date is assumed to be a year between 1000 and 3000")
      return datetime(year: rawDate, month: 1, day: 1)
    }
    if (type(rawDate) == str) {
      let yearMatch = rawDate.find(regex(`^([1|2])([0-9]{3})$`.text))
      if (yearMatch != none) {
        // This isn't awesome, but probably fine
        return datetime(year: int(rawDate), month: 1, day: 1)
      }
      let dateMatch = rawDate.find(regex(`^([1|2])([0-9]{3})([-\/])([0-9]{1,2})([-\/])([0-9]{1,2})$`.text))
      if (dateMatch != none) {
        let parts = rawDate.split(regex("[-\/]"))
        return datetime(
          year: int(parts.at(0)),
          month: int(parts.at(1)),
          day: int(parts.at(2)),
        )
      }
      panic("Unknown datetime object from string, try: `2020/03/15` as YYYY/MM/DD, also accepts `2020-03-15`")
    }
    if (type(rawDate) == dictionary) {
      if ("year" in rawDate and "month" in rawDate and "day" in rawDate) {
        return return datetime(
          year: rawDate.at("year"),
          month: rawDate.at("month"),
          day: rawDate.at("day"),
        )
      }
      if ("year" in rawDate and "month" in rawDate) {
        return return datetime(
          year: rawDate.at("year"),
          month: rawDate.at("month"),
          day: 1,
        )
      }
      if ("year" in rawDate) {
        return return datetime(
          year: rawDate.at("year"),
          month: 1,
          day: 1,
        )
      }
      panic("Unknown datetime object from dictionary, try: `(year: 2022, month: 2, day: 3)`")
    }
    panic("Unknown date of type '" + type(rawDate)+ "' accepts: datetime, str, int, and object")
  }
  if (type(alias) != array) { return }
  for a in alias { if (a in raw) { return validateDate(raw, a) } }
}

#let validateAffiliation(raw) = {
  let out = (:)
  if (type(raw) == str) {
    out.name = raw;
    return out;
  }
  let id = validateString(raw, "id")
  if (id != none) { out.id = id }
  let name = validateString(raw, "name")
  if (name != none) { out.name = name }
  let institution = validateString(raw, "institution")
  if (institution != none) { out.institution = institution }
  let department = validateString(raw, "department")
  if (department != none) { out.department = department }
  let doi = validateString(raw, "doi")
  if (doi != none) { out.doi = doi }
  let ror = validateString(raw, "ror")
  if (ror != none) { out.ror = ror }
  let address = validateString(raw, "address")
  if (address != none) { out.address = address }
  let city = validateString(raw, "city")
  if (city != none) { out.city = city }
  let region = validateString(raw, "region", alias: ("state", "province"))
  if (region != none) { out.region = region }
  let postal-code = validateString(raw, "postal-code", alias: ("postal_code", "postalCode", "zip_code", "zip-code", "zipcode", "zipCode"))
  if (postal-code != none) { out.postal-code = postal-code }
  let country = validateString(raw, "country")
  if (country != none) { out.country = country }
  let phone = validateString(raw, "phone")
  if (phone != none) { out.phone = phone }
  let fax = validateString(raw, "fax")
  if (fax != none) { out.fax = fax }
  let email = validateString(raw, "email")
  if (email != none) { out.email = email }
  let url = validateString(raw, "url")
  if (url != none) { out.url = url }
  let collaboration = validateBoolean(raw, "collaboration")
  if (collaboration != none) { out.collaboration = collaboration }
  return out;
}

#let pickAffiliationsObject(raw) = {
  if ("affiliation" in raw and "affiliations" in raw) {
    panic("You can only use `affiliation` or `affiliations`, not both")
  }
  if ("affiliation" in raw) {
    raw.affiliations = raw.affiliation
  }
  if ("affiliations" not in raw) { return; }
  if (type(raw.affiliations) == str or type(raw.affiliations) == "dictionary") {
    // convert to a list
    return (validateAffiliation(raw.affiliations),)
  } else if (type(raw.affiliations) == "array") {
    // validate each entry
    return raw.affiliations.map(validateAffiliation)
  } else {
    panic("The `affiliation` or `affiliations` must be a array, dictionary or string, got:", type(raw.affiliations))
  }
}

#let validateAuthor(raw) = {
  let out = (:)
  if (type(raw) == str) {
    out.name = raw;
    out.affiliations = ()
    return out;
  }
  let name = validateString(raw, "name")
  if (name != none) { out.name = name }
  let orcid = validateString(raw, "orcid", alias: ("ORCID",))
  if (orcid != none) { out.orcid = orcid }
  let email = validateString(raw, "email")
  if (email != none) { out.email = email }
  let corresponding = validateBoolean(raw, "corresponding")
  if (corresponding != none) { out.corresponding = corresponding }
  else if (email != none) { out.corresponding = true }
  let phone = validateString(raw, "phone")
  if (phone != none) { out.phone = phone }
  let fax = validateString(raw, "fax")
  if (fax != none) { out.fax = fax }
  let url = validateString(raw, "url", alias: ("website", "homepage"))
  if (url != none) { out.url = url }
  let github = validateString(raw, "github")
  if (github != none) { out.github = github }

  let deceased = validateBoolean(raw, "deceased")
  if (deceased != none and deceased) { out.deceased = deceased }
  let equal-contributor = validateBoolean(raw, "equal_contributor", alias: ("equal-contributor", "equalContributor"))
  if (equal-contributor != none and equal-contributor) { out.equal-contributor = equal-contributor }

  let note = validateString(raw, "note")
  if (note != none) { out.note = note }

  let affiliations = pickAffiliationsObject(raw);
  if (affiliations != none) { out.affiliations = affiliations } else { out.affiliations = () }

  return out;
}

#let consolidateAffiliations(authors, affiliations) = {
  let cnt = 0
  for affiliation in affiliations {
    if ("id" not in affiliation) {
      affiliation.insert("id", "aff-" + str(cnt + 1))
    }
    affiliations.at(cnt) = affiliation
    cnt += 1
  }

  let authorCnt = 0
  for author in authors {
    let affCnt = 0
    for affiliation in author.affiliations {
      let pos = affiliations.position(item => { ("id" in item and item.id == affiliation.name) or ("name" in item and item.name == affiliation.name) })
      if (pos != none) {
        affiliation.remove("name")
        affiliation.id = affiliations.at(pos).id
        affiliations.at(pos) = affiliations.at(pos) + affiliation
      } else {
        affiliation.id = if ("id" in affiliation) { affiliation.id } else { affiliation.name }
        affiliations.push(affiliation)
      }
      author.affiliations.at(affCnt) = (id: affiliation.id)
      affCnt += 1
    }
    authors.at(authorCnt) = author
    authorCnt += 1
  }

  // Now that they are normalized, loop again and update the numbers
  let fullAffCnt = 0
  let authorCnt = 0
  for author in authors {
    let affCnt = 0
    for affiliation in author.affiliations {
      let pos = affiliations.position(item => { item.id == affiliation.id })
      let aff = affiliations.at(pos)
      if ("index" not in aff) {
        fullAffCnt += 1
        aff.index = fullAffCnt
        affiliations.at(pos) = affiliations.at(pos) + (index: fullAffCnt)
      }
      author.affiliations.at(affCnt) = (id: affiliation.id, index: aff.index)
      affCnt += 1
    }
    authors.at(authorCnt) = author
    authorCnt += 1
  }
  return (authors: authors, affiliations: affiliations)
}

/// Create a short citation in APA format, e.g. Cockett _et al._, 2023
/// - show-year (boolean): Include the year in the citation
/// - fm (fm): The frontmatter object
/// -> content
#let show-citation(show-year: true, fm) = {
  if ("authors" not in fm) {return none}
  let authors = fm.authors
  let date = fm.date
  let year = if (show-year and date != none) { ", " + date.display("[year]") } else { none }
  if (authors.len() == 1) {
    return authors.at(0).name.split(" ").last() + year
  } else if (authors.len() == 2) {
    return authors.at(0).name.split(" ").last() + " & " + authors.at(1).name.split(" ").last() + year
  } else if (authors.len() > 2) {
    return authors.at(0).name.split(" ").last() + " " + emph("et al.") + year
  }
  return none
}


#let validateLicense(raw) = {
  if ("license" not in raw) { return none }
  let rawLicense = raw.at("license")
  if (type(rawLicense) == str) {
    if (rawLicense == "CC0"  or rawLicense == "CC0-1.0") {
      return (
        id: "CC0-1.0",
        url: "https://creativecommons.org/licenses/zero/1.0/",
        name: "Creative Commons Zero v1.0 Universal",
      )
    } else if (rawLicense == "CC-BY" or rawLicense == "CC-BY-4.0") {
      return (
        id: "CC-BY-4.0",
        url: "https://creativecommons.org/licenses/by/4.0/",
        name: "Creative Commons Attribution 4.0 International",
      )
    } else if (rawLicense == "CC-BY-NC" or rawLicense == "CC-BY-NC-4.0") {
      return (
        id: "CC-BY-NC-4.0",
        url: "https://creativecommons.org/licenses/by-nc/4.0/",
        name: "Creative Commons Attribution Non Commercial 4.0 International",
      )
    } else if (rawLicense == "CC-BY-NC-SA" or rawLicense == "CC-BY-NC-SA-4.0") {
      return (
        id: "CC-BY-NC-SA-4.0",
        url: "https://creativecommons.org/licenses/by-nc-sa/4.0/",
        name: "Creative Commons Attribution Non Commercial Share Alike 4.0 International",
      )
    } else if (rawLicense == "CC-BY-ND" or rawLicense == "CC-BY-ND-4.0") {
      return (
        id: "CC-BY-ND-4.0",
        url: "https://creativecommons.org/licenses/by-nd/4.0/",
        name: "Creative Commons Attribution No Derivatives 4.0 International",
      )
    } else if (rawLicense == "CC-BY-NC-ND" or rawLicense == "CC-BY-NC-ND-4.0") {
      return (
        id: "CC-BY-NC-ND-4.0",
        url: "https://creativecommons.org/licenses/by-nc-nd/4.0/",
        name: "Creative Commons Attribution Non Commercial No Derivatives 4.0 International",
      )
    }
    panic("Unknown license string: '" + rawLicense + "'")
  }
  if (type(rawLicense) == dictionary) {
    assert("id" in rawLicense and "url" in rawLicense and "name" in rawLicense, message: "License nust contain fields of 'id' (the SPDX ID), 'url': the URL to the license, and 'name' the human-readable license name")
    let id = validateString(rawLicense, "id")
    let url = validateString(rawLicense, "url")
    let name = validateString(rawLicense, "name")
    return (id: id, url: url, name: name)
  }
  panic("Unknown format for license: '" + type(rawLicense) + "'")
}

#let load(raw) = {
  let out = (:)
  let title = validateContent(raw, "title")
  if (title != none) { out.title = title }
  let subtitle = validateContent(raw, "subtitle")
  if (subtitle != none) { out.subtitle = subtitle }
  let short-title = validateString(raw, "short-title", alias: ("short_title", "shortTitle", "running-head", "running_head", "runningHead", "runningTitle", "running_title", "running-title"))
  if (short-title != none) { out.short-title = short-title }

  // author information
  if ("author" in raw and "authors" in raw) {
    panic("You can only use `author` or `authors`, not both")
  }
  if ("author" in raw) {
    raw.authors = raw.author
  }
  if ("authors" in raw) {
    if (type(raw.authors) == str or type(raw.authors) == "dictionary") {
      // convert to a list
      out.authors = (validateAuthor(raw.authors),)
    } else if (type(raw.authors) == "array") {
      // validate each entry
      out.authors = raw.authors.map(validateAuthor)
    } else {
      panic("The `author` or `authors` must be a array, dictionary or string, got:", type(raw.authors))
    }
  } else {
    out.authors = ()
  }

  let affiliations = pickAffiliationsObject(raw);
  if (affiliations != none) { out.affiliations = affiliations } else { out.affiliations = () }

  let open-access = validateBoolean(raw, "open-access", alias: ("open_access", "openAccess",))
  if (open-access != none) { out.open-access = open-access }
  let venue = validateString(raw, "venue")
  if (venue != none) { out.venue = venue }
  let license = validateLicense(raw)
  if (license != none) { out.license = license }
  let doi = validateString(raw, "doi")
  if (doi != none) {
    assert(not doi.starts-with("http"), message: "DOIs should not include the link, use only the part after `https://doi.org/[]`")
    out.doi = doi
  }

  if ("date" in raw) {
    out.date = validateDate(raw, "date");
  } else {
    out.date = datetime.today()
  }
  let citation = validateString(raw, "citation")

  if (citation != none) {
    out.citation = citation;
  } else {
    out.citation = show-citation(out)
  }

  if ("abstract" in raw and "abstracts" in raw) {
    panic("You can only use `abstract` or `abstracts`, not both")
  }
  if ("abstract" in raw) {
    raw.abstracts = raw.abstract
  }
  if ("abstracts" in raw) {
    if (type(raw.abstracts) == str or type(raw.abstracts) == content) {
      raw.abstracts = (content: raw.abstracts)
    }
    if (type(raw.abstracts) == dictionary) {
      if ("title" not in raw.abstracts) {
        raw.abstracts.title = "Abstract"
      }
      raw.abstracts = (raw.abstracts,)
    }
    if (type(raw.abstracts) == array) {
      // validate each entry
      out.abstracts = raw.abstracts.map((abs) => {
        if (type(abs) != dictionary or "title" not in abs or "content" not in abs) {
          return
        }
        return (title: abs.at("title"), content: abs.at("content"))
      })
    } else {
      panic("The `abstract` or `abstracts` must be content, or an array, got:", type(raw.abstracts))
    }
  }

  let keywords = validateArray(raw, "keywords")
  if (keywords != none) {
    out.keywords = keywords.map((k) => validateString((keyword: k), "keyword"))
  }

  let consolidated = consolidateAffiliations(out.authors, out.affiliations)
  out.authors = consolidated.authors
  out.affiliations = consolidated.affiliations

  return out
}

