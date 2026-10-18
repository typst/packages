/// Classic Presets

#let classic(body) = {
  show <cyclesubtitle>: it => [#h(0.5em) #text(
    size: 10em/11
  )[#it]]
  show <poemsubtitle-incycle>: it => [#h(0.25em) #text(
    style: "italic",
    size: 10em/11
  )[#it]]
  show <inline-poemtitle>: it => [#text(
  )[#smallcaps(it)]]
  show <dedication>: it => [#h(-0.5em) #text(
    style: "italic",
    size: 8em/11
  )[#it]]
  show <interjection>: it => [#h(-0.5em) #text(
    style: "italic",
    size: 9em/11
  )[#smallcaps(all:true, it)]]
  show <verse-number>: set text(
    size: 8em/11,
    number-type: "lining")
body}

// classic

#let preset-classic(body) = {
  show <poemtitle>: it => [#text(
    size: 14em/11,
    number-type: "old-style",
    number-width: "proportional"
  )[#smallcaps(it)]]
  show <cycletitle>: it => [#text(
    size: 14em/11,
    number-type: "old-style",
    number-width: "proportional"
  )[#smallcaps(it)]]
  show <poemtitle-incycle>: it =>[#text(
    size: 12em/11,
    number-type: "old-style",
    number-width: "proportional"
  )[#smallcaps(all: true, it)]]
  show: classic
body}

// classic-headings

#let preset-classic-headings(body) = {
  show <poemtitle>: it => box(heading(level: 2, it))
  show <cycletitle>: it => box(heading(level: 2, it))
  show <poemtitle-incycle>: it => box(heading(level: 3, it))
  show: classic
body}
