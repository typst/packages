# Toulouse INP template
This template is destined for the students of the schools of the Toulouse INP group.

## Examples
A list of examples is available [here](https://github.com/Killian-fal/tlseinp-typst-template/tree/main/examples).

## Documentation <a id="documentation-section"></a>

| Parameter       | Description                                                                                                       | Example                                                                         |
|-----------------|-------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| title           | report title displayed on first page                                                                              | any string                                                                      |
| subtitle        | report subtitle displayed on first page                                                                           | any string                                                                      |
| page-header     | Text displayed at top left of all report pages (e.g. [example 1](examples/example1/))                             | any string                                                                      |
| author          | Text displayed at the top right of all report pages and on the first page (e.g.  [example 1](examples/example1/)) | any string                                                                      |
| group           | Text displayed above the author on the first page                                                                 | any string                                                                      |
| year            | Text displayed below author on first page                                                                         | any string                                                                      |
| class           | Text displayed below author on first page                                                                         | any string                                                                      |
| formation-image | Image displayed at top right of first page (e.g.  [example 2](examples/example2/))                                | formation.[N7, A7, ENSAT, PREP-TRANSI, FC, LA_PREPA, INP] or custom typst image |
| project-image   | Image displayed at top left of first page (e.g.  [example 2](examples/example2/))                                 | formation.[N7, A7, ENSAT, PREP-TRANSI, FC, LA_PREPA, INP] or custom typst image |
| lang            | Report language                                                                                                   | fr, en, etc.. (see typst documentation)                                         |

### Additional functionality
The termplate can display a table of 
- of all images/lists:
```typst
#figures(kind: none, headingName: "Table of all :)")
```

- all images without list:
```typst
#figures()
```

- all lists without image:
```typst
#figures(kind: list, headingName: "Table of listings")
```

The template also automatically manages a list of deliverables:
```typst
#deliverables(
  (
    "tests.pdf": "file showing our tests",
    "wow.pdf": "Wow !",
  )
)

// or with custom heading name
#deliverables(headingName: "Custom Deliverables",
  (
    "tests.pdf": "file showing our tests",
    "wow.pdf": "Wow !",
  )
)
```

The template also automatically manages appendices in another typst file:
```typst
= Appendices <appendix>
#appendices(title: "Table of appendices", show-outline: true, include "annexe.typ")
```

- `title` is the title of the section displaying the appendices table
- `show-outline` (default: **true**) enables this table to be displayed or not

**IMPORTANT:** For the code to be successful, the following code must be added just after `#show: tlseinp.with(...)`.
```typst
#context {
  outline(target: selector(heading).before(locate(<appendix>)), indent: auto)
}
```

## Contributions
All contributions are welcome [here](https://github.com/Killian-fal/tlseinp-typst-template)! :)

## License
This template is released under the [Apache 2.0 license.](https://www.apache.org/licenses/LICENSE-2.0.html)
