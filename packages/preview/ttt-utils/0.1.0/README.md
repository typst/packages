# ttt-utils

`ttt-utils` is the core package of the [typst-teacher-tools-collection](https://github.com/jomaway/typst-teacher-templates).


## Modules
It contains several modules:

- `assignments` contains functions for creating exams.
- `components` contains useful visual components such _lines_ or _caro pattern_, _tags_, etc ...
- `grading` contains functions for grading exams.
- `helpers` contains some utility functions.
- `layout` contains some layout functions such as _side-by-side_, etc...
- `random` contains a function to shuffle an array. ! Might be replaced with [suiji](https://typst.app/universe/package/suiji) soon.


## Usage 

You can import the modules you need with:

```typst
#import "@preview/ttt-utils:0.1.0": components
```

then you can access the modules function with:

`#components.lines(4)` or `#components.caro(5)`, ...

or import the wanted functions:

```typst
#import "@preview/ttt-utils:0.1.0": components, assignments

#import assignments: assignment, question, answer
#import components: caro as grid_pattern

// Add a question.

#assignment[First assignment

    #question[
        The question is?
        #answer(field: grid_pattern(5))[The answer is ...]
    ]
]

```

Proper docs will follow. 
