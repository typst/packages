#import "../brand.typ": colour, tech-colours

#let repository-shares(languages) = {
  assert(type(languages) == dictionary and languages.len() > 0,
    message: "repository: provide at least one language weight")
  assert(languages.values().all(value => type(value) in (int, float) and value >= 0),
    message: "repository: language weights must be non-negative numbers")
  let total = languages.values().sum()
  assert(total > 0, message: "repository: language weights must have a positive total")
  languages.pairs().filter(pair => pair.last() > 0)
    .map(pair => (name: pair.first(), share: pair.last() / total))
}

/// Language weights can be percentages, bytes, or any comparable quantities.
#let repository(name: none, languages: (:), url: auto,
  colors: tech-colours, ink: colour.neutral-dark, fallback: rgb("8a9599"),
  size: 1em, bar-height: .5em, gap: .5em,
) = {
  assert(name == none or (type(name) == str and name.trim() != ""),
    message: "repository: name must be none or a non-empty string")
  let shares = repository-shares(languages)
  let fill(item) = colors.at(lower(item.name), default: fallback)
  set text(size: size, fill: ink)
  block(width: 100%, breakable: false, [
    #if name != none {
      link(if url == auto { "https://github.com/" + name } else { url },
        grid(columns: (auto, 1fr), column-gutter: .4em, align: horizon,
          image(bytes(read("../static/icons/github.svg").replace("<path ", "<path fill=\"" + ink.to-hex() + "\" ")), height: .9em, alt: "GitHub"),
          text(weight: "semibold", name),
        ),
      )
      v(gap)
    }
    #block(width: 100%, radius: bar-height / 2, clip: true,
      grid(columns: shares.map(item => item.share * 100%), rows: bar-height,
        ..shares.map(item => rect(width: 100%, height: bar-height, fill: fill(item), stroke: none)),
      ),
    )
    #v(gap)
    #grid(columns: (auto, 1fr, auto), column-gutter: .5em, row-gutter: .25em, align: horizon,
      ..shares.map(item => (
        circle(radius: .2em, fill: fill(item)),
        text(size: .85em, item.name),
        text(size: .85em, str(calc.round(item.share * 100, digits: 1)) + "%"),
      )).flatten(),
    )
  ])
}
