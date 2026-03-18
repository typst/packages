# appreciated-letter
A basic letter with sender and recipient address. The letter is ready for a DIN DL windowed envelope.

## Usage

You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `appreciated-letter`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/appreciated-letter
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

This template exports the `letter` function with the following named arguments:

- `sender`: The letter's sender as content. This is displayed at the top of the page.
- `recipient`: The address of the letter's recipient as content. This is displayed near the top of the page.
- `date`: The date, and possibly place, the letter was written at as content. Flushed to the right after the address.
- `subject`: The subject line for the letter as content.
- `name`: The name the letter closes with as content.

The function also accepts a single, positional argument for the body of the
letter.

The template will initialize your package with a sample call to the `letter`
function in a show rule. If you, however, want to change an existing project to
use this template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/appreciated-letter:0.1.0": letter

#show: letter.with(
  sender: [
    Jane Smith, Universal Exports, 1 Heavy Plaza, Morristown, NJ 07964
  ],
  recipient: [
    Mr. John Doe \
    Acme Corp. \
    123 Glennwood Ave \
    Quarto Creek, VA 22438
  ],
  date: [Morristown, June 9th, 2023],
  subject: [Revision of our Producrement Contract],
  name: [Jane Smith \ Regional Director],
)

Dear Joe,

#lorem(99)

Best,
```
