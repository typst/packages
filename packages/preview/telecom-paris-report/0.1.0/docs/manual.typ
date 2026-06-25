#import "../src/lib.typ": telecom-paris-report

#show: telecom-paris-report.with(
  title: "Télécom Paris Report Template",
  subtitle: "Official Package Documentation",
  short-title: "Template Manual",
  authors: (
    (name: "Arsène Mallet", mail: "arsene.mallet@telecom-paris.fr"),
  ),
  abstract: [
    This document serves as the official manual for the unofficial Télécom Paris
    report template. It details all available parameters, their expected types,
    and how they affect the layout of the final document.
  ],
  keywords: ("Documentation", "API", "Manual", "Typst"),
  date: "June 25, 2026",
  sidebar-text: "Documentation",
  show-mail: true,
  lang: "en",
)

= Introduction
The `telecom-paris-report` template is fairly customizable. Its purpose is to
provide a boilerplate layout following the school's style guidelines. You
configure the document by passing a dictionary of arguments to the main template
function via the `#show` rule.

= Configuration API

== Text and Content Parameters
- `title` (`str` | `content`): Main title of the document. Appears large and
  bold on the cover page.
- `subtitle` (`str` | `content`): Subtitle of the document. Appears in grey
  directly below the main title on the cover.
- `short-title` (`str` | `content`): A condensed title used exclusively in the
  page headers. If omitted, the template falls back to the main `title`.
- `abstract` (`content`): The summary of your report. Generates an "Abstract"
  (or "Résumé") block on the cover page.
- `keywords` (`array`): A list of string keywords. Displayed below the abstract
  on the cover page.
- `date` (`str` | `content`): The date of publication or submission. Displayed
  at the bottom center of the cover page.
- `sidebar-text` (`str`): Custom text to display vertically within the red
  sidebar on the left of the cover page.

== People Parameters
- `authors` (`array`): List of document authors. Can be an array of strings or
  an array of dictionaries in the format `(name: "...", mail: "...")`.
- `supervisors` (`array`): List of project supervisors. Uses the same format as
  `authors` and generates a dedicated "Under the supervision of" section on the
  cover.

== Styling and Toggles
- `lang` (`str`): Sets the localization for automated text (like "Abstract" vs
  "Résumé"). Accepts exactly `"en"` or `"fr"`. Defaults to `"en"`.
- `font` (`str` | `array`): The font family used throughout the document.
  Defaults to `"Arial"`.
- `logo` (`bool`): Toggles the display of the official Télécom Paris / IP Paris
  logos on the cover and in the headers. Defaults to `true`.
- `show-mail` (`bool`): Determines whether the email addresses provided in the
  `authors` and `supervisors` arrays are displayed beneath their names. Defaults
  to `false`.
- `show-colored-bar` (`bool`): Toggles the grey-black-red indicator bar at the
  absolute bottom of every content page. Defaults to `true`.

= Authoring
Once the `#show` rule is configured, you can write standard Typst markup.
Headings (e.g., `= Section`) will automatically receive the custom visual
treatment consisting of the red, black, and grey vertical indicators.
