# manuscr-ismin

This template is the one I use when writing my reports at Mines Saint-Étienne.
It uses the Typst language and is inspired by [Timothé Dupuch's](https://github.com/thimotedupuch/Template_Rapport_ISMIN_Typst),
the [Bubble template](https://github.com/hzkonor/bubble-template),
the [ilm template](https://github.com/talal/ilm),
the [Diatypst template ](https://github.com/skriptum/Diatypst),
and a lot of code bits were given by the very nice Typst community on Discord and the Forum, so I deeply thank all of them.
Most of the typography rules used by this template are from [_Butterick's Practical Typography_](https://practicaltypography.com/).
I also recommend reading (for my fellow Frenches) the book _Règles françaises de typographie mathématique_ by Alexandre André [here](http://sgalex.free.fr/typo-maths_fr.pdf).

In the default `main.typ`, I tried to showcase everything that this report could do and most of Typst's capabilities.
Feel free to check the very extensive documentation for more information.

## Usage

I advise using the Typst Web App, but it is possible to install the CLI compiler locally on your machine.
As for files:
- the file `main.typ` is where you are going to write,
- the file `bibs.yaml` is supposed to contain the bibliographical references in the Hayagriva format (leave empty if not used),
- the file `conf.yaml` is where you are going to set the fonts used by the document and the main color,
- the folder `assets` contains the graphical ressources used by the template,
- the folder `images` contains... the images for your document (comes with a nice picture of two famous cats) - please segment your files into folders when working.

### `conf.yaml`

#### Fonts

Make sure to correctly input your fonts in the YAML file.
By default, it is set with the New Computer Modern font family, but if you want to go for Typst's default look:

```yml
fonts:
	body-font: "Libertinus Serif"
	code-font: "Cascadia Mono"
	math-font: "New Computer Modern Math"
	mono-font: "Libertinus Mono"
	sans-font: "Libertinus Sans"
```

#### Colour

The colour is defined by a string and is in the hexadecimal format. 
By default, the colour is _violet EMSE_, but if you want to change it to - for instance - the colour of a tomato:

```yml
main-color: "#FF6347"
```

### Function `manuscr-imsin`

Following, a description of this template's parameters: 

- `title` : the title of the document (mandatory), in bold,
- `uptitle` : an "uptitle" above the document in small capitals and old-style figures (for instance, the course's name),
- `subtitle` : the subtitle below the title,
- `authors` : field containing the authors in a dictionnary, if you only use one author, remember to add a comma at the end ;
- `name` : the author's name,
- `affiliation` : the author's affiliation,
- `year` : the author's year,
- `class` : the author's class,
- `email` : the author's email address ;
- `date` : the date,
- `logo` : path the logo you want to use - by the default, it is Mines Saint-Étienne's,
- `header-title` : the text in the left in the header,
- `header-middle` : the text in the centre of the header (in bold),
- `header-subtitle` : the text at the right in the header (in italic),
- `number-style` : the style of numbers; can be either `"old-style"` or `"lining"`.

Here is an example of how to call the function:

```
#show: manuscr-ismin.with(
	uptitle: [Processor Architecture 2],
	title: [Project Report],
	subtitle: [An implementation of Ascon-128],
	authors: (
		(
			name: "Naps la Napsance",
			affiliation: "ISMIN",
			year: "2A",
			class: "G3",
			email: "naps@emse.fr"
		),
	),
	header-title: "N a p s",
	header-subtitle: "Project Report",
	header-middle: [Proc. Arch. 2],
	date: "09/12/2023"
	)
```

### Other functions

- `violet-emse` : Mines Saint-Étienne's purple,
- `gray-emse` : Mines Saint-Étienne's gray,
- `lining` : to locally get lining numbers,
- `arcosh` : the hyperbolic arc cosine function for math mode (I needed it at some point),
- `mono` : function that formats text with the `mono-font`, useful for when you want to have monospaced text that is not code, like paths or binary numbers,
- `sans` : formats text with the `sans-font`,
- `body-font` : font used for the text,
- `code-font` : font used for the `raw` function,
- `math-font` : font used for math mode,
- `mono-font` : font used by the `mono` function,
- `sans-font` : font used by the `sans` function,
- `primary-color` : the document's default colour,
- `block color`, `body-color`, `header-color`, `fill-color` : lightened colours derived from `primary-color`.
