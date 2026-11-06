# Acrostiche (0.1.0)

Manages acronyms so you don't have to.

## Usage

The main goal of Acrostiche is to keep track of which acronym to define.

### Define acronyms and proxy functions
First, define the acronyms in a dictionary named `acronyms` with the keys being the acronyms, and the values an array of their definition. If there is only a singular version of the definition, the array contain only one value (don't forget the trailing comma to force typst to consider it as an array). If there are both singular and plural versions, define the definition as an array where the first item is the singular definition and the second item is the plural.
Then, initialize arostiche with the acronyms you just defined with the `#init-acronyms(...)` function:

Here is a sample of the `acronyms.typ` file:
```
#import "@preview/acrostiche:0.1.0": *

#let acronyms = (
  "NN": ("Neural Network",),
  "OS": ("Operating System",),
  "BIOS": ("Basic Input/Output System", "Basic Input/Output Systems"), 
)
#init-acromyns(acronyms)
```

### Call acrostiche functions
Once the acronyms and proxy functions are defined, you can use them in the text with the `#acr(...)` function. The argument is the acronym as a string (for example "BIOS"). On the first call of the function, it returns the acronym with its definition (for example "Basic Input/Output System (BIOS)").

To get the plural version of the acronym, you can use the `#acrpl(...)` function that adds an 's' after the acronym. If a plural version of the definition is provided, it will be used if the first use of the acronym is plural. Otherwise, the singular version is used and a trailing 's' is added.

At any point in the document you can reset acronyms with the functions `#reset-acronym(...)` (for a single acronym) or `reset-all-acronyms()` (to reset all acronyms). After a reset, the next use of the acronym is expanded.

You can also print an index of all acronyms used in the document with the `#print-index()` function. The index is printed as a section for which you can choose the heading level and outline parameters (with respectively the `level: int` and `outlined: bool` parameters). You can also choose their order with the `sorted: string` parameter that accept either an empty string (print in the order their are defined), "up" (print in ascending alphabetical order), or "down" (print in descending alphabetical order).
The index contains all the acronyms you defined.

Finally, you can call the `#display-def(...)` function to get the definition of an acronym. Set the `plural` parameter to true to get the plural version.

## Possible Errors:

 * If an acronyms are not defined, an error will tel you which acronym is not defined. Simply add it to the dictionary or check the spelling.
 * For every acronym "ABC" that you define, the associate state named "acronym-state-ABC" is initialized and used. To avoid errors do not try to use this state manually for other purposes. Similarly the state named "acronyms" is reserved to acrostiche, avoid using it.

Have fun acrostiching!
