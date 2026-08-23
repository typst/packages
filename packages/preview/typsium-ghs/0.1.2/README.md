[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FTypsium%2Ftypsium-ghs%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://github.com/Typsium/typsium-ghs)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Typsium/typsium/blob/0.1.2/LICENSE)
![User Manual](https://img.shields.io/badge/manual-.pdf-purple)

# Typst GHS and HP Statements

Quickly display and format hazard and precautionary statements.

## Usage
Easily Display Hazard and Precautionary statements in four languages (english, french italian and german): 
```typst
#import "@preview/typsium-ghs:0.1.2":*

#h-statement(310)\
#p-statement(310)\
#hp("P305+P351+P338", only-statement:true)
```
<p align="center">
<img alt="at the top a hazard statement, in the middle a protectionary statement, at the bottom a combined statement with the number hidden and only the text shown." src="https://raw.githubusercontent.com/Typsium/typsium-ghs/0.1.2/tests/simple-hp/ref/1.png" />
</p>

Use the display statements method to quickly display a bunch of statements you copied from wikipedia or other sources. It will automatically separate and detect statements.
```typst
#display-statements("H315,H319 - P273 - P302 + P352 - P305 + P351 + P338")
```

<img alt="A list of properly formatted statements separated by newline characters and combined statements automatically detected." src="https://raw.githubusercontent.com/Typsium/typsium-ghs/0.1.2/tests/display-statements/ref/1.png" />
</p>

There are variants for some statements:
```typst
#p-statement(310, only-statement: true)\
#p-statement(310, variant:1)\
#p-statement(310, variant:2)
```
<p align="center">
<img alt="at the top a statement with the number hidden and only the text shown, this displays as 'call a poison center/doctor/...'. In the middle a statement with the first variant selected, this displays as 'call a poison center'. At the bottom a statement with the second variant selected, this displays as 'call a doctor'." src="https://raw.githubusercontent.com/Typsium/typsium-ghs/0.1.2/tests/variants/ref/1.png" />
</p>

You can also add parameters when needed:
```typst
#h-statement(370)\
#h-statement(370, parameters:"the lungs")\
#h-statement(370, parameters:("the lungs", "when inhaled"))\
#h-statement(370, variant:1)\
#h-statement(370, variant:1, parameters:"when inhaled")\
```
<p align="center">
<img alt="statements with default parameters, custom text inserted as a parameter and variants with parameters." src="https://raw.githubusercontent.com/Typsium/typsium-ghs/0.1.2/tests/parameters/ref/1.png" />
</p>

Use the `#ghs(<number>)` command to display a GHS pictogram, to get more information about each pictogram use `#ghs-info`
```typst
#import "@preview/typsium-ghs:0.1.0": *
#grid(
  columns: 9,
  ..range(1,10).map(x=> ghs(x))
)
```
<p align="center">
<img alt="all of the ghs pictograms displayed next to each other." src="https://raw.githubusercontent.com/Typsium/typsium-ghs/0.1.2/tests/ghs-pictograms/ref/1.png" />
</p>
