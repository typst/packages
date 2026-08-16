# NoN Unlabeled: No Numbering for Unlabeled objects
Prevents unlabeled objects like math.expression or figure from being automatically numbered.

Usage:

```typst
#import "@preview/non-unlabeled.typ": *

// You need to do this to enable the package
#show math.equation: dont-number-unlabeled(math.equation)
#show figure: dont-number-unlabeled(figure)

// You also need to define how you number your objects (you can do this also without using headcount)
#import "@preview/headcount:0.1.0": *
#set ref(supplement: [Eq.])
#set math.equation(numbering: dependent-numbering("(1.1)", levels: 1))
#set figure(numbering: dependent-numbering("(1.1)", levels: 1))

#set heading(numbering: "1.")

= Suspicious additions

This equation is unimportant: it will not be numbered:
$
3 + 3 = 4
$

This one, on the other hand, will be used later:
$
3 + 3 = 7
$ <label>

Therefore it will be numbered. The following two equations instead won't.

$
3 + 3 = 42
$

$
3 + 3 = 24
$

This also needs to be numbered
$
3 + 3 = 777
$ <label2>

```
