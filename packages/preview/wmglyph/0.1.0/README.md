# wmglyph

Typst plugin to read Windows Metafile

# Usage

```typst
#import "@preview/wmglyph:0.1.0": *

#image(wmf(read("wmf_file.wmf", encoding: none)))
#wmf-image(read("wmf_file.wmf", encoding: none))
```
