[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FTypsium%2Ftypsium-iso-7010%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://github.com/Typsium/typsium-iso-7010)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Typsium/typsium-iso-7010/blob/0.1.1/LICENSE)

# ISO 7010 Warning, Fire, Emergency and Safety Pictograms in Typst

A package for displaying commonly used warning signs in typst.

## Usage
```typst
#import "@preview/typsium-iso-7010:0.1.1": *

#grid(
  columns: 2,
  emergency-sign(2, height: 10em, inset:0%),
  emergency-arrow(direction:0, height: 10em, inset:0%),
)
```
<img alt="Combined pictogram of emergency exit and arrow pointing to the right." src="https://raw.githubusercontent.com/Typsium/typsium-iso-7010/0.1.1/tests/emergency-exit/ref/1.png" />


You can use <fire/warning/emergency>-sign methods or the more general iso-7010 method:
```typst
    #grid(
    columns: 2,
    fire-arrow(direction:"up", height: 10em, inset:0%),
    iso-7010("F001", height: 10em, inset:0%),
    )
```
<img alt="Combined pictogram of arrow pointing up and a fire extinguisher." src="https://raw.githubusercontent.com/Typsium/typsium-iso-7010/0.1.1/tests/fire-extinguisher/ref/1.png" />

Get the localised names of each sign using the get-name method:
```typst
context{
  #get-name("E002")
}
```
For a full list of pictograms, please visit the [Wikipedia page](https://en.wikipedia.org/wiki/ISO_7010).

```typst
#grid(
  columns: 10,
  mandatory-actions-sign(1, height: 2em),
  mandatory-actions-sign(3, height: 2em),
  mandatory-actions-sign(8, height: 2em),
  mandatory-actions-sign(14, height: 2em),
  mandatory-actions-sign(61, height: 2em),
  prohibited-actions-sign(3, height: 2em),
  prohibited-actions-sign(10, height: 2em),
  prohibited-actions-sign(45, height: 2em),
  prohibited-actions-sign(49, height: 2em),
  prohibited-actions-sign(75, height: 2em),
)
```
<img alt="Various example pictograms" src="https://raw.githubusercontent.com/Typsium/typsium-iso-7010/0.1.1/tests/mandatory-prohibited/ref/1.png" />

```typst
#grid(
  columns: 4,
  iso-7010("W002", height: 2em),
  iso-7010("W003", height: 2em),
  iso-7010("w16", height: 2em),
  iso-7010("w071", height: 2em), 
)
```
<img alt="More example pictograms." src="https://raw.githubusercontent.com/Typsium/typsium-iso-7010/0.1.1/tests/warning/ref/1.png" />
