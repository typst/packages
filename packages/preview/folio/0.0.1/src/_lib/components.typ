#import "brand.typ": *
#import "utils.typ": format-currency, risk-color, risk-score

// ── Status chip (e.g. for projects) ─────────────────────────────────────────
#let status-chip(status) = {
  let color = if status == "Completado" { verde-exito } else if status == "En Progreso" { azul-medio } else {
    gris-texto
  }
  box(
    fill: color.lighten(80%),
    stroke: color,
    radius: 10pt,
    inset: (x: 8pt, y: 3pt),
    text(fill: color, size: 9pt, weight: "bold", status),
  )
}

// ── Priority badge (for requirements) ───────────────────────────────────────
#let priority-badge(p) = {
  let color = if p == "Alta" { rojo-error } else if p == "Media" { naranja-main } else { verde-exito }
  box(
    fill: color.lighten(75%),
    stroke: color,
    radius: 3pt,
    inset: (x: 5pt, y: 2pt),
    text(fill: color, size: size-small, weight: "bold", p),
  )
}

// ── Risk badge (for risk register) ──────────────────────────────────────────
#let risk-badge(prob, impact) = {
  let score = risk-score(prob, impact)
  let color = risk-color(score)

  let label = if score >= 6 { "Alto" } else if score >= 3 { "Medio" } else { "Bajo" }

  box(
    fill: color.lighten(75%),
    stroke: color,
    radius: 3pt,
    inset: (x: 5pt, y: 2pt),
    text(fill: color, size: size-small, weight: "bold", label),
  )
}

// ── Info Pair (for grid metadata) ───────────────────────────────────────────
#let info-pair(label, value) = {
  stack(
    spacing: 4pt,
    text(weight: "bold", size: 9pt, fill: gris-texto, label),
    text(size: size-body, value),
  )
}

// ── Team card ───────────────────────────────────────────────────────────────
#let team-card(member) = {
  box(
    stroke: gris-borde,
    radius: 6pt,
    inset: 10pt,
    width: 100%,
    stack(
      spacing: 4pt,
      text(weight: "bold", size: size-body, member.name),
      text(fill: gris-texto, size: 9pt, member.role),
      if "responsabilidades" in member or "responsibilities" in member {
        let resp = member.at("responsabilidades", default: member.at("responsibilities", default: ""))
        if resp != "" {
          v(2pt)
          text(size: size-small, fill: gris-texto, resp)
        }
      },
    ),
  )
}

// ── Section title ───────────────────────────────────────────────────────────
#let section-title(title, subtitle: none) = {
  v(8pt)
  text(size: size-header, weight: "bold", title)
  if subtitle != none {
    linebreak()
    text(size: size-body, fill: gris-texto, subtitle)
  }
  v(4pt)
  line(length: 100%, stroke: 0.5pt + gris-borde)
  v(6pt)
}

// ── Signature block ─────────────────────────────────────────────────────────
#let signature-block(name, date: none, role: none) = {
  box(
    width: 100%,
    stack(
      spacing: 4pt,
      v(30pt), // Space for physical signature
      line(length: 100%, stroke: 0.5pt + rgb("#bdbdbd")),
      text(size: 9pt, weight: "bold", name),
      if role != none { text(size: 8pt, fill: gris-texto, role) },
      if date != none { text(size: 8pt, fill: gris-texto, date) },
    ),
  )
}

