// Modèle 4 : Rapport de Stage pour l'ECE Paris
// Modèle officiel incluant la page de garde ECE et la fiche d'évaluation entreprise obligatoire

#import "../theme.typ": *
#import "../utils.typ": *
#import "../i18n.typ": *
#import "../base.typ": *

// Utilitaire de coalescence (premier élément non nul / non vide)
#let _first(..vals, default: none) = {
  for v in vals.pos() {
    if v != none and v != "" { return v }
  }
  default
}

// Case à cocher pour formulaires officiels
#let _stage-checkbox(checked: false) = box(
  width: 9pt,
  height: 9pt,
  stroke: 0.8pt + black,
  radius: 1.2pt,
  baseline: -0.5pt,
  align(center + horizon)[#if checked { text(size: 7.5pt, weight: "bold")[✓] }]
)

// Grille d'évaluation officielle ECE par défaut (modifiable et extensible)
#let get-default-sections(dict) = (
  (
    title: dict.eval_tech_title,
    total: 20,
    total-label: dict.eval_tech_total,
    criteria: (
      (label: dict.eval_tech_1, max: 4),
      (label: dict.eval_tech_2, max: 6),
      (label: dict.eval_tech_3, max: 10),
    ),
  ),
  (
    title: dict.eval_human_title,
    total: 20,
    total-label: dict.eval_human_total,
    criteria: (
      (label: dict.eval_human_1, max: 7),
      (label: dict.eval_human_2, max: 5),
      (label: dict.eval_human_3, max: 5),
      (label: dict.eval_human_4, max: 3),
    ),
  ),
)

