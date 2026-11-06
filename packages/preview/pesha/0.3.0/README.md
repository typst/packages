# Pesha

> Pesha (Urdu: پیشہ) is the Urdu term for occupation/profession. It is pronounced as pay-sha.

A clean and minimal template for your CV or résumé.

This template is inspired by Matthew Butterick's excellent
[_Practical Typography_](https://practicaltypography.com) book.

See the [example.pdf](https://github.com/talal/pesha/blob/main/example.pdf) file to see
how it looks.

## Usage

You can use this template in the Typst web app by clicking "Start from template" on the
dashboard and searching for `pesha`.

Alternatively, you can use the CLI to kick this project off using the command

```sh
typst init @preview/pesha
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

This template exports the `pesha` function with the following named arguments:

| Argument | Type | Description |
| --- | --- | --- |
| `name` | [string] | A string to specify the author's name.  |
| `address` | [string] | A string to specify the author's address. |
| `contacts` | [array] | An array of content to specify your contact information. E.g., phone number, email, LinkedIn, etc. |
| `profile-picture` | [content] | The result of a call to the [image function] or `none`. For best result, make sure that your image has an 1:1 aspect ratio. |
| `paper-size` | [string] | Specify a [paper size string] to change the page size (default is `a4`). |
| `footer-text` | [content] | Content that will be prepended to the page numbering in the footer. |

The function also accepts a single, positional argument for the body.

The template will initialize your package with a sample call to the `pesha` function in a
show rule. If you, however, want to change an existing project to use this template, you
can add a show rule like this at the top of your file:

```typ
#import "@preview/pesha:0.3.0": *

#show: pesha.with(
  name: "Max Mustermann",
  address: "5419 Hollywood Blvd Ste c731, Los Angeles, CA 90027",
  contacts: (
    [(323) 555 1435],
    [#link("mailto:max@mustermann.com")],
  ),
  paper-size: "us-letter",
  footer-text: [Mustermann Résumé ---]
)

// Your content goes below.
```

[array]: https://typst.app/docs/reference/foundations/array/
[content]: https://typst.app/docs/reference/foundations/content/
[string]: https://typst.app/docs/reference/foundations/str/
[paper size string]: https://typst.app/docs/reference/layout/page#parameters-paper
[image function]: https://typst.app/docs/reference/visualize/image/
