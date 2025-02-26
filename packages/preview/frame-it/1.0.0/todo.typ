#set heading(numbering: "1.1.1")

= OPEN
== make color calculation respect predefined colors
The color gradient calculated should generate colors which are plenty distinct from colors
given by the user.

= Postponed
== decentralize theorem definitions
Right now, we define frames as groups through the `make-frames` call, grouped together
by their color-gradient and kind.
However, this is fairly arbitrary. A more flexible system would have one `init-theorem` call
for each theorem kind.
The color gradient would need to be externalized. See @externalize-color-gradient.

_Response_: The current system does not create problems for me at all in practice.

== external color gradient handle <externalize-color-gradient>
Sometimes, we want to group theorems with common/different kinds but at the same time,
we want the color gradient to go over all of them.
For this, we should figure out a way to externlize this. Maybe with a counter.
However, this isn't trivial as we need to figure out how many colors there will be used in total
before we can do any calculations.

_Response_: Not needed at this point. Too complicated.

= DONE
== [DONE] As a user, I am able to apply styling as a show rule to naturally change the default style for parts of my file
Technically, we could use state explicitly or have the factory not apply the show rule yet and enforce that the user sets a show rule.\
Syntax would probably be `show: set-style(style)`\
We would need to look into if we need to introduce a new `set-frame-style` variant which does not set the show rule.
_Scrapped_ because we supply styling in the arguments now.

== [DONE] Hint Styling/Variants
Which are less intrusive, for example only highlighting the edge of the page in a color.

== [DONE] Style using argument
We do not like the syntax `#(slim.theorem)[...]` anymore because it is less discoverable, the brace is weird
and you have to add the slim argument to the `make-frames` destructuring, which is unexpected.

We prefer a syntax where the theorem functions have a positional `style: "slim"` argument.

== [DONE] We want to reduce the styling to one function which can also be supplied customly
This would open the door for more streamlined styling editions and providing custom styling
on demnad.

== [DONE] low-emphasize elements
Sometimes, we like to make a categorical point which doesn't have the same weight
as our normal theorems.
This todo adds elements which are visually less distinct
and spacious as the current design.

DONE: `frame-theorems` exports inline and slim elements where all other frames can also be accessed
in the altered versions. In the future, when typst supports functions as scopes, we can add
this preferred syntax:
```typst
definition.small[Infinite Primes][...]
```
Alternatively, we might add another function which initializes frames without a default
`definition[][]` export and instead each theorem kind is only a dictionary with all the versions:

This would enable the old syntax again
```
definition.small[][]
```

== [DONE] fix: When caption is overflowing, the caption is displayed below instead of above
When there is such a long title or tags that they fill the entire width, then the header
"Definition" for instance, is displayed below the tags and title instead of, more sensibly, above.

