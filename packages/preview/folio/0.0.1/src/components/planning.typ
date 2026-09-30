#import "../core/resolve.typ": get-title, resolve
#import "../core/state.typ": folio-state
#import "../theme/ui.typ": badge, card, data-table, metric
#import "../utils/formatters.typ": format-date, format-money
#import "../theme/resolver.typ": resolve-token
#import "../core/refs.typ": (
  compliance-label, link-to-compliance, link-to-req, milestone-label, req-label,
  task-label,
)
#import "@preview/gantty:0.5.1" as gantty
#import "../compute.typ" as compute

#let boundaries(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Project Boundaries (Scope)")]

  let scope = resolve(data, data-path)
  if type(scope) == dictionary {
    let in-items = scope.at("in_scope", default: ())
    if type(in-items) == str { in-items = (in-items,) }
    if type(in-items) == array and in-items.len() > 0 {
      card(title: "In Scope")[
        #list(..in-items)
      ]
    }
    let out-items = scope.at("out_of_scope", default: ())
    if type(out-items) == str { out-items = (out-items,) }
    if type(out-items) == array and out-items.len() > 0 {
      card(title: "Out of Scope")[
        #list(..out-items)
      ]
    }
  } else {
    [#scope]
  }
}

#let requirements(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Requirements Register")]

  let reqs = resolve(data, data-path)
  if type(reqs) != array {
    [#reqs]
    return
  }

  // Group by category
  let categories = reqs.map(r => r.at("category", default: "General")).dedup()

  for cat in categories {
    let cat-reqs = reqs.filter(r => r.at("category", default: "General") == cat)
    let subtotal = cat-reqs.fold(0.0, (acc, r) => {
      let qty = float(r.at("qty", default: 1))
      let uc = float(r.at("unit_cost", default: 0))
      acc + qty * uc
    })

    card(title: cat)[
      #data-table(
        columns: (auto, 1fr, auto, auto, auto, auto),
        headers: ("ID", "Description", "Qty", "Unit", "Unit Cost", "Priority"),
        rows: cat-reqs
          .map(r => {
            let rid = r.at("id", default: "-")
            let c-ids = r.at("compliance_ids", default: ())
            if type(c-ids) == str { c-ids = (c-ids,) }
            (
              [#rid#req-label(rid)],
              [
                #r.at("description", default: "-")
                #c-ids.map(id => [ #link-to-compliance(id)]).join()
              ],
              str(r.at("qty", default: 1)),
              r.at("unit", default: "—"),
              if r.at("unit_cost", default: 0) > 0 {
                format-money(r.at("unit_cost", default: 0))
              } else { "—" },
              badge(r.at("priority", default: "medium"), intent: if r.at(
                "priority",
                default: "",
              )
                == "high" { "danger" } else if r.at("priority", default: "")
                == "low" { "neutral" } else { "warning" }),
            )
          })
          .flatten(),
      )
      #if subtotal > 0 {
        align(right)[*Subtotal: #format-money(subtotal)*]
      }
    ]
  }
}

