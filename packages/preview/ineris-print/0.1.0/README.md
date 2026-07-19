# Ineris
This is a Typst template to help formatting documents according to the design guidelines of the French institute for industrial environment and risks.

## Usage
You can use the CLI to kick this project off using the command
```
typst init @preview/ineris
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports several functions, each one corresponding to a kind of document :
- `internal-note`: short document (several pages) for internal use ;
- `external-note`: short document made to be sent to external clients or partners ;
- `internal-report`: longer document (several dozens of pages, organized by chapters) for internal use ;
- `external-report`: longer document made to be send to external clients or partners.

To use a template, start your document with the following lines:

```typ
#import "@preview/ineris:0.1.0": *
#show: external-report.with(
	title: [Title of your document], 
	subtitle: [Subtitle of your document],
	author: [Author of your document],
)

// Your content goes here
```

The followings fields are available to configure your document metadata:

- `title`: The document's title as a string or content.
- `subtitle`: The document's subtitle as a string or content.
- `author`: The document's author(s) as a string or an array.
- `date`: The document's date as a datetime, or `datetime.today()` for the current time.
- `version`: The document's version as a string.
- `description`: A short summary of the document.
- `keywords`: A list of keywords as a string or an array.
- `diffusion`: Tells if the diffusion is restricted.
- `cgr`: Number of the affair.
- `sender`: Department who produced the document.
- `recipient`: Who the document is addressed to.
- `readers`: Who read and validated your document.
- `participants`: Who participated to the writing of the document.
- `cc`: Who shall get a copy of the document.
- `attachments`: Other documents attached (as a string).
- `simplified`: `True` if a simplified version of the template must be used, `false` otherwise.
- `title-image`: An image object to use on the front page. The image should be included with a width of 100% and a height of 9.3cm.

The previous functions also accept a single, positional argument for the body of the paper.

Not every metadata fields is available for each template. The following table show the valid combinations:

| Template     | internal-note | external-note | internal-report | external-report |
|--------------|:-------------:|:-------------:|:---------------:|:---------------:|
| title        |       x       |       x       |        x        |        x        |
| subtitle     |       x       |       x       |        x        |        x        |
| author       |       x       |       x       |        x        |        x        |
| date         |       x       |       x       |        x        |        x        |
| version      |       x       |       x       |        x        |        x        |
| description  |       x       |       x       |        x        |        x        |
| keywords     |       x       |       x       |        x        |        x        |
| diffusion    |       x       |               |        x        |                 |
| cgr          |       x       |       x       |        x        |        x        |
| sender       |       x       |       x       |        x        |        x        |
| recipient    |       x       |       x       |        x        |        x        |
| readers      |               |               |                 |        x        |
| participants |               |               |                 |        x        |
| approver     |               |               |        x        |        x        |
| cc           |       x       |       x       |        x        |                 |
| attachments  |       x       |       x       |        x        |                 |
| simplified   |               |       x       |                 |                 |
| title-image  |               |               |        x        |        x        |


## Special commands
- `#tablex(..args)`: same syntax ax Typst `table` command, with two additional parameters named `sum-row` and `sum-column`. When they are included, a last row or column will be added at the end of the table with its cells automatically calculated based on the values on the same column or row. `sum-row` and `sum-column` both are dictionaries with the following fields:
	- `cell`: cell format
	- `text`: title of the row or column
	- `accumulator`: accumulator function, with two parameters: `init` and `update(content, value)` which returns the new value of the accumulator based on the current value and the content of a cell ; by default, it is a sum accumulator
- `#myblock(mytitle, ..args)`: it accepts the same arguments as the Typst `block` command. This function generates a focus block with a frame and a coloured background.
