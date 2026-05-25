# University of Bath Risk Assessment Template

A highly customizable, locally deployed Typst template designed for University of Bath risk assessments.

## Initialising the Template

To use this template simply run the following commands.
```sh
typst init '@preview/bath-risk-assessment:0.1.0' name-of-your-project
cd name-of-your-project
typst watch main.typ
```

## Filling out Risk Assessment Details

Fill out all associated hazards and controls with appropriate scores and likelihoods.

### Git Recommendation

In order to reduce repository bloat enable git LFS to track the image files used in figures.
```sh
git lfs install
git lfs track "*.png" "*.jpg" "*.jpeg" "*.svg"
git add .gitattributes
git commit -m "Configure Git LFS to track image files"
```

## University of Bath Branding

University of Bath branding terms are distributed as is and are not modified in any way. Please refer to the [University of Bath Brand Guidelines](https://www.bath.ac.uk/guides/who-should-use-the-university-brand/) and [Using the University Logo](https://www.bath.ac.uk/guides/using-the-university-of-bath-logo/) for more information on how to use these terms correctly in your documentation.