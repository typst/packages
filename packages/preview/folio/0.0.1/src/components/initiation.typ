#import "../core/resolve.typ": get-title, resolve
#import "../core/state.typ": folio-state
#import "../theme/ui.typ": badge, card, data-table
#import "../theme/resolver.typ": resolve-token
#import "../core/refs.typ": (
  assumption-label, link-to-objective, link-to-risk, objective-label,
  stakeholder-label,
)

#let cover() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))

  let name = resolve(data, "project.name")
  let desc = resolve(data, "project.description")

  align(center + horizon)[
    #text(size: resolve-token(st, "typography.size.xl"), weight: "bold")[#name]
    #v(1em)
    #text(size: resolve-token(st, "typography.size.lg"), style: "italic")[#desc]
  ]
}

#let pitch(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Elevator Pitch")]
  let val = resolve(data, data-path)
  card[#val]
}

#let business-case(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Business Case")]
  let val = resolve(data, data-path)
  card[#val]
}

#let objectives(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Project Objectives")]

  let obj-list = resolve(data, data-path)
  if type(obj-list) == array {
    data-table(
      columns: (auto, 1fr, auto),
      headers: ("ID", "Objective", "Priority"),
      rows: obj-list
        .map(o => {
          let oid = o.at("id", default: "-")
          (
            [#oid#objective-label(oid)],
            o.at("description", default: "-"),
            badge(o.at("priority", default: "neutral"), intent: if o.at(
              "priority",
              default: "",
            )
              == "high" { "danger" } else { "neutral" }),
          )
        })
        .flatten(),
    )
  } else {
    [#obj-list]
  }
}

#let success-criteria(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Success Criteria")]

  let criteria = resolve(data, data-path)
  if type(criteria) == array {
    data-table(
      columns: (auto, auto, 1fr, auto, auto),
      headers: ("ID", "Type", "Criterion", "Measurement", "Objective"),
      rows: criteria
        .map(c => {
          let obj-id = c.at("objective_id", default: none)
          (
            c.at("id", default: "-"),
            badge(c.at("type", default: "project"), intent: "neutral"),
            c.at("criterion", default: "-"),
            c.at("measurement", default: "-")
              + " → "
              + c.at("target", default: "-"),
            if obj-id != none { link-to-objective(obj-id) } else { "-" },
          )
        })
        .flatten(),
    )
  } else {
    [#criteria]
  }
}

#let stakeholders(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Stakeholder Register")]

  let shs = resolve(data, data-path)
  if type(shs) == array {
    data-table(
      columns: (auto, 1fr, auto, auto, auto, auto),
      headers: (
        "ID",
        "Name / Role",
        "Organization",
        "Interest",
        "Influence",
        "Engagement",
      ),
      rows: shs
        .map(s => {
          let sid = s.at("id", default: "-")
          (
            [#sid#stakeholder-label(sid)],
            [*#s.at("name", default: "-")* — #s.at("role", default: "-")],
            s.at("organization", default: "-"),
            badge(s.at("interest", default: "low"), intent: if s.at(
              "interest",
              default: "",
            )
              == "high" { "danger" } else if s.at("interest", default: "")
              == "medium" { "warning" } else { "neutral" }),
            badge(s.at("influence", default: "low"), intent: if s.at(
              "influence",
              default: "",
            )
              == "high" { "danger" } else if s.at("influence", default: "")
              == "medium" { "warning" } else { "neutral" }),
            s.at("engagement", default: "-"),
          )
        })
        .flatten(),
    )
  } else {
    [#shs]
  }
}

#let assumptions-log(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Assumptions Log")]

  let items = resolve(data, data-path)
  if type(items) == array {
    data-table(
      columns: (auto, auto, 1fr, auto, auto),
      headers: ("ID", "Type", "Description", "Status", "Risk"),
      rows: items
        .map(a => {
          let aid = a.at("id", default: "-")
          let risk-id = a.at("risk_id", default: none)
          (
            [#aid#assumption-label(aid)],
            badge(a.at("type", default: "assumption"), intent: "neutral"),
            a.at("description", default: "-"),
            badge(a.at("status", default: "Open"), intent: if a.at(
              "status",
              default: "",
            )
              == "Validated" { "success" } else if a.at("status", default: "")
              == "Invalidated" { "danger" } else { "neutral" }),
            if risk-id != none { link-to-risk(risk-id) } else { "-" },
          )
        })
        .flatten(),
    )
  } else {
    [#items]
  }
}
