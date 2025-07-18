# Acrostiche (0.5.2)

Manages acronyms so you don't have to.

## Quick Start

```
#import "@preview/acrostiche:0.5.2": *

#init-acronyms((
  "WTP": ("Wonderful Typst Package","Wonderful Typst Packages"),
))

Acrostiche is a #acr("WTP")! This #acr("WTP") enables easy acronyms manipulation.

Its main features are auto-expansion of the first occurence, global or selective expansion reset #reset-all-acronyms(), implicit or manual plural form support (there may be multiple #acrpl("WTP")), and customizable index printing. Have Fun!
```


## Usage

The main goal of Acrostiche is to keep track of which acronyms to define.

### Define acronyms
All acronyms used with Acrostiche must be defined in a dictionary passed to the `init-acronyms` function.
There are two possible forms for the definition, depending on the required features.

#### Simple Definitions
For a quick and easy definion, you can use the acronym to display as the key and an array of one or more strings as the singular and plural versions of the expanded meaning of the acronym.

```
#init-acronyms((
  "SDA": ("Simply Defined Acronym","Simply Defined Acronyms"),
  "ASDA": ("Another Simply Defined Acronym","Another Simply Defined Acronyms"),
))
```

If there is only a singular version of the definition, the array contains only one value.
If there are both singular and plural versions, define the definition as an array where the first item is the singular definition and the second item is the plural.

#### Advanced Definitions
If you find yourself needing more flexibility when defining the acronyms, you can pass a dictionary for each acronym.
The expected keys are: `short` the singular short form to display, `short-pl` the plural short form, `long` singular long (expanded) form to display, and `long-pl` the plural long form.
The main benefit of this definition is to use a separate key for calling the acronym, useful when acronyms are long and tedious to write.

```
#init-acronyms((
  "la": (
short: "LATATW",
long: "Long And Tedious Acronym To Write",
short-pl: "LATAsTW",
long-pl: "Long And Tedious Acronyms To Write"),
))
```

Any other keys than these will be discarded.


### Call Acrostiche functions
Once the acronyms are defined, you can use them in the text with the `#acr(...)` function.
The argument is the acronym as a string (for example, "BIOS"). On the first call of the function, it prints the acronym with its definition (for example, "Basic Input/Output System (BIOS)").
On the next calls, it prints only the acronym.

To get the plural version of the acronym, you can use the `#acrpl(...)` function that adds an 's' after the acronym.
If a plural version of the definition is provided, it will be used if the first use of the acronym is plural.
Otherwise, the singular version is used, and a trailing 's' is added.

To intentionally print the full version of the acronym (definition + acronym, as for the first instance), without affecting the state, you can use the `#acrfull(...)` function. 
For the plural version, use the `#acrfullpl(...)` function.
Both functions have shortcuts with `#acrf(...)` and `#acrfpl(...)`.

At any point in the document, you can reset acronyms with the functions `#reset-acronym(...)` (for a single acronym) or `reset-all-acronyms()` (to reset all acronyms). After a reset, the next use of the acronym is expanded.
Both functions have shortcuts with `#racr(...)` and `#raacr(...)`.

You can also print an index of all acronyms used in the document with the `#print-index()` function.
The index is printed as a section for which you can choose the heading level, the numbering, and the outline parameters (with respectively the `level: int`, `numbering: none | string | function`, and `outlined: bool` parameters).
Clicking on an acronym in the text links to the index, this can be disabled with `clicking: false`.
You can also choose their order with the `sorted: string` parameter that accepts either an empty string (print in the order they are defined), "up" (print in ascending alphabetical order), or "down" (print in descending alphabetical order).
By default, the index contains all the acronyms you defined. You can choose to only display acronyms that are actually used in the document by passing `used-only: true` to the function. Warning, the detection of used acronym uses the states at the end of the document. Thus, if you reset an acronym and do not use it again until the end, it will not appear in the index.
 You can use the `title: string` parameter to change the name of the heading for the index section.
The default value is "Acronyms Index". Passing an empty string for `title` results in the index having no heading (i.e., no section for the index).
You can customize the string displayed after the acronym in the list with the `delimiter: ":"` parameter.
To adjust the spacing between the acronyms adjust the `row-gutter: auto | int | relative | fraction | array` parameter, the default is `2pt`.

Finally, you can call the `#display-def(...)` function to display the definition of an acronym. Set the `plural` parameter to true to get the plural version.

### Functions Summary:

