# Introduction

This template was created with the aim of simplifying the creation of new content for PRIME courses at TU Delft.

We chose [Typst](https://typst.app) as it is modern open source mark-up language. It offers (almost) the same capabilities as $\LaTeX$, with the simplified syntax of Markdown, making it an easy mark-up language to learn.

This document shows you how to use this template as well as how to compile your slides. In addition, we will give you a few examples so that you can start creating your own template.

This guide assumes that you already have the Typst compiler installed in your system. If you do not have Typst installed in your system we refer you to the [Typst repository](https://github.com/typst/typst?tab=readme-ov-file) and follow the instructions for installing it in your machine.

1. [Installation](Installation.md)
2. [Compiling the examples](compiling_examples.md)
3. [Start a presentation from an existing example](existing_example.md)
3. [How to create a new presentation](new_presentation.md)
4. [Advanced use of the template](using_template.md)

#  Known and Possible Issues/Bugs

- The label `<touying:hidden>` does not work for hidding slides. 

- If you hide a slide containing speaker notes with a conditional, and you compile the pdf with pdfpc for a presentation with speaker notes, the speaker notes from the hidden slide will appear in the "presenter view" messing with the rest of the speaker notes. If you hide a slide, comment (if they exist) the speaker notes as well for that slide.

# Authors

Dani Balagué Guardia
