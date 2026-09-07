/// Importing presets

#import "presets.typ": (
  preset-classic,
  preset-classic-headings,
  preset-elegant,
  preset-elegant-headings)


/// Global parameters

  // Indents
  #let base-indent = state("base-indent", 1em)
  #let verse-indent = state("verse-indent", 1em)
  #let stanza-indent = state("stanza-indent", 0pt)

  // Spacing
  #let v-after-poemtitle = state("v-after-poemtitle", 20em/11)
  #let always-align-poemtitle = state("always-align-poemtitle", false)
  
  #let poem-options(indents: (:), poemtitle: (:)) = {
    let indents = (base: 1em, verse: 1em, stanza: 0pt, ..indents)
    base-indent.update(indents.base); verse-indent.update(indents.verse); stanza-indent.update(indents.stanza)
    let poemtitle = (clearance: 20em/11, always-align: true, ..poemtitle)
    v-after-poemtitle.update(poemtitle.clearance); always-align-poemtitle.update(poemtitle.always-align)}

  // Verse numbers
  #let show-verse-numbers = state("show-verse-numbers", false)
  #let verse-number-start = state("verse-number-start", 1)
  #let verse-number-modulo = state("verse-number-modulo", 1)
  #let verse-number-distance = state("verse-number-distance", 5em/11)
  
  #let verse-numbering(toggle, start: 1, modulo: 1, distance: 5em/11) = {
    show-verse-numbers.update(toggle)
    verse-number-start.update(start)
    verse-number-modulo.update(modulo)
    verse-number-distance.update(distance)}


/// Overhang

#let overhang(mark: none) = {linebreak(justify: false); h(1fr); text(mark)}


/// Splitting verses

#let current-versesplit = state("current-versesplit", 0pt)

#let splitverse(part-of-verse) = [#context [
  #h(current-versesplit.get())#part-of-verse #linebreak(justify: false)
  #current-versesplit.update(current-versesplit.get() + measure(part-of-verse).width)]<splitverse>]

#let versesplit = [#context [
  #h(current-versesplit.get())
  #current-versesplit.update(0pt)]<splitverse>]


/// Inline poemtitles

