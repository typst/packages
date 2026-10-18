#import "@preview/gantty:0.5.1": gantt
#import "practicas-utils.typ": (
  activity_end_date, activity_start_date, calc_total_hours, get_period_end, get_period_end_str,
  is_working_day, normalize_activity,
)

#let DATE_FMT_STR = "[day]/[month]/[year]"

#let _activities = state("activities", none)
#let _period_start = state("period_start", none)
#let _hours_per_day = state("hours_per_day", none)

#let _caratula(
  title: none,
  author: none,
  id: none,
  advisor: none,
  company: none,
  boss: none,
  field: none,
  period: none,
  schedule: none,
  hours: none,
  /// school specific
  university: none,
  faculty: none,
  school: none,
  school-logo: none,
  ///
) = {
  place(
    float: true,
    auto,
    scope: "parent",
    clearance: 2em,
  )[
    #set par(first-line-indent: 0em, leading: 1em)
    #set text(size: 0.85em, weight: "bold")
    #layout(size => {
      let middle = [
        #text(1.55em)[_ #title _] #h(0pt, weak: true)

        #university #h(0pt, weak: true)

        #faculty #h(0pt, weak: true)

        #school #h(0pt, weak: true)
      ]
      block(height: 2.95cm)[
        #grid(
          columns: (1fr, 4fr, 1fr),
          // column-gutter: 3em,
          column-gutter: 10pt,
          align: (right + horizon, center + horizon, left + horizon),
          image("imgs/unsaac_logo.png"), middle, school-logo,
        )
      ]
    })
  ]

  let sep = ":"
  let rows = ()
  if author != none { rows += (smallcaps[- *Practicante*], [*#sep*], [#author]) }
  if id != none { rows += (smallcaps[- *Código*], [*#sep*], [#id]) }
  if advisor != none { rows += (smallcaps[- *Asesor*], [*#sep*], [#advisor]) }
  if company != none { rows += (smallcaps[- *Empresa*], [*#sep*], [#company]) }
  if boss != none { rows += (smallcaps[- *Jefe Inmediato*], [*#sep*], [#boss]) }
  if field != none { rows += (smallcaps[- *Área*], [*#sep*], [#field]) }
  if period != none { rows += (smallcaps[- *Período*], [*#sep*], [#period]) }
  if schedule != none { rows += (smallcaps[- *Horario*], [*#sep*], [#schedule]) }
  if hours != none { rows += (smallcaps[- *Total de horas*], [*#sep*], [#hours]) }
  grid(
    columns: (auto, auto, auto),
    gutter: 1em,
    ..rows,
  )
}

#let _signature_block(
  company_manager: none,
  author: none,
  advisor: none,
) = {
  let rows = ()
  if company_manager != none {
    rows.push((key: smallcaps[*Encargado del\ lugar de prácticas*], value: [#company_manager]))
  }
  if author != none { rows.push((key: smallcaps[*Alumno Practicante*], value: [#author])) }
  if advisor != none { rows.push((key: smallcaps[*Docente Asesor*], value: [#advisor])) }
  block(
    breakable: false,
    grid(
      columns: rows.map(_ => 1fr),
      gutter: 0.5em,
      align: center + horizon,
      ..rows.map(_ => [#v(3em)]),
      ..rows.map(_ => [#box(width: 5cm, baseline: 5pt, stroke: (bottom: 0.5pt + luma(150)))]),
      ..rows.map(r => [#r.key]),
      ..rows.map(r => [#r.value]),
    ),
  )
}

#let doc-practica-plan-actividades(
  titulo: none,
  autor: none,
  codigo: none,
  area: none,
  fecha-inicio: none,
  horario: none,
  empresa: none,
  jefe: none,
  asesor: none,
  actividades: none,
  horas-por-dia: 6,
  excluir-fin-semana: true, // TODO
  excluir-feriados: true, // TODO
  /// school specific
  facultad: [Ingeniería Eléctrica, Electrónica, Informática y Mecánica],
  escuela: [Ingeniería Informática y de Sistemas],
  escuela-logo: image("imgs/escuela_logo.png"),
  ///
  doc,
) = {
  assert(type(fecha-inicio) == datetime, message: "'fecha-inicio' must be a datetime")
  assert(
    is_working_day(fecha-inicio),
    message: "'fecha-inicio' must be a working day (not a weekend or holiday)",
  )
  _activities.update(actividades.map(act => normalize_activity(act, horas-por-dia)))
  _hours_per_day.update(horas-por-dia)
  _period_start.update(fecha-inicio)

  set page(
    paper: "a4",
    // binding: start, // TODO: wait till its supported for 'duplex' param
    flipped: true,
    margin: (
      rest: 2cm,
    ),
  )
  set text(
    font: "TeX Gyre Termes",
    spacing: 0.35em,
    lang: "es",
    region: "pe",
  )
  set par(
    first-line-indent: 1.2em,
    leading: 0.65em,
    justify: true,
  )
  set heading(numbering: "1.")
  show heading.where(level: 1): set block(below: 1em)
  set list(indent: 1.2em, spacing: 0.85em)

  _caratula(
    title: titulo,
    author: autor,
    id: codigo,
    company: empresa,
    field: area,
    period: get_period_end_str(fecha-inicio, horas-por-dia, actividades),
    schedule: horario,
    hours: calc_total_hours(actividades),
    ///
    university: upper[Universidad Nacional de San Antonio Abad Del Cusco],
    faculty: upper[Facultad de #facultad],
    school: upper[Escuela Profesional de #escuela],
    school-logo: escuela-logo,
  )

  doc

  v(1fr)
  _signature_block(
    company_manager: jefe,
    author: autor,
    advisor: asesor,
  )
  v(1fr)
}

#let doc-practica-informe-parcial(
  titulo: none,
  autor: none,
  codigo: none,
  area: none,
  fecha-inicio: none,
  horario: none,
  empresa: none,
  jefe: none,
  asesor: none,
  actividades: none,
  horas-por-dia: 6,
  excluir-fin-semana: true,
  excluir-feriados: true,
  /// school specific
  facultad: [Ingeniería Eléctrica, Electrónica, Informática y Mecánica],
  escuela: [Ingeniería Informática y de Sistemas],
  escuela-logo: image("imgs/escuela_logo.png"),
  ///
  duplex: false,
  binding-margin: 0%,
  doc,
) = {
  assert(type(fecha-inicio) == datetime, message: "'fecha-inicio' must be a datetime")
  assert(
    is_working_day(fecha-inicio),
    message: "'fecha-inicio' must be a working day (not a weekend or holiday)",
  )
  _activities.update(actividades.map(act => normalize_activity(act, horas-por-dia)))
  _hours_per_day.update(horas-por-dia)
  _period_start.update(fecha-inicio)

  let margin = 2cm
  let margins = if duplex {
    (
      inside: margin + binding-margin,
      outside: margin - binding-margin,
    )
  } else {
    (
      left: margin + binding-margin,
    )
  }

  set page(
    paper: "a4",
    margin: (
      ..margins,
      rest: margin,
    ),
  )
  set text(
    font: "TeX Gyre Termes",
    spacing: 0.35em,
    lang: "es",
    region: "pe",
  )
  set par(
    first-line-indent: 1.2em,
    leading: 0.65em,
    justify: true,
  )
  set heading(numbering: "1.")
  show heading.where(level: 1): set block(below: 1em)
  set list(indent: 1.2em, spacing: 0.85em)
  set enum(indent: 1.2em, spacing: 0.85em)
  /// TODO: https://github.com/typst/typst/issues/905
  set enum(
    full: true,
    numbering: (..args) => {
      let nums = args.pos()
      let style_per_level = ("1.", "a)", "(i)")
      numbering(
        style_per_level.at(nums.len() - 1, default: "1."),
        nums.at(nums.len() - 1),
      )
    },
  )

  _caratula(
    title: titulo,
    author: autor,
    id: codigo,
    advisor: asesor,
    company: empresa,
    boss: jefe,
    field: area,
    period: get_period_end_str(fecha-inicio, horas-por-dia, actividades),
    schedule: horario,
    hours: calc_total_hours(actividades),
    ///
    university: upper[Universidad Nacional de San Antonio Abad Del Cusco],
    faculty: upper[Facultad de #facultad],
    school: upper[Escuela Profesional de #escuela],
    school-logo: escuela-logo,
  )

  doc

  v(1fr)
  _signature_block(
    advisor: asesor,
  )
  v(1fr)
}

#let actividades-tabla(actividades: none) = {
  context {
    let acts = if actividades != none { actividades } else { _activities.get() }
    if acts == none or acts.len() == 0 { return }

    let tcolors = (
      header_bg: rgb("#1f4e79"),
      header_fg: white,
      odd_row: luma(245),
      even_row: none,
    )

    let cum = 0
    let rows = ()
    for (idx, act) in acts.enumerate(start: 1) {
      let start = activity_start_date(_period_start.get(), _hours_per_day.get(), cum)
      cum += act.at("duracion", default: 0)
      let end = activity_end_date(_period_start.get(), _hours_per_day.get(), cum)
      rows.push((
        [#idx],
        act.at("nombre", default: none),
        act.at("descripcion", default: none),
        [#start.display(DATE_FMT_STR)],
        [#end.display(DATE_FMT_STR)],
      ))
    }

    table(
      columns: (auto, 2fr, 4fr, auto, auto),
      align: (center, left, left, center, center),
      fill: (x, y) => if calc.odd(y) {
        tcolors.odd_row
      } else {
        tcolors.even_row
      },
      table.header(
        table.cell(fill: tcolors.header_bg, text(fill: tcolors.header_fg)[Nro]),
        table.cell(fill: tcolors.header_bg, text(fill: tcolors.header_fg)[Actividad]),
        table.cell(fill: tcolors.header_bg, text(fill: tcolors.header_fg)[Descripción]),
        table.cell(fill: tcolors.header_bg, text(fill: tcolors.header_fg)[Fecha Inicio]),
        table.cell(fill: tcolors.header_bg, text(fill: tcolors.header_fg)[Fecha Fin]),
      ),
      ..rows.flatten(),
    )
  }
}

#let actividades-contenidos(actividades: none) = {
  context {
    let acts = if actividades != none { actividades } else { _activities.get() }
    if acts == none or acts.len() == 0 { return }

    let cum = 0
    for act in acts {
      let activity = act.at("nombre", default: none)
      let details = act.at("contenido", default: none)

      if activity == none { continue }

      let start = activity_start_date(_period_start.get(), _hours_per_day.get(), cum)
      cum += act.at("duracion", default: 0)
      let end = activity_end_date(_period_start.get(), _hours_per_day.get(), cum)

      [
        + #block(breakable: false)[
            *#activity* \
            #h(1fr) (#start.display(DATE_FMT_STR) - #end.display(DATE_FMT_STR)) \
            #if details != none { details }]
          #v(1em)
      ]
    }
  }
}

#let actividades-gantt(actividades: none) = {
  context {
    let acts = if actividades != none { actividades } else { _activities.get() }
    if acts == none or acts.len() == 0 { return }

    let gantt_chart = (
      tasks: acts
        .enumerate()
        .map(((act_i, act)) => (
          name: [#act.nombre],
          subtasks: act
            .gantt
            .enumerate()
            .map(((i, st)) => {
              // hack because inside context can't access external variable
              let hours = (
                acts.slice(0, act_i).fold(0, (acc, x) => acc + x.at("duracion", default: 0))
                  + act.gantt.slice(0, i).fold(0, (acc, x) => acc + x.at("duracion", default: 0))
              )
              let start = activity_start_date(_period_start.get(), _hours_per_day.get(), hours)
              hours += st.at("duracion", default: 0)
              let end = activity_end_date(_period_start.get(), _hours_per_day.get(), hours)

              // end_of_working_day returns the last inclusive working day;
              // gantty expects an exclusive end, so always advance by 1.
              // Clamp: a partial-day subtask whose hours don't push the cumulative
              // total past the next day boundary gets end == prev subtask's end < start.
              // Show it for at least 1 day starting from start.
              (
                name: st.at("nombre", default: none),
                start: start,
                end: (if end < start { start } else { end }) + duration(days: 1),
              )
            }),
        )),
    )

    [
      #set text(size: 0.70em)
      #gantt(gantt_chart)
    ]
  }
}
