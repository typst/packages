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
#import "@preview/fontawesome:0.5.0": *
#import "@preview/modernpro-coverletter:0.0.6": *

#show: coverletter.with(
  font-type: "PT Serif",
  name: [example],
  address: [],
  contacts: (
    (text: [#fa-icon("location-dot") UK]),
    (text: [123-456-789], link: "tel:123-456-789"),
    (text: [example.com], link: "https://www.example.com"),
    (text: [github], link: "https://github.com/"),
    (text: [example\@example.com], link: "mailto:example@example.com"),
  ),
  recipient: (
    start-title: [],
    cl-title: [],
    date: [],
    department: [],
    institution: [],
    address: [],
    postcode: [],
  ),
)

#set par(justify: true, first-line-indent: 2em)
#set text(weight: "regular", size: 12pt)
```

| Parameter | Description |
| --- | --- |
| `font-type` | The font type of the cover letter, e.g. "PT Serif" |
| `name` | The name of the sender |
| `address` | The address of the sender |
| `contacts` | The contact information of the sender(text:[], link: []) |

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
#import "@preview/fontawesome:0.5.0": *
#import "@preview/modernpro-coverletter:0.0.6": *

#show: statement.with(
  font-type: "PT Serif",
  name: [],
  address: [],
  contacts: (
    (text: [#fa-icon("location-dot")]),
    (text: [#fa-icon("mobile") 123-456-789], link: "tel:123-456-789"),
    (text: [#fa-icon("link") example.com], link: "https://www.example.com"),
    (text: [#fa-icon("github") github], link: "https://github.com/"),
    (text: [#fa-icon("envelope") example\@example.com], link: "mailto:example@example.com"),
  ),
)

#v(1em)
#align(center, text(13pt, weight: "semibold")[#underline([Title])])
#set par(first-line-indent: 2em, justify: true)
#set text(11pt, weight: "regular")

// Main body of the statement
```

| Parameter | Description |
| --- | --- |
| `font-type` | The font type of the cover letter, e.g. "PT Serif" |
| `name` | The name of the sender |
| `address` | The address of the sender |
| `contacts` | The contact information of the sender(text:[], link: []) |

### Icons

The new version also integrates the FontAwesome icons. You can use the `#fa-icon("icon")` function to insert the icons in the cover letter or statement template as shown above.

You just need to import the FontAwesome package at the beginning of the document.

```typst
#import "@preview/fontawesome:0.5.0": *
```

## Preview

### Cover Letter

![Cover Letter Preview](https://minioapi.pjx.ac.cn/img1/2024/08/79decf8975b899d31b9dc76c5466a01a.png)

### Statement

![Statement Preview](https://minioapi.pjx.ac.cn/img1/2024/08/0483a06862932e1e9a9f1589676ce862.png)
