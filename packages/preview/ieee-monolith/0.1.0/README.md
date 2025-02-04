# IEEE Setup With Single Column

I like IEEE style of references/bibliography.

And I wanted it to be single column instead of two.

Credit: Typst GmbH (I used their template as the base for mine)

## The goal of this template:
- You can just copy-and-paste `main.typ` from your previously-written `ieee-charged` (by Typst Team) document. And it works!
    - Additional features are all optional. e.g. global font setting
- Adjust spacings according to the single column setup.


## Usage
This template is suppose be compatible with `charged-ieee` template by Typst Team. 

Just replace: 
```
#import "@preview/charged-ieee:0.1.3": ieee

```
with: 
```
#import "@preview/ieee-monolith:0.1.0": ieee
```