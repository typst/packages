# Presentate
**Presentate** is a package for creating presentation in Typst. It comes with simple animations like `#pause`, `#meanwhile`, `#uncover`, and `#only`. For usage, please refer to [demo](https://github.com/pacaunt/typst-presentate/blob/main/examples/demo.pdf).

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
![image](https://github.com/user-attachments/assets/89adc75e-be3c-471c-ac4f-5681feef17ca)

### CeTZ, Equation, Pinit, and Fletcher Support
Please look at the details in [demo](https://github.com/pacaunt/typst-presentate/blob/main/examples/demo.pdf).
Here are some examples: 
1. Correct page numbering and compatible with Typst `outline()` ![image](https://github.com/user-attachments/assets/46079a87-7917-41ff-bfed-1f37769bb463)

2. `#pause` and `#meanwhile` for simple animations, with correct hiding marks and numbers. ![image](https://github.com/user-attachments/assets/97d77d9f-5f79-400b-9d22-2d1ef0b992d9)

3. Simple animations in `math.equation` support. ![image](https://github.com/user-attachments/assets/2ca66888-3f47-4cf3-8286-47f0997812bd)
4. `#uncover` and `#only`. ![image](https://github.com/user-attachments/assets/4040857c-9322-42a2-972c-57a7fc68f7e0)
5. CeTZ hackable: ![image](https://github.com/user-attachments/assets/5ec8d403-5c09-444e-a299-5fa238c90aac)
6. Pinit compatible (example from [minideck](https://github.com/knuesel/typst-minideck)): ![image](https://github.com/user-attachments/assets/d3459085-0b74-4f7f-8887-7840fd6817df)

7. Fletcher hackable (Inspired from [Touying reducer](https://touying-typ.github.io/docs/integration/fletcher)): ![image](https://github.com/user-attachments/assets/7f1e3440-13af-4795-991d-d1ae567caf42)
8. Fake Frozen counters for equation, heading, figure, numbering. 
 

## Acknowledgement 
Thanks [Mimideck package author](https://github.com/knuesel/typst-minideck) for the `minideck` package that inspires me the syntax and examples.
[Touying package authors](https://github.com/touying-typ/touying) and [Polylux author](https://github.com/polylux-typ/polylux) for inspring me the syntax and parsing method. 
