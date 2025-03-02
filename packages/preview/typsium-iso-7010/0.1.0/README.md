[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FTypsium%2Ftypsium-iso-7010%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://github.com/Typsium/typsium-iso-7010)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Typsium/typsium/blob/main/LICENSE)
![User Manual](https://img.shields.io/badge/manual-.pdf-purple)

# ISO 7010 Hazard and Safety Pictograms in Typst

A Typst package for displaying commonly used warning signs in typst.

## Usage
```typst
#import "@preview/typsium-iso-7010:0.1.0": *

#grid(
  columns: 2,
  emergency-sign(2, height: 10em),
  emergency-arrow(direction:"right", height: 10em),
)
```

![result](https://raw.githubusercontent.com/Typsium/typsium-iso-7010/main/tests/emergency-exit/ref/1.png)


```typst
    #grid(
    columns: 2,
    fire-arrow(direction:"up", height: 10em),
    fire-sign(2, height: 10em),
    )
```
![result](https://raw.githubusercontent.com/Typsium/typsium-iso-7010/main/tests/fire-extinguisher/ref/1.png)

For a full list of pictograms, please visit the [Wikipedia page](https://en.wikipedia.org/wiki/ISO_7010).
![result](https://raw.githubusercontent.com/Typsium/typsium-iso-7010/main/tests/mandatory-prohibited/ref/1.png)
![result](https://raw.githubusercontent.com/Typsium/typsium-iso-7010/main/tests/warning/ref/1.png)
