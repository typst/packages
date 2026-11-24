# remetente

A clean and minimal formal letter template for Typst, featuring a colored header band where a custom logo can be placed.

## Usage

Start a new project from the template with the following command:

```shell
typst init @preview/remetente:0.2.0
```

The template will initialize your package with a sample call to the `letter` function in a `show` rule:

```typst
#import "@preview/remetente:0.2.0": letter

#show: letter.with(
  // Sender address displayed at the top right of the first page
  sender-address: [
    Sender's Name \
    #emph[
      1 Example Street \
      Sampleton, Sampleshire \
      WX1 2YZ
    ]
  ],
  // Recipient address displayed below the sender address
  recipient-address: [
    Recipient's Name \
    #emph[
      2 Somewhere Avenue \
      Somewhereton \
      AB8 9CD
    ]
  ],
  // Letter's date
  date: [4 October 1905],
  // Letter's subject displayed in bold
  subject: [Very important subject matter],
  // Letter's closing signature(s)
  signature: [Sender's Name],
  // Content displayed in the colored band at the top of the page
  header-band-content: text(fill: rgb("#2B58A2"), weight: "bold", size: 20pt)[Logo],
  // Only draw the header band on the first page
  first-page-header: true,
)

Dear Mr. Recipient,

// Write the body of your letter here
#lorem(99)

Sincerely,
```

## API documentation

| Argument                 | Type                                             | Default                       | Description                                                                        |
| ------------------------ | ------------------------------------------------ | ----------------------------- | ---------------------------------------------------------------------------------- |
| `paper`                  | `str`                                            | `"a4"`                        | Paper size                                                                         |
| `sender-address`         | `none` / `str` / `content`                       | `none`                        | Sender address shown at the top right of the page                                  |
| `recipient-address`      | `none` / `str` / `content`                       | `none`                        | Recipient address shown below the sender address                                   |
| `date`                   | `auto` / `datetime` / `str` / `content` / `none` | `auto`                        | Date shown under the address(es)                                                   |
| `subject`                | `none` / `content`                               | `none`                        | Subject line displayed in bold above the letter's content                          |
| `signature`              | `none` / `str` / `content` / `array`             | `none`                        | Closing signature(s). If an array is provided, the elements are laid out in a grid |
| `header-band-content`    | `none` / `content`                               | `none`                        | Content drawn in the colored header band                                           |
| `header-band-background` | `color`                                          | `oklch(95.6%, 0.005, 286deg)` | Fill color of the colored header band                                              |
| `header-band-height`     | `length`                                         | `11.25pt`                     | Height of the colored header band                                                  |
| `font`                   | `str` / `array`                                  | `Libertinus Serif`            | Font used throughout the letter                                                    |
| `font-size`              | `length`                                         | `11.25pt`                     | Base font size                                                                     |
| `leading`                | `length`                                         | `0.715em`                     | Line spacing                                                                       |
| `spacing`                | `length`                                         | `1.3em`                       | Paragraph spacing                                                                  |
| `link-font-color`        | `color`                                          | `oklch(62.3%, 0.064, 241deg)` | Color of links inside the letter                                                   |
| `first-page-header`      | `boolean`                                        | `false`                       | Only draw the header band on the first page                                        |
| `body`                   | `content`                                        | -                             | The letter's content                                                               |
