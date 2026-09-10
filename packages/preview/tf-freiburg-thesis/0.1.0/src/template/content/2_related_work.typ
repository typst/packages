#import "@preview/tf-freiburg-thesis:0.1.0": *


= Related Work <related-work>

This template is structurally inspired by the DMI Basel Typst template: https://github.com/Nifalu/dmi-basilea-thesis. It uses the same general package shape: a public package entrypoint plus a copied starter project for `typst init`.

The examples below show the citation formats available in this starter project. A plain reference such as @turing1950 produces the standard citation form selected by the bibliography style. To make a source part of the sentence, write @turing1950[t], which renders the prose form through the template's short textual-citation rule.

The same distinction is available as explicit helper functions: #citep(<turing1950>) is the parenthetical form, while #citet(<turing1950>) is the textual prose form. Typst's built-in supplement syntax still works for page or section references, for example @turing1950[p. 433].

Multiple citations can be placed next to each other, as in @goodfellow2016 @vaswani2017, or written with the helper when you prefer function-style markup: #citep(<goodfellow2016>, <vaswani2017>).

Multiple citations can be placed next to each other, as in @goodfellow2016[t] @vaswani2017[t], or written with the helper when you prefer function-style markup: #citet(<goodfellow2016>, <vaswani2017>).

