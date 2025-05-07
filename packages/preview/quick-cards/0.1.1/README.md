[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FAnts-Aare%2Fquick-cards%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://github.com/Ants-Aare/quick-cards)
[![MIT License](https://img.shields.io/badge/license-apache-blue)](https://github.com/Ants-Aare/quick-cards/blob/main/LICENSE)
![User Manual](https://img.shields.io/badge/manual-.pdf-purple)

# Create Flashcards fast!
Quick-Cards is a package for creating flashcards in Typst as fast as possible. It features three distinct creation models:
- Auto: Just apply the show rule and your headings become categories, subheadings questions and everything else are the answers
- Manual: Call #question[] #answer[] #hint[] or #category[] to define your cards
- Full Auto: Convert CSV tables from Excel/Sheets into flashcards

## Usage:
```typ
#import "@preview/quick-cards:0.1.1": *

#show: quick-cards-show.with(
  columns:2,                        // quick-cards does layout automatically i.e.
  rows:4,                           // questions and answers line up when printing twosided
  card-template: flashcard-classic, // there's predefined templates or create your own
  parse-body: true                  // enable Auto mode
)

= Art                               // category
== Who painted the Mona Lisa?       // question
=== Also created the vitruvian man. // hint
Leonardo da Vinci                   // answer

```
![Showcase](https://github.com/Ants-Aare/quick-cards/blob/main/examples/showcase.png)
```typ
#show: quick-cards-show.with(
  columns:2,
  rows:4,
  card-template: flashcard-modern, // try using different styles!
  parse-body: false
)

#category[Derivation]              // same functionality, you can even mix auto and manual
#question[What's the power rule of derivation?]
#hint[Don't forget to multiply by the exponent!]
#answer[$                          // include math, Cetz, svgs, images, etc 
  f(x) &= x^n\
  f'(x) &= n #sym.dot x^(n-1)
$]
```
![Showcase-Modern](https://github.com/Ants-Aare/quick-cards/blob/main/examples/showcase-modern.png)

Alternatively try sending data directly to the quick-cards-layout function instead of using show rules. This way you can import data, turn it into content and apply a proper layout:
```typ
#quick-cards-layout(
  columns: 3,
  rows:5,
  cards: csv("Test.csv")
    .map(x=> flashcard-simple(
      question: x.at(0),
      answer: x.at(1),
      hint: x.at(2),
      category: x.at(2)
    ))
)
```
Use images instead of text categories, by defining image/category pairs:
```typ
#set-category-database(
  (
    Art: image("Assets/icon-category-art.svg"),
    Movies: image("Assets/icon-category-movies.svg"),
    Nature: image("Assets/icon-category-nature.svg"),
    People: image("Assets/icon-category-people.svg"),
  ),
)
```