#let milestones(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Milestones")]

  let ms-list = resolve(data, data-path)
  if type(ms-list) == array {
    data-table(
      columns: (auto, 1fr, auto),
      headers: ("Date", "Milestone", "Status"),
      rows: ms-list
        .map(m => {
          let mid = m.at("id", default: m.at("title", default: ""))
          (
            format-date(m.at("date", default: "")),
            [#m.at("title", default: "")#milestone-label(mid)],
            badge(m.at("status", default: "Pending"), intent: if m.at(
              "status",
              default: "",
            )
              == "Done" { "success" } else { "neutral" }),
          )
        })
        .flatten(),
    )
  } else {
    [#ms-list]
  }
}

// Budget: new rich (line_items, extra_costs) dict shape only.
#let budget(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Budget Details")]

  let raw = resolve(data, data-path)
  if type(raw) != dictionary {
    [#raw]
    return
  }

  let line-items = raw.at("line_items", default: ())
  let extra-costs = raw.at("extra_costs", default: ())

  let categories = line-items
    .map(i => i.at("category", default: "General"))
    .dedup()
  let sub = compute.line-subtotal(line-items)

  for cat in categories {
    let cat-items = line-items.filter(i => (
      i.at("category", default: "General") == cat
    ))
    let cat-total = compute.line-subtotal(cat-items)

    card(title: cat)[
      #data-table(
        columns: (auto, 1fr, auto, auto, auto, auto),
        headers: ("ID", "Description", "Qty", "Unit", "Unit Cost", "Total"),
        rows: cat-items
          .map(i => {
            let total = (
              float(i.at("qty", default: 1))
                * float(i.at("unit_cost", default: 0))
            )
            let req-id = i.at("req_id", default: none)
            (
              i.at("id", default: "-"),
              if req-id != none {
                [#i.at("description", default: "-") (#link-to-req(req-id))]
              } else { i.at("description", default: "-") },
              str(i.at("qty", default: 1)),
              i.at("unit", default: "—"),
              format-money(i.at("unit_cost", default: 0)),
              format-money(total),
            )
          })
          .flatten(),
      )
      #align(right)[*Category subtotal: #format-money(cat-total)*]
    ]
  }

  if extra-costs.len() > 0 {
    let show-extras = extra-costs
      .map(e => {
        let amt = if e.at("percentage", default: none) != none {
          sub * float(e.at("percentage", default: 0))
        } else { float(e.at("cost", default: 0)) }
        (e.at("description", default: "-"), format-money(amt))
      })
      .flatten()
    card(title: "Additional Costs")[
      #data-table(
        columns: (1fr, auto),
        headers: ("Description", "Amount"),
        rows: show-extras,
      )
    ]
  }

  let ext = compute.extras-total(extra-costs, sub)
  let grand = sub + ext
  card[
    #stack(
      dir: ltr,
      spacing: 3em,
      metric("Line Items Subtotal", format-money(sub)),
      metric("Additional Costs", format-money(ext)),
      metric("Grand Total", format-money(grand), intent: "success"),
    )
  ]
}

// Internal helper to build the gantty drawer from folio tokens
#let _build-gantty-drawer(st) = {
  let primary = resolve-token(st, "palette.primary")
  let neutral = resolve-token(st, "palette.intent.neutral")
  let border = resolve-token(st, "palette.surface.border")
  let warning = resolve-token(st, "palette.intent.warning")
  let md-size = resolve-token(st, "typography.size.md")
  let sm-size = resolve-token(st, "typography.size.sm")

  let bar-h = resolve-token(st, "geometry.gantt.bar-height")
  let sub-bar-h = resolve-token(st, "geometry.gantt.subtask-bar-height")
  let side-pad = resolve-token(st, "geometry.gantt.sidebar-padding")
  let side-spacing = resolve-token(st, "geometry.gantt.sidebar-spacing")

  (
    field: gantty.field.default-field-drawer,
    dependencies: gantty.dependencies.default-dependencies-drawer,
    sidebar: gantty.sidebar.default-sidebar-drawer.with(
      padding: side-pad,
      spacing: side-spacing,
      formatters: (
        fase => align(right, text(weight: "bold", size: md-size, smallcaps(
          fase.name,
        ))),
        act => align(right, text(size: sm-size, fill: neutral, act.name)),
      ),
      dividers: (
        (stroke: (paint: primary, thickness: 1.5pt)),
        (stroke: (paint: border, thickness: 0.5pt)),
      ),
      stroke: (paint: primary, thickness: 1pt),
    ),
    headers: gantty.header.default-headers-drawer.with(headers: (
      gantty.header.default-month-header(
        table-style: (stroke: (paint: primary, thickness: 1.5pt)),
      ),
      gantty.header.default-day-header(
        table-style: (stroke: (paint: primary.lighten(60%), thickness: 0.5pt)),
        gridlines-style: (
          stroke: (paint: border, thickness: 0.2pt, dash: "dotted"),
        ),
      ),
    )),
    tasks: gantty.task.default-tasks-drawer.with(
      styles: (
        (
          uncompleted: (
            style: (fill: primary, stroke: primary.darken(20%)),
            width: bar-h,
          ),
        ),
        (
          uncompleted: (
            style: (fill: primary.lighten(40%), stroke: primary),
            width: sub-bar-h,
          ),
        ),
      ),
    ),
    dividers: gantty.dividers.default-dividers-drawer.with(styles: (
      (stroke: (paint: primary, thickness: 1pt)),
      (stroke: (paint: border, thickness: 0.4pt)),
    )),
    milestones: gantty
      .milestones
      .default-milestones-drawer
      .with(
        style: (stroke: (paint: warning, thickness: 2pt)),
      ),
  )
}

