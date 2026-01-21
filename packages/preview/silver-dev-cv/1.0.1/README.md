# Typst-CV-Resume

This Typst CV template is a streamlined version of the the Latex template [Modernpro](https://github.com/jxpeng98/Typst-CV-Resume).

## How to start

### Use Typst CLI

If you use Typst CLI, you can use the following command to create a new project:

```bash
typst init silver-dev-cv
```

It will create a folder named `silver-dev-cv` with the following structure:

```plain
silver-dev-cv
└── cv.typ
```

### Typst website

If you want to use the template via [Typst](https://typst.app), You can `start from template` and search for `silver-dev-cv`.

## How to use the template

### The arguments

The template has the following arguments:
| Argument | Description | Default |
| --- | --- | --- |
| `font-type` | The font type. You can choose any supported font in your system. | `Times New Roman` |
| `continue-header` | Whether to continue the header on the follwing pages. | `false` |
| `name` | Your name. | `""` |
| `address` | Your address. | `""` |
| `lastupdated` | Whether to show the last updated date. | `true` |
| `pagecount` | Whether to show the page count. | `true` |
| `date` | The date of the CV. | `today` |
| `contacts` | contact details, e.g phone number, email, etc. | `(text: "", link: "")` |

### Starting the CV

```Typst
#import "@preview/silver-dev-cv:1.0.0": *

#show: cv.with(
  font-type: "PT Serif",
  continue-header: "false",
  name: "",
  address: "",
  lastupdated: "true",
  pagecount: "true",
  date: "2024-07-03",
  contacts: (
    (text: "08856", link: ""),
    (text: "example.com", link: "https://www.example.com"),
    (text: "github.com", link: "https://www.github.com"),
    (text: "123@example.com", link: "mailto:123@example.com"),
  )
)
```


### Content

Once you set up the arguments, you can start to add details to your CV / Resume.

I preset the following functions for you to create different parts:
| Function | Description |
| --- | --- |
| `#section("Section Name")` | Start a new section |
| `#sectionsep` | End the section |
|`#oneline-title-item(title: "", content: "")`| Add a one-line item (**Title:** content)|
|`#oneline-two(entry1: "", entry2: "")`| Add a one-line item with two entries, aligned left and right|
|`#descript("descriptions")`| Add a description for self-introduction|
|`#award(award: "", date: "", institution: "")`| Add an award (**award**, *institution*   *date*)|
|`#education(institution: "", major: "", date: "", institution: "", core-modules: "")`| Add an education experience|
|`#job(position: "", institution: "", location: "", date: "", description: [])`| Add a job experience (description is optional)|
|`#twoline-item(entry1: "", entry2: "", entry3: "", entry4: "")`| Two line items, similar to education and job experiences|

## License

The template is released under the MIT License. For more information, please refer to the [LICENSE](https://github.com/jxpeng98/Typst-CV-Resume/blob/main/LICENSE) file.
