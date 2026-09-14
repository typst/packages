# Fibber

*fibber (noun): One who tells trivial lies. Microfabrications, if you will.*

Draw microfabrication diagrams using typst. Built on CeTZ.

## Table of Contents
[Usage](#usage)
- [Step Functions](#step-functions)
- [Generating a Legend](#generating-a-legend)
- [Formatting Outputs](#formatting-outputs)
- [Formatting Quickstart](#formatting-quickstart)

## Usage

Import like so
```
#import "@preview/fibber:0.1.0"
```
See examples in the [examples directory](https://github.com/gauthamrmn/fibber/tree/main/0.1.0/examples).
Overall, diagram data is created using the `#device-steps` function.

```
#device-steps(
    width: 8,
    layer-height: 1,
    background-color: white,
    materials: (:),
    steps: (),
    display-steps: (),
    )
```

All parameters of device-steps have a default value. `width` and `layer-height` parameters represent an aspect ratio, because the diagram will be scaled to fit in its container when it is rendered.

Materials is by default empty, but you cannot make a meaningful device without any defined materials.
Define a materials dictionary in the following way:

```
#let materials = (
    "Material 1": gray,
    "Material 2": rgb("b0bccc"),
)
```
With the left side being a string representing the material name, and the right side being its corresponding color.

`steps` is by default an empty array, but passing an empty array to steps will return nothing, because the diagrams are defined by their steps. `steps` should be a list of length 1 or greater where each member is one of the following "step functions": `deposit` or `etch`. Those functions will be explained in the next section.

`display-steps` is by default an empty array, but this corresponds to displaying all individual step functions of the process. In many cases, this is undesirable. For example, you may have a two layer substrate. In fibber, this would be rendered using 2 `deposit`ions, but in real life, you would want to treat it as one step. `display-steps` is an array of of the array indexes of the steps you would like to display.


### Step Functions

#### `deposit` function

```
#deposit(
    material: none,
    height: 1,
    pattern: ((left, middle, right)) => ((left, right),),
    start-layer: none)
    )
```

The `material` parameter is by default `none`, but this is meaningless. `material` should be passed as a string that corresponds to one of the materials in the dictionary passed to `#device-steps`.
The `height` parameter is the number of layers the deposition will occupy (deposition will happen from the lowest unfilled layer and count up). It is 1 by default.
The `pattern` parameter is a little bit tricky. By default, the pattern is set to cover the whole layer. In general, the `pattern` parameter should be an in-line function with the argument (left, middle, right) that returns an N-length array of 2-length arrays. In simpler terms, It should look like this:

```
#let my-pattern = ((left, middle, right)) => (
    (left + 1.5, middle - 0.75), // first element is left side of deposition, second element is right side
    (middle - 0.5, middle + 0.5),
    (middle + 0.75, right - 1.5),
)
```
The `((left, middle, right)) =>` syntax is mandatory, but will be the same every time. The left and right sides of a deposition can have their positions defined relative to the left, middle, and right of the device, which is why it's important to know that by default the width of the device is 8 (So `left` = 0, `middle` = 4, `right` = 8).

The `start-layer` parameter is by default `none`, but this tells the device to start depositing at the current layer. In general, the `start-layer` parameter can either be a number (integer or float), or a function. If it is a number, the deposited layer will be drawn at the layer corresponding to the number specified. However, `start-layer` can also be a function, as shown below

```
deposit(
    ...
    start-layer: (current-layer) => current - 3
    )
```

Which enables you to specify the layer relative to the current position.  Generally, it is not recommended to use the `start-layer` parameter to place something above an air gap, as this is physically impossible, and devices in fibber should be specified according to the actual steps used to make them.

#### `etch` function

The etch function is declared as follows:
```
etch(
    height: 1,
    pattern: : ((left, middle, right)) => ((left, right),),
    start-layer: none
    )
```

Many of the key concepts are the same as the `deposit` function. Notably, the default height and pattern are the same, and the `start-layer` parameter takes in similar inputs. 
However, etching happens from the top, so the etch function begins at `start-layer` and etches `height` layers going down.

#### `set-active-layer` function

The `set-active-layer` function is declared as follows:
```
set-active-layer(
    new-layer: current-layer => current-layer
    )
```

Generally the use of this function is ill-advised, because it counts as a step, but that may feel unintuitive. It also generally breaks the intuition that new layers will by default go on top of the topmost layer. However, in some situations it can be useful in making sure that intuition applies to following steps.

The `new-layer` parameter functions the same as `start-layer` in `deposit` and `etch`.


### Generating a legend

To generate a legend for the materials, simply pass your materials dictionary to the `generate-legend` function like so
```
generate-legend(my-materials-dictionary)
```

### Formatting outputs 

This step is done using the `step-diagram` function and the `format-legend` function.

The `step-diagram` function is declared as follows.
```
step-diagram(
    device-steps: (),
    step-desc: (),
    legend: [],
    columns: 1,
    column-gutter: 5%,
    row-gutter: 5%
    )
```

By default, `device-steps` is blank. To generate a step diagram, make sure that you put the output of the `device-steps`' function in a variable, and pass that variable to the `device-steps` parameter of `step-diagram`. 

By default, `step-desc` is blank. This means that there will be no subtitles explaining your teps. To fix this, pass an array of steps into `step-desc`, like so
```
...
step-desc: ("1. Do the first step", "2. Do the second step",)
...
```

By default, `legend` is blank. To add a legend, pass in the output of a `format-legend` function, which will be explained in he next section.

By default, `columns` is 1. `columns` represents the number of columns in the grid of steps that is outputted, so by default it outputs a long list. This is often undesirable, so you can use this parameter to increase the number of columns in the grid, and it will accordingly resize your diagrams to make them fit.

`column-gutter` and `row-gutter` define the spacing between grid elements. Usually it's okay to leave these as their defaults.

The 'format-legend` command is defined as follows.
```
format-legend(
    columns: 1,
    column-gutter: 10%,
    row-gutter: 2.5%,
    materials: (:),
    format-text: (it) => text(it)
    )
```

The `columns` parameter is 1 by default, but this can be increased to increase the number of columns used in generating the materials legend. 

Similar to `step-diagram`, `column-gutter` and `row-gutter` can generally be left as their defaults,

By default, `materials` is empty, but this is nonsensical. Pass to the `materials` parameter the same dictionary that you passed to `device-steps`

`format-text`'s default value does not format the text. This parameter takes a function of one argument (the text in your legend), and allows you to apply formatting to it (for example, you can set it to `(it) => ce(it)` to format your chemical formulas with the typsium package. Usually it's okay to not mess with this.

### Formatting Quickstart

Assuming you have a materials dictionary `materials`, a device-steps object `device-steps`, and an arraay of step description strings `step-desc`, you can use the following code to generate a generic step-diagram.

```
#step-diagram(
    columns: 2,
    device-steps: device-steps,
    step-desc: step-desc,
    legend: format-legend(columns: 2, materials: materials,),
```

