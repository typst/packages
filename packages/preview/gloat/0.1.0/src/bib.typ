/// Create a publications entry for a conference abstract.
/// -> content
#let abstract(
  /// List of authors in order. -> array | str
  authors: (),
  /// Title of the abstract. -> str | content
  title: "",
  /// Conference that the abstract was presented in/submitted to. -> str | content
  conference: "",
  /// (optional) Submission number for the abstract. -> str | int | content
  number: "",
  /// (optional) Page number in the abstract booklet. Omit if the book was not paginated
  ///  or if the abstract repository was entirely digital.
  /// -> int | str | content | none
  pages: "",
  /// Date the abstract was presented. -> datetime | str
  date: "",
  /// Kind of presentation that the abstract was used for. -> str | content | none
  kind: "",
  /// Location of the conference. Format as City State, Country. -> str | content | none
  location: "",
  /// (optional) Digital Object Identifier for the abstract. -> str | content | none
  DOI: none,
) = {
  let credit = (
    { if pages != "" [#pages,] else [] },
    { if kind != "" [ Abstract and #kind] else [ Abstract] },
    { if number != "" [ #number] },
  )
    .enumerate()
    .map(((i, cred)) => { if cred != none { [#cred] } else { none } })
    .join()

  enum.item[
    #{ if type(authors) == array { authors.enumerate().map(((i, author)) => text(author)).join(", ") } else { authors } }.
    #title.
    #emph[#conference],
    // #date.display("[year] [month repr:long] [day]")\;
    #location\;
    #credit.
    #{
      if DOI != none [DOI: #link("https://doi.org" + DOI)[#DOI]]
    }
  ]
}

/// Create a publications entry for a peer-reviewed paper.
/// -> content
#let paper(
  /// List of authors in order. -> array | str
  authors: (),
  /// Title of the abstract. -> str | content
  title: "",
  /// Journal that the paper was published in. -> str | content | none,
  journal: none,
  /// Date of publication. -> datetime | str | content | none
  published: "",
  /// (optional) Volume of the journal. -> str | content | none
  vol: none,
  /// (optional) Issue of the journal. -> str | content | none
  issue: none,
  /// (optional) Page range of publication in journal. -> str | content | none
  pages: none,
  /// (optional) Digital Object Identifier for publication. -> str | content | none
  DOI: none,
  /// Whether or not to show the DOI -> bool
  show-link: false,
) = {
  // date formatting
  let date = {
    if type(published) == datetime {
      // prefer datetime form
      strong[#published.display("[year]")]
    } else if type(published) == content or type(published) == str {
      // handle string/content form
      strong[#published]
    }
  }

  // take list of identifiers for journal (journal name, volume, issue, pages) and flatten them into single string.
  let credit = (
    { if journal != none { [#emph(journal) #date] } else { [#date] } },
    { if vol != none [, #vol#{ if issue != none [ (#issue)] }] },
    { if pages != none [, #pages] },
  )
    .enumerate()
    .map(((i, cred)) => { if cred != none { [#cred] } else { none } })
    .join()

  // the actual item listed
  enum.item[
    #{ if type(authors) == array { authors.enumerate().map(((i, author)) => text(author)).join(", ") } else { authors } }.
    #title.
    #credit.
    #{
      if DOI != none [DOI: #link("https://doi.org" + DOI)[#DOI]]
    }
  ]
}


/// Create an entry detailing a preprinted (non-peer-reviewed) manuscript.
/// -> content
#let preprint(
  /// List of authors in order. -> array | str
  authors: (),
  /// Title of the abstract. -> str | content
  title: "",
  /// Preprint archive that the manuscript was published in. -> str | content | none,
  journal: "",
  /// Date of publication. -> datetime | str | content | none
  published: "",
  /// (optional) Status of the manuscript. Traditionally listed as "submitted" or "in revisions", depending on progress.
  /// -> str | none
  status: none,
  /// (optional) Digital Object Identifier for publication. -> str | content | none
  DOI: none,
) = {
  // date formatting
  let date = {
    if type(published) == datetime {
      // prefer datetime form
      published.display("[month repr:long] [day], [year]")
    } else {
      // handle string/content form
      published
    }
  }

  // the actual item listed
  enum.item[
    #{ if type(authors) == array { authors.enumerate().map(((i, author)) => text(author)).join(", ") } else { authors } }.
    #title.
    #emph[#status].
    Preprint available on #emph[#journal], #date.
    #{
      if DOI != none [DOI: #link("https://doi.org/" + DOI)[#DOI]]
    }
  ]
}

/// Create an entry for a conference presentation.
/// -> content
#let pres(
  /// List of authors in order. -> array | str
  authors: (),
  /// Title of the abstract. -> str | content
  title: "",
  /// Conference that the abstract was presented in/submitted to. -> str | content
  conference: "",
  /// (optional) Submission number for the abstract. -> str | int | content
  number: "",
  /// (optional) Page number in the abstract booklet. Omit if the book was not paginated
  ///  or if the abstract repository was entirely digital.
  /// -> int | str | content | none
  pages: "",
  /// Date the abstract was presented. -> datetime | str
  date: "",
  /// Kind of presentation that the abstract was used for. -> str | content | none
  kind: "",
  /// Location of the conference. Format as City State, Country. -> str | content | none
  location: "",
  /// (optional) Digital Object Identifier for the abstract. -> str | content | none
  DOI: none,
) = {
  let credit = (
    { if pages != "" [#pages, ] },
    { if kind != "" [#kind] },
    { if number != "" [ #number] },
  )
    .enumerate()
    .map(((i, cred)) => { if cred != none [#cred] })
    .join()

  enum.item[
    #{ if type(authors) == array { authors.enumerate().map(((i, author)) => text(author)).join(", ") } else { authors } }.
    #title.
    #emph[#conference],
    // #date.display("[year] [month repr:long] [day]")\;
    #location\;
    #credit.
    #{
      if DOI != none [DOI: #link("https://doi.org" + DOI)[#DOI]]
    }
  ]
}