// Page de garde officielle de stage (reproduction fidèle du modèle ECE)
#let stage-cover(ctx) = {
  grid(
    columns: (auto, 1fr),
    align: (left + top, right + top),
    _render-logo(ctx.logo, width: 5.5cm),
    align(right)[
      #text(size: 11.5pt, weight: "bold")[#ctx.dict.type_doc] \
      #v(3pt)
      #text(size: 10pt, weight: "bold")[#ctx.cycle • #ctx.annee-cycle • #ctx.annee-universitaire]
    ]
  )

  v(1.2cm)

  // Section 1 : Élève ingénieur
  text(size: 11pt, weight: "bold")[#ctx.dict.student_section]
  v(0.35cm)
  grid(
    columns: (auto, 1fr),
    column-gutter: 6pt,
    row-gutter: 6pt,
    text(weight: "regular")[#ctx.dict.first_name_label],
    text(weight: "medium")[#ctx.first-name],
    text(weight: "regular")[#ctx.dict.last_name_label],
    text(weight: "medium")[#ctx.last-name],
    text(weight: "regular")[#ctx.dict.major_label],
    text(weight: "medium")[#if ctx.major != none { ctx.major } else { "" }],
  )

  v(0.8cm)

  // Section 2 : Entreprise d'accueil
  text(size: 11pt, weight: "bold")[#ctx.dict.company_section]
  v(0.35cm)
  grid(
    columns: (auto, 1fr),
    column-gutter: 6pt,
    row-gutter: 6pt,
    text(weight: "regular")[#ctx.dict.company_name_label],
    text(weight: "medium")[#ctx.company-name],
    text(weight: "regular")[#ctx.dict.company_address_label],
    text(weight: "medium")[#ctx.company-address],
  )
  v(7pt)
  [
    #ctx.dict.confidential_label #h(5pt)
    #_stage-checkbox(checked: ctx.confidential == true) #ctx.dict.yes_label #h(10pt)
    #_stage-checkbox(checked: ctx.confidential == false) #ctx.dict.no_label
  ]
  v(7pt)
  [
    #ctx.dict.return_report_label #h(5pt)
    #_stage-checkbox(checked: ctx.return-to-supervisor == true) #ctx.dict.yes_label #h(10pt)
    #_stage-checkbox(checked: ctx.return-to-supervisor == false) #ctx.dict.no_label
  ]

  v(0.8cm)

  // Section 3 : Description de la mission
  text(size: 11pt, weight: "bold")[#ctx.dict.mission_section]
  v(0.35cm)
  if ctx.mission-description != none [
    #par(justify: true, leading: 0.65em)[#ctx.mission-description]
  ]
  if ctx.missions != () and ctx.missions != none [
    #v(5pt)
    #text(weight: "regular")[#ctx.dict.missions_intro]
    #v(3pt)
    #list(..ctx.missions.map(m => if type(m) == str { [ #m ] } else { m }))
  ]

  v(0.8cm)

  // Section 4 : Signature du Maître de Stage (obligatoire)
  text(size: 11pt, weight: "bold")[#ctx.dict.supervisor_signature_label]
  v(0.35cm)
  if ctx.supervisor-signature != none {
    if type(ctx.supervisor-signature) == content {
      ctx.supervisor-signature
    } else if type(ctx.supervisor-signature) == str {
      image(ctx.supervisor-signature, width: 4.5cm)
    } else {
      ctx.supervisor-signature
    }
  }
}

// Fiche d'évaluation officielle "Entreprise" (dernière page obligatoire)
#let fiche-evaluation-stage(ctx) = {
  page(
    header: none,
    footer: none,
    margin: (top: 1.6cm, bottom: 1.6cm, left: 2cm, right: 2cm),
  )[
    // En-tête officiel
    #grid(
      columns: (auto, 1fr),
      align: (left + top, right + top),
      _render-logo(ctx.logo, width: 4.5cm),
      align(right)[
        #text(size: 11.5pt, weight: "bold")[#ctx.dict.eval_stage_title] \
        #v(3pt)
        #text(size: 10pt, weight: "bold")[#ctx.cycle • #ctx.annee-cycle] \
        #v(3pt)
        #text(size: 10pt, weight: "bold")[#ctx.annee-universitaire]
      ]
    )

    #v(0.6cm)

    // Coordonnées étudiant & maître de stage
    #let _disp(val, placeholder) = if val != none and val != "" { val } else { text(fill: rgb("#999999"))[#placeholder] }
    #let student-display = _disp(ctx.student-name, "……………………………………………………")
    #let major-display = _disp(ctx.major, "…………………………")
    #let company-display = _disp(ctx.company-name, "………………………………………………………")
    #let sup-display = _disp(ctx.supervisor-name, "……………………………………………………")
    #let phone-display = _disp(ctx.supervisor-phone, "………………………………")
    #let email-display = _disp(ctx.supervisor-email, "………………………………………”")

    #set par(justify: false)
    #grid(
      columns: (1.2fr, 1fr),
      row-gutter: 6pt,
      [#text(weight: "bold")[#ctx.dict.eval_student_label] #student-display],
      [#text(weight: "bold")[#ctx.dict.eval_major_label] #major-display],
      grid.cell(colspan: 2)[#text(weight: "bold")[#ctx.dict.eval_company_label] #company-display],
      grid.cell(colspan: 2)[#text(weight: "bold")[#ctx.dict.eval_supervisor_label] #sup-display],
      [#text(weight: "bold")[#ctx.dict.eval_phone_label] #phone-display],
      [#text(weight: "bold")[#ctx.dict.eval_email_label] #email-display],
    )

    #v(0.4cm)

    // Construction dynamique du tableau d'évaluation
    #let sections = if ctx.evaluation-sections != none { ctx.evaluation-sections } else { get-default-sections(ctx.dict) }
    #let stroke-box = 0.6pt + black
    #let stroke-inner = (left: stroke-box, right: stroke-box, top: none, bottom: none)
    #let _c(body, colspan: 1, stroke: stroke-box, align: auto) = table.cell(colspan: colspan, stroke: stroke, align: align, body)

    #let table-cells = (
      _c(align: right, text(size: 8.5pt, style: "italic")[#ctx.dict.eval_half_points]),
      _c(align: center, text(size: 9.5pt, weight: "bold")[#ctx.dict.eval_note_header]),
    )
    #let grand-total = 0

    #for sec in sections {
      let sec-criteria = sec.at("criteria", default: ())
      let sec-total = sec.at("total", default: sec-criteria.map(c => c.at("max", default: 0)).sum())
      grand-total += sec-total

      table-cells.push(_c(colspan: 2, stroke: (left: stroke-box, right: stroke-box, top: stroke-box, bottom: none), text(weight: "bold", size: 9.5pt)[#sec.title]))
      for crit in sec-criteria {
        table-cells.push(_c(stroke: stroke-inner, pad(left: 10pt)[• #crit.label]))
        table-cells.push(_c(stroke: stroke-inner, [/#crit.max]))
      }
      let total-label = sec.at("total-label", default: "Total Note " + sec.title)
      table-cells.push(_c(text(weight: "bold")[#total-label]))
      table-cells.push(_c(text(weight: "bold")[/#sec-total]))
    }

    #table-cells.push(_c(text(weight: "bold")[#ctx.dict.eval_total]))
    #table-cells.push(_c(text(weight: "bold")[/#grand-total]))

    #let final-scale = ctx.at("evaluation-final-scale", default: 20)
    #table-cells.push(_c(ctx.dict.eval_soit))
    #table-cells.push(_c([/#final-scale]))

    #table(
      columns: (1fr, 75pt),
      inset: (x: 8pt, y: 3.2pt),
      align: (col, row) => if col == 0 { left + horizon } else { right + horizon },
      ..table-cells
    )

    #v(0.35cm)

    // Observations
    #rect(
      width: 100%,
      height: 3.4cm,
      stroke: stroke-box,
      inset: 8pt,
      align(top + left)[
        #text(weight: "bold", size: 9.5pt)[#ctx.dict.eval_observations]
        #if ctx.evaluation-observations != none [
          #v(4pt)
          #ctx.evaluation-observations
        ]
      ]
    )

    #v(0.35cm)

    // Signatures et cachet
    #let loc = if ctx.city != none { ctx.city } else { "……………………………" }
    #text(size: 9.5pt)[A #loc, le ……………………….]

    #v(0.5cm)
    #grid(
      columns: (1fr, 1fr),
      align: center,
      [
        #text(weight: "bold", size: 9.5pt)[#ctx.dict.eval_signature_supervisor] \
        #text(size: 8.5pt)[#ctx.dict.eval_mandatory]
        #if ctx.supervisor-signature != none [
          #v(6pt)
          #if type(ctx.supervisor-signature) == str {
            image(ctx.supervisor-signature, width: 3.5cm)
          } else {
            ctx.supervisor-signature
          }
        ]
      ],
      [
        #text(weight: "bold", size: 9.5pt)[#ctx.dict.eval_signature_stamp] \
        #text(size: 8.5pt)[#ctx.dict.eval_mandatory]
      ],
    )
  ]
}

// Modèle officiel Rapport de Stage ECE Paris
#let stage(
  student: none,
  first-name: none,
  prenom: none,
  last-name: none,
  nom: none,
  authors: none,

  company: none,
  entreprise: none,
  company-name: none,
  company-address: none,
  adresse-entreprise: none,

  confidential: none,
  confidentiel: none,
  return-to-supervisor: none,
  remettre-maitre-de-stage: none,
  remettre-tuteur: none,
  remettre-au-tuteur: none,

  mission: none,
  missions: (),
  mission-description: none,
  description-mission: none,

  maitre-de-stage: none,
  supervisor: none,
  tuteur: none,
  signature-maitre-de-stage: none,
  supervisor-signature: none,
  signature-tuteur: none,
  signature: none,
  maitre-de-stage-phone: none,
  telephone-maitre-de-stage: none,
  supervisor-phone: none,
  tuteur-telephone: none,

  cycle: none,
  annee-cycle: none,
  cycle-year: none,
  annee-universitaire: none,
  academic-year: none,

  evaluation-sections: none,
  grille-evaluation: none,
  evaluation-grid: none,
  evaluation-final-scale: 20,
  evaluation-observations: none,

  title: none,
  lang: "fr",
  major: none,
  majeure: none,
  promo: "ING5",
  groupe: none,
  city: none,
  logo: auto,
  draft: false,
  font: "Arial",
  font-size: 10pt,
  leading: 0.65em,
  show-header: false,
  header: auto,
  show-footer: true,
  footer: auto,
  ..rest-args,
  body
) = {
  let dict = if lang in i18n-stage { i18n-stage.at(lang) } else { i18n-stage.at("fr") }

  // Résolution élève
  let s_dict = if type(student) == dictionary { student } else { (:) }
  let s_str = if type(student) == str { student } else if type(authors) == str { authors } else if type(authors) == array and authors.len() > 0 {
    let a0 = authors.first()
    if type(a0) == dictionary { a0.at("name", default: "") } else { str(a0) }
  } else { "" }
  let s_parts = if s_str != "" { s_str.split(" ") } else { () }

  let act_first_name = _first(first-name, prenom, s_dict.at("first-name", default: s_dict.at("firstname", default: s_dict.at("prenom", default: none))), if s_parts.len() > 0 { s_parts.first() } else { none }, default: "")
  let act_last_name = _first(last-name, nom, s_dict.at("last-name", default: s_dict.at("lastname", default: s_dict.at("nom", default: none))), if s_parts.len() > 1 { s_parts.slice(1).join(" ") } else { none }, default: "")
  let student_full_name = if s_str != "" { s_str } else if "name" in s_dict { s_dict.name } else if act_first_name != "" or act_last_name != "" { (act_first_name + " " + act_last_name).trim() } else { none }
  let act_major = _first(major, majeure, s_dict.at("major", default: s_dict.at("majeure", default: none)))

  // Résolution entreprise
  let c_dict = if type(company) == dictionary { company } else if type(entreprise) == dictionary { entreprise } else { (:) }
  let c_str = if type(company) == str { company } else if type(entreprise) == str { entreprise } else { none }
  let act_company_name = _first(company-name, c_dict.at("name", default: c_dict.at("nom", default: none)), c_str, default: "")
  let act_company_address = _first(company-address, adresse-entreprise, c_dict.at("address", default: c_dict.at("adresse", default: none)), default: "")

  // Résolution confidentialité, retour & missions
  let act_confidential = _first(confidential, confidentiel, default: none)
  let act_return_report = _first(remettre-maitre-de-stage, return-to-supervisor, remettre-tuteur, remettre-au-tuteur, default: none)
  let act_mission_desc = _first(mission-description, description-mission, mission, default: none)

  // Résolution maître de stage & signature
  let sup_raw = _first(maitre-de-stage, supervisor, tuteur, default: none)
  let sup_dict = if type(sup_raw) == dictionary { sup_raw } else { (:) }
  let sup_name = if type(sup_raw) == str { sup_raw } else { sup_dict.at("name", default: sup_dict.at("nom", default: "")) }
  let sup_email = sup_dict.at("email", default: "")
  let sup_phone = _first(maitre-de-stage-phone, telephone-maitre-de-stage, supervisor-phone, tuteur-telephone, sup_dict.at("phone", default: sup_dict.at("tel", default: sup_dict.at("telephone", default: none))), default: "")
  let act_sig = _first(signature-maitre-de-stage, supervisor-signature, signature-tuteur, signature, default: none)

  // Cycle, années & grille d'évaluation
  let act_cycle = _first(cycle, default: dict.cycle_default)
  let act_annee_cycle = _first(annee-cycle, cycle-year, default: dict.year_default)
  let act_annee_univ = _first(annee-universitaire, academic-year, default: dict.academic_year_default)
  let act_eval_sections = _first(evaluation-sections, grille-evaluation, evaluation-grid, default: none)
  let act_authors = _first(authors, if student_full_name != none { (student_full_name,) } else { none }, default: ("Élève Ingénieur",))

  let stage-ctx = (
    dict: dict,
    first-name: act_first_name,
    last-name: act_last_name,
    student-name: student_full_name,
    major: act_major,
    company-name: act_company_name,
    company-address: act_company_address,
    confidential: act_confidential,
    return-to-supervisor: act_return_report,
    mission-description: act_mission_desc,
    missions: missions,
    supervisor-name: sup_name,
    supervisor-email: sup_email,
    supervisor-phone: sup_phone,
    supervisor-signature: act_sig,
    cycle: act_cycle,
    annee-cycle: act_annee_cycle,
    annee-universitaire: act_annee_univ,
    evaluation-sections: act_eval_sections,
    evaluation-final-scale: evaluation-final-scale,
    evaluation-observations: evaluation-observations,
    logo: logo,
    city: city,
  )

  base-report(
    dict: i18n-stage,
    title: if title != none { title } else { dict.default_title },
    authors: act_authors,
    supervisor: sup_name,
    major: act_major,
    promo: promo,
    groupe: groupe,
    city: city,
    logo: logo,
    draft: draft,
    font: font,
    font-size: font-size,
    leading: leading,
    show-header: show-header,
    header: header,
    show-footer: show-footer,
    footer: footer,
    table-of-contents: true,
    numbering-format: "1.1",
    heading-sizes: (18pt, 14pt, 12pt),
    cover: ctx => stage-cover(stage-ctx),
    ..rest-args,
  )[
    #body
    #fiche-evaluation-stage(stage-ctx)
  ]
}

#let rapport-stage = stage
