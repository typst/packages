# thesis-template-typst
This repository provides a unofficial Typst template for writing your Bachelor's or Master's thesis at the HSG (University of St. Gallen). It includes a thesis template. For more information about writing a thesis at the HSG, please visit the [HSG Student Web (Login required)](https://universitaetstgallen.sharepoint.com/sites/PruefungenDE/SitePages/en/Master-Arbeiten.aspx?web=1).

**Note:** This is only a template. You have to adapt the template to your thesis and discuss the structure of your thesis with your supervisor!

--- 
## Guidelines 

Please thorougly read the guidelines and hints on [website](https://www.unisg.ch/fileadmin/user_upload/HSG_ROOT/_Kernauftritt_HSG/Universitaet/Schools/SOM/Faculty/Chair_of_Organization_Studies/Guideline_HSG.pdf)

---
## Usage
You can use this template in the Typst web app by clicking "Start from template" on the dashboard and searching for `gallus-hsg`.

Locally, you can use the following command to start with this templates:

```
typst init @preview/gallus-hsg:1.0.0
```

### Set thesis metadata 
Fill in your thesis details in the [`metadata.typ`](/metadata.typ) file: 
* The language of the document (en or de)
* Title
* Subtitle
* Type of thesis (Bachelor's, Master's, etc.)
* Professor
* Your name (without e-mail address or matriculation number)
* Matriculation number
* The submission date

### Write your thesis
For the actual content of your thesis, there is a dedicated folder named [`/content`](/content) which includes all the chapters and sections of your thesis.
You can add or remove chapters as needed (adapt the [`thesis.typ`](/thesis.typ) with the `#include(...)` accordingly).
If you need to customize the layout of the template, you can do so by modifying the corresponding file in the [`layout`](/layout) directory.

---
## Further Resources

- [Typst Documentation](https://typst.app/docs/)
- [Typst Guide for LaTeX Users](https://typst.app/docs/guides/guide-for-latex-users/)
