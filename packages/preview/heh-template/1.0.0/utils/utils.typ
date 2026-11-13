#import "/utils/states.typ": heh-config

#let get-next-heading(level: 1) = context {
  let headings = query(heading.where(level: level).after(here()))
  if headings.len() > 0 {
    let h = headings.first()
    if h.location().page() == here().page() {
      h.body
    } else {
      none
    }
  } else {
    none
  }
}

#let show-if-has-match(
  selector: heading,
  to-show: outline,
) = context {
  if (counter(selector).final().at(0) >= 1) {
    to-show()
  }
}

#let template-svg(
  source,
  params: (key: "variable", value: "value"),
  ..args,
) = {
  let imageString = read(source)

  for param in params {
    imageString = imageString.replace(
      regex("\{" + param.key + "\}"),
      param.value,
    )
  }

  image(bytes(imageString), ..args)
}

#let single-color-svg(
  source,
  color,
  ..args,
) = template-svg(
  source,
  params: ((key: "color", value: color.to-hex()),),
  ..args,
)

#let campus-branded-svg(
  source,
  ..args,
) = context {
  let config = heh-config.get()
  template-svg(
    source,
    params: (
      (key: "color", value: config.campus.style.primary-color.to-hex()),
      (key: "title", value: config.campus.naming.logo-title),
      (key: "subtitle", value: config.campus.naming.logo-subtitle),
    ),
    ..args,
  )
}

#let heh-logo(..args) = campus-branded-svg(
  "/assets/logos/heh-logo.vsvg",
  ..args,
)

#let format-author-names(
  authors,
  include-email,
  email-separator: linebreak(),
) = {
  let formatted-authors = ()

  for author in authors {
    // Le 3ème champ peut être le nom abrégé de l'auteur
    let name = author.at(2, default: author.at(0))
    let email = author.at(1)

    if include-email {
      formatted-authors.push([#name#email-separator#email])
    } else {
      formatted-authors.push([#name])
    }
  }

  return formatted-authors
}

