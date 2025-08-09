# cartao

Dead simple, _printable_, flashcards with Typst.

## Example usage:

```typ
#import "@preview/cartao:0.2.0": *

#show: latex
#show: perforate

// define your cards

= Testing Testing 1 2 3

/ Question? --- Hint:
  answer

/ Don't forget the... ---:
  \-\-\-!

= Portuguese

/ card --- Hint\: Its the title of this package!:
  cartão

= French

/ card --- Hint\: close to the portuguese:
  carte
```

## Documentation

This template first defines the below `counter` and `state`s
```typ
#let _cn = counter("cardnumber")
#let _ch = state("h", "init")
#let _cq = state("q", "init")
#let _ca = state("a", "init")
```

### `card`

Defines a card by updating the `counter` and `state`s, and dropping a `<card>` label.

```typ
#let card(hint, question, answer) = [
  #_cn.step()
  #_ch.update(hint)
  #_cq.update(question)
  #_ca.update(answer)
  <card>
]
```

A show rule parses typst's builtin `terms` syntax, uses `card` only if the the `term` contains `---`, and uses the normal `term` layout for all other `terms`:

```typ
#let parse-term(it) = {
  let a = it.description

  let h = if it.term.has("children") {
    if it.term.children.contains[---] {
      it
        .term
        .children
        .slice(it.term.children.position(i => { i == [---] }) + 1)
        .join()
    } else {
      it.term.children.sum()
    }
  } else { it.term }

  let q = if it.term.has("children") {
    if it.term.children.contains[---] {
      it
        .term
        .children
        .slice(0, it.term.children.position(i => { i == [---] }))
        .join()
    }
  } else []

  return (q, h, a)
}

#show terms.item: it => {
  if it.term.has("children") and it.term.children.contains[---] {
    card(..parse-term(it))
  } else { it }
}
```

### `perforate`

```typ
#show: perforate.with(dimensions: dimensions)
```

A function for producing cards in a useful layout for printing.  
[Search Amazon to see some examples.](https://www.amazon.ca/s?k=perforated+card&crid=3EIOD2O9O098Z&sprefix=perforated+car%2Caps%2C146&ref=nb_sb_noss_2)

`dimensions` - a `dictionary` containing:
  * `w` - the width of each card
  * `h` - the height of each card
  * `pw` - the width of the page
  * `ph` - the width of the page
  * `r` - the number of rows
  * `c` - the number of columns

`cartao` exports its own `dictionary`, `types`, with some preset dimensions:
```typ
#let types = (
  a48: (w: 210mm / 2, h: 297mm / 4, c: 2, r: 4, pw: 210mm, ph: 297mm),
  letter8: (w: 8.5in / 2, h: 11in / 4, c: 2, r: 4, pw: 8.5in, ph: 11in),
  business: (w: 3.5in, h: 2in, c: 2, r: 5, pw: 8.5in, ph: 11in),
  index: (w: 5in, h: 3in, c: 1, r: 3, pw: 8.5in, ph: 11in),
)
```


## card builders

```typ
#context {
  let questions = ()
  let answers = ()

  // 1. Find all locations of the <card> label
  let locs = query(<card>)

  for loc in locs {
    // 2. Get the values of the counter, states and level 1 heading at each <card>.
    let cg = query(selector(heading).before(loc.location())).last().body
    let ch = _ch.at(loc.location())
    let cq = _cq.at(loc.location())
    let ca = _ca.at(loc.location())
    let cn = _cn.at(loc.location()).first()
    let cf = _cn.final().first()

    // 3. Populates arrays of questions and answers using these values.
    questions.push(front(cg, cq, ch, cn, cf, c))
    answers.push(back(ca, cn, cf, c))
  }

  // 4. Loop over the arrays & dump each card's `content` onto the page.
  build(questions, answers)
}
```

In `perforate`, the `front` and `back` functions apply labels to each element as follows:

```typ
#let front(g, q, h, n, f, d) = box(width: d.w, height: d.h)[
  #g <group>
  #q <question>
  #h <hint>
  #[#n/#f] <cards>
  #n <currentcard>
  #f <finalcard>
]
#let back(a, n, f, d) = box(width: d.w, height: d.h)[
  #a <answer>
  #[#n/#f] <cards>
  #n <currentcard>
  #f <finalcard>
]
``` 

... which allows styling to be accomplished by abusing show rules on labels.
`cartao` exports one such function, `latex` to style those elements:

```typ
#let latex(body) = {
  set text(font: "New Computer Modern", size: 11pt)
  set par(leading: .6em, linebreaks: "optimized")
  set block(spacing: 1.5em)
  set list(marker: ([•], [◦], [--]))

  show <hint>: it => h(it)
  show <question>: it => q(it)
  show <answer>: it => a(it)
  show <group>: it => g(it)
  show <cards>: it => nf(it)
  show <currentcard>: it => n(it)
  show <finalcard>: it => f(it)
  body
}
```

Be sure to `show` your rules before the laying the cards out on the page.

