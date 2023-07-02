# Acrobat (0.1.0)

Juggles with acronyms so you don't have to.

## Usage

The main goal of acrobat is to keep track of which acronym to define.

First, define the acronyms in a file dictionary named `acronyms` with the keys as acronym, and the values their definition. If there is only a singular definition, you can define it either as a string or as an array with a single string item. If there are both singular and plural, define the definition as an array where the first item is the singular definition and the second item is the plural.
The first value of the array is the singular version of the definition. If there is a second value, it is the plural version of the definition. Any additional value is useless.

Here is a sample of the `acronyms.typ` file:
```
#import "@preview/acrobat:0.1.0": *

#let acronyms = (
  "OS": "Operating System",
  "NN": ("Neural Network",),
  "BIOS": ("Basic Input/Output System", "Basic Input/Output Systems"), 
)
```
Typst package system does not allow sharing variables between packages and the main document.
Thus, you would have to pass the acronym dictionary for each call.
But because this is annoying, you can copy-paste the proxy functions at the top of your document to make it way easier. Just copy-paste and forget it!

```
#let get-def(acr,plural: false) = full-get-def(acr,plural,acronyms)
#let acr(acr) = full-acr(acr, acronyms)
#let acrpl(acr) = full-acrpl(acr,acronyms)
#let reset-all-acronyms() = full-reset-all-acronyms(acronyms)
#let print-index(level:1,outlined:false,all:true,sorted:"") = full-print-index(level:level,outlined:outlined,all:all,sorted:sorted,acronyms)
```

Once the acronyms and proxy functions are defined, you can use them in the text with the `#acr(...)` function. The argument is the acronym as a string. On the first call of the function, the acronym is expanded and the acronym added between parenthesis.

To get the plural version of the acronym, you can use the `#acrpl(...)` function that adds an 's' after the acronym. If a plural version of the definition is provided, it will be used if the first use of the acronym is plural. Otherwise, the singular version is used and a trailing 's' is added.

At any point in the document you can reset and acronym with the functions `#reset-acronym(...)` or `reset-all-acronyms()`. After a reset, the next use of the acronym is expanded.

You can also print an index of all acronyms used in the document with the `#print-index()` function. The index is printed in a section for which you can choose the heading level and outline flag (with respectively the `level` and `outlined` parameters). You can also force the index to include all acronyms, even if not used in the document, with the `all` flag. Finally, you can also choose their order with the `sorted` parameter that accept an empty string (print in the order their are defined), "up" (print in ascending alphabetical order), or "down" (print in descending alphabetical order).

Finally, you can call the `#get-def(...)` function to get the definition of an acronym. Set the `plural` parameter to true to get the plural version.

## Possible Errors:

 * If an acronyms are not defined, an error will telle you which acronym is not defined. Simply add it to the dictionary or check the spelling.
 * If the proxy functions are not defined in the main document, an error will tell you to define them. Simply copy paste the functions definitions (see above) in your document.

Have fun acrobating!
