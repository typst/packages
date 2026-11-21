#import "_h.typ": *
#pagebreak(weak: true)
#heading(level: 1, T("Aliases and index", "Alias et index"))
#T[Many functions carry a second name (French names from the original LaTeX packages, or short forms). An alias behaves exactly like its target. The index at the end lists every function with its chapter.][Beaucoup de fonctions portent un second nom (noms français issus des paquets LaTeX d’origine, ou formes courtes). Un alias se comporte exactement comme sa cible. L’index final liste chaque fonction avec son chapitre.]

#let rows = ()
#for (target, al) in aliases { for a in al { rows.push((a, target)) } }
#{
  rows = rows.sorted(key: r => r.at(0))
  set text(size: 7.8pt)
  grid(columns: (1fr, 1fr, 1fr), gutter: 10pt,
    ..range(3).map(k => {
      let h = calc.ceil(rows.len() / 3)
      table(columns: (1fr, 1fr), stroke: (x: none, y: 0.25pt + luma(210)), inset: (x: 3pt, y: 2pt),
        table.header([*alias*], [*#T("target", "cible")*]),
        ..rows.slice(calc.min(k * h, rows.len()), calc.min((k + 1) * h, rows.len())).map(r => (raw(r.at(0)), raw(r.at(1)))).flatten())
    }))
}

== #T("Index of functions", "Index des fonctions")
#{
  let items = ()
  for (i, c) in chapters.enumerate() { for n in c.names { items.push((n, i + 2)) } }
  items = items.sorted(key: x => x.at(0))
  set text(size: 7.6pt)
  columns(3, gutter: 8pt, for it in items [#raw(it.at(0)) #box(width: 1fr, repeat[.]) #it.at(1) \ ])
}
