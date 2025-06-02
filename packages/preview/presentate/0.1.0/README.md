# Presentate
is a package for creating presentation in Typst. It comes with simple animations like `#pause`, `#meanwhile`, `#uncover`, and `#only`. For usage, please refer to [demo](https://github.com/pacaunt/typst-presentate/blob/main/examples/demo.pdf).

## Usage 
Import the package with 
```typst
#import "@preview/presentate:0.1.0": *
```
and then, the functions are automatically available. 

### creating slides 
```typst
#set page(paper: "presentation-16-9")
#set text(size: 25pt)

#slide[
  = Welcome 

  + First #pause 

  + Second #pause 

  + Third
]
```
Results in 
![image](https://github.com/user-attachments/assets/04cfc447-12e3-4f06-95c3-a419d71593ad)

### CeTZ, Equation, Pinit, and Fletcher Support
Please look at the examples in [demo](https://github.com/pacaunt/typst-presentate/blob/main/examples/demo.pdf).

## Acknowledgement 
Thanks [@knuesel](https://github.com/knuesel/typst-minideck) for the `minideck` package that inspires me the syntax and examples.
[Touying package authors]() and [Polylux author]() for inspring me the syntax and parsing method. 
