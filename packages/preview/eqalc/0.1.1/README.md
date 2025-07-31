# Eqalc

Convert your [Typst](https://typst.app/home) math equations to functions in order to graph or plot them.
So you only have to write your equation out ONCE!

[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/7ijme/eqalc/blob/main/LICENSE)

## Installing

Install eqalc by cloning it and then importing like this:

```typ
#import "@preview/eqalc:0.1.1": math-to-func, math-to-code, math-to-table

#let f = $g(t)=2t dot sqrt(e^t)+ln(t)+2pi$
#f\
#math-to-code(f)
#math-to-table(f, min: 1, max: 5, step: 1)

// `math-to-func` will return a function that can be used to map over values

// You can also use labels:
$ g(t) = 2t dot sqrt(e^t) + ln(t) + 2pi $ <eq>
#context math-to-code(<eq>)
#context math-to-table(<eq>, min: 1, max: 5, step: 1)
```

![image](https://github.com/user-attachments/assets/0cde46d3-e9d6-42f6-a536-f681f6b9091c)

Available functions at the moment:

- `math-to-func`
- `math-to-code`
- `math-to-table`
- `math-to-data`

More on these functions in the [manual](https://github.com/7ijme/eqalc/blob/main/docs/manual.pdf).

## How it works

Eqalc parses your equations by recursively going through the math expressions.

```typ
// Let's take #f from the example above
#repr(f)
// This will return a tree representation of the equation
equation(
    block: false,
    body: sequence(
        sequence([g], lr(body: sequence([(], [t], [)]))),
        [=],
        [2],
        [t],
        [ ],
        [⋅],
        [ ],
        root(radicand: attach(base: [e], t: [t])),
        [+],
        sequence(
            op(text: [ln], limits: false),
            lr(body: sequence([(], [t], [)])),
            ),
        [+],
        [2],
        [π],
    ),
)

#math-to-str(f)
// This will return the equation as a string
// `2*t*calc.root(calc.pow(calc.e, t), 2)+calc.ln(t)+2*calc.pi`
```

If the given math expression is an equation, the left hand side will be turned into the name of the function, and the right hand side will be the body of the function.

Only one variable is allowed in the right hand side of the equation.

## Contributing
Any contributions are welcome! Just fork the repository and make a pull request.
