# [Wavy](https://github.com/Enter-tainer/wavy)

Draw digital timing diagram in Typst using [Wavedrom](https://wavedrom.com/).

![](wavy.svg)


````typ
#import "@preview/wavy:0.1.3"

#set page(height: auto, width: auto, fill: black, margin: 2em)
#set text(fill: white)

#show raw.where(lang: "wavy"): it => wavy.render(it.text)

= Wavy

Typst, now with waves.

```wavy
{
  signal:
  [
    {name:'clk',wave:'p......'},
    {name:'bus',wave:'x.34.5x',data:'head body tail'},
    {name:'wire',wave:'0.1..0.'}
  ]
}
```

```js
{
  signal:
  [
    {name:'clk',wave:'p......'},
    {name:'bus',wave:'x.34.5x',data:'head body tail'},
    {name:'wire',wave:'0.1..0.'}
  ]
}
```

````


## Documentation

### `render`

Render a wavedrom json5 string to an image

#### Arguments

* `src`: `str` - wavedrom json5 string
* All other arguments are passed to `image` so you can customize the image size

#### Returns

The image, of type `content`
