#let include-orcid(author, orcid) = {
  if orcid != none [
    #if orcid.contains(regex("^\d{4}-\d{4}-\d{4}-\d{4}$")) == false {
      panic("ORCID format must be XXXX-XXXX-XXXX-XXXX: " + orcid)
    } else if type(orcid) != str {
      panic("ORCID must be of type string: " + type(orcid))
    }

    #author
    #box(height: 1em, image("../assets/img/ORCID_iD.svg.png", width: 2.5%))
    #link("https://orcid.org/" + orcid)
  ] else {
    author
  }
}
