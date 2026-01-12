#let accent-color = rgb("#26428b")
#let header-font = "DM Sans"
#let body-font = "New Computer Modern"
#let body-size = 11pt

#let section-top-margin = 0.1em
#let section-line-offset =-0.6em
#let section-bottom-margin = -0.4em
#let grid-row-spacing = 0.7em 
#let list-indentation = 1em

#let linkedin-icon = image.decode("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='#0077b5'><path d='M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z'/></svg>")
#let github-icon = image.decode("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'><path d='M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.041-1.412-4.041-1.412-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z'/></svg>")
#let web-icon = image.decode("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='black' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><circle cx='12' cy='12' r='10'></circle><line x1='2' y1='12' x2='22' y2='12'></line><path d='M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z'></path></svg>")

#let icon(img) = box(img, height: 1.0em, baseline: 15%)

#let project(body) = {
  set page(margin: (x: 1.2cm, y: 1cm), paper: "us-letter")
  set text(font: body-font, size: body-size, lang: "en")
  body
}

#let format-dates(start: none, end: none) = {
  (start, end).filter(it => it != none).join(" – ")
}

#let cv-header(name: "", email: "", phone: "", linkedin: "", github: "") = {
  align(center)[
    #text(size: 20pt, weight: "bold")[#name] \
    #v(-0.8em)
    #let entries = ()
    #if email != "" { entries.push(link("mailto:" + email)[#email]) }
    #if phone != "" { entries.push(phone) }
    #if linkedin != "" { entries.push(link("https://linkedin.com/in/" + linkedin)[#icon(linkedin-icon) #h(2pt) #text(fill: rgb("#0077b5"))[#linkedin]]) }
    #if github != "" { entries.push(link("https://github.com/" + github)[#icon(github-icon) #h(2pt) #github]) }
    #entries.join(" | ")
  ]
}

#let cv-section(title) = {
  v(section-top-margin)
  text(fill: accent-color, weight: "bold", size: 11pt)[#upper(title)]
  v(section-line-offset)
  line(length: 100%, stroke: 0.5pt)
  v(section-bottom-margin)
}

#let cv-edu(school: "", degree: none, start: none, end: none, relevant: none) = {
  let date-str = format-dates(start: start, end: end)
  grid(
    columns: (1fr, auto),
    row-gutter: grid-row-spacing,
    [*#degree* #if school != "" [ | _#school _ ]], [*#date-str*],
    grid.cell(colspan: 2, if relevant != none { pad(left: 1.2em, [*Relevant:* #relevant]) })
  )
}

#let cv-work(company: "", title: "", location: none, start: none, end: none, points: ()) = {
  let date-str = format-dates(start: start, end: end)
  grid(columns: (1fr, auto), [*#title* | _#company _], [#if location != none [#location ~] *#date-str*])
  v(section-bottom-margin)
  set list(indent: list-indentation)
  for p in points { list.item(p) }
}

#let cv-project(name: "", tech: none, github: none, url: none, start: none, end: none, points: ()) = {
  let date-str = format-dates(start: start, end: end)
  grid(
    columns: (1fr, auto),
    [
      *#name* #if tech != none [| #tech]
      #if github != none [#h(4pt) #link("https://github.com/" + github)[#icon(github-icon)]]
      #if url != none [#h(2pt) #link(url)[#icon(web-icon)]]
    ],
    [*#date-str*]
  )
  v(section-bottom-margin)
  set list(indent: list-indentation)
  for p in points { list.item(p) }
}