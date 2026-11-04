# Introduction

This is a very minimal, modern style built for documents produced by the [TactileLibrary® Research Center](https://tactilelibrary.net) of the [West University of Timișoara](https://uvt.ro). It only handles basic functionality such as the title page, header, footer, and fonts.

# Usage

To use the template, simply add the following text to the beginning of your document:

```typ
#import "@preview/tl-modern-report:0.1.0": rep

#show: rep.with(
  title: "Your title",
  subtitle: "Your subtitle",
  author: "Your name",
  logo: "path/to/your/logo",
)
```

The full list of supported arguments is shown in the following table:

| Argument          | Description                                                                        | Default          |
|-------------------|------------------------------------------------------------------------------------|------------------|
| title             | Title of your document, used for the cover page, header, and document properties.  | "TITLE"          |
| subtitle          | Subtitle of your document, used for the cover page and header.                     | "SUBTITLE"       |
| author            | Author name, used for the cover page and document properties. Cannot be an array.  | "Author"         |
| position          | Author's role within the company, used for the cover page. Optional.               | ""               |
| date              | Datetime object, used for the cover page and document properties.                  | datetime.today() |
| language          | An ISO 639-1/2/3 language code, also applied to the date format on the cover page. | "en"             |
| logo              | Path to your logo file, used for the cover page and header.                        | "logoipsum.svg"    |
| page-numbering    | Numbering rule for the pages.                                                      | "1/1"            |
| section-numbering | Numbering rule for the sections.                                                   | "1."             |