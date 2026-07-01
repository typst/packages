#import "@preview/simple-unimi-thesis:0.1.0": *

#show: project

#show: frontmatter

// dedication

// acknowledgements

#show: acknowledgements

= Acknowledgements

#lorem(100)

#toc // table of contents

#show: mainmatter

// main section of the thesis

= First chapter

#lorem(100)

= Second chapter

#lorem(100)

// appendix

#show: appendix

= First appendix

#lorem(100)

#show: backmatter

// bibliography

// associated laboratory

// if the laboratory you want to cite is missing:
#let missinglab = yaml("myoverride.yml")
#closingpage("mylab", laboratories: missinglab)
