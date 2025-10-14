# Typst-CV-Resume

This Typst CV template is inspired by the Latex template [Deedy-Resume](https://github.com/deedy/Deedy-Resume). You can use it for both industry and academia.

If you want to find a cover letter template, you can check out [modernpro-coverletter](https://github.com/jxpeng98/typst-coverletter).

## How to start

### Use Typst CLI

If you use Typst CLI, you can use the following command to create a new project:

```bash
typst init @preview/modernpro-cv
```

>If you use the typst version `<0.13.0`, you need to use the following code to initial your project.
> `typst init @preview/modernpro-cv:1.0.2`

It will create a folder named `modernpro-cv` with the following structure:

```plain
modernpro-cv
├── bib.bib
├── cv_double.typ
└── cv_single.typ
```

If you want to use the single-column version, you can modify the template `cv-single.typ`. If you prefer the two-column version, you can use the `cv-double.typ`.

**Note:** The `bib.bib` is the bibliography file. You can modify it to add your publications.

### Manual Download

If you want to manually download the template, you can download `modernpro-cv-{version}.zip` from the [release page](https://github.com/jxpeng98/Typst-CV-Resume/releases)

### Typst website

If you want to use the template via [Typst](https://typst.app), You can `start from template` and search for `modernpro-cv`.

## How to use the template

### The arguments

The template has the following arguments:
| Argument | Description | Default |
| --- | --- | --- |
| `font-type` | The font type. You can choose any supported font in your system. | `Times New Roman` |
| `continue-header` | Whether to continue the header on the follwing pages. | `false` |
| `margin` | Override the page margin. When omitted, the template falls back to the built-in layout (1.25 cm sides with layout-specific top/bottom). | `none` |
| `name` | Your name. | `""` |
| `address` | Your address. | `""` |
| `lastupdated` | Whether to show the last updated date. | `true` |
| `pagecount` | Whether to show the page count. | `true` |
| `date` | The date of the CV. | `today` |
| `contacts` | contact details, e.g phone number, email, etc. | `(text: "", link: "")` |

### Start single column version

If you want to use the single column version, you create a new `.typ` file and copy the following code:

```Typst
#import "@preview/modernpro-cv:1.2.0": *
#import "@preview/fontawesome:0.5.0": *

#show: cv-single.with(
  font-type: "PT Serif",
  continue-header: "false",
  margin: (left: 1.75cm, right: 1.75cm, top: 2cm, bottom: 2cm),
  name: [],
  address: [],
  lastupdated: "true",
  pagecount: "true",
  date: "2024-07-03",
  contacts: (
    (text: [#fa-icon("location-dot") UK]),
    (text: [#fa-icon("mobile") 123-456-789], link: "tel:123-456-789"),
    (text: [#fa-icon("link") example.com], link: "https://www.example.com"),
  )
)
```

### Start double column version

The double column version is similar to the single column version. However, you need to add contents to the specific `left` and `right` sections.

```Typst
#import "@preview/modernpro-cv:1.2.0": *
#import "@preview/fontawesome:0.5.0": *

#show: cv-double(
  font-type: "PT Sans",
  continue-header: "true",
  margin: (left: 1.5cm, right: 1.5cm, top: 2.2cm, bottom: 1.8cm),
  name: [#lorem(2)],
  address: [#lorem(4)],
  lastupdated: "true",
  pagecount: "true",
  date: "2024-07-03",
  contacts: (
    (text: [#fa-icon("location-dot") UK]),
    (text: [#fa-icon("mobile") 123-456-789], link: "tel:123-456-789"),
    (text: [#fa-icon("link") example.com], link: "https://www.example.com"),
  ),
  left: [
    // contents for the left column
  ],
  right:[
    // contents for the right column
  ]
)
```

### Start the CV

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
|`#references(references:())`| Add a reference list. In the `()`, you can add multi reference entries with the following format `(name: "", position: "", department: "", institution: "", address: "", email: "",),`|
|`#show bibliography: none #bibliography("bib.bib")`| Add a bibliography. You can modify the `bib.bib` file to add your publications. **Note:** Keep this at the end of your CV|

**Note:** Use `+ @ref` to display your publications. For example,

```Typst
#section("Publications")

// numbering list 
+ @quenouille1949approximate
+ @quenouille1949approximate

// Keep this at the end
#show bibliography: none
#bibliography("bib.bib")
```

## Preview

### Single Column

![Single-Column-Preview](https://img.pengjiaxin.com/2024/07/a81ac7ec96be0625eefccb81ead160d3.png)

### Double Column

![Double-Column-Preview](https://img.pengjiaxin.com/2024/07/12e9b31e306055f615edf49f9b8ffe55.png)

## Legacy Version

I redesigned the template and submitted the new version to Typst Universe. However, you can find the legacy version in the `legacy` folder if you prefer to use the multi-font setting. You can also download the `modernpro-cv-legacy.zip` from the [release page](https://github.com/jxpeng98/Typst-CV-Resume/releases).

**Note:** The legacy version also has a cover letter template. You can use it with the CV template.

## Cover Letter

If you used the previous version of this template, you might know that I also provided a cover letter template.

If you want to use a consistent cover letter with the new version of the CV template, you can find it from another repository [typst-coverletter](https://github.com/jxpeng98/typst-coverletter).

you can also use the following code in the command line:

```bash
typst init modernpro-coverletter
```

## License

The template is released under the MIT License. For more information, please refer to the [LICENSE](https://github.com/jxpeng98/Typst-CV-Resume/blob/main/LICENSE) file.
