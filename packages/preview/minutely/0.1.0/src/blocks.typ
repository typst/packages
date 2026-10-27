#import "i18n.typ": tr, fmt-date

#let _box(body) = block(
  width: 100%, inset: 10pt, radius: 4pt, stroke: 0.5pt + luma(200), breakable: false, body,
)

#let _side(label, no, body) = {
  v(0.4em)
  block(width: 100%, inset: (left: 0.8em, y: 0.3em), stroke: (left: 1.5pt + luma(180)), {
    strong(label)
    if no != none { h(0.5em); text(fill: luma(80))[§#no] }
    parbreak()
    body
  })
}

#let _count(v) = if type(v) == array { v.len() } else if type(v) == str { 1 } else if v == none { 0 } else { v }
#let _names(v) = if type(v) == array and v.len() > 0 { v.join(linebreak()) } else if type(v) == str { v }

// Vote: each of agrees/against/abstain is a number, a name, or an array of names.
// decision: none = computed from the counts; true/"yes" = passed, false/"no" = rejected,
// anything else is shown as-is.
#let vote(question: none, agrees: 0, against: 0, abstain: 0, decision: none, result: auto) = {
  let (f, a, b) = (agrees, against, abstain).map(_count)
  let decision = if decision == none and result != auto { result } else { decision }
  let verdict = if decision in (true, "yes", "ja") { tr("passed") }
    else if decision in (false, "no", "nej") { tr("rejected") }
    else if decision != none { decision }
    else if f > a { tr("passed") } else if f < a { tr("rejected") } else { tr("tie") }
  let cell(label, n, v) = align(center)[
    *#label* \ #n
    #let names = _names(v)
    #if names != none { linebreak(); text(0.85em, names) }
  ]
  _box({
    if question != none { strong(question); v(6pt) }
    grid(columns: (1fr, 1fr, 1fr),
      cell(tr("for"), f, agrees), cell(tr("against"), a, against), cell(tr("abstain"), b, abstain))
    v(8pt)
    align(center, strong(verdict))
  })
}

// Responsibility tag: `- Get answer from X #resp("Simon")`.
#let resp(..names) = {
  h(1em)
  box(inset: (x: 0.8em, y: 0.35em), fill: luma(225), radius: 2pt,
    text(9pt, weight: "bold")[#tr("responsible"): #names.pos().join(", ")])
}
#let ansvar = resp

#let proposal(no: none, body) = _side(tr("proposal"), no, body)

// Amendment: either free text (`#amendment(no: 3)[...]`) or before/after.
#let amendment(no: none, before: none, after: none, ..body) = _side(tr("amendment"), no, {
  body.pos().join()
  if before != none [*#tr("before"):* #before #parbreak()]
  if after != none [*#tr("after"):* #after]
})

#let next-meeting(date: none, time: none, location: none, note: none) = {
  v(1em)
  heading(level: 1, tr("next-meeting"))
  if date != none { fmt-date(date) }
  if time != none [ #tr("at") #time]
  if location != none [ #tr("in") #location]
  if note != none { parbreak(); note }
}
