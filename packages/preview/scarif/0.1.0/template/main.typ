#import "@preview/scarif:0.1.0" as s

#show: s.template

#s.title("Scarif", sub-title: "A Modern Typst Template")

= What is Scarif?

Scarif is a beautifully designed Typst template that brings tropical elegance to your documents. Drawing design inspiration from the official Typst documentation website, it combines sophisticated typography with curated color gradients to create stunning layouts. The name itself is inspired by a breathtaking planet from a famous sci-fi universe.

= Examples

== Code snippets

The #s.raw("scarif.raw()") function displays code blocks with elegant styling. It wraps code in a rounded container with subtle shadows, making snippets stand out while maintaining visual harmony.

#s.raw(```typ
#let add(a, b) = a + b
```)

== Images

The #s.raw("scarif.image()") function enhances images with polished styling. It applies rounded corners and soft shadows while optimizing width for maximum impact:

#s.image(read("beach.jpg", encoding: none), height: 290pt)
