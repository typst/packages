#import "pages/title.typ": title-page
#import "pages/abstract.typ": abstract-page
#import "pages/acknowledgements.typ": acknowledgements-page
#import "pages/originality.typ": declaration-of-originality-page

#let zhaw-cover-page(cover, print-mode: false) = {
  if cover == none {
    return
  }
  if cover.override != none {
    cover.override
  } else {
    title-page(
      school: cover.school,
      institute: cover.institute,
      work_type: cover.work-type,
      title: cover.title,
      authors: cover.authors,
      supervisors: cover.supervisors,
      co-supervisors: cover.co-supervisors,
      industry-partner: cover.industry-partner,
      print-mode: print-mode,
    )
  }
}

#let zhaw-abstract-section(abstract, cover) = {
  if abstract == none {
    return
  }
  if abstract.override != none {
    abstract.override
  } else {
    if cover == none {
      panic(
        "`cover` metadata is required when the abstract section is included. Set `abstract: none` to omit the section, or provide a `cover` dictionary.",
      )
    }
    if abstract.de == none {
      panic("ZHAW requires a German abstract even for English works.")
    }
    abstract-page(
      en: abstract.en,
      de: abstract.de,
      keywords: abstract.keywords,
      authors: cover.authors,
      title: cover.title,
    )
  }
}

#let zhaw-acknowledgements-section(acknowledgements, cover) = {
  if acknowledgements == none {
    return
  }
  if acknowledgements.override != none {
    acknowledgements.override
  } else {
    if cover == none {
      panic(
        "`cover` metadata is required when the acknowledgements section is included. Set `acknowledgements: none` to omit the section, or provide a `cover` dictionary.",
      )
    }
    acknowledgements-page(
      acknowledgements: acknowledgements.text,
      supervisors: cover.supervisors,
      co-supervisors: cover.co-supervisors,
      authors: cover.authors,
    )
  }
}

#let zhaw-declaration-section(declaration-of-originality, cover) = {
  if declaration-of-originality == none {
    return
  }
  if declaration-of-originality.override != none {
    declaration-of-originality.override
  } else {
    if cover == none {
      panic(
        "`cover` metadata is required when the declaration of originality section is included. Set `declaration-of-originality: none` to omit the section, or provide a `cover` dictionary.",
      )
    }
    declaration-of-originality-page(
      declaration_of_originality: declaration-of-originality.text,
      location: declaration-of-originality.location,
      authors: cover.authors,
    )
  }
}
