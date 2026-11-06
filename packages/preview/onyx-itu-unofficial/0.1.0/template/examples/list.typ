= List Examples

== Unordered Lists
Simple bullet points are created with the `-` symbol:

- This is the first item
- This is the second item
- This is the third item

== Ordered Lists
Numbered lists are created with the `+` symbol:

+ First ordered item
+ Second ordered item
+ Third ordered item

== Nested Lists

You can create nested lists by adding indentation:

- Fruits
  - Apples
  - Bananas
  - Oranges
- Vegetables
  - Carrots
  - Broccoli
  - Spinach

== Mixed List Types

+ Step one
+ Step two
  - Sub-item A
  - Sub-item B
+ Step three

== Term Lists

Term lists (similar to definition lists) use `/`:

/ Term 1: This is the definition of the first term.
/ Term 2: This is the definition of the second term.
/ Typst: A markup-based typesetting system.

== Customized Lists

#set enum(numbering: "1.a)")
+ First level item
  + Nested item a)
  + Nested item b)
+ Another first level item

#set list(marker: [→])
- Custom bullet item
- Another custom bullet item