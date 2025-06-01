#import "eggs.typ": *
#import "eggs.typ": judge as j

#import abbreviations: poss, prog, sg, pl, sbj, obj, fut, neg, obl, gen, com, ins, all, pst, inf, indf, def, dem, pred, ins, f

// #set page(
//   width: 9.5cm,
//   height: 3.5cm,
//   margin: 0.7cm
// )
// #set align(center)
// #set text(size: 1.2em)

#show: eggs.with(
)

#example(auto-glosses: false)[
  - word  word
    - word1  word
   - two
]



// #lorem(20)

// #example[
//   text
// ]

// #lorem(20)

// #example(label: <mul>)[
//   header very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very very long // #ex-label(<mul>)
//   + #ex-label(<one>) subexample 1\
//     some more text 
//   + subexample 4 #metadata(<four>)
//   #subexample(label: <man>, number: 8)[subexample manual]
//   // #subexample[subexample manual 2]
//   + subexample 6 very very very very very very very very very very very very very very very very very very very very very very very very long
// ]

// #example(label: <glpl>)[
//   + Russian
//     - какая-то  глосса    
//     - some.#f   gloss
//     'some gloss' #ex-label(<list>)
//   + - #j[\*]еще~одна  глосса  круто  не~правда~ли
//     - one~more  gloss   cool   isn't~it
//   + - очень  длинная  длинная  длинная  длинная  длинная  длинная  длинная  длинная  длинная   длинная  длинная  длинная  длинная  длинная  длинная  длинная    глосса
//     - very  long  long  long  long  long  long  long  long  long   long  long  long  long  long  long  long    gloss
// ]

// @mul
// @one
// @four
// @glpl:b
// @list
// @man
// @mul:c

#example[
  + - primer   s     gloss-ami
    - example  with  gloss-#pl.#ins
    'an/the example with glosses'
  + #judge[\*]example without glosses
]
