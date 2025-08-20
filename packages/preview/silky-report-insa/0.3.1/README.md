# INSA - Typst Template
Typst Template for full documents and reports for the french engineering school INSA.

## Table of contents
1. [Examples & Usage](#examples)
    1. [🧪 TP report](#🧪-tp-report)
    1. [📚 Internship report](#📚-internship-report)
    1. [🗒️ Blank templates](#🗒️-blank-templates)
1. [Fonts information](#fonts)
1. [Notes](#notes)
1. [License](#license)
1. [Changelog](#changelog)

## Examples & Usage

### 🧪 TP report
<p align="center">
    <img alt="thumbnail" src="thumbnail-insa-report.png" style="width: 65%"/>
</p>

This is the default report for the `silky-report-insa` package. It uses the `insa-report` show rule.  
It is primarily used for reports of Practical Works (Travaux Pratiques).

#### Example
```typst
#import "@preview/silky-report-insa:0.3.1": *
#show: doc => insa-report(
  id: 3,
  pre-title: "STPI 2",
  title: "Interférences et diffraction",
  authors: [
    *LE JEUNE Youenn*

    *MAUVY Eva*
    
    Groupe D

    Binôme 5
  ],
  date: "11/04/2023",
  insa: "rennes",
  doc)

= Introduction
Le but de ce TP est d’interpréter les figures de diffraction observées avec différents objets diffractants
et d’en déduire les dimensions de ces objets.

= Partie théorique - Phénomène d'interférence
== Diffraction par une fente double
Lors du passage de la lumière par une fente double de largeur $a$ et de distance $b$ entre les centres
des fentes...
```

#### Parameters
| Parameter | Description                   	| Type         	| Example |
|-----------	|-------------------------------	|--------------	|--------------------------------	|
| **id** | TP number                     	| int          	| `1` |
| **pre-title** | Text written before the title 	| str          	| `"STPI 2"` |
| **title** | Title of the TP               	| str          	| `"Interférences et diffraction"` |
| **authors** | Authors                       	| content      	| `[\*LE JEUNE Youenn\*]` |
| **date** | Date of the TP                	| datetime/str 	| `"11/04/2023"` |
| **insa** | INSA name (`rennes`, `hdf`...)                       	| str      	| `"rennes"` |
| **lang** | Language                      	| str          	| `"fr"` |


### 📚 Internship report
<p align="center">
    <img alt="thumbnail" src="thumbnail-insa-stage.png" style="width: 90%"/>
</p>

If you want to make an internship report, you will need to use another show rule: `insa-stage`.

#### Example
```typst
#import "@preview/silky-report-insa:0.3.1": *
#show: doc => insa-stage(
  "Youenn LE JEUNE",
  "INFO",
  "2023-2024",
  "Real-time virtual interaction with deformable structure",
  "Sapienza University of Rome",
  image("logo-example.png"),
  "Marilena VENDITELLI",
  "Bertrand COUASNON",
  [
    Résumé du stage en français.
  ],
  [
    Summary of the internship in english.
  ],
  insa: "rennes",
  lang: "fr",
  doc
)

= Introduction
Présentation de l'entreprise, tout ça tout ça.

#pagebreak()
= Travail réalisé
== Première partie
Blabla

== Seconde partie
Bleble

#pagebreak()
= Conclusion
Conclusion random

#pagebreak()
= Annexes
```

This template can also be used for a report that is written in english: in this case, add the `lang: "en"` parameter to the function call in the show rule.

#### Parameters
| **Parameter** | Required 	| Type    	| Description                                            	| Example |
|-----------------	|----------	|---------	|--------------------------------------------------------	|-----------------------------------------------------------	|
| **name** | yes      	| str     	| Name of the student                                    	| `"Youenn LE JEUNE"` |
| **department** | yes      	| str     	| Department of the student                              	| `"INFO"` |
| **year** | yes      	| str     	| School year during the internship                      	| `"2023-2024"` |
| **title** | yes      	| str     	| Title of the internship                                	| `"Real-time virtual interaction with deformable structure"` |
| **company** | yes      	| str     	| Company                                                	| `Sapienza University of Rome` |
| **company-logo** | yes      	| content 	| Logo of the company                                    	| `image("logo-example.png")` |
| **company-tutor** | yes      	| str     	| Tutor in the company                                   	| `"Marilena VENDITELLI"` |
| **insa-tutor** | yes      	| str     	| Tutor at INSA                                          	| `"Bertrand COUASNON",` |
| **summary-french** | yes      	| content 	| Summary in French                                      	| `[   Résumé du stage en français. ]` |
| **summary-english** | yes      	| content 	| Summary in English                                     	| `[   Summary of the internship in english. ]` |
| **student-suffix** | no       	| str    	| Suffix at the end of "ingénieur" in french            	| `"e"` |
| **thanks-page** | no       	| content 	| Special thanks page.                                   	| `[   Thanks to my *supervisor*, blah blah blah. ]` |
| **omit-outline** | no       	| bool    	| Whether to skip the outline page or not                	| `false` |
| **insa** | no         | str       | INSA name (`rennes`, `hdf`...)                        	| `"rennes"` |
| **lang** | no       	| str     	| Language of the template. Some strings are translated. 	| `"fr"` |

### 🗒️ Blank templates
<p align="center">
    <img alt="thumbnail" src="thumbnail-insa-document.png" style="width: 90%"/>
</p>

If you do not want the preformatted output with "TP x", the title and date in the header, etc. you can simply use the `insa-document` show rule and customize all by yourself.

#### Blank template types
The graphic charter provides 3 different document types, that are translated in this Typst template under those names:
- **`light`**, which does not have many color and can be printed easily. Has 3 spots to write on the cover: `cover-top-left`, `cover-middle-left` and `cover-bottom-right`.
- **`colored`**, which is beautiful but consumes a lot of ink to print. Only has 1 spot to write on the cover: `cover-top-left`.
- **`pfe`**, which is primarily used for internship reports. Has 4 spots to write on both the front and back covers: `cover-top-left`, `cover-middle-left`, `cover-bottom-right` and `back-cover`.

The document type must be the first argument of the `insa-document` function.

#### Example
```typst
#import "@preview/silky-report-insa:0.3.1": *
#show: doc => insa-document(
  "light",
  cover-top-left: [*Document important*],
  cover-middle-left: [
    NOM Prénom

    Département INFO
  ],
  cover-bottom-right: "uwu",
  page-header: "En-tête au pif",
  doc
)
```

#### Parameters
| **Parameter** | Type     	| Description |
|--------------------	|----------	|----------------------------------------------------------------------------------------------------------------------------------------------------------	|
| **cover-type** | str      	| (**REQUIRED**) Type of cover. Available are: light, colored, pfe. |
| **cover-top-left** | content  	|  |
| **cover-middle-left** | content  	|  |
| **cover-bottom-right** | content  	|  |
| **back-cover** | content  	| What to display on the back cover. |
| **page-header** | content  	| Header of the pages (except the front and back). If `none`, will display the INSA logo. If not empty, will display the passed content with an underline. |
| **page-footer** | content  	| Footer of the pages (except the front and back). The page counter will be displayed at the right of the footer, except if the page number is 0. |
| **include-back-cover** | bool     	| whether to add the back cover or not. |
| **insa** | str        | INSA name (`rennes`, `hdf`...)                       	| `"rennes"` |
| **lang** | str      	| Language of the template. Some strings are translated. |
| **metadata-title** | content  	| Title of the document that will be embedded in the PDF metadata. |
| **metadata-authors** | str list 	| Authors that will be embedded in the PDF metadata. |
| **metadata-date** | datetime 	| Date that will be set as the document creation date. If not specified, will be set to now. |

## Fonts
The graphic charter recommends the fonts **League Spartan** for headings and **Source Serif** for regular text. To have the best look, you should install those fonts.

> You can download the fonts from [here](https://github.com/SkytAsul/INSA-Typst-Template/tree/main/fonts).

To behave correctly on computers lacking those specific fonts, this template will automatically fallback to similar ones:
- **League Spartan** -> **Arial** (approved by INSA's graphic charter, by default in Windows) -> **Liberation Sans** (by default in most Linux)
- **Source Serif** -> **Source Serif 4** (downloadable for free) -> **Georgia** (approved by the graphic charter) -> **Linux Libertine** (default Typst font)

### Note on variable fonts
If you want to install those fonts on your computer, Typst might not recognize them if you install their _Variable_ versions. You should install the static versions (**League Spartan Bold** and most versions of **Source Serif**).

Keep an eye on [the issue in Typst bug tracker](https://github.com/typst/typst/issues/185) to see when variable fonts will be used!

## Notes
This template is being developed by Youenn LE JEUNE from the INSA de Rennes in [this repository](https://github.com/SkytAsul/INSA-Typst-Template).

For now it includes assets from the INSA de Rennes and INSA Hauts de France graphic charters, but users from other INSAs can open a pull request on the repository with the correct assets for their INSA.

If you have any other feature request, open an issue on the repository.

## License
The typst template is licensed under the [MIT license](https://github.com/SkytAsul/INSA-Typst-Template/blob/main/LICENSE). This does *not* apply to the image assets. Those image files are property of Groupe INSA and INSA Rennes.

## Changelog
### 0.3.1
- Added `insa` option to all templates
- Added INSA HdF assets
- Added `student-suffix` option to `insa-stage`
- Made outline not shown in outline

### 0.3.0
- Added `omit-outline` option to `insa-stage`
- Added `thanks-page` parameter to `insa-stage`
- Added metadata-related options to `insa-document`
- Made some PDF metadata automatically exported for `insa-stage` and `insa-report`
- Made page number not displayed if equals to 0
- Adjusted positions of elements in back covers
- Fixed some translations
- Updated README to have changelog, visual examples of all documents and parameters table