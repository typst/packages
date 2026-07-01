# Acrostiche (0.3.2)

Manages acronyms so you don't have to.

## Quick Start

```
#import "@preview/acrostiche:0.3.2": *

#init-acronyms((
  "WTP": ("Wonderful Typst Package","Wonderful Typst Packages"),
))

Acrostiche is a #acr("WTP")! This #acr("WTP") enables easy acronyms manipulation.

Its Main features are auto-expansion of the first occurence, global or selective expansion reset #reset-all-acronyms(), implicit or manual plural form support (there may be multiple #acrpl("WTP")), and customizable index printing. Have Fun!
```


## Usage

The main goal of Acrostiche is to keep track of which acronyms to define.

### Define acronyms
First, define the acronyms in a dictionary, with the keys being the acronyms and the values being arrays of their definitions.
If there is only a singular version of the definition, the array contains only one value.
If there are both singular and plural versions, define the definition as an array where the first item is the singular definition and the second item is the plural.
Then, initialize Arostiche with the acronyms you just defined with the `#init-acronyms(...)` function:

Here is a sample of the `acronyms.typ` file:
```
#import "@preview/acrostiche:0.3.2": *

#init-acronyms((
  "NN": ("Neural Network"),
  "OS": ("Operating System",),
  "BIOS": ("Basic Input/Output System", "Basic Input/Output Systems"), 
)) 
```

### Call Acrostiche functions
Once the acronyms are defined, you can use them in the text with the `#acr(...)` function.
The argument is the acronym as a string (for example, "BIOS"). On the first call of the function, it prints the acronym with its definition (for example, "Basic Input/Output System (BIOS)").
On the next calls, it prints only the acronym.

To get the plural version of the acronym, you can use the `#acrpl(...)` function that adds an 's' after the acronym.
If a plural version of the definition is provided, it will be used if the first use of the acronym is plural.
Otherwise, the singular version is used, and a trailing 's' is added.

At any point in the document, you can reset acronyms with the functions `#reset-acronym(...)` (for a single acronym) or `reset-all-acronyms()` (to reset all acronyms). After a reset, the next use of the acronym is expanded.

You can also print an index of all acronyms used in the document with the `#print-index()` function.
The index is printed as a section for which you can choose the heading level, the numbering, and the outline parameters (with respectively the `level: int`, `numbering: none | string | function`, and `outlined: bool` parameters).
You can also choose their order with the `sorted: string` parameter that accepts either an empty string (print in the order they are defined), "up" (print in ascending alphabetical order), or "down" (print in descending alphabetical order).
The index contains all the acronyms you defined. You can use the `title: string` parameter to change the name of the heading for the index section.
The default value is "Acronyms Index". Passing an empty string for `title` results in the index having no heading (i.e., no section for the index).
You can customize the string displayed after the acronym in the list with the `delimiter: ":"` parameter.
To adjust the spacing between the acronyms adjust the `row-gutter: auto | int | relative | fraction | array` parameter, the default is `2pt`.

Finally, you can call the `#display-def(...)` function to display the definition of an acronym. Set the `plural` parameter to true to get the plural version.

## Possible Errors:

 * If an acronym is not defined, an error will tell you which one is causing the error. Simply add it to the dictionary or check the spelling.
 * For every acronym "ABC" that you define, the state named "acronym-state-ABC" is initialized and used. To avoid errors, do not try to use this state manually for other purposes. Similarly, the state named "acronyms" is reserved to Acrostiche; avoid using it.
 * `display-def` leverages the state `display` function and only works if the return value is actually printed in the document. For more information on states, see the Typst documentation on states.

If you notice any bug or want to contribute a new feature, please open an issue or a merge request on the fork [Grisely/packages](https://github.com/Grisely/packages)
