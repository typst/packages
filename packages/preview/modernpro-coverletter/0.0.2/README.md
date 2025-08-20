# Typst-ModernPro-Coverletter

This is a cover letter template for Typst with Sans font. It is a modern and professional cover letter template. It is easy to use and customize. This cover letter template is suitable for any job application or general purpose.

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

The template will have the following features:

```typst
#show: main.with(
  font-type: "openfont",
  name: [#lorem(2)],
  address: [#lorem(4)],
  contacts: (
    (text: "08856", link: ""),
    (text: "example.com", link: "https://www.example.com"),
    (text: "github.com", link: "https://www.github.com"),
    (text: "123@example.com", link: "mailto:123@example.com"),
  ),
  recipient: (
    start-title: [Dear],
    cl-title: [Job Application for Hiring Manager],
    date: [],
    department: [#lorem(2)],
    institution: [#lorem(2)],
    address: [#lorem(4)],
    postcode: [#lorem(1)],
  ),
)

#lorem(300)
```

- `font-type`: The font type of the cover letter. It can be "macfont" or "openfont".
- recipient: The recipient information of the cover letter.
  - `start-title`: The start title of the letter.
  - `cl-title`: The title of the letter (i.g., Job Application for Hiring Manager).
  - date: The date of the letter(If "" or [], it will generate the current date).
  - department: The department of the recipient, can be "" or [].
  - institution: The institution of the recipient.
  - address: The address of the recipient.
  - postcode: The postcode of the recipient.

## Preview

![Cover Letter Preview](https://minioapi.pjx.ac.cn/img1/2024/07/522ef6ebbddcdb3f20e1a80b4ca25d48.png)
