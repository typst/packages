/// Importing presets

#import "presets.typ": (
  preset-classic,
  preset-classic-headings)


/// Global parameters

  // Indents
  #let base-indent = state("base-indent", 1em)
  #let verse-indent = state("verse-indent", 1em)
  #let stanza-indent = state("stanza-indent", 0pt)

  // Spacing
  #let always-align-poemtitle = state("always-align-poemtitle", true)
  #let v-after-poemtitle = state("v-after-poemtitle", 20em/11)

  // Verse numbers
  #let show-verse-numbers = state("show-verse-numbers", false)
  #let verse-number-start = state("verse-number-start", 1)
  #let verse-number-modulo = state("verse-number-modulo", 1)
  #let verse-number-distance = state("verse-number-distance", 5pt)


/// Splitting verses

#let current-versesplit = state("current-versesplit", 0pt)

#let splitverse(part-of-verse) = [#context [
  #h(current-versesplit.get())#part-of-verse
  #current-versesplit.update(current-versesplit.get() + measure(part-of-verse).width)]<splitverse>]

#let versesplit = [#context [
  #h(current-versesplit.get())
  #current-versesplit.update(0pt)]<splitverse>]

  // Test for split verses
  #let is-splitverse(content) = {
    let arr = content.fields().values()
    if arr.len() != 0 {
      arr.last() == <splitverse>}
    else {return false}}


/// Inline poemtitles

#let inline-poemtitle(part-of-verse) = {
  [#box(height: 0pt, width: 0pt, clip: true,
  [#hide[#part-of-verse<poemtitle>]])]
  [#box(part-of-verse)<inline-poemtitle>]}


/// Interjections

#let interjection(interjectionbody) = {
  [#interjectionbody<interjection>]}

  // Test for interjections
  #let is-interjection(content) = {
    let arr = content.fields().values()
    if arr.len() != 0 {
      arr.last() == <interjection> or arr.last() == <dedication>}
    else {return false}}


/// Dedications

#let dedication(dedicationbody) = {
  [#dedicationbody<dedication>]}

  // Test for dedications
  #let is-dedication(content) = {
    let arr = content.fields().values()
    if arr.len() != 0 {
      arr.last() == <dedication>}
    else {return false}}


/// Printing poembodys

#let print-poembody(poembody, indentpattern, nesting) = {
  
  // Map the indentpattern and poembody to arrays verseindents and poemcontent
  let verseindents = ()
  for verseindent in indentpattern.fields().values().at(0) [
    #verseindents.push(int(verseindent)+1)]
  let poemcontent = poembody.fields().values().at(0)
  poemcontent.pop()

  // Testing for special elements in the poembody 
  let is-special(element) = {
    is-interjection(poemcontent.at(element, default: [])) or is-splitverse(poemcontent.at(element + 1, default: []))}
  
  // Initialize counting parameters
  let next-element = 1
  let current-verse = 0
  let current-verse-number = verse-number-start.get()

  // If there is a dedication, print it
  if is-dedication(poemcontent.at(1)) {
    poemcontent.remove(0)
    poemcontent.insert(0, [#v(-v-after-poemtitle.get() / (2 * nesting)) #h(base-indent.get())])
    poemcontent.insert(2, v(v-after-poemtitle.get() / nesting, weak: true))}

  // Insert indents (and verse-numbers)
  for element in poemcontent {
    // Calculate the current-indent
    let current-indent = (verseindents.at(calc.rem-euclid(current-verse, verseindents.len())) - 1) * verse-indent.get() + base-indent.get()
    // If the element marks the end of a stanza or verse ...
    if element == parbreak() or element == linebreak() {
      // If the next element is special, insert only the base-indent
      if is-special(next-element) {
        poemcontent.insert(next-element,h(base-indent.get()))}
      // If the next element is normal ...
      else {
        // If verse-numbers are to be shown, insert the verse-number and the current-indent
        if show-verse-numbers.get() {
          poemcontent.insert(next-element,[#box(width: 0pt)[
            #if calc.rem-euclid(current-verse-number, verse-number-modulo.get()) == 0 [
              #align(right)[#current-verse-number #h(verse-number-distance.get())]]<verse-number>]
            #h(current-indent - 2.75pt)])}
        // If verse numbers are not to be shown, insert only the current-indent
        else {
          poemcontent.insert(next-element,h(current-indent))}
        // If the element marks the end of a stanza, insert the stanza-indent
        if element == parbreak() {
          poemcontent.insert(next-element,h(stanza-indent.get()))
          next-element += 1}
        // Conclude the verse and step up the verse-number
        current-verse += 1
        current-verse-number += 1}
      // Move to the next (non-inserted) element
      next-element += 1}
    next-element += 1}
    
  // Print the indented (and numbered) poembody
  for element in poemcontent {
    [#element]}}


/// Printing poems

#let poem(poemtitle, poembody, indentpattern) = {[ #context {

  // Print the poemtitle
  if poemtitle != [] [#poemtitle<poemtitle>\ ] else if always-align-poemtitle.get() [#box(width: measure([0 <poemtitle>]).values().at(0), height: measure([0 <poemtitle>]).values().at(1))]
  v(v-after-poemtitle.get(), weak: true)

  // Print the poembody
  print-poembody(poembody, indentpattern, 1)}]}


/// Printing cycles
  
#let cycle(cycletitle, ..cyclesubtitle, cyclebody) = {[ #context {
  
  // Print the cycletitle (and subtitle)
  if cyclesubtitle != arguments() [
  #cycletitle<cycletitle>
  #cyclesubtitle.at(0)<cyclesubtitle>\ ]
  else [#cycletitle<cycletitle>\ ]
  v(v-after-poemtitle.get(), weak: true)

  // Print the cyclebody
  [#cyclebody]}]}


/// Printing poems in cycles
  
#let poem-incycle(poemtitle, ..poemsubtitle, poembody, indentpattern) = {[ #context{
  
  // Print the poemtitle (and subtitle)
  if poemsubtitle != arguments() [
  #poemtitle<poemtitle-incycle>
  #poemsubtitle.at(0)<poemsubtitle-incycle>\ ]
  else if poemtitle != [] [#poemtitle<poemtitle-incycle>\ ]
  else [#box(width: measure([0 <poemtitle-incycle>]).values().at(0), height: measure([0 <poemtitle-incycle>]).values().at(1))]
  v(v-after-poemtitle.get() / 2, weak: true)
  
  // Print the poembody
  print-poembody(poembody, indentpattern, 2)}]}
