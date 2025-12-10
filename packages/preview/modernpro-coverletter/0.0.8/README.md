# Typst-ModernPro-Coverletter

This is a cover letter template for Typst with Sans font. It is a modern and professional cover letter template. It is easy to use and customize. This cover letter template is suitable for any job application or general purpose.

If you want to find a CV template, you can check out [modernpro-cv](https://github.com/jxpeng98/Typst-CV-Resume/blob/main/README.md).

## How to use

### Use from the Typst Universe

It is simple and easy to use this template from the Typst Universe. If you prefer to use the local editor and `typst-cli`, you can use the following command to create a new cover letter project with this template.

```bash
typst init @preview/modernpro-coverletter
```

It will create a new cover letter project with this template in the current directory.

### Use from GitHub

You can also use this template from GitHub. You can clone this repository and use it as a normal project.

```bash
git clone https://github.com/jxpeng98/typst-coverletter.git
```

## Features

This package provides one **cover letter** template and one **statement** template.

### Cover Letter

```typst
#import "@preview/fontawesome:0.6.0": *
#import "@preview/modernpro-coverletter:0.0.7": *

#show: coverletter.with(
  font-type: "PT Serif",
  margin: (left: 2cm, right: 2cm, top: 3cm, bottom: 2cm),
  name: [example],
  address: [],
  salutation: [Best regards,],
  supplements: ([Enclosure: Resume], [Portfolio: example.com]),
  contacts: (
    (text: [#fa-icon("location-dot") UK]),
    (text: [123-456-789], link: "tel:123-456-789"),
    (text: [example.com], link: "https://www.example.com"),
    (text: [github], link: "https://github.com/"),
    (text: [example\@example.com], link: "mailto:example@example.com"),
  ),
  recipient: (
    start-title: [Dear Hiring Manager,],
    cl-title: [Job Application for Software Engineer],
    date: [],
    department: [Department of Engineering],
    institution: [Example Company],
    address: [London, UK],
    postcode: [W1 S2],
  ),
  // Customisation options (uncomment to use)
  // primary-colour: rgb("#000000"),
  // closing-spacing: 1em,
  // signature-spacing: 0.5em,  // increase to 2em+ for printed version
  // supplement-spacing: 1em,
)

// Main body of the cover letter
```

| Parameter | Description | Default |
| --- | --- | --- |
| `font-type` | The font type of the cover letter, e.g. "PT Serif" | `none` |
| `margin` | Optional page margins as a single value or directional tuple | `(left: 1.25cm, right: 1.25cm, top: 3cm, bottom: 1.5cm)` |
| `name` | The name of the sender | `none` |
| `address` | The address of the sender | `none` |
| `contacts` | The contact information of the sender(text:[], link: []) | `()` |
| `salutation` | Closing greeting text; set to `none` to hide | `"Sincerely,"` |
| `supplements` | One or more lines after the name (e.g., enclosure notes); accepts a string/content value or an array | `none` |
| **Colour Options** | | |
| `primary-colour` | Primary text colour | `rgb("#000000")` |
| `headings-colour` | Headings text colour | `rgb("#2b2b2b")` |
| `subheadings-colour` | Subheadings text colour | `rgb("#333333")` |
| `date-colour` | Date text colour | `rgb("#666666")` |
| `link-colour` | Link text colour; `none` inherits from text | `none` |
| **Font Size Options** | | |
| `name-size` | Font size for the name in header | `20pt` |
| `body-size` | Font size for the main body text | `11pt` |
| `address-size` | Font size for the address | `11pt` |
| `contact-size` | Font size for contact information | `10pt` |
| `recipient-size` | Font size for recipient information | `10pt` |
| `cl-title-size` | Font size for the cover letter title | `12pt` |
| `supplement-size` | Font size for supplement/enclosure text | `10pt` |
| **Layout Options** | | |
| `line-stroke` | Stroke width for the header separator line | `0.2pt` |
| `header-ascent` | Header ascent distance | `1em` |
| `first-line-indent` | First line indent for paragraphs | `2em` |
| `line-spacing` | Line spacing within paragraphs | `0.65em` |
| `paragraph-spacing` | Spacing between paragraphs | `0.8em` |
| `contact-separator` | Separator between contact items | `" \| "` |
| **Header Alignment** | | |
| `name-align` | Alignment for name in header | `center` |
| `address-align` | Alignment for address in header | `center` |
| `contact-align` | Alignment for contacts in header | `center` |
| **Font Weight Options** | | |
| `name-weight` | Font weight for name in header | `"bold"` |
| `body-weight` | Font weight for body text | `"regular"` |
| `salutation-weight` | Font weight for salutation | `"regular"` |
| `signature-weight` | Font weight for signature name | `"bold"` |
| **Signature Block Spacing** | | |
| `closing-spacing` | Vertical space before the salutation | `0.8em` |
| `signature-spacing` | Vertical space between salutation and name (increase to `2em`+ for printed/signed version) | `0.3em` |
| `supplement-spacing` | Vertical space between name and supplements | `0.8em` |
| **Date Format** | | |
| `date-format` | Format string for auto-generated date | `"[day] [month repr:long] [year]"` |

| Parameter in Recipient | Description |
| --- | --- |
| `start-title` | The start title of the letter |
| `cl-title` | The title of the letter (i.g., Job Application for Hiring Manager) |
| `date` | The date of the letter(If "" or [], it will generate the current date) |
| `department` | The department of the recipient, can be "" or [] |
| `institution` | The institution of the recipient |
| `address` | The address of the recipient |
| `postcode` | The postcode of the recipient |

### Statement

```typst
#import "@preview/fontawesome:0.6.0": *
#import "@preview/modernpro-coverletter:0.0.7": *

#show: statement.with(
  font-type: "PT Serif",
  margin: (left: 2cm, right: 2cm, top: 3cm, bottom: 2cm),
  name: [Your Name],
  address: [Your Address],
  contacts: (
    (text: [#fa-icon("location-dot") UK]),
    (text: [#fa-icon("mobile") 123-456-789], link: "tel:123-456-789"),
    (text: [#fa-icon("link") example.com], link: "https://www.example.com"),
    (text: [#fa-icon("github") github], link: "https://github.com/"),
    (text: [#fa-icon("envelope") example\@example.com], link: "mailto:example@example.com"),
  ),
  // Customisation options (uncomment to use)
  // primary-colour: rgb("#000000"),
  // name-size: 20pt,
  // body-size: 11pt,
)

#v(1em)
#align(center, text(13pt, weight: "semibold")[#underline([Statement Title])])

// Main body of the statement
```

| Parameter | Description | Default |
| --- | --- | --- |
| `font-type` | The font type of the statement, e.g. "PT Serif" | `none` |
| `margin` | Optional page margins as a single value or directional tuple | `(left: 1.25cm, right: 1.25cm, top: 3cm, bottom: 1.5cm)` |
| `name` | The name of the sender | `none` |
| `address` | The address of the sender | `none` |
| `contacts` | The contact information of the sender(text:[], link: []) | `()` |
| `supplement` | Additional content at the end of the statement | `none` |
| **Colour Options** | | |
| `primary-colour` | Primary text colour | `rgb("#000000")` |
| `headings-colour` | Headings text colour | `rgb("#2b2b2b")` |
| `subheadings-colour` | Subheadings text colour | `rgb("#333333")` |
| `date-colour` | Date text colour | `rgb("#666666")` |
| `link-colour` | Link text colour; `none` inherits from text | `none` |
| **Font Size Options** | | |
| `name-size` | Font size for the name in header | `20pt` |
| `body-size` | Font size for the main body text | `11pt` |
| `address-size` | Font size for the address | `11pt` |
| `contact-size` | Font size for contact information | `10pt` |
| **Layout Options** | | |
| `line-stroke` | Stroke width for the header separator line | `0.2pt` |
| `header-ascent` | Header ascent distance | `1em` |
| `first-line-indent` | First line indent for paragraphs | `2em` |
| `line-spacing` | Line spacing within paragraphs | `0.65em` |
| `paragraph-spacing` | Spacing between paragraphs | `0.8em` |
| `contact-separator` | Separator between contact items | `" \| "` |
| **Header Alignment** | | |
| `name-align` | Alignment for name in header | `center` |
| `address-align` | Alignment for address in header | `center` |
| `contact-align` | Alignment for contacts in header | `center` |
| **Font Weight Options** | | |
| `name-weight` | Font weight for name in header | `"bold"` |
| `body-weight` | Font weight for body text | `"regular"` |

### Icons

The new version also integrates the FontAwesome icons. You can use the `#fa-icon("icon")` function to insert the icons in the cover letter or statement template as shown above.

You just need to import the FontAwesome package at the beginning of the document.

```typst
#import "@preview/fontawesome:0.6.0": *
```

## Preview

### Cover Letter

![Cover Letter Preview](https://img.pengjiaxin.com/2024/08/79decf8975b899d31b9dc76c5466a01a.png)

### Statement

![Statement Preview](https://img.pengjiaxin.com/2024/08/0483a06862932e1e9a9f1589676ce862.png)
