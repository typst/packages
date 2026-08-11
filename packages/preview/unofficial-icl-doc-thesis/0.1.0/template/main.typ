#import "@preview/unofficial-icl-doc-thesis:0.1.0": project, back-matter
#import "@preview/unofficial-icl-doc-thesis:0.1.0": *

#show: project.with(
  title: "Your Project Title",
  author: "Your Name",
  supervisor: "Supervisor Name",
  report-type: "MEng Individual Project",
  degree: "Master of Engineering (MEng)",
  abstract: [
    Write your abstract here.
  ],
  // logo: "figures/your-logo.svg",  // replace with your institution logo
)

= Introduction

Your introduction here.

= Background

= Contribution

= Experimental Results

= Conclusion

#back-matter()
#bibliography("references.bib", style: "elsevier-vancouver")
