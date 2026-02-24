# ttt-utils

`ttt-utils` is the core package of the [typst-teacher-tools collection](https://github.com/jomaway/typst-teacher-templates).

## Modules
It contains several modules:

- `assignments` contains functions for creating exams.
- `components` contains useful visual components such _lines_ or _caro pattern_, _tags_, etc ...
- `grading` contains functions for grading exams.
- `helpers` contains some utility functions.
- `layout` contains some layout functions such as _side-by-side_, etc...
- `random` contains a function to shuffle an array.


## Usage

You can import the modules you need with:

```typst
#import "@preview/ttt-utils:0.1.3": components
```

then you can access the modules function with:

`#components.lines(4)` or `#components.caro(5)`, ...

or import the wanted functions:

```typst
#import "@preview/ttt-utils:0.1.3": components, assignments

#import assignments: assignment, question, answer
#import components: caro as grid_pattern

// Add a question.

#assignment[First assignment

    #question[
        #answer(field: grid_pattern(5))
    ]
]

```

## Similar projects

- [scrutinize](https://github.com/SillyFreak/typst-packages/tree/main/scrutinize) by [SillyFreak](https://github.com/SillyFreak): Package to create exams, very similar to the `assignment` module, but only questions without assignments, and a bit more low level. I adopted a few of his ideas.

## CHANGELOG

See [CHANGELOG.md](../CHANGELOG.md)
