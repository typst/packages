#import "../style.typ" as style
#import "components.typ": ftn-logo, ftn-logo-new, uns-logo

#let cover(
  title: auto,
  author: (name: auto),
  degree: [Основне академске студије],
  date: auto,
  style: style,
) = [
  #let name = if author.name == auto {
    context document.author.first(default: [Именко Презимић])
  } else { author.name }
  #let date = if date == auto { datetime.today() } else { date }
  #let year = if type(date) == datetime {
    date.year()
  } else {
    date
  }

  #show: style.cover

  #grid(
    columns: (auto, 1fr, auto),
    align: center + horizon,

    uns-logo,
    stack(
      dir: ttb,
      spacing: 0.77em,

      upper[Универзитет у Новом Саду],
      stack(
        dir: ttb,
        spacing: 0.5em,

        upper[*Факултет техничких наука у*],
        upper[*Новом Саду*],
      ),
    ),
    ftn-logo,
    grid.hline(),
  )

  #v(1fr)
  #pad(left: 3%)[#name]

  #v(.7fr)
  #std.title(title)

  #v(1fr)
  #align(center)[
    #stack(
      dir: ttb,
      spacing: 1em,
      upper[завршни рад],
      emph[-- #degree --],
    )
  ]

  #v(1fr)
  #align(bottom + center)[Нови Сад, #year]
]

#let cover-new(
  title: auto,
  author: (name: auto),
  degree: [Основне академске студије],
  date: auto,
  style: style,
) = [
  #let name = if author.name == auto {
    context document.author.first(default: [Именко Презимић])
  } else { author.name }
  #let date = if date == auto { datetime.today() } else { date }
  #let year = if type(date) == datetime {
    date.year()
  } else {
    date
  }

  #show: style.cover

  #place(top + center, float: true)[
    //dy: -1cm, float: true)[
    #grid(
      align: (left, right),
      inset: 0.1mm,
      columns: (1fr, 1fr),
      uns-logo, pad(ftn-logo-new, top: 1mm),
    )
  ]

  #place(top + center, float: false)[
    #stack(
      dir: ttb,
      spacing: 0.77em,

      upper[Универзитет у Новом Саду],
      stack(dir: ttb, spacing: 0.5em, upper[*Факултет техничких наука у*], upper[*Новом Саду*]),
    )
  ]

  #v(1fr)
  #pad(left: 3%)[#name]

  #v(.7fr)
  #std.title(title)

  #v(1fr)
  #align(center)[
    #stack(
      dir: ttb,
      spacing: 1em,
      upper[завршни рад],
      emph[-- #degree --],
    )
  ]

  #v(1fr)
  #align(bottom + center)[Нови Сад, #year]
]