| **Function**                  | **Description**                                                                                                     |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------|
| **#init-acronyms(...)**        | Initializes the acronyms by defining them in a dictionary where the keys are acronyms and the values are definitions. |
| **#acr(...)**                  | Prints the acronym with its definition on the first call, then just the acronym in subsequent calls.                  |
| **#acrpl(...)**                | Prints the plural version of the acronym. Uses plural definition if available, otherwise adds an 's' to the acronym. |
| **#acrfull(...)**              | Displays the full (long) version of the acronym without affecting the state or tracking its usage.                    |
| **#acrfullpl(...)**            | Displays the full plural version of the acronym without affecting the state or tracking its usage.                    |
| **#reset-acronym(...)**        | Resets a single acronym so the next usage will include its definition again.                                         |
| **#reset-all-acronyms()**      | Resets all acronyms so the next usage will include their definitions again.                                          |
| **#print-index(...)**          | Prints an index of all acronyms used, with customizable heading level, order, and display parameters.                |
| **#display-def(...)**          | Displays the definition of an acronym. Use `plural: true` to display the plural version of the definition.           |
| **racr, raacr, acrf, acrfpl**  | Shortcuts names for respectively `reset-acronym`, `reset-all-acronyms`, `acrfull`, and `acrfullpl`.                  | 

Shortcut names inspired by the `acronym` package for LaTeX by Tobias Oetiker:

| **Function**                  | **Description**                                                                                                     |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------|
| **#ac(...)**        | Same as `acr`, display an acronym.|
| **#acf(...)**        | Same as `acrfull`, display the long version of an acronym.|
| **#acfp(...)**        | Same as `acf` but plural.|
| **#acs(...)**        | Display the short version of the acronym, does not update the acronym state.|
| **#acsp(...)**        | Same as `acs` but plural.|
| **#acused(...)**        | Mark an acronym as used without printing anything.|
| **#acresetall(...)**        | Reset all acronyms.|

## Advanced Definitions
This is a bit of a hacky feature coming from pure serendipity.
There is no enforcement of the type of the definitions.
Most users would naturally use strings as definitions, but any other content is acceptable.
For example, you set your definition to a content block with rainbow-fille text, or even an image.
The rainbow text is kinda cool because the gradient depend on the position in the page so depending on the position of first use the acronym will have a pseudo-random color.

If you use anything else than string for the definition, do not forget the trailing comma to force the definition to be an array (an array of a single element is not an array in Typst at the time of writing this).
I cannot guarantee that arbitrary content will remain available in future versions but I will do my best to keep it as it is kinda cool.
If you find cool uses, please reach out to show me!


<blockquote>
Yes it is posible to build nest/recursive acronyms definitions.
If you point to another acronym, it all works fine.
If you point to the same acronym, you obviously create a recursive situation, and it fails.
It will not converge, and the compiler will warn you and will panic.
Be nice to the compiler, don't throw recursive traps.
</blockquote>


Here is a minimal working example of funky acronyms:

```
#import "@preview/acrostiche:0.5.2": *                                                           
#init-acronyms((
  "RFA": ([#text(fill: gradient.linear(..color.map.rainbow))[Rainbow Filled Acronym]],),                                                             
  "NA": ([Nested #acr("RFA") Acronym],)
))
#acr("NA")
```

## Possible Errors:

 * If an acronym is not defined, an error will tell you which one is causing the error. Simply add it to the dictionary or check the spelling.
 * `display-def` leverages the state `display` function and only works if the return value is actually printed in the document. For more information on states, see the Typst documentation on states.
 * Acrostiche uses a state named `acronyms` to keep track of the definitions and usage. If you redefined this state or use it manually in your document, unexpacted behaviour might happen.

# Contributing

If you notice any bug or want to contribute a new feature, please open an issue or a merge request on the fork [Grisely/packages](https://github.com/Grisely/packages)
All contributions are welcome.
All merge requests should only modify the `dev` directory.
Once enough modifications are added to the `dev` version, a new version folder will be created and merged upstream.

To test modifications locally, copy the dev folder to the local directory for typst packages as version 0.0.0:

```
rm -rf ~/.local/share/typst/packages/preview/acrostiche/0.0.0 && cp -R ../dev ~/.local/share/typst/packages/preview/acrostiche/0.0.0
```


# Acknowledgments

Thank you to the contributors: **caemor**, **AurelWeinhold**, **daniel-eder**, **iostapyshyn**, **ChHecker**, **Drodt**, **seyfu-t**.
