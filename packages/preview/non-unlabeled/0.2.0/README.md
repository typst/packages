# NoN Unlabeled: No Numbering for Unlabeled objects
**Non Unlabeled** prevents unlabeled objects (like `math.expression` or `figure`) from being automatically numbered.

Example:

```typst
#import "@preview/non-unlabeled:0.2.0": *

// You need to do this to enable the package
#show math.equation: dont-number-unlabeled(math.equation) // For maths expressions
#show figure: dont-number-unlabeled(figure) // For numbers

// You also need to define how you number your objects (you can do this also without using headcount)
#import "@preview/headcount:0.1.0": *
#set math.equation(numbering: dependent-numbering("(1.1)", levels: 1))
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

![alt text](img/image.png "Title")
