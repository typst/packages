// Normalize title metadata once; names and institutions remain author-supplied content.
#let _array(value) = if value == none or value == () { () } else if type(value) == array { value } else { (value,) }

#let presentation-people(info) = {
  let pattern = info.at("affiliation-numbering", default: "1")
  assert(type(pattern) in (str, function), message: "Affiliation numbering must be a Typst numbering pattern or function.")
  let scope = info.at("affiliation-scope", default: none)
  assert(scope == none or type(scope) == str, message: "Affiliation scope must be a string or none.")
  let institutions = info.at("institutions", default: auto)
  let affiliations = ()
  if institutions == auto {
    for (index, name) in _array(info.at("institution", default: none)).enumerate() {
      affiliations.push((id: str(index + 1), name: name, address: none))
    }
  } else if type(institutions) == dictionary {
    for (id, institution) in institutions {
      let record = if type(institution) == dictionary { institution } else { (name: institution) }
      assert("name" in record, message: "Each institution needs a name.")
      affiliations.push((id: id, name: record.name, address: record.at("address", default: none)))
    }
  } else {
    for (index, institution) in _array(institutions).enumerate() {
      let record = if type(institution) == dictionary { institution } else { (name: institution) }
      assert("name" in record, message: "Each institution needs a name.")
      affiliations.push((id: record.at("id", default: str(index + 1)), name: record.name,
        address: record.at("address", default: none)))
    }
  }
  let ids = affiliations.map(it => it.id)
  assert(ids.dedup().len() == ids.len(), message: "Institution IDs must be unique.")
  affiliations = affiliations.enumerate().map(((index, institution)) => institution + (
    marker: numbering(pattern, index + 1), scope: scope,
  ))
  let authors = ()
  for author in _array(info.at("authors", default: info.at("author", default: none))) {
    let record = if type(author) == dictionary { author } else { (name: author) }
    assert("name" in record, message: "Each author needs a name.")
    let refs = _array(record.at("affiliations", default: ()))
    assert(refs.all(id => id in ids), message: "Author affiliations must reference known institution IDs.")
    authors.push((name: record.name, short: record.at("short", default: record.name),
      affiliations: refs.map(id => ids.position(it => it == id) + 1),
      affiliation-links: refs.map(id => affiliations.at(ids.position(it => it == id))),
      emails: _array(record.at("emails", default: record.at("email", default: none)))))
  }
  (authors: authors, institutions: affiliations,
    emails: _array(info.at("emails", default: info.at("email", default: none))))
}

// Locations, rather than generated labels, keep repeated/fitted title pages
// independent without counters or duplicate labels during measurement.
#let affiliation-link(id, marker, scope: none, same-page: false) = context {
  let anchors = query(<ambrosia-institution>).filter(it => it.value.id == id
    and it.value.scope == scope and (not same-page or it.location().page() == here().page()))
  let previous = anchors.filter(it => it.location().page() <= here().page())
  let target = if previous.len() > 0 { previous.last() } else { anchors.at(0, default: none) }
  if target == none { marker } else { link(target.location(), target.value.marker) }
}

#let short-authors(info) = {
  let explicit = info.at("short-author", default: auto)
  if explicit != auto { return explicit }
  let authors = presentation-people(info).authors
  if authors.len() == 0 { [] }
  else if authors.len() == 1 { authors.first().short }
  else if authors.len() == 2 { [#authors.first().short & #authors.last().short] }
  else { [#authors.first().short et al.] }
}

#let email-link(email, fill: auto) = {
  if type(email) == str {
    // Break long addresses after punctuation; the mailto target stays intact.
    let display = email.replace(regex("[@._-]"), match => match.text + "\u{200b}")
    link("mailto:" + email, if fill == auto { display } else { text(fill: fill, display) })
  } else { email }
}

#let author-card(author, mono-font, fill, compact: false) = {
  text(fill: fill, weight: if compact { "bold" } else { "regular" })[
    #author.name#if author.affiliations.len() > 0 {
      super(author.affiliation-links.map(it => affiliation-link(it.id, it.marker, scope: it.scope, same-page: true)).join(","))
    }
  ]
  if author.emails.len() > 0 {
    parbreak()
    text(font: mono-font, size: 0.6em, author.emails.map(email => email-link(email, fill: fill)).join(linebreak()))
  }
}

#let authors-grid(people, mono-font, fill, compact: false, columns: auto, alignment: auto) = {
  if people.authors.len() > 0 {
    layout(bounds => context {
      let columns = if columns == auto {
        let capacity = calc.max(1, calc.min(people.authors.len(), 3, calc.floor(bounds.width / (11 * text.size))))
        calc.ceil(people.authors.len() / calc.ceil(people.authors.len() / capacity))
      } else { columns }
      let alignment = if alignment != auto { alignment } else if compact { left } else { center }
      let gap = (0.8em).to-absolute()
      let cell-width = (bounds.width - (columns - 1) * gap) / columns
      [#metadata((columns: columns, rows: calc.ceil(people.authors.len() / columns),
        authors: people.authors.len(), width: bounds.width.pt()))<ambrosia-author-layout>]
      grid(columns: (1fr,), row-gutter: 0.6em, align: alignment,
        ..range(0, people.authors.len(), step: columns).map(offset => {
          let row = people.authors.slice(offset, calc.min(offset + columns, people.authors.len()))
          block(width: row.len() * cell-width + (row.len() - 1) * gap,
            grid(columns: (1fr,) * row.len(), column-gutter: gap, align: alignment + top,
              ..row.map(author => author-card(author, mono-font, fill, compact: compact))))
        }))
    })
  }
}

#let institutions-list(people, fill) = {
  if people.institutions.len() > 0 {
    let referenced = people.authors.any(author => author.affiliations.len() > 0)
    text(size: 0.7em, fill: fill, people.institutions.enumerate().map(((index, institution)) => [
      #metadata((id: institution.id, marker: institution.marker, scope: institution.scope))<ambrosia-institution>
      #if referenced { super(institution.marker); h(0.2em) }
      #institution.name
      #if institution.address != none { [#h(0.3em)#institution.address] }
    ]).join(linebreak()))
  }
}

#let emails-grid(people, mono-font, fill) = {
  // An address supplied per-author does not need a second global display.
  let personal = people.authors.map(it => it.emails).flatten()
  let emails = people.emails.filter(it => it not in personal).dedup()
  if emails.len() > 0 {
    grid(columns: (1fr,) * calc.min(emails.len(), 3), column-gutter: 0.8em, row-gutter: 0.4em,
      ..emails.map(email => text(font: mono-font, size: 0.65em, email-link(email, fill: fill))))
  }
}