#let inline-poemtitle(part-of-verse) = {
  [#box(height: 0pt, width: 0pt, clip: true,
  [#hide[#part-of-verse<poemtitle>]])]
  [#box(part-of-verse)<inline-poemtitle>]}


/// Interjections

#let interjection(interjectionbody) = {
  [#interjectionbody<interjection>]}


/// Dedications

#let dedication(dedicationbody) = {
  [#dedicationbody<dedication>]}

#let dedication-ofcycle(dedicationbody) = context {
  v(- v-after-poemtitle.get() / 2, weak: false)
  h(base-indent.get()); [#dedicationbody<dedication>]
  v(v-after-poemtitle.get(), weak: true)}


/// Printing poembodys

#let print-poembody(poembody, indentpattern, nesting) = {

  // Map the indentpattern to array verseindents
  let verseindents = ()
  for verseindent in indentpattern.fields().values().at(0) {
    verseindents.push(int(verseindent) + 1)}

  // Tag and map the lines of the poembody to array lines
  let tag(name, input) = (tag: name, item: input)
  let lines = (); let construct-verse = []
  for element in poembody.fields().values().at(0) {
    // Tag dedications
    if element.fields().at("label", default: none) == <dedication> {
      lines.push(tag("dedication", element))}
    // Tag interjections
    else if element.fields().at("label", default: none) == <interjection> {
      lines.push(tag("interjection", element))}
    // Tag split verses
    else if element.fields().at("label", default: none) == <splitverse> {
      lines.push(tag("splitverse", element))}
    // Tag manual verse number suppression
    else if element.fields().at("label", default: none) == <do-not-number> {
      lines.push(tag("do-not-number", element))}
    // Tag parbreaks, linebreaks and verses
    else if element == parbreak() {
      lines.push(tag("verse", construct-verse)); construct-verse = []
      lines.push(tag("break", parbreak()))}
    else if element == linebreak() {
      lines.push(tag("verse", construct-verse)); construct-verse = []
      lines.push(tag("break", linebreak()))}
    else if not (construct-verse == [] and element == [ ]) {construct-verse += element}}
  lines.push(tag("verse", construct-verse))
  
  // Filter out empty elements
  lines = lines.filter(it =>
    it.item != [] and it.item.fields().at("children", default: ()).dedup() != ([ ],))
  if lines.at(0).item != parbreak() {
    lines.insert(0, tag("break", parbreak()))}
    
  // Initialize counting and numbering parameters
  let current-line = 0; let current-verse = 0; let current-verse-number = verse-number-start.get()
  let pass = ("break", "dedication", "interjection")
  
  // Print the dedication
  if lines.at(1).tag == "dedication" {
    lines.insert(1, tag("break", v(-v-after-poemtitle.get() / (2 * nesting))))
    lines.insert(3, tag("break", v(v-after-poemtitle.get() / nesting, weak: true)))}
  
  // Construct the numbered and indented poembody
  for line in lines {
    // Accessing current or shifted line
    let lines-at(shift: 0) = lines.at(current-line + shift, default: (tag: "", item: []))
    // Testing for parts of split verses in current and shifted lines
    let is-splitverse-at(shifts: (0)) = {
      for shift in shifts {if lines-at(shift: shift).tag != "splitverse" {return false}}; return true}
    let is-not-splitverse-at(shifts: (0)) = {
      for shift in shifts {if lines-at(shift: shift).tag == "splitverse" {return false}}; return true}
    // Calculating current or shifted indent
    let current-indent(shift: 0) = (verseindents.at(calc.rem-euclid(current-verse + shift, verseindents.len())) - 1) * verse-indent.get() + base-indent.get()
    // Insert verse numbers and indents
    if not pass.contains(line.tag) and is-not-splitverse-at(shifts: (-2, -1)) {
      // Insert verse numbers
      if show-verse-numbers.get() and not line.tag == "do-not-number" {
        lines.insert(current-line, tag("verse-number", [#box(width: 0pt)[
          #if calc.rem-euclid(current-verse-number, verse-number-modulo.get()) == 0 [
            #align(right)[#current-verse-number #h(verse-number-distance.get())]]<verse-number>]]))
        current-line += 1; current-verse-number += 1}
      // Insert stanza-indent
      if lines-at(shift: -1).item == parbreak() {
        lines.insert(current-line, tag("indent", [#h(stanza-indent.get())]))
        current-line += 1}
      // Insert current-indent
      lines.insert(current-line, tag("indent", [#h(current-indent())]))
      current-line += 2; current-verse += 1}
    // Adjust parts of split verses
    else if is-splitverse-at(shifts: (-1, 0)) or (is-splitverse-at(shifts: (-2, 0)) and lines-at(shift: -1).tag == "break") {
      lines.insert(current-line, tag("indent", [#h(current-indent(shift: -1) * 1.25)]))
      current-line += 2}
    else {current-line += 1}}

  // Print the numbered and indented poembody
  for line in lines {line.item}}


/// Printing poems

#let poem(poemtitle, poembody, ..indentpattern) = context {

  // Print the poemtitle
  if poemtitle != [] [#poemtitle<poemtitle>\ ]
  else if always-align-poemtitle.get() [#box(width: measure([0 <poemtitle>]).values().at(0), height: measure([0 <poemtitle>]).values().at(1))]
  v(v-after-poemtitle.get(), weak: true)

  // Print the poembody
  print-poembody(poembody, indentpattern.at(0, default: [0]), 1)}


/// Printing cycles
  
#let cycle(cycletitle, ..cyclesubtitle, cyclebody) = context {
  
  // Print the cycletitle and subtitle
  if cyclesubtitle != arguments() [
    #cycletitle<cycletitle>
    #cyclesubtitle.at(0)<cyclesubtitle>\ ]
  else [#cycletitle<cycletitle>\ ]
  v(v-after-poemtitle.get(), weak: true)

  // Print the cyclebody
  cyclebody}


/// Printing poems in cycles
  
#let poem-incycle(poemtitle, ..poemsubtitle, poembody, indentpattern) = context {
  
  // Print the poemtitle and subtitle
  if poemsubtitle != arguments() [
    #poemtitle<poemtitle-incycle>
    #poemsubtitle.at(0)<poemsubtitle-incycle>\ ]
  else if poemtitle != [] [#poemtitle<poemtitle-incycle>\ ]
  else [#box(width: measure([0 <poemtitle-incycle>]).values().at(0), height: measure([0 <poemtitle-incycle>]).values().at(1))]
  v(v-after-poemtitle.get() / 2, weak: true)
  
  // Print the poembody
  print-poembody(poembody, indentpattern, 2)}
