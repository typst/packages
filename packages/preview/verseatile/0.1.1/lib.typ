// Global parameters

#let base-indent = state("base-indent", 1em)
#let verse-indent = state("verse-indent", 1em)

#let v-after-poemtitle = state("v-after-poemtitle", 20pt)

#let show-verse-numbers = state("show-verse-numbers", false)
#let verse-number-modulo = state("verse-number-modulo", 1)
#let verse-number-distance = state("verse-number-distance", 5pt)

// Printing inline poemtitles

#let inline-poemtitle(part-of-verse) = {
  [#box(height: 0pt, width: 0pt, clip: true,
  [#hide[#part-of-verse<poemtitle>]])]
  [#box(part-of-verse)<inline-poemtitle>]}

// Printing poems

#let poem(poemtitle, poembody, indentpattern) = {[

  #context {

  // Print the poemtitle

  if poemtitle != [] [#poemtitle<poemtitle>] else [#hide[0 <poemtitle>]]
  v(v-after-poemtitle.get(), weak: true)
  
  // Map the indent pattern and poembody to an array
  
  let verseindents = ()
  for verseindent in indentpattern.fields().values().at(0) [
    #verseindents.push(int(verseindent)+1)]
  let poemcontent = poembody.fields().values().at(0)
  poemcontent.pop()
  
  // Insert the indents and versenumbers into the poembody
  
  let current-element = 1
  let current-verse = 1
  for element in poemcontent {
    let current-indent = (verseindents.at(calc.rem-euclid(current-verse - 1, verseindents.len())) - 1) * verse-indent.get() + base-indent.get()
    if element == parbreak() or element == linebreak() {
      if show-verse-numbers.get() { 
        [#poemcontent.insert(current-element,[#box(width: 0pt)[#if calc.rem-euclid(current-verse, verse-number-modulo.get()) == 0 [
          #align(right)[#current-verse #h(verse-number-distance.get())]]]<verse-number>
        #h(current-indent - 2.75pt)])]}
      else [
        #poemcontent.insert(current-element,h(current-indent))]
      current-element += 1
      current-verse += 1}
    current-element += 1}
    
  // Print the indented and numbered poembody
  
  for element in poemcontent {
    [#element]}}]}

// Printing cycles
  
#let cycle(cycletitle, cyclebody) = {[

  #context {
  
  // Print the cycle

  [#cycletitle<cycletitle>
  #v(v-after-poemtitle.get(), weak: true)
  #cyclebody]}]}

// Printing poems in cycles
  
#let poem-incycle(poemtitle, poembody, indentpattern) = {[

  #context{
  
  // Print the poemtitle

  [#poemtitle <poemtitle-incycle>
  #v(v-after-poemtitle.get() / 2, weak: true)]
  
  // Map the indent pattern and poembody to an array
  
  let verseindents = ()
  for verseindent in indentpattern.fields().values().at(0) [
    #verseindents.push(int(verseindent)+1)]
  let poemcontent = poembody.fields().values().at(0)
  poemcontent.pop()
  
  // Insert the indents and versenumbers into the poembody
  
  let current-element = 1
  let current-verse = 1
  for element in poemcontent {
    let current-indent = (verseindents.at(calc.rem-euclid(current-verse - 1, verseindents.len())) - 1) * verse-indent.get() + base-indent.get()
    if element == parbreak() or element == linebreak() {
      if show-verse-numbers.get() { 
        [#poemcontent.insert(current-element,[#box(width: 0pt)[#if calc.rem-euclid(current-verse, verse-number-modulo.get()) == 0 [
          #align(right)[#current-verse #h(verse-number-distance.get())]]]<verse-number>
        #h(current-indent - 2.75pt)])]}
      else [
        #poemcontent.insert(current-element,h(current-indent))]
      current-element += 1
      current-verse += 1}
    current-element += 1}
    
  // Print the indented and numbered poembody
  
  for element in poemcontent {
    [#element]}}]}
