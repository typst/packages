# cartao

Dead simple flashcards with Typst.

## Example usage:

```typ
#import "@preview/cartao:0.1.0": card, letter8up, a48up

#set page(
  paper: "a4",
  // paper: "us-letter",
  // paper: "presentation-16-9",
  margin: (x: 0cm, y: 0cm),
)

// build the cards
#a48up
// #letter8up
// #present

// define your cards
#card(
  [Header],
  [Footer],
  [Question?],
  [answer]
)

#card(
  [portuguese],
  [Hint: Its the title of this package!],
  [card],
  [cartão]
)

#card(
  [french],
  [Hint: close to the portuguese],
  [card],
  [carte]
)
```

## Documentation

### `card`

Defines a card by updating the below `counter` and `state`(s), and dropping a <card> label.

```typ
#let card(header, footer, question, answer) = [
  #cardnumber.step()
  #cardheader.update(header)
  #cardfooter.update(footer)
  #cardquestion.update(question)
  #cardanswer.update(answer)
  <card>
]
```

#### Arguments

* `header`
* `footer`
* `question`
* `answer`

### card builders

**How they work**

1. Find all locations of the `<card>` label
2. Get the values of the `cardnumber` counter, and `cardheader`, `cardfooter`, `cardquestion`, `cardanswer` states at each `<card>`.
3. Populates an array of questions and an array of answers using these values
    - The `#a48up` and `#letter8up` functions describe the layout of each card for each item in these arrays, and also rearrange the answers so that the layout makes sense when printed double sided.
4. Loop over the arrays and dump each item's `content` onto the page.
    - in the case of `#a48up` and `letter8up`, each item is dumped into a 2-column table.

`cartao` comes builtin with the following card building functions. Take a look at the source for how they work, and use them as a guide to help you build your own flashcards with different sizes/formats.

### `a48up`

Produces a 2x8 portrait card layout on a4 paper.

Designed to be printed double-sided on the perforated 8-up a4 card paper you can find on [Amazon](https://www.amazon.ca/s?k=a4+perforated+card&crid=37RT2L4H5XSD0&sprefix=a4+perforated+ca%2Caps%2C648&ref=nb_sb_noss)

###### Usage  

```typ
#a48up
```

### `letter8up`

Produces a 2x8 portrait card layout on us-letter paper.

###### Usage  

```typ
#letter8up
```

### `present`

A 16:9 presentation of the flashcards with questions and answers on different slides

###### Usage  

```typ
#present
```

