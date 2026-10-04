#import "@preview/dsek:0.1.0": *
#import "@preview/tidy:0.4.3"

#show: plain-document.with(
  title: [Documentation for `dsek`],
  doc-type: "Documentation",
  lang: "en",
  use-cover-page: true,
)

#let document-module(path, name) = {
  let path = "/src/documents/" + path
  let gh-base = "https://github.com/Dsek-LTH/dsek-typst/blob/main"

  let module = tidy.parse-module(
    read(path),
    enable-curried-functions: true,
    name: name,
    label-prefix: path.replace(".", ":") + ":",
    old-syntax: true,
  )

  show heading.where(level: 1): it => {
    pagebreak()
    it
  }
  show heading.where(level: 2): set heading(outlined: false)
  show heading.where(level: 2): it => {
    set text(size: 15pt)
    raw(it.body.text)
    parbreak()
  }
  show heading.where(level: 3): set heading(numbering: none)
  show heading.where(level: 4): set heading(numbering: none)

  heading[#name.trim(".typ")]

  link(gh-base + path)[Source code]

  tidy.show-module(
    show-module-name: false,
    first-heading-level: 1,
    show-outline: false,
    module,
  )
}

#document-module("plain-document.typ", "Plain document / Dokument")
#document-module("governing/statutes.typ", "Statutes / Stadgar")
#document-module("governing/regulations.typ", "Regulations / Reglemente")
#document-module("governing/strategic-goals.typ", "Strategic Goals / Strategiska mål")
#document-module("governing/policy.typ", "Policy")
#document-module("governing/guideline.typ", "Guideline / Riktlinje")
#document-module("meetings/agenda.typ", "Agenda / Föredragningslista")
#document-module("meetings/minutes.typ", "Minutes / Protokoll")
#document-module("meetings/notice.typ", "Notice / Kallelse")
#document-module("meetings/deliberations/board-response.typ", "Board response / Styrelsens svar")
#document-module("meetings/deliberations/consideration.typ", "Consideration / Handling")
#document-module("meetings/deliberations/motion.typ", "Motion")
#document-module("meetings/deliberations/proposal.typ", "Proposal / Proposition")
#document-module("other/requirements-profile.typ", "Requirements profile / Kravprofil")
#document-module("other/nomination.typ", "Nomination / Valförslag")
#document-module("other/plan-of-operations.typ", "Plan of operations / Verksamhetsplan")
#document-module("other/equal-treatment-plan.typ", "Equal treatment plan / Likabehandlingsplan")
