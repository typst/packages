# Humanities CV 

A minimal template for an academic CV in the humanities. 

## Usage

You can use this template in the Typst web app by clicking "Start from template" on the
dashboard and searching for `humanities-cv`.

Alternatively, you can use the CLI to kick this project off using the command

```sh
typst init @preview/humanities-cv
```

Typst will create a new directory with all the files needed to get you started.

If you already have a typst file, you add the following to the top:

```typst
#import "@preview/humanities-cv:0.1.0": humanities-cv, experience, paper

#show: humanities-cv.with(
  name: "Bob Typesetterson",
  address: "5419 Hollywood Blvd Ste c731, Los Angeles, CA 90027",
  updated: "October 2025",
  contacts: (
    [(323) 555 1435],
    [#link("mailto:hi@ohrg.org")],
  ),
  footer-text: [Typesetterson --- Page#sym.space]
)
```


Once you have specified that you want to show all typst content via the `humanities-cv` function via the code above, you can build out your CV using headers, the `experience` function, and the `paper` function.
Here's an example:

```typst
= Education

#experience(
  place: [Bachelor of Arts in English, Typst University],
  time: [2023--26],
)[
Undergraduate thesis #quote[A literary theory of typesetting].
Advised by:
- Laurenz Typistotle (English)
]

= Professional experience 
#experience(
  place: [#link("https://typst.app/")[Typst]],
  title: "Intern",
  time: [2026],
  location: "Online"
)[
    Built out a killer template for a CV in the humanities.
]


= Peer-reviewed Publications
#paper(
  venue: [#link("https://typst.app/blog/")[The Typst blog]],
  title: [Why literary theory matters in Typst], 
  date: [2025] 
)

#paper(
  venue: [#link("https://www.euppublishing.com/loi/jobs")[Journal of Beckett Studies] [submitted]],
  title: [Typesetting systems in Beckett],
  date: [2026]
)
```

Refer to [the template](./template/main.typ) for a complete example.


## Configuration

This template exports the `humanities-cv` function with the following named arguments:

| Argument | Type | Description |
| --- | --- | --- |
| `name` | `string` | A string to specify the author's name.  |
| `address` | `string` | A string to specify the author's address. |
| `contacts` | `array` | An array of content to specify your contact information. E.g., phone number, email, LinkedIn, etc. |
| `updated` | `string` | A string to specify when the document was last updated. |
| `profile-picture` | `content` | The result of a call to the [image function] or `none`. For best result, make sure that your image has an 1:1 aspect ratio. |
| `paper-size` | `string` | Specify a [paper size string] to change the page size (default is `a4`). |
| `footer-text` | `content` | Content that will be prepended to the page numbering in the footer. |
| `page-numbering-format` | `string` | [Pattern](https://typst.app/docs/reference/model/numbering/#parameters-numbering) that will be used for displaying page numbering in the footer (default is `1 of 1`). |

