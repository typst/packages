[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FTypsium%2Ftypsium-ghs%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://github.com/Typsium/typsium-ghs)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Typsium/typsium/blob/main/LICENSE)
![User Manual](https://img.shields.io/badge/manual-.pdf-purple)

# Typst GHS and HP Statements

A Typst package for quickly displaying and formatting Hazard and Precautionary statements.

## Usage
Use the `#ghs` command to display a GHS pictogram, to get more information about each pictogram use `#ghs-info`
```typst
#grid(
  columns: 9,
  ..range(1,10).map(x=> ghs(x))
)
```
![result](https://raw.githubusercontent.com/Typsium/typsium-ghs/main/tests/ghs-pictograms/ref/1.png)

Easily Display Hazard and Precautionary statements in three languages (english, french and german): 
```typst
#h-statement(310)\
#p-statement(310)\
#hp("P305+P351+P338", only-statement:true)
```
![result](https://raw.githubusercontent.com/Typsium/typsium-ghs/main/tests/simple-hp/ref/1.png)

There are variants for some statements:
```typst
#p-statement(310, only-statement: true)\
#p-statement(310, variant:1)\
#p-statement(310, variant:2)
```
![result](https://raw.githubusercontent.com/Typsium/typsium-ghs/main/tests/variants/ref/1.png)

You can also add parameters when needed:
```typst
#h-statement(370)\
#h-statement(370, parameters:"the lungs")\
#h-statement(370, parameters:("the lungs", "when inhaled"))\
#h-statement(370, variant:1)\
#h-statement(370, variant:1, parameters:"when inhaled")\
```
![result](https://raw.githubusercontent.com/Typsium/typsium-ghs/main/tests/parameters/ref/1.png)
