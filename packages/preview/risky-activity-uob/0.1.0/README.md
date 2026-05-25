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