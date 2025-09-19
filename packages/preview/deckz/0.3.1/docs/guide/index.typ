#import "../template.typ": *

= How to use DECKZ
<sec:guide>

DECKZ is a Typst package designed to *display playing cards in the classic poker style*, using the standard French suits (hearts #text(red, emoji.suit.heart), diamonds #text(red, emoji.suit.diamond), clubs #text(black, emoji.suit.club), and spades #text(black, emoji.suit.spade)). 
Whether you need to show a single card, a hand, or a full deck, DECKZ provides flexible tools to visualize cards in a variety of formats and layouts. 
The package has been developed with the idea of it being used in games, teaching materials, or any document where clear and attractive card visuals are needed.

This manual for DECKZ is organized in three main parts: 
+ @sec:guide helps you get started with the *main features*; 
+ @sec:documentation provides *detailed documentation* for each function, serving as a reference; 
+ @sec:examples presents *practical examples* that combine different features. 
At the end, you'll find credits and instructions for contributing to the project.

#info-alert[
	This manual refers to the most recent DECKZ release as of today: *version #doc.package.version*.
]


== Import the package

To start using DECKZ in your Typst document, simply *import the package* with:

#show-import(imports: none)

This makes all DECKZ functions available under the #text(purple.darken(30%))[`deckz`] namespace.
Congratulations, you're now ready to start visualizing cards!


#include "01.basics.typ"

#include "02.grouping.typ"

#include "03.customization.typ"

#include "04.random.typ"

#include "05.scoring.typ"