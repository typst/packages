# ttt-utils

`ttt-utils` is the core package of the [typst-teacher-tools collection](https://github.com/jomaway/typst-teacher-templates).

## Modules
It contains several modules:

- `assignments` contains functions for creating exams.
- `rubic` contains a function for creating rubic tables.
- `components` contains useful visual components such _lines_ or _caro pattern_, _tags_, etc ...
- `grading` contains functions for grading exams.
- `helpers` contains some utility functions.
- `layout` contains some layout functions such as _side-by-side_, etc...
- `random` contains a function to shuffle an array.


## Usage

You can import the modules you need with the following command.
Just replace `<VERSION>` with a valid version like `0.2.0`

```typst
#import "@preview/ttt-utils:<VERSION>": components
```


then you can access the modules function with:

`#assignments.question[]` or `#components.caro(5)`, ...

or import the wanted functions:

```typst
#import "@preview/ttt-utils:<VERSION>": components, assignments

#import assignments: scenario, question, answer
#import components: caro

// Add a question.

#scenario[First scenario

    #question[
        What is the capital of France?
        
        #caro(5)[
          #answer[Paris]
        ]
    ]
]

```
