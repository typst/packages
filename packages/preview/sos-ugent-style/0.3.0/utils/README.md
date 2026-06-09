# Scope of 'utils'
Some functions are very interesting in most dissertations or documents,
but should not be part of a general UGent template.
At the moment, they can be found in this directory.
See [lib.typ](lib.typ) for all exported utilities.

## Researched Typst Universe packages
This file also contains some research on the various Typst packages useful for
a dissertation (I did the work, why not write it down?).
Some categories are described here.

### Mathematics packages
Only one option: use `physica`.
Just use directly in your dissertation, no use putting it here in utils.
~~It is showcased in the examples directory.~~

### Glossary packages
Synonyms:
- glossary (a list of words used in the text with a definition),
- abbreviations (a list of abbreviations to the full meaning),
  - acronyms (a subset of abbreviations, there are also initialisms and other
    categories), ...
They are synonyms in the sense that packages mostly do both of them.

After my review (see 👇), I think **glossy** is *the* best package at the
moment and missing features should be added there. That is also why glossy
is [thightly integrated](../src/utils/README.md) into sos-ugent-style. Because
of the glossy architecture, even this integration remains pretty lightweight.

I reviewed most glossary packages on Typst Universe:  
Hot:
Package          | Remarks
-----------------|---------------------------------------------------------
**glossy**       | Based on 'glossarium', but easier syntax
abbr             | Can contain [content], instead of stringifying everything
acrostiche       | Same, can contain [content]. Contains a lot of commands (downside)

Not:
                 |
-----------------|---------------------------------------------------------
glossarium       | Inspiring, but glossy (fork) has superior usability. Does references Dherse. (**previously used**)
gloss-awe        | unmaintained on Universe
leipzig-glossing | too advanced, for linguistics
acrotastic       | outdated, amateuristic fork

### Theorem packages

|               |                                                                                |
|---------------|-----------------------------------------                                       |
|theorion       | Nice theming!, seems very future complete! It acknowledges ctheorems & thmbox. |
|thmbox         | Nice colors!                                                                   |
|ctheorems      | Stable, bit outdated?                                                          |
|theoretic      |                                                                                |
|great-theorems |                                                                                |
|lemmify        |                                                                                |
|frame-it       | just different boxes...                                                        |
|Dherse ubox    | Custom code from Dherse, very interesting & colorblind friendly                |
|colorful-boxes | Also boxes                                                                     |
|minienvs       | unmaintained, no examples                                                      |
