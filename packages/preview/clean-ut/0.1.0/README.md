# Typst thesis templates for bachelor and master thesis

This template is designed to write final theses in the field of life sciences with a clean look, offering 1) the automatic generation of a two-column bibliography 2) automatic subfigure-numbering and 3) allows for the display of short captions for figures in the outline. The biggest downside of this template yet is its pre-defined customization of text, tables, figures... which make this template less flexible. But you are of course free to make changes anytime :)
The first two pages are generated for the University Tübingen, feel free to change them, too.

## Disclaimer

- This thesis is not official and does not represent the University of Tübingen in any way
- This is a template and does not have to meet the exact requirements of your university. Check what your thesis should look like!
- The thesis is currently only supported in English

## Custom functions

The caption-function is a slight modification of the original caption of figures:

```typ
#figure(.., caption: [#caption[short description][more details]])
```
This will display the short description in the outline of figures and will show the original figure caption as: 

**Figure X: short description.** more details

Furthermore, the TODO-function is a small QoL-improvement, allowing for highlighting text for later editing:

```typ
#todo[text]
```

Finally, the custom subfigure-function automatically numbers the subfigures with A,B,C... above the top-left corner of the figure:

```typ
#subfig-grid(columns: 2,
figure(.., caption: []),
figure(.., caption: []),
..,
caption: [caption describing the whole figure, including subfigures])
```

Note that this does **not** allow for captioning of the subfigures directly (this will look bad), but instead requires a description  of subfigures in the total figure caption