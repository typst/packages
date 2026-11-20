#let default-style-config(
  decorations-color: rgb("#2F5496"),
  primary-color: rgb("#2756a2"),
  onprimary-color: rgb("#FFFFFF"),
) = {
  (
    decorations-color: decorations-color,
    primary-color: primary-color,
    onprimary-color: onprimary-color,
  )
}

#let default-contact-config(
  address-line1: "Avenue Victor Maistriau 8a",
  address-line2: "B-7000 Mons",
  phone-nr-pretty: "+32 (0)65 33 81 54",
  phone-nr-short: auto,
  mail: "scitech-mons@heh.be",
) = {
  (
    address-line1: address-line1,
    address-line2: address-line2,
    phone-nr-pretty: phone-nr-pretty,
    phone-nr-short: if phone-nr-short == auto {
      phone-nr-pretty.replace("(0)", "").replace(" ", "")
    } else { phone-nr-short },
    mail: mail,
  )
}

#let default-naming-config(
  short-name: "DST",
  full-name: "Département des sciences et technologies",
  logo-title: "Sciences",
  logo-subtitle: "et technologies",
) = {
  (
    short-name: short-name,
    full-name: full-name,
    logo-title: logo-title,
    logo-subtitle: logo-subtitle,
  )
}

#let default-config(
  naming: default-naming-config,
  contact: default-contact-config,
  style: default-style-config,
) = {
  (
    naming: naming(),
    contact: contact(),
    style: style(),
  )
}

// Les configs du DST sont les configurations par défaut
#let dst-naming-config = default-naming-config
#let dst-contact-config = default-contact-config
#let dst-style-config = default-style-config.with(
  primary-color: rgb("#E41513"),
  onprimary-color: rgb("#FFFFFF"),
)

#let dst-config = default-config.with(
  naming: dst-naming-config,
  contact: dst-contact-config,
  style: dst-style-config,
)

#let dss-ms-naming-config = default-naming-config.with(
  short-name: "DSS-MS",
  full-name: "Département des sciences sociales (Mons)",

  logo-title: "Sciences",
  logo-subtitle: "sociales",
)


#let dss-ms-contact-config = default-contact-config.with(
  address-line1: "Avenue Victor Maistriau 13",
  address-line2: "B-7000 Mons",
  phone-nr-pretty: "+32 (0)65 39 48 90",
  mail: "social-mons@heh.be",
)

#let dss-style-config = default-style-config.with(
  primary-color: rgb("#EB6922"),
  onprimary-color: rgb("#FFFFFF"),
)

#let dss-ms-config = default-config.with(
  naming: dss-ms-naming-config,
  contact: dss-ms-contact-config,
  style: dss-style-config,
)

#let dss-to-naming-config = default-naming-config.with(
  short-name: "DSS-TO",
  full-name: "Département des sciences sociales (Tournai)",
)

#let dss-to-contact-config = default-contact-config.with(
  address-line1: "Rue des Carmes 19B",
  address-line2: "B-7500 Tournai",

  phone-nr-pretty: "+32 (0)69 22 55 12",
  mail: "social-tournai@heh.be",
)

#let dss-to-config = default-config.with(
  naming: dss-to-naming-config,
  contact: dss-to-contact-config,
  style: dss-style-config,
)

#let dsee-ms-naming-config = default-naming-config.with(
  short-name: "DSEE-MS",
  full-name: "Département des sciences de l'éducation et de l'enseignement (Mons)",

  logo-title: "Sciences de l'éducation",
  logo-subtitle: "et Enseignement",
)

#let dsee-ms-contact-config = default-contact-config.with(
  address-line1: "Boulevard Albert-Elisabeth 2",
  address-line2: "B-7000 Mons",

  phone-nr-pretty: "+32 (0)65 33 76 66",
  mail: "peda-mons@heh.be",
)

#let dsee-style-config = default-style-config.with(
  primary-color: rgb("#B83A6E"),
  onprimary-color: rgb("#FFFFFF"),
)

#let dsee-ms-config = default-config.with(
  naming: dsee-ms-naming-config,
  contact: dsee-ms-contact-config,
  style: dsee-style-config,
)

#let dsee-to-naming-config = default-naming-config.with(
  short-name: "DSS-TO",
  full-name: "Département des sciences de l'éducation et de l'enseignement (Tournai)",
)

#let dsee-to-contact-config = default-contact-config.with(
  address-line1: "Rue des Carmes 19B",
  address-line2: "B-7500 Tournai",

  phone-nr-pretty: "+32 (0)69 22 55 12",
  mail: "peda-tournai@heh.be",
)

#let dsee-to-config = default-config.with(
  naming: dsee-to-naming-config,
  contact: dsee-to-contact-config,
  style: dsee-style-config,
)

#let deco-naming-config = default-naming-config.with(
  short-name: "DECO",
  full-name: "Département des sciences juridiques, économiques et de gestion",

  logo-title: "Sciences juridiques,",
  logo-subtitle: "économiques et de gestion",
)

#let deco-contact-config = default-contact-config.with(
  address-line1: "Rue du Chambge 23",
  address-line2: "B-7500 Tournai",

  phone-nr-pretty: "+32 (0)69 22 67 72",
  mail: "eco-tournai@heh.be",
)

#let deco-style-config = default-style-config.with(
  primary-color: rgb("#6E5EA5"),
  onprimary-color: rgb("#FFFFFF"),
)

#let deco-config = default-config.with(
  naming: deco-naming-config,
  contact: deco-contact-config,
  style: deco-style-config,
)

