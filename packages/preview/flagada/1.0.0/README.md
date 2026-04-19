# Flagada

A typst package to display **country flags** in your Typst documents. This first version is extremely simple, as the only two arguments is the country and the height of the flag to display in the document.

## Loading the package

```typst
#import "@preview/flagada:1.0.0" : *
```

## Calling a flag

You need to know the ISO 3166-1 code of the country (string of 2 characters) to display.

Either call the flag as with the long call version `flag-zz()` or short call `flag("ZZ")`,  `zz` or `"ZZ"` being the ISO 3166-1 code.

Please note that long call version, like `flag-zz()`, must use _lowercase_ of the ISO 3166-1 code. Short version can use both _lowercase_ or _uppercase_ of the ISO 3166-1

### Example

```typst
Hello people coming from #flag-fr(), #flag-eu(), #flag("DE") and more
```

![Hello people coming from France, Europe, Germany and more](doc/example_1.png)

## Modifying the height

By default the flag height is `0.65em`, which is usually the default text size.

To modify the height, include the `height` parameter in your call.

Either call the flag as `flag-zz(height:6em)` or `flag("ZZ",height:6em)`, `zz` or `"ZZ"` being the ISO 3166-1 code.

### Example for height

```typst
Hello people coming from #flag-be(height: 1em), #flag-fr(height: 2em), #flag-eu(height:3em), #flag("DE",height: 2em), #flag("LU",height: 1em) and more
```

![Hello people coming from Belgium, France, Europe, Germany, Luxembourg and more](doc/example_2.png)

## Comments

### Coat of arms

Some flags include coat of arms or other specific components. As ususally these components are hard to build in Typst, a SVG version from Wikimedia is used. The coat of arms for countries are in directory `coat of arms/`

#### Example of coat of arms

![Hello people coming from Europe, Spain, Portugal and more](doc/example_3.png)

In this example, coats of arms are used for Spanish and Portuguese flags (but not for European flag as stars can be constructed or displayed from an unicode like `U+2605`)

### Width not updatable

For the moment, the official format defined by each country has been used to build their flag (e.g. 1:2 fro GB, 2:3 for FR, 10:19 for US ...). No possibility to modify the width has been considered. As a consequence, when you display two or more flags close to each other at the same height, their width might not be equal for each flag.

### Flags covered

Flags for most of the ISO 3166-1 codes are available in the current version (1.0.0):

AD AE AF AG AI AL AM AO AQ AR AS AT AU AW AX AZ BA BB BD BE BF BG BH BI BJ BL BM BN BO BQ BR BS BT BV BW BY BZ CA CC CD CF CG CH CI CK CL CM CN CO CR CU CV CW CX CY CZ DE DJ DK DM DO DZ EC EE EG EH ER ES ET EU FI FJ FK FM FO FR GA GB GD GE GF GG GH GI GL GM GN GP GQ GR GS GT GU GW GY HK HM HN HR HT HU ID IE IL IM IN IO IQ IR IS IT JE JM JO JP KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD ME MF MG MH MK ML MM MN MO MP MQ MR MS MT MU MV MW MX MY MZ NA NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PS PT PW PY QA RE RO RS RU RW SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR SS ST SV SX SY SZ TC TD TF TG TH TJ TK TL TM TN TO TR TT TV TW TZ UA UG UM US UY UZ VA VC VE VG VI VN VU WF WS YE YT
ZA ZM ZW

For these flags, comments are welcome

![A list of flags available in flagada](doc/example_4.png)

## History

### V0.1.0

The inital version of flags, not covering all countries, but mainly independant countries in Europe, America, Africa and Asia.

### V0.2.0

Adding some of missing country flags. In this version, only KI is a missing flag of an independant country. The missing flags not covering ISO 3166-1 codes are for specific places (islands, local place ...) related to another country.

### V1.0.0

All country flags for an ISO 3166-1 code are now available.

## Extra

Flagada has an internal function `polygram` to display easily regular stars (5, 7 or more sides)

```typst
polygram(schlafli,size,color,paint:none)
```

- `schlafi` must be an array of two integers (to be a [Schläfi symbol](https://en.wikipedia.org/wiki/Schl%C3%A4fli_symbol))
- `size` is the size of the polygram
- `color` is the filling color of the generated polygram
- `paint` is the stroke color of the generated polygram. By default, it is not used (`none`)

Please note that there are no variables controls for this fonction.