// Gantt: nested (start, end, tasks, milestones) dict shape only.
#let gantt(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Gantt Chart")]

  let raw = resolve(data, data-path)
  if type(raw) != dictionary {
    [#raw]
    return
  }

  gantty.gantt(
    (
      start: raw.at("start", default: ""),
      end: raw.at("end", default: ""),
      tasks: raw.at("tasks", default: ()),
      milestones: raw.at("milestones", default: ()),
    ),
    drawer: _build-gantty-drawer(st),
  )
}

#let team(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Project Team")]

  let members = resolve(data, data-path)
  if type(members) == array {
    data-table(
      columns: (auto, 1fr, auto),
      headers: ("Role", "Name", "Contact"),
      rows: members
        .map(m => (
          m.at("role", default: "-"),
          m.at("name", default: "-"),
          m.at("email", default: "-"),
        ))
        .flatten(),
    )
  } else {
    [#members]
  }
}

#let quality(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Quality Plan")]

  let q = resolve(data, data-path)
  if type(q) != dictionary {
    [#q]
    return
  }

  let standards = q.at("standards", default: ())
  if standards.len() > 0 {
    card(title: "Standards")[
      #list(..standards)
    ]
  }

  let accept-proc = q.at("acceptance_procedure", default: none)
  if accept-proc != none {
    card(title: "Acceptance Procedure")[#accept-proc]
  }

  let testing = q.at("testing_strategy", default: none)
  if testing != none {
    card(title: "Testing Strategy")[#testing]
  }

  let criteria = q.at("criteria", default: ())
  if type(criteria) == array and criteria.len() > 0 {
    card(title: "Quality Criteria")[
      #data-table(
        columns: (auto, 1fr, auto),
        headers: ("Requirement", "Criterion", "Method"),
        rows: criteria
          .map(c => (
            link-to-req(c.at("req_id", default: "-")),
            c.at("criterion", default: "-"),
            c.at("method", default: "-"),
          ))
          .flatten(),
      )
    ]
  }
}

#let communication(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Communication Plan")]

  let comms = resolve(data, data-path)
  if type(comms) == array {
    data-table(
      columns: (1fr, auto, auto, auto, auto),
      headers: ("What", "Audience", "Frequency", "Channel", "Owner"),
      rows: comms
        .map(c => (
          c.at("what", default: "-"),
          c.at("audience", default: "-"),
          c.at("frequency", default: "-"),
          c.at("channel", default: "-"),
          c.at("owner", default: "-"),
        ))
        .flatten(),
    )
  } else {
    [#comms]
  }
}

#let risk-strategy(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Risk Management Strategy")]

  let rs = resolve(data, data-path)
  if type(rs) != dictionary {
    [#rs]
    return
  }

  let approach = rs.at("approach", default: none)
  if approach != none { card(title: "Approach")[#approach] }

  let cats = rs.at("categories", default: ())
  if cats.len() > 0 {
    card(title: "Risk Categories")[
      #list(..cats)
    ]
  }

  let scoring = rs.at("scoring", default: none)
  let tolerance = rs.at("tolerance", default: none)
  let threshold = rs.at("escalation_threshold", default: none)

  if scoring != none or tolerance != none or threshold != none {
    card(title: "Thresholds & Scoring")[
      #if scoring != none { [*Scoring:* #scoring \ ] }
      #if tolerance != none { [*Tolerance:* #tolerance \ ] }
      #if threshold != none { [*Escalation threshold:* #threshold] }
    ]
  }
}

#let compliance(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Compliance Register")]

  let items = resolve(data, data-path)
  if type(items) == array {
    data-table(
      columns: (auto, 1fr, auto, auto, auto),
      headers: ("ID", "Regulation", "Jurisdiction", "Requirements", "Status"),
      rows: items
        .map(c => {
          let req-ids = c.at("req_ids", default: ())
          if type(req-ids) == str { req-ids = (req-ids,) }
          let audit-date = c.at("audit_date", default: none)
          let cid = c.at("id", default: "-")
          (
            [#cid#compliance-label(cid)],
            [*#c.at("regulation", default: "-")*#if audit-date != none { [\ Audit: #format-date(audit-date)] }],
            c.at("jurisdiction", default: "—"),
            if req-ids.len() > 0 { req-ids.map(link-to-req).join(", ") } else {
              "—"
            },
            badge(c.at("status", default: "Pending"), intent: if c.at(
              "status",
              default: "",
            )
              == "Compliant" { "success" } else if c.at("status", default: "")
              == "Non-compliant" { "danger" } else { "neutral" }),
          )
        })
        .flatten(),
    )
  } else {
    [#items]
  }
}
