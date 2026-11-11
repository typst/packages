// =============================================================================
// src/components/header.typ: Running page header and institutional logos
// =============================================================================

#import "../utils.typ": normalize-color

/// Resolves a logo parameter (`auto`, file path `str`, `content`, or `none`).
///
/// - logo (content, str, none, auto): Logo input.
/// - default-path (str): Default image path when `logo` is `auto`.
/// - width (length, ratio): Rendered image width.
/// -> content
#let _resolve-logo(logo, default-path, width) = {
  if logo == none {
    []
  } else if logo == auto {
    image(default-path, width: width)
  } else if type(logo) == str {
    image(logo, width: width)
  } else {
    logo
  }
}

/// Renders the standardized ABET institutional running page header table with logos.
///
/// - institution (dictionary, str, content): Institution details.
/// - doc-code (str): Document code according to university format standards.
/// - approval-date (str): Approval date of the format template.
/// - logo-left (content, str, none, auto): Left logo image. Defaults to EPIS logo.
/// - logo-right (content, str, none, auto): Right logo image. Defaults to ABET logo.
/// - assets-dir (str): Base directory path for default assets.
/// - header-border-color (color, str): Border color for running header table.
/// -> content
#let render-page-header(
  institution: (
    university: "UNIVERSIDAD NACIONAL DE SAN AGUSTÍN",
    faculty: "FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS",
    school: "ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMAS",
  ),
  doc-code: "GUIA-PRLE-001",
  approval-date: "2022/03/01",
  logo-left: auto,
  logo-right: auto,
  assets-dir: "../../assets",
  header-border-color: rgb("#808080"),
) = {
  let inst-content = if type(institution) == dictionary [
    #institution.at(
      "university",
      default: "UNIVERSIDAD NACIONAL DE SAN AGUSTÍN",
    ) \
    #institution.at(
      "faculty",
      default: "FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS",
    ) \
    #institution.at(
      "school",
      default: "ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMAS",
    )
  ] else if type(institution) in (str, content) [
    #institution
  ] else [
    UNIVERSIDAD NACIONAL DE SAN AGUSTÍN \
    FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS \
    ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMAS
  ]

  let left-img = _resolve-logo(logo-left, assets-dir + "/epis.png", 95%)
  let right-img = _resolve-logo(logo-right, assets-dir + "/abet.png", 97%)

  block(
    width: 100%,
    inset: (bottom: 1em),
  )[
    #table(
      align: center + horizon,
      stroke: 0.5pt + normalize-color(header-border-color),
      columns: (1fr, 2fr, 1fr),
      align(horizon)[#left-img],
      text(size: 7.5pt, weight: "bold", fill: black)[#inst-content],
      align(horizon)[#right-img],
      table.cell(colspan: 3)[
        #text(size: 7pt, weight: "bold")[Formato: ]
        #text(
          size: 7pt,
        )[Guía de Práctica de Laboratorio / Talleres / Centros de Simulación]
      ],
      text(size: 7pt, weight: "bold")[Aprobación: #approval-date],
      text(size: 7pt, weight: "bold")[Código: #doc-code],
      table.cell(align: right + horizon)[
        #context text(
          size: 7pt,
          weight: "bold",
        )[Página: #counter(page).display("1")]
      ],
    )
  ]
}
