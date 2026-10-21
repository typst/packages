Browser-optimized paged export for Typst
with videos, speaker notes, and custom elements.

## Usage

```typst
#import "@preview/yap:0.1.0": video, notes

#video("example.mp4")
#notes[Speaker notes]
```

If you're using the [Typst web app](https://typst.app),
export as SVG, you'll get a zip.
If you're using the local compiler,
run `typst watch main.typ main{p}.svg`.

Go to the [yap webapp](https://yap.snlx.net)
and select the exported zip or the project folder
(folders are auto-reloaded when the content changes).
You can also find more usage examples and the full API spec there.

When you're done, press `enter` in the viewer to save the document to disk.

## Extending

There are 2 files to play with:
- `theme.css` if you want to change how the viewer looks
- `extend.js` if you need custom behavior

You can create `box`es or `block`s with `<labels>` from within typst
and then get them as though they are HTML divs using the `getTypstLabel("label")`
function in `extend.js`.
