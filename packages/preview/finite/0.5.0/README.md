# finite (v0.5.0)

**finite** is a [Typst](https://github.com/typst/typst) package for rendering finite automata on top of [CeTZ](https://github.com/johannes-wolf/typst-canvas).

## Usage

Import the package from the Typst preview repository:

```typst
#import "@preview/finite:0.5.0": automaton
```

After importing the package, simply call `#automaton()` with a dictionary holding a transition table:
```typst
#import "@preview/finite:0.5.0": automaton

#automaton((
  q0: (q1:0, q0:"0,1"),
  q1: (q0:(0,1), q2:"0"),
  q2: (),
))
```

The output should look like this:
![Example for a finite automaton drawn with finite](docs/assets/example.png)

## Further documentation

See `manual.pdf` for a full manual of the package.
