# Configuration reference

Import `fydp-report` from `lib.typ` locally or from the published package after
acceptance. Apply it as a show rule with `#show: fydp-report.with(..project)`.

| Parameter | Default | Meaning |
| --- | --- | --- |
| `title` | Example title | Title content, e.g. `[My Project]` |
| `students` | One example student | Nonempty array of `(name: "…", id: "…")` dictionaries |
| `date` | `[Month Year]` | Explicit submission date as content |
| `university` | United International University | Cover institution |
| `department` | Department of Computer Science and Engineering | Cover department |
| `degree` | Bachelor of Science in Computer Science and Engineering | Degree wording |
| `supervisors` | `()` | Array of content values, e.g. `([Name, Designation],)` |
| `logo` | `none` | Image/content placed above department wording |
| `abstract` | `none` | Abstract content; `none` omits the page |
| `acknowledgements` | `none` | Acknowledgements content; `none` omits the page |
| `publications` | `none` | Publication-list content; `none` omits the page |
| `show-figure-list` | `true` | Include List of Figures |
| `show-table-list` | `true` | Include List of Tables |
| `outline-depth` | `3` | Contents depth: chapters, sections, subsections |
| `font` | `"New Computer Modern"` | Body font family |
| `font-size` | `11pt` | Body size |
| `margin` | `3cm` | A Typst page-margin value |
| `body` | Required | Document content supplied by the show rule |

`template/project.typ` enables abstract and acknowledgements using `include`.
It is the default configuration for student reports, while the function defaults
allow a minimal report with only a cover, contents, optional lists, and chapters.

Remove an existing dictionary key before replacing it; do not specify a named
argument twice. The root entry point supplies `logo` from an optional CLI input;
use `python3 scripts/project.py build --logo local-assets/uiu.png` rather than
adding a second `logo` key to `project`.

## Numbering and structure

- The cover is unnumbered. Preliminary pages begin at Roman `i`.
- The body restarts at Arabic `1`.
- Level-one headings are chapters and begin on new pages.
- Headings use `1`, `1.1`, `1.1.1`; equation numbers use `(1)`.
- The bibliography is an unnumbered heading listed in the contents.
- Tables use top captions; other figures use the default bottom captions.
- Running headers appear on chapter continuation pages.

`guidance(body)` is also exported for optional instructional callouts. Import it
in a file that calls it, then write `#guidance[Replace this with your own work.]`.
Remove such guidance before submission.

## Stage and bibliography

Report stage is a student-content setting in `template/content.typ`, independent
of the layout API. Its default is `final`; the `stage` CLI input can select
`fydp-1`. You can adjust the chapter selection to your course's requirements.

The bibliography call also lives in `content.typ`, so paths resolve in the
student project rather than inside the package. To change citation style, edit
the `style: "ieee"` argument there using a Typst-supported bibliography style.
Changing it changes the output from the supplied LaTeX's `unsrt` bibliography.
