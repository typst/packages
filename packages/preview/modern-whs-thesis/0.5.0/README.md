# WHS Thesis Template

![Title page](thumbnail.png)

This **unofficial** template can be used to write in [Typst](https://github.com/typst/typst) with the corporate design of the [Westfälische Hochschule](https://www.w-hs.de/).

#### Disclaimer

Please ask your supervisor if you are allowed to use typst and this template for your thesis or other documents.
Note that this template is not checked by the Westfälische Hochschule for correctness.
Thus, this template does not guarantee completeness or correctness.

## Usage

Create a new typst project based on this template locally.
```bash
typst init @preview/modern-whs-thesis
cd modern-whs-thesis
```

Or create a project on the typst web app based on this template.

## Configuration

The package can be configured where it is initialized. The configuration is done in the `meta.typ` file.

```typst
#show: whs-thesis.with(
   meta.title,
   meta.title-size,
   meta.author,
   meta.first-name,
   meta.last-name,
   meta.date,
   meta.keywords,
   [#abstract],
   meta.bibliography,
   acronyms.acronyms,
   meta.degree,
   meta.place,
   meta.thesis-type,
   meta.study-course,
   meta.department,
   meta.first-examiner,
   meta.second-examiner,
   meta.date-of-submission,
)
```

## Customizing this template

If the predefined design of this template doesnt fit your needs, you can customize it by following these steps:

1. Download the repository of this template
2. Copy the template folder `/templates/thesis/template` into your project.
3. Replace the import of `@preview/modern-whs-thesis` with `template/lib.typ`
