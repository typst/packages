// Importing presets

#import "presets.typ": (
  preset-classic,
  preset-classic-headings)

// Global parameters

#let base-indent = state("base-indent", 1em)
#let verse-indent = state("verse-indent", 1em)
#let stanza-indent = state("stanza-indent", 0pt)

#let always-align-poemtitle = state("always-align-poemtitle", true)
#let v-after-poemtitle = state("v-after-poemtitle", 20em/11)

#let show-verse-numbers = state("show-verse-numbers", false)
#let verse-number-start = state("verse-number-start", 1)
#let verse-number-modulo = state("verse-number-modulo", 1)
#let verse-number-distance = state("verse-number-distance", 5pt)

// Splitting verses

#let current-versesplit = state("current-versesplit", 0pt)

#let splitverse(part-of-verse) = [#context [
  #h(current-versesplit.get())#part-of-verse
  #current-versesplit.update(current-versesplit.get() + measure(part-of-verse).width)]<splitverse>]

#let versesplit = [#context [
  #h(current-versesplit.get())
  #current-versesplit.update(0pt)]<splitverse>]

#let is-splitverse(content) = {
  let arr = content.fields().values()
  if arr.len() != 0 {
  arr.last() == <splitverse>}
  else {return false}}

// Printing inline poemtitles

#let inline-poemtitle(part-of-verse) = {
  [#box(height: 0pt, width: 0pt, clip: true,
  [#hide[#part-of-verse<poemtitle>]])]
  [#box(part-of-verse)<inline-poemtitle>]}

// Printing interjections and dedications

#let interjection(interjectionbody) = {
  [#interjectionbody<interjection>]}

#let dedication(dedicationbody) = {
  [#dedicationbody<dedication>]}

#let is-interjection(content) = {
  let arr = content.fields().values()
  if arr.len() != 0 {
  arr.last() == <interjection> or arr.last() == <dedication>}
  else {return false}}

#let is-dedication(content) = {
  let arr = content.fields().values()
  if arr.len() != 0 {
  arr.last() == <dedication>}
  else {return false}}
  
// Printing poembodys

#let print-poembody(poembody, indentpattern, nesting) = {
  
  // Map the indent pattern and poembody to an array
  
  let verseindents = ()
  for verseindent in indentpattern.fields().values().at(0) [
    #verseindents.push(int(verseindent)+1)]
  let poemcontent = poembody.fields().values().at(0)
  poemcontent.pop()
  
  // Insert the indents and versenumbers into the poembody
  
  let current-element = 1
  let current-verse = 1
  let current-verse-number = verse-number-start.get()
  if is-dedication(poemcontent.at(1)) {
    poemcontent.remove(0)
    poemcontent.insert(0, [#v(-v-after-poemtitle.get() / (2 * nesting)) #h(base-indent.get())])
    poemcontent.insert(2, v(v-after-poemtitle.get() / nesting, weak: true))}
  for element in poemcontent {
    let current-indent = (verseindents.at(calc.rem-euclid(current-verse - 1, verseindents.len())) - 1) * verse-indent.get() + base-indent.get()
    if element == parbreak() or element == linebreak() {
      if show-verse-numbers.get() and not (is-interjection(poemcontent.at(current-element, default: [])) or is-splitverse(poemcontent.at(current-element + 1, default: []))) { 
        [#poemcontent.insert(current-element,[#box(width: 0pt)[#if calc.rem-euclid(current-verse-number, verse-number-modulo.get()) == 0 [
          #align(right)[#current-verse-number #h(verse-number-distance.get())]]]<verse-number>
        #if element == parbreak() and not is-interjection(poemcontent.at(current-element, default: [])) [#h(stanza-indent.get())]
        #h(current-indent - 2.75pt)])]}
      else if (is-interjection(poemcontent.at(current-element, default: [])) or is-splitverse(poemcontent.at(current-element + 1, default: []))) [
        #poemcontent.insert(current-element,h(base-indent.get()))]
      else [
        #poemcontent.insert(current-element,h(current-indent))]
      current-element += 1
      if not (is-interjection(poemcontent.at(current-element, default: [])) or is-splitverse(poemcontent.at(current-element + 1, default: []))) {
      current-verse += 1
      current-verse-number += 1}}
    current-element += 1}
    
  // Print the indented and numbered poembody
  
  for element in poemcontent {
    [#element]}}

// Printing poems

#let poem(poemtitle, poembody, indentpattern) = {[

  #context {

  // Print the poemtitle

  if poemtitle != [] [#poemtitle<poemtitle>\ ] else if always-align-poemtitle.get() [#box(width: measure([0 <poemtitle>]).values().at(0), height: measure([0 <poemtitle>]).values().at(1))]
  v(v-after-poemtitle.get(), weak: true)

  // Print the poembody
  
  print-poembody(poembody, indentpattern, 1)}]}

// Printing cycles
  
#let cycle(cycletitle, ..cyclesubtitle, cyclebody) = {[

  #context {
  
  // Print the cycle

  if cyclesubtitle != arguments() [
  #cycletitle<cycletitle>
  #cyclesubtitle.at(0)<cyclesubtitle>\ ]
  else [#cycletitle<cycletitle>\ ]
  v(v-after-poemtitle.get(), weak: true)
  [#cyclebody]}]}

// Printing poems in cycles
  
#let poem-incycle(poemtitle, ..poemsubtitle, poembody, indentpattern) = {[

  #context{
  
  // Print the poemtitle

  if poemsubtitle != arguments() [
  #poemtitle<poemtitle-incycle>
  #poemsubtitle.at(0)<poemsubtitle-incycle>\ ]
  else if poemtitle != [] [#poemtitle<poemtitle-incycle>\ ]
  else [#box(width: measure([0 <poemtitle-incycle>]).values().at(0), height: measure([0 <poemtitle-incycle>]).values().at(1))]
  v(v-after-poemtitle.get() / 2, weak: true)
  
  // Print the poembody
  
  print-poembody(poembody, indentpattern, 2)}]}
