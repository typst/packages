# Boxr
Boxr is a modular, and easy to use, package for creating cardboard cutouts in Typst.

## Usage
Create a boxr structure in your project by with the following code:
```
#import "@preview/boxr:0.1.0"

#render_structure(
  "box",
  width: 100pt,
  height: 100pt,
  depth: 100pt,
  tab_size: 20pt,
  [
    Hello from boxr!
  ]
)
```
The `render_structure` function is the main function for boxr. It either takes a path to one of the default structures provided by boxr (e.g.: `"box"`) or an unpacked json file with your own custom structure (e.g.: `json(my_structure.json)`). These describe the structure of the cutout.\
The other named arguments depend on the structure you are rendering. All unnamed arguments are passed to the structure as content and will be rendered on each box face (not triangles or tabs).

## Creating your own structures
Structures are defined in `.json` files. An example structure that just shows a box with a tab on one face is shown below:
```
{
  "variables": ["height", "width", "tab_size"],
  "width": ["width"],
  "height": ["height", "tab_size"],
  "offset_x": [],
  "offset_y": ["tab_size"],
  "root": {
    "type": "box",
    "id": 0,
    "width": "width",
    "height": "height",
    "children": {
      "top": "tab|tab_size"
    }
  }
}
```
The `variables` key is a list of variable names that can be passed to the structure. These will be required to be passed to the `render_structure` function.\
The `width` and `height` keys are lists of *variables* that are used to calculate the width and height of the structure.\
The `offset_x` and `offset_y` keys are lists of *variables* that are used to place the structure in the middle of its bounds. It is relative to the root node. In this case for example, the top tab adds a `tab_size` on top of the box as opposed to the bottom, where there is no tab. So one `tab_size` is added to the `offset_y`.\
`root` denotes the first node in the structure.\
A node can be of the following types:
- `box`:
  - The root node has a `width` and `height` key that can be a *variable*. All following nodes have a `size` key that can be a *variable*. Child nodes use `size` and the parent node's `width` and `height` to calculate their own width and height.
  - Can have `children` nodes.
  - Can have an `id` key that is used to place content on the face of the box. The id-th unnamed argument is placed on the face. Multiple faces can have the same id.
  - Can have a `no-fold` key. If this exists, no fold stroke will be drawn between this box and its parent.
- `triangle_<left|right>`:
  - Has a `width` and `height` key that can be a *variable*.
  - `left` and `right` denote the direction the other right angled line is facing relative to the base.
  - Can have `children` nodes
  - Can have a `no-fold` key. If this exists, no fold stroke will be drawn between this triangle and its parent.
- `tab`:
  - Is not a json object, but a string that denotes a tab. The tab is placed on the parent node.
  - Has a tab_size after the first `|` and a cutin_size after the second `|`. These can be *variables*.

## Variables
Variables are strings that are used to calculate various sizes in a structure. They can have the following forms:
- `variable name`: This is a variable that was listed in the `variables` key of the structure. It will have the value passed to the `render_structure` function.
- `number`: This is a fixed number that will be interpreted as a pt value.
- `combination of two of these`: These are usually denoted like `<var1>:Operator:<var2>`. The operator can be `Add`, `Sub`, `Mul`, `Div` or `Hyp` at the moment. `Hyp` is used to calculate the hypotenuse of a right angled triangle. The other operators are self explanatory.