// ── Reqs Table (for reuse in docs) ──────────────────────────────────────────
#let req-table(reqs) = {
  let total = reqs.map(r => r.qty * r.unit_cost).sum()

  table(
    columns: (auto, 1fr, auto, auto, auto, auto),
    fill: (col, row) => if row == 0 { azul-medio } else if calc.odd(row) { gris-claro } else { white },
    stroke: gris-borde,
    inset: (x: 8pt, y: 6pt),

    // Header
    table.header(
      text(fill: white, weight: "bold", size: 9pt, "ID"),
      text(fill: white, weight: "bold", size: 9pt, "Descripción"),
      text(fill: white, weight: "bold", size: 9pt, "Cantidad"),
      text(fill: white, weight: "bold", size: 9pt, "Unidad"),
      text(fill: white, weight: "bold", size: 9pt, "C. Unitario"),
      text(fill: white, weight: "bold", size: 9pt, "Subtotal"),
    ),

    // Rows
    ..reqs
      .map(r => {
        let subtotal = r.qty * r.unit_cost
        (
          text(size: size-small, str(r.id)),
          text(size: size-small, str(r.description)),
          text(size: size-small, align(right, str(r.qty))),
          text(size: size-small, str(r.unit)),
          text(size: size-small, align(right, format-currency(r.unit_cost))),
          text(size: size-small, weight: "bold", align(right, format-currency(subtotal))),
        )
      })
      .flatten(),

    // Total row
    table.cell(colspan: 5, align(right, text(weight: "bold", "TOTAL"))),
    text(weight: "bold", fill: azul-medio, align(right, format-currency(total))),
  )
}

// ── Budget summary box ──────────────────────────────────────────────────────
#let budget-summary(req-total, extras, grand-total) = {
  box(
    stroke: azul-medio,
    radius: 6pt,
    inset: 16pt,
    width: 100%,
    stack(
      spacing: 8pt,
      text(weight: "bold", size: 12pt, "Resumen de Presupuesto"),
      line(length: 100%, stroke: 0.5pt + gris-borde),
      grid(
        columns: (1fr, auto),
        gutter: 6pt,
        text("Subtotal requerimientos:"), text(weight: "bold", format-currency(req-total)),
        text("Costos adicionales:"), text(weight: "bold", format-currency(extras)),
        text(weight: "bold", "TOTAL:"),
        text(weight: "bold", fill: azul-medio, size: size-header, format-currency(grand-total)),
      ),
    ),
  )
}

// ── Gantt chart ─────────────────────────────────────────────────────────────
#let gantt-chart(phases, milestones, start_date, end_date) = {
  import "@preview/gantty:0.5.1" as gantty

  let drawer = (
    field: gantty.field.default-field-drawer,
    dependencies: gantty.dependencies.default-dependencies-drawer,
    sidebar: gantty.sidebar.default-sidebar-drawer.with(
      padding: 15pt,
      spacing: 12pt,
      formatters: (
        fase => align(right, text(weight: "bold", size: 10pt, smallcaps(fase.name))),
        act => align(right, text(size: 9pt, act.name)),
      ),
      dividers: (
        (stroke: (paint: azul-medio, thickness: 1.5pt)),
        (stroke: (paint: gris-borde, thickness: 0.5pt)),
      ),
      stroke: (paint: azul-oscuro, thickness: 1pt),
    ),
    headers: gantty.header.default-headers-drawer.with(headers: (
      gantty.header.default-month-header(
        table-style: (stroke: (paint: azul-oscuro, thickness: 1.5pt)),
      ),
      gantty.header.default-day-header(
        table-style: (stroke: (paint: azul-claro, thickness: 0.5pt)),
        gridlines-style: (stroke: (paint: gris-borde, thickness: 0.2pt, dash: "dotted")),
      ),
    )),
    tasks: gantty.task.default-tasks-drawer.with(
      styles: (
        (uncompleted: (style: (fill: azul-medio, stroke: azul-oscuro), width: 16pt)),
        (uncompleted: (style: (fill: azul-claro, stroke: azul-medio), width: 10pt)),
      ),
    ),
    dividers: gantty.dividers.default-dividers-drawer.with(styles: (
      (stroke: (paint: azul-medio, thickness: 1pt)),
      (stroke: (paint: gris-borde, thickness: 0.4pt)),
    )),
    milestones: gantty.milestones.default-milestones-drawer.with(
      style: (stroke: (paint: naranja-main, thickness: 2pt)),
    ),
  )

  let gantt-data = (
    start: start_date,
    end: end_date,
    tasks: phases,
    milestones: milestones,
  )

  gantty.gantt(gantt-data, drawer: drawer)
}
